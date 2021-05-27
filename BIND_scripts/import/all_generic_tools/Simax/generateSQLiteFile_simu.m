%function generateSQLiteFile(lepsis_file, timecodeColumn, dataMappingSpecifications, plotFile)
function generateSQLiteFile_simu(xmlMappingDOM, pathToVar, pathToTrip)
    tic;
    
    %Creation of the trip structure
    disp('Creating SQLiteTripObject...');
    [~, name, ~] = fileparts(pathToVar);
    
    %Trip file name change
    if ~isempty(regexp(name, '_', 'ONCE')) && length(regexp(name, '_')) > 1 && contains(name, 'Simu_Data')
        regTripName = regexp(name, '_');
        name = name(1:regTripName(end-1)-1);
    end
    
    %Get deltaTC_ref
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip([pathToTrip filesep name '.trip'], 0.04, true);
    attributeList = trip.getMetaInformations().getTripAttributesList();
    if ~isempty(find(strcmp(attributeList, 'deltaTC_ref'), 1)) && ~isempty(trip.getAttribute('deltaTC_ref'))
        deltaTC_ref = textscan(trip.getAttribute('deltaTC_ref'),'%f');
    else
        deltaTC_ref = [];
    end
    
    dataMappings = xmlMappingDOM.getElementsByTagName('data_mapping');
    createDataStructureFromMapping(trip, dataMappings);
    
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
    
    [~, itemsNumber] = size(header);
    lines(1) = [];
    
    %Removing last line (usually broken)
    disp('Removing last line...');
    lines(end) = [];
    
    %Finding which timecode columns are available
    disp('Extracting timecode columns...');
    
    secTimeCodeAvailable = true;
    try
        secIndice = getColumnIndiceForName(header, 'sec');
    catch ME %#ok<NASGU>
        disp('--> sec unavailable, skipping...');
        secTimeCodeAvailable = false;
    end
    if secTimeCodeAvailable
        disp('--> Extracting sec...');
        rawSecTimecodes = extractColumn(secIndice, lines);
        secTimecodes = secToTimecode(rawSecTimecodes);
    end
    
    heureGMTTimeCodeAvailable  = true;
    try
        heureGMTIndice = getColumnIndiceForName(header, 'heureGMT');
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
        tempsTimecodes = tempsToTimecode(rawTempsTimecodes);
    end
    
    %% find 'CLAP_DEB' & 'CLAP_FIN' comments indices and timecodes
    indiceColumnCommentaires = getColumnIndiceForName(header, 'commentaires');
    columnCommentaires = extractColumn(indiceColumnCommentaires, lines);
    indicesCommentaires = find(strcmp(columnCommentaires, ';Message_:_') ==1);
    indiceClapDeb = 1;
    indiceClapFin = length(columnCommentaires);
    for i_commentaire = 1:1:length(indicesCommentaires)
        ligneCommentaire = getCellArrayFromLines(lines, indicesCommentaires(i_commentaire), indicesCommentaires(i_commentaire), length(header));
        commentaire = ligneCommentaire(indiceColumnCommentaires);
        if ~isempty(strfind(commentaire{:}, 'CLAP_DEB'))
            indiceClapDeb = indicesCommentaires(i_commentaire);
            continue
        elseif ~isempty(strfind(commentaire{:}, 'CLAP_FIN'))
            indiceClapFin = indicesCommentaires(i_commentaire);
            break
        elseif ~isempty(strfind(commentaire{:}, 'TERMINE'))
            indiceClapFin = indicesCommentaires(i_commentaire);
        end
    end
    
    %% Insertion of the datas in the trip
    %[~, recordsNumber] = size(lines);
    SLICES_SIZE = 10000;
    %slicesStartingIndexes = 1:SLICES_SIZE:recordsNumber;
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
                    deltaSimu = cell2mat(timecodeClapFin) - cell2mat(timecodeClapDeb); %Calculate delta simu
                    if ~isempty(deltaTC_ref)
                        ratio = cell2mat(deltaTC_ref)/deltaSimu; %Calculate ratio between delta ref and delta simu
                        frequence_simu = (indiceClapFin - indiceClapDeb) / (deltaSimu*ratio); %Calculate simulator frequence
                        timecodes = num2cell((cell2mat(secTimecodes)-cell2mat(timecodeClapDeb))*ratio);
                    else
                        ratio = [];
                        frequence_simu = [];
                        timecodes = num2cell((cell2mat(secTimecodes)-cell2mat(timecodeClapDeb)));
                    end
                case 'heureGMT'
                    %timecodes = heureGMTTimecodes;
                    timecodeClapDeb = heureGMTTimecodes(indiceClapDeb);
                    timecodeClapFin = heureGMTTimecodes(indiceClapFin);
                    deltaSimu = cell2mat(timecodeClapFin) - cell2mat(timecodeClapDeb); %Calculate delta simu
                    if ~isempty(deltaTC_ref)
                        ratio = cell2mat(deltaTC_ref)/deltaSimu; %Calculate ratio between delta ref and delta simu
                        frequence_simu = (indiceClapFin - indiceClapDeb) / (deltaSimu*ratio); %Calculate simulator frequence
                        timecodes = num2cell((cell2mat(heureGMTTimecodes)-cell2mat(timecodeClapDeb))*ratio);
                    else
                        ratio = [];
                        frequence_simu = [];
                        timecodes = num2cell((cell2mat(heureGMTTimecodes)-cell2mat(timecodeClapDeb)));
                    end
                case 'temps'
                    %timecodes = tempsTimecodes;
                    timecodeClapDeb = tempsTimecodes(indiceClapDeb);
                    timecodeClapFin = tempsTimecodes(indiceClapFin);
                    deltaSimu = cell2mat(timecodeClapFin) - cell2mat(timecodeClapDeb); %Calculate delta simu
                    if ~isempty(deltaTC_ref)
                        ratio = cell2mat(deltaTC_ref)/deltaSimu; %Calculate ratio between delta ref and delta simu
                        frequence_simu = (indiceClapFin - indiceClapDeb) / (deltaSimu*ratio); %Calculate simulator frequence
                        timecodes = num2cell((cell2mat(tempsTimecodes)-cell2mat(timecodeClapDeb))*ratio);
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
                bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
                if ~isempty(variableMapping.getAttribute('imported_variable_id'))
                    columnName = char(variableMapping.getAttribute('imported_variable_id'));
                    disp(['--> Filling ' bindDataName '.' bindVariableName ]);
                    if ~isempty(find(strncmpi(columnName, header, length(columnName)), 1))
                        columnIndex = getColumnIndiceForName(header, columnName);
                        dataValuesColumn = {cells{:, columnIndex}};
                        sliceTimecodes = timecodes(startLine:endLine);
                        %Replacing commas by dots to avoid troubles when converting to
                        %string in Matlab. In the same loop, if the cell is empty,
                        %we keep its indice in a cell array.
                        emptyCellsIndices = [];
                        for l = 1:1:length(dataValuesColumn)
                            if isempty(dataValuesColumn{l}) || strcmp(dataValuesColumn{l},'infini')
                                emptyCellsIndices(end + 1) = l; %#ok<AGROW>
                                %                   elseif strcmp(dataValuesColumn{l},'infini')
                                %                       dataValuesColumn{l} = -2;
                            else
                                dataValuesColumn{l} = regexprep(dataValuesColumn{l}, ',(?=\d*$)', '.');
                            end
                        end
                        %Generating clean values for insertion
                        %                     dataValuesColumn(emptyCellsIndices) = [];
                        timecodesCleaned = sliceTimecodes;
                        %                     timecodesCleaned(emptyCellsIndices) = [];
                        %Insertion
                        if ~isempty(dataValuesColumn) && ~isempty(timecodesCleaned)
                            dataValuesColumn = strrep(dataValuesColumn, '"', '');
                            trip.setBatchOfTimeDataVariablePairs(bindDataName, bindVariableName, [timecodesCleaned(:), dataValuesColumn(:)]');
                        end
                    else
                        disp(['Could not find column ' columnName ' in header']);
                    end
                end
                
            end
        end
    end
    
    %Perform the final operations
    %#1 : Set the datas as base according to mapping
    disp('Setting isBase attribute on data...');
    for i = 0:1:dataMappings.getLength() - 1
        dataMapping = dataMappings.item(i);
        bindDataIsBase =  logical(str2double(dataMapping.getAttribute('bind_data_isbase')));
        bindDataName = char(dataMapping.getAttribute('bind_data_name'));
        trip.setFrequencyData(bindDataName, round(frequence_simu));
        disp(['--> set isBase ' bindDataName ' : ' num2str(bindDataIsBase)]);
        trip.setIsBaseData(bindDataName, bindDataIsBase);
    end
    
    %Add meta informations
    trip.setAttribute('import_simu','OK');
    trip.setAttribute('deltaTC_simu_initial',num2str(deltaSimu));
    trip.setAttribute('ratio_deltaTC (=deltaRef/deltaSimu)',num2str(ratio));
    trip.setAttribute('frequence_simu',num2str(frequence_simu));
    
    if isempty(deltaTC_ref)
        trip.setAttribute('deltaTC_ref',num2str(deltaSimu));
    end
    
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

function out = secToTimecode(sec)
    secNonInterpolatedTimecodes = cell(length(sec), 1);
    %We just have to convert a string to a double
    for i = 1:1:length(sec)
        secNonInterpolatedTimecodes{i, 1} = strrep(sec{i}, ',', '.');
        secNonInterpolatedTimecodes{i, 1} = strrep(secNonInterpolatedTimecodes{i, 1}, '"', '');
        secNonInterpolatedTimecodes{i, 1} = str2double(secNonInterpolatedTimecodes{i, 1});
    end
    out = affineTimecodeInterpolation(secNonInterpolatedTimecodes);
end

function out = heureGMTToTimecode(heureGMT)
    
    heureGMTNonInterpolatedTimecodes = cell(length(heureGMT), 1);
    
    %Convert gtm time to seconds
    for i = 1:1:length(heureGMT)
        %In some cases we have some quotes because matlab sucks, and excel
        %also. Oh, and the simulator too by the way. Have fun I you're
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
    %heureTempsInterpolatedTimecodes = affineTimecodeInterpolation(heureTempsNonInterpolatedTimecodes);
    offsetedTimecodes = num2cell(cell2mat(heureTempsNonInterpolatedTimecodes) - heureTempsNonInterpolatedTimecodes{1});
    out = offsetedTimecodes;
end


function out = getColumnIndiceForName(headerArray, columnName)
    out = find(strncmpi(columnName, headerArray, length(columnName)), 1);
    if isempty(out)
        error(['Could not find column ' columnName ' in header']);
    end
end

function out = affineTimecodeInterpolation(timecodes)
    numberOfTimecodes = length(timecodes');
    affine = polyfit(1:1:numberOfTimecodes, cell2mat(timecodes'), 1);
    for i = 1:1:numberOfTimecodes
        out{i} = polyval(affine, i);
    end
end