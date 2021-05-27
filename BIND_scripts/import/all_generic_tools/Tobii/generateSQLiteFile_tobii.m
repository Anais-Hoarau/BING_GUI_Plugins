%function generateSQLiteFile(lepsis_file, timecodeColumn, dataMappingSpecifications, plotFile)
function deltaTobii = generateSQLiteFile_tobii(xmlMappingDOM, pathToVar, pathToTrip)
    tic;
   
    %Creation of the trip structure
    disp('Creating SQLiteTripObject...');
    [~, name, ~] = fileparts(pathToVar);
    
    % modification of the trip file name
    regTripName = regexp(name, '_');
    name = name(1:regTripName(end-1)-1);
    
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip([pathToTrip filesep name '.trip'], 0.04, false);
    
    %Get deltaTC_ref, startTC_ref, stopTC_ref
%     attributeList = trip.getMetaInformations().getTripAttributesList();
%     if find(strcmp(attributeList, 'deltaTC_ref')) && ~isempty(trip.getAttribute('deltaTC_ref'))
%         deltaTC_ref = textscan(trip.getAttribute('deltaTC_ref'),'%f');
%     else
%         deltaTC_ref = [];
%     end
%     
%     if find(strcmp(attributeList, 'startTC_ref')) && ~isempty(trip.getAttribute('startTC_ref'))
%         startTC_ref = textscan(trip.getAttribute('startTC_ref'),'%f');
%     else
%         startTC_ref = [];
%     end
%     
%     if find(strcmp(attributeList, 'stopTC_ref')) && ~isempty(trip.getAttribute('stopTC_ref'))
%         stopTC_ref = textscan(trip.getAttribute('stopTC_ref'),'%f');
%     else
%         stopTC_ref = [];
%     end

%     if and(find(strcmp(attributeList, 'mopad_top_clap_start')), ~isempty(trip.getAttribute('mopad_top_clap_start')))
%         startTC_ref = textscan(trip.getAttribute('mopad_top_clap_start'),'%f');
%     else
%         startTC_ref = [];
%     end
    
%     if find(strcmp(attributeList, 'mopad_top_clap_stop')) && ~isempty(trip.getAttribute('mopad_top_clap_stop'))
%         stopTC_ref = textscan(trip.getAttribute('mopad_top_clap_stop'),'%f');
%     else
%         stopTC_ref = [];
%     end
%     deltaTC_ref = num2cell(cell2mat(stopTC_ref)-cell2mat(startTC_ref));
    
    dataMappings = xmlMappingDOM.getElementsByTagName('data_mapping');    
    createStructureFromMapping(trip, dataMappings);
    
    %Opening the file and storing it as a line by line cell array
    disp('Loading lines in memory...');
    file = fopen(pathToVar);
    lines = {};
    while ~feof(file)
        aLine = fgetl(file);
        lines{end + 1} = aLine;
    end
    fclose(file);
    memInfo = whos('lines');
    disp('--> Removing empty lines...');
    removeIndices = [];
    for i = 1:1:length(lines)
       if isempty(lines{i})
          removeIndices(end + 1) = i; 
       end
    end
    lines(removeIndices) = [];
    disp(['--> Lines size in memory : ' num2str(round(memInfo.bytes / (1024*1024))) 'Mo']);
    
    %Extracting header
    disp('Extracting header...');
    header = regexp(lines{1}, '\t', 'split');
    %Removing empty cells (trailing columns)
    header(cellfun(@isempty,header)) = [];
    header{1}=header{1}(4:end);
    
    [~, itemsNumber] = size(header);
    lines(1) = [];
    
    %Removing last line (usually broken)
    disp('Removing last line...');
    lines(end) = [];
    
    %Finding which timecode columns are available
    disp('Extracting timecode columns...');    

    secTimeCodeAvailable = true; 
    try
        secIndice = getColumnIndiceForName(header, 'RecordingTimestamp');
    catch ME %#ok<NASGU>
        disp('--> sec unavailable, skipping...');
        secTimeCodeAvailable = false;
    end
    if secTimeCodeAvailable
        disp('--> Extracting sec...');
        rawSecTimecodes = extractColumn(secIndice, lines);
        secTimecodes = secToTimecode(rawSecTimecodes);
        secTimecodes = num2cell(cell2mat(secTimecodes)/1000);
    end
    
    heureGMTTimeCodeAvailable  = true; 
    try
        heureGMTIndice = getColumnIndiceForName(header, 'LocalTimeStamp');
    catch ME %#ok<NASGU>
        disp('--> heureGMT unavailable, skipping...');
        heureGMTTimeCodeAvailable = false;
    end
    if heureGMTTimeCodeAvailable
       disp('--> Extracting heureGMT...');
       rawHeureGMTTimecodes = extractColumn(heureGMTIndice, lines);
       heureGMTTimecodes = heureGMTToTimecode(rawHeureGMTTimecodes);
    end
    
    tempsTimeCodeAvailable = true;
    try
        tempsIndice = getColumnIndiceForName(header, 'temps');
    catch ME %#ok<NASGU>
        disp('--> temps unavailable, skipping...');
        tempsTimeCodeAvailable = false;
    end
    if tempsTimeCodeAvailable
        disp('--> Extracting temps...');
        rawTempsTimecodes = extractColumn(tempsIndice, lines);
        %tempsTimecodes = rawTempsTimecodes;
        tempsTimecodes = tempsToTimecode(rawTempsTimecodes);
    end
    
    %% déterminate 'clap_deb' comment timecode
    indiceCommentaires = getColumnIndiceForName(header, 'StudioEvent');
    commentaires = extractColumn(indiceCommentaires, lines);
    indiceClapDeb = find(strcmp(commentaires, 'clap_deb') ==1);
    indiceClapFin = find(strcmp(commentaires, 'clap_fin') ==1);
    
    %% Insertion of the datas in the trip
    %[~, recordsNumber] = size(lines);
    SLICES_SIZE = 10000;
    slicesStartingIndexes = indiceClapDeb:SLICES_SIZE:indiceClapFin;
    
    %Iterate on the slices
    for i = 1:1:length(slicesStartingIndexes)
        startLine = slicesStartingIndexes(i);
        endLine = min(startLine + SLICES_SIZE - 1, indiceClapFin);
        disp(['Inserting lines ' num2str(startLine) ' to ' num2str(endLine) '...']);
        cells = getCellArrayFromLines(lines, startLine , endLine, length(header));
        %iterate on all the data mappings
        for j = 0:1:dataMappings.getLength() - 1
            dataMapping = dataMappings.item(j);
            bindDataName = char(dataMapping.getAttribute('bind_data_name'));
            timecodeColumnToUse = char(dataMapping.getAttribute('imported_timecode_id'));
            variableMappings = dataMapping.getElementsByTagName('variable_mapping');
     
            switch timecodeColumnToUse
                case 'sec'
                    %timecodes = secTimecodes;
                    timecodeClapDeb = secTimecodes(indiceClapDeb);
                    timecodeClapFin = secTimecodes(indiceClapFin);
                    deltaTobii = cell2mat(timecodeClapFin) - cell2mat(timecodeClapDeb);
                    if exist('deltaTC_ref', 'var') && exist('startTC_ref', 'var') && exist('stopTC_ref', 'var')
                        ratio = cell2mat(deltaTC_ref)/deltaTobii; %Calculate ratio between delta ref and delta tobii
                        timecodes = num2cell(((cell2mat(secTimecodes)-cell2mat(timecodeClapDeb))*ratio)+cell2mat(startTC_ref));
                    elseif exist('startTC_ref', 'var')
                        timecodes = num2cell((cell2mat(secTimecodes)-cell2mat(timecodeClapDeb))+cell2mat(startTC_ref));
                    else
                        ratio = [];
                        frequence_simu = [];
                        timecodes = num2cell(cell2mat(secTimecodes)-cell2mat(timecodeClapDeb));
                    end
                case 'heureGMT'
                    %timecodes = heureGMTTimecodes;
                    timecodeClapDeb = heureGMTTimecodes(indiceClapDeb);
                    timecodeClapFin = heureGMTTimecodes(indiceClapFin);
                    deltaTobii = cell2mat(timecodeClapFin) - cell2mat(timecodeClapDeb);
                    if exist('deltaTC_ref', 'var') && exist('startTC_ref', 'var') && exist('stopTC_ref', 'var')
                        ratio = cell2mat(deltaTC_ref)/deltaTobii; %Calculate ratio between delta ref and delta tobii
                        timecodes = num2cell(((cell2mat(heureGMTTimecodes)-cell2mat(timecodeClapDeb))*ratio)+cell2mat(startTC_ref));
                    elseif exist('startTC_ref', 'var')
                        timecodes = num2cell((cell2mat(heureGMTTimecodes)-cell2mat(timecodeClapDeb))+cell2mat(startTC_ref));
                    else
                        ratio = [];
                        frequence_simu = [];
                        timecodes = num2cell((cell2mat(heureGMTTimecodes)-cell2mat(timecodeClapDeb)));
                    end
                case 'temps'
                    %timecodes = tempsTimecodes;
                    timecodeClapDeb = tempsTimecodes(indiceClapDeb);
                    timecodeClapFin = tempsTimecodes(indiceClapFin);
                    deltaTobii = cell2mat(timecodeClapFin) - cell2mat(timecodeClapDeb);
                    if exist('deltaTC_ref', 'var') && exist('startTC_ref', 'var') && exist('stopTC_ref', 'var')
                        ratio = cell2mat(deltaTC_ref)/deltaTobii; %Calculate ratio between delta ref and delta simu
                        timecodes = num2cell(((cell2mat(tempsTimecodes)-cell2mat(timecodeClapDeb))*ratio)+cell2mat(startTC_ref));
                    elseif exist('startTC_ref', 'var')
                        timecodes = num2cell((cell2mat(tempsTimecodes)-cell2mat(timecodeClapDeb))+cell2mat(startTC_ref));
                    else
                        ratio = [];
                        frequence_simu = [];
                        timecodes = num2cell((cell2mat(tempsTimecodes)-cell2mat(timecodeClapDeb)));
                    end
                otherwise
                    error('Unable to get the timecode column selected, for it is not one of the known allowed format.');
            end
            %Iterate on all the variables of the data
            for k = 0:1:variableMappings.getLength() - 1
                variableMapping =  variableMappings.item(k);
                columnName = char(variableMapping.getAttribute('imported_variable_id'));
                bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
                disp(['--> Filling ' bindDataName '.' bindVariableName ]);
                columnIndex = getColumnIndiceForName(header, columnName);
                dataValuesColumn = {cells{:, columnIndex}};
                sliceTimecodes = timecodes(startLine:endLine);
                %Replacing commas by dots to avoid troubles when converting to
                %string in Matlab. In the same loop, if the cell is empty,
                %we keep its indice in a cell array.
                emptyCellsIndices = [];
                for l = 1:1:length(dataValuesColumn)
                    if isempty(dataValuesColumn{l})
                        emptyCellsIndices(end + 1) = l; %#ok<AGROW>
                    else
                        dataValuesColumn{l} = regexprep(dataValuesColumn{l}, ',(?=\d*$)', '.');
                    end
                end
                %Generating clean values for insertion
                dataValuesColumn(emptyCellsIndices) = [];
                timecodesCleaned = sliceTimecodes;
                timecodesCleaned(emptyCellsIndices) = [];
                %Insertion
                if ~isempty(dataValuesColumn) && ~isempty(timecodesCleaned)
                    dataValuesColumn = strrep(dataValuesColumn, '"', '');
                    trip.setBatchOfTimeDataVariablePairs(bindDataName, bindVariableName, [timecodesCleaned(:), dataValuesColumn(:)]');
                end
                
            end
        end   
    end
    
    %% Perform the final operations
    %#1 : Set the datas as base according to mapping
    disp('Setting isBase attribute on data...');
    for i = 0:1:dataMappings.getLength() - 1
        dataMapping = dataMappings.item(i);
        bindDataIsBase =  logical(str2double(dataMapping.getAttribute('bind_data_isbase')));
        bindDataName = char(dataMapping.getAttribute('bind_data_name'));
        disp(['--> set isBase ' bindDataName ' : ' num2str(bindDataIsBase)]);
        trip.setIsBaseData(bindDataName, bindDataIsBase);
    end
    
    %Add meta informations
    trip.setAttribute('deltaTC_ref', num2str(deltaTobii));
    trip.setAttribute('import_tobii','OK');
    
    %Closing the trip
    disp('Closing trip...');
    delete(trip);
    %Display execution time
    disp(['Converted in ' num2str(toc/60) 'mn']);
end

function out = getCellArrayFromLines(lines, startLine, endLine, columnsNumber)
    out = cell(endLine - startLine + 1, columnsNumber);
    for i = startLine:1:endLine
        splitted = regexp(lines{i}, '\t', 'split');
        while(length(splitted) >  columnsNumber)
            if ~isempty(splitted{end})
                splitted{end-1} = [splitted{end -1} '|' splitted{end}];
            end
            splitted(end) = [];
        end
        [~, itemsNumber] = size(splitted);
        out( (i - startLine) + 1, 1:itemsNumber) = splitted;
    end
end

function out = extractColumn(columnIndice, lines)
    column = cell(length(lines), 1);
    for i = 1:1:length(lines)
        splitted =  regexpi(lines{i}, '\t', 'split');
        column{i} = splitted{columnIndice};
    end
    out = column;
end

function createStructureFromMapping(trip, dataMappings)
    for i = 0:1:dataMappings.getLength() - 1
        dataMapping = dataMappings.item(i);
        bindDataName = char(dataMapping.getAttribute('bind_data_name'));
        disp(['Creating ' bindDataName ' and his variables']);
        bindDataComment = char(dataMapping.getAttribute('bind_data_comment'));
        bindDataFrequency = char(dataMapping.getAttribute('bind_data_frequency'));
        variableMappings = dataMapping.getElementsByTagName('variable_mapping');
        bindVariables = cell(1, variableMappings.length);
        for j = 0:1:variableMappings.getLength() - 1
            variableMapping =  variableMappings.item(j);
            bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
            bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
            bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
            bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));

            bindVariable = fr.lescot.bind.data.MetaDataVariable();
            bindVariable.setName(bindVariableName);
            bindVariable.setType(bindVariableType);
            bindVariable.setUnit(bindVariableUnit);
            bindVariable.setComments(bindVariableComments);
            bindVariables{j+1} = bindVariable;
        end
        bindData = fr.lescot.bind.data.MetaData();
        bindData.setName(bindDataName);
        bindData.setComments(bindDataComment);
        bindData.setFrequency(bindDataFrequency);
        bindData.setVariables(bindVariables);

        trip.addData(bindData);
    end 
end

function out = secToTimecode(sec)
    secNonInterpolatedTimecodes = cell(length(sec), 1);
    %We just have to convert a string to a double
    for i = 1:1:length(sec)
        secNonInterpolatedTimecodes{i, 1} = strrep(sec{i}, ',', '.');
        secNonInterpolatedTimecodes{i, 1} = strrep(secNonInterpolatedTimecodes{i, 1}, '"', '');
        secNonInterpolatedTimecodes{i, 1} = str2double(secNonInterpolatedTimecodes{i, 1});
    end
    %out = affineTimecodeInterpolation(secNonInterpolatedTimecodes);
    out = secNonInterpolatedTimecodes;
end

function out = heureGMTToTimecode(heureGMT)
    
    heureGMTNonInterpolatedTimecodes = cell(length(heureGMT), 1);
   
    %Convert gmt time to seconds
    for i = 1:1:length(heureGMT)
        %In some cases we have some quotes because matlab sucks, and excel
        %also. Oh, and the simulator too by the way. Have fun If you're
        %working with all these programms !
        gmtString = strrep(heureGMT{i}, '"', '');
        gmtString = strrep(gmtString,',','.'); % fix number representation
        scanned = textscan(gmtString, '%f:%f:%f');
        [hour min sec] = scanned{:};
        newTimeCode = (hour * 3600) + (min * 60) + sec;
        heureGMTNonInterpolatedTimecodes{i, 1} = newTimeCode;
    end
    %Substracting the first timecode to all column as an offset
    offsetedTimecodes = num2cell(cell2mat(heureGMTNonInterpolatedTimecodes) - heureGMTNonInterpolatedTimecodes{1});
    out = offsetedTimecodes;

end

function out = tempsToTimecode(heureTemps)
    
    heureTempsNonInterpolatedTimecodes = cell(length(heureTemps), 1);
   
    %Convert gtm time to seconds
    for i = 1:1:length(heureTemps)
        gmtString = strrep(heureTemps{i}, '"', '');
        scanned = textscan(gmtString, '%f:%f:%f,%f');
        [hour min sec ms] = scanned{:};
        newTimeCode = (hour * 3600) + (min * 60) + sec + ms/100000;
        heureTempsNonInterpolatedTimecodes{i, 1} = newTimeCode;
    end
    %Substracting the first timecode to all column as an offset
    heureTempsInterpolatedTimecodes = affineTimecodeInterpolation(heureTempsNonInterpolatedTimecodes);
    offsetedTimecodes = num2cell(cell2mat(heureTempsInterpolatedTimecodes) - heureTempsInterpolatedTimecodes{1});
    out = offsetedTimecodes;
end


function out = getColumnIndiceForName(headerArray, columnName)
    out = find(strcmpi(columnName, headerArray), 1);
    if isempty(out)
        error(['Could not find column ' columnName ' in header']);
    end
end


% function out = getColumnIndiceForName(headerArray, columnName)
%     out = find(strncmpi(columnName, headerArray, length(columnName)), 1);
%     if isempty(out)
%         error(['Could not find column ' columnName ' in header']);
%     end
% end

function out = affineTimecodeInterpolation(timecodes)
    numberOfTimecodes = length(timecodes');
    affine = polyfit(1:1:numberOfTimecodes, cell2mat(timecodes'), 1);
    for i = 1:1:numberOfTimecodes
        out{i} = polyval(affine, i);
    end
end