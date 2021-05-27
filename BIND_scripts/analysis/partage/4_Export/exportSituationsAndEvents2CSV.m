% function exportSituationsAndEvents2CSV( theTrip, csvFile, DataVariableNameForEnrichment, cellArrayOfMarkersToExport)
% theTrip (sqlitetrip) Handle to the trip
% csvFile (String) Name of the output csv file
% delimiter (String) The character that separates the columns in the CSV
% file (',', ';', '\t' for example)
% DataVariableNameForEnrichment mandatory A Nx2 cellArray of string formed according to the
% principle { DataName.variableName, exportName }
% cellArrayOfMarkersToExport mandatory A Nx3 cellArray formed according to
% the principle { markerType, MarkerName, ModalityName }
%   - MarkerType (String) must be 'event' or 'situation'
%   - MarkerName (String) Must be an existing marker
%   - ModalityName (String) is optional (use '' if not needed) and must
%   correspond to a variable of the marker. Export will concatene
%   the MarkerName with modalityName to build new different types of marker for ABSTRACT from the same table in BIND.
function exportSituationsAndEvents2CSV( theTrip, csvFile, delimiter, DataVariableNameForEnrichment, cellArrayOfMarkersToExport)

% Define metaInformations
metaInformations = theTrip.getMetaInformations();

% Open the CSV file
fid = fopen(csvFile, 'w');

% Loop two times
for i=1:length(cellArrayOfMarkersToExport)
    
    markerDescription = cellArrayOfMarkersToExport{i};
    marker = markerDescription{1};
    markerName = markerDescription{2};
    markerModality = markerDescription{3};
    
    switch marker
        case 'situation'
            record = theTrip.getAllSituationOccurences(markerName);
        case 'event'
            record = theTrip.getAllEventOccurences(markerName);
    end
    
    markerVariablesNames = record.getVariableNames();
    pattern = '';
    
    % If there is no data in the table,
    % markerVariablesNames is empty
    % And we have no data to export
    if ~isempty(markerVariablesNames)
        
        % If there is a modality, the modality variable values are not written
        % in the export file as this value will be merged with the type.
        % TODO: check if the modality is an existing variable
        
        markerRowNumber = length(markerVariablesNames);
        if strcmp(markerModality,'')
            finalRowNumber = length(markerVariablesNames);
        else
            finalRowNumber = length(markerVariablesNames)-1;
        end
        
        
        lineNumber = length(record.getVariableValues(markerVariablesNames{1}));
        cellToWrite = cell(finalRowNumber,lineNumber);
        cellNameToWrite = cell(finalRowNumber,1);
        cellModality = cell(lineNumber,1);
        
        switch marker
            case 'situation'
                rowValue = record.getVariableValues('startTimecode');
            case 'event'
                rowValue = record.getVariableValues('timecode');
        end
        
        % the timecode is always the first column.
        columnToWrite = 1;
        for k = 1:lineNumber
            cellToWrite{columnToWrite,k} = rowValue{k};
        end
        
        switch marker
            case 'situation'
                cellNameToWrite{columnToWrite} = 'startTimecode';
            case 'event'
                cellNameToWrite{columnToWrite} = 'timecode';
        end
        
        % The two first column is always the timecode and the type
        pattern = [ pattern '%s' delimiter '%s' delimiter];
        
        % we build the pattern for enrichment variables
        for i=1:length(DataVariableNameForEnrichment)
            pattern = [ pattern '%s' delimiter '%s' delimiter]; % key, value
        end
        
        % we build the pattern for marker variables
        columnToWrite = 2;
        for i=1:markerRowNumber
            rowValue = record.getVariableValues(markerVariablesNames{i});
            if ~strcmpi(markerVariablesNames{i},'startTimecode') && ~strcmpi(markerVariablesNames{i},'timecode')
                % dealing with the modality
                if strcmpi(markerVariablesNames{i},markerModality)
                    for k = 1:lineNumber
                        cellModality{k} = rowValue{k};
                    end
                else
                    pattern = [ pattern '%s' delimiter '%s' delimiter]; % key, value
                    for k = 1:lineNumber
                        cellToWrite{columnToWrite,k} = rowValue{k};
                    end
                    cellNameToWrite{columnToWrite} = markerVariablesNames{i};
                    columnToWrite = columnToWrite +1;
                end
            end
        end
        
        pattern = [ pattern '\n'];
        
        
        % quand on a celltowrite, on itere dessus pour le marquer dans le
        % fichier
        for i=1:lineNumber
            % on commence par le time code
            lineToWrite = { num2str(cellToWrite{1,i}) };
            timecode = cellToWrite{1,i};
            
            % On met le type
            if strcmpi(markerModality,'')
                lineToWrite = { lineToWrite{:} markerName };
            else
                % there is a modality => we take the value of it and merge it
                % with the type.
                % We check if the modality is not a string to convert it
                % to a proper format.
                if ~ischar(cellModality{i})
                   modality = sprintf('%d', cellModality{i});
                else
                    modality = cellModality{i};
                end
                lineToWrite = { lineToWrite{:} [markerName '_' modality ] };
            end
            
            % Data enrichment 
            for j=1:length(DataVariableNameForEnrichment)
                exportDescription = DataVariableNameForEnrichment{j};
                exportidentifier = exportDescription{1};
                exportName = exportDescription{2};
                
                splittedName = regexp(exportidentifier, '\.', 'split');
                
                exportTableName = splittedName{1};
                exportVariableName = splittedName{2};
                
                try
                    %Pour les cas où les données à ajouter ont le même
                    %timecodes que les situations ou les events
                    rec = theTrip.getDataOccurenceAtTime(exportTableName,timecode);
                    
                catch ME
                    %Pour les cas où les données à ajouter ont des
                    %timecodes différents des situations ou des events
                    rec =theTrip.getDataOccurenceNearTime(exportTableName,timecode);
                end

                
                variableValue = cell2mat(rec.getVariableValues(exportVariableName));
                lineToWrite = { lineToWrite{:} exportName };
                lineToWrite = { lineToWrite{:} num2str(variableValue) };
                
            end
                     
       
            % then pairs of key,values
            for k=1:finalRowNumber
                if ~strcmpi(cellNameToWrite{k},'startTimecode') && ~strcmpi(cellNameToWrite{k},'timecode')
                    lineToWrite = { lineToWrite{:} cellNameToWrite{k} };
                    lineToWrite = { lineToWrite{:} num2str(cellToWrite{k,i}) };
                end
            end
            
            message = sprintf(pattern, lineToWrite{:});
            fprintf(fid,'%s',message);
        end
    end
end


fclose(fid);

end