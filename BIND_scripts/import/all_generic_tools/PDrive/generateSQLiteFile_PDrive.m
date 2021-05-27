%function generateSQLiteFile(lepsis_file, timecodeColumn, dataMappingSpecifications, plotFile)
function generateSQLiteFile_PDrive(xmlMappingDOM, pathToMat, pathesToAdditionalMat, pathToTrip)
    tic;
    
    %Creation of the trip structure
    disp('Creating SQLiteTripObject...');
    [~, name, ~] = fileparts(pathToMat);
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip([pathToTrip filesep name '.trip'], 0.04, true);
    dataMappings = xmlMappingDOM.getElementsByTagName('data_mapping');    
    createDataStructureFromMapping(trip, dataMappings);
    
    %Opening the file and storing it as a line by line cell array
    disp('Loading file in memory...');
    matFile = matfile(pathToMat);
    datas = matFile.Data;
    %extracting headers
    headerNonFormatted = matFile.Vars;
    itemsNumber = size(headerNonFormatted, 1);
    header = cell(1, itemsNumber);
    for i = 1:1:itemsNumber
        header{i} = headerNonFormatted(i,:);
    end
    

    videoFile = fr.lescot.bind.data.MetaVideoFile(['./' name '.avi'], 0, 'Quadravision 1');
    trip.addVideoFile(videoFile);
    
    %%% Optionnal block to concatenate additional mat files %%%
    if ~isempty(pathesToAdditionalMat)
        offset = 0;
        gpsTimeIndex = getColumnIndiceForName(header, 'GPS time [s]');
        timecodeIndex = getColumnIndiceForName(header, 'time [s]');
        distanceIndex = getColumnIndiceForName(header, 'distance [km]');
        lastGPSTimeFromBaseFile = datas(end, gpsTimeIndex);
        lastTimecodeFromBaseFile = datas(end, timecodeIndex);
        distanceOffset = datas(end, distanceIndex);
        for i = 1:1:length(pathesToAdditionalMat)
            additionalMat =  matfile(pathesToAdditionalMat{i});
            additionalDatas = additionalMat.Data;
            [~, additionalName, ~] = fileparts(pathesToAdditionalMat{i});
            firstGPSTimeFromAdditionalFile = additionalDatas(1, gpsTimeIndex);
            offset = offset + lastTimecodeFromBaseFile + (firstGPSTimeFromAdditionalFile - lastGPSTimeFromBaseFile);
            additionalDatas(:, timecodeIndex) = additionalDatas(:, timecodeIndex) + offset;
            additionalDatas(:, distanceIndex) = additionalDatas(:, distanceIndex) + distanceOffset;
            datas = [datas; additionalDatas];
            
            videoFile = fr.lescot.bind.data.MetaVideoFile(['./' additionalName '.avi'], -offset, ['Quadravision ' num2str(i+1)]);
            trip.addVideoFile(videoFile);
        end
    end
    %%% End optionnal block
    memInfo = whos('datas');
    disp(['--> Lines size in memory : ' num2str(round(memInfo.bytes / (1024*1024))) 'Mo']);
    
    
   
    
    %Finding which timecode columns are available
    disp('Extracting timecode column...');
    timecodeIndex = getColumnIndiceForName(header, 'time [s]');
    timecodes = num2cell(datas(:,timecodeIndex));
    
    %Insertion of the datas in the trip
    recordsNumber = size(datas, 1);
    SLICES_SIZE = 10000;
    slicesStartingIndexes = 1:SLICES_SIZE:recordsNumber;
    
    %Iterate on the slices
    for i = 1:1:length(slicesStartingIndexes)
        startLine = slicesStartingIndexes(i);
        endLine = min(startLine + SLICES_SIZE - 1, recordsNumber);
        disp(['Inserting lines ' num2str(startLine) ' to ' num2str(endLine) '...']);   
        cells = num2cell(datas(startLine:endLine,:));
        %iterate on all the data mappings
        for j = 0:1:dataMappings.getLength() - 1
            dataMapping = dataMappings.item(j);
            bindDataName = char(dataMapping.getAttribute('bind_data_name'));
            variableMappings = dataMapping.getElementsByTagName('variable_mapping');
     
            %Iterate on all the variables of the data
            for k = 0:1:variableMappings.getLength() - 1
                variableMapping =  variableMappings.item(k);
                columnName = char(variableMapping.getAttribute('imported_variable_id'));
                bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
                disp(['--> Filling ' bindDataName '.' bindVariableName ]);
                columnIndex = getColumnIndiceForName(header, columnName);
                dataValuesColumn = {cells{:, columnIndex}};
                sliceTimecodes = timecodes(startLine:endLine);
                
                %Insertion
                if ~isempty(dataValuesColumn) && ~isempty(sliceTimecodes)%~isempty(timecodesCleaned)
                    %trip.setBatchOfTimeDataVariablePairs(bindDataName, bindVariableName, [timecodesCleaned(:), dataValuesColumn(:)]');
                    trip.setBatchOfTimeDataVariablePairs(bindDataName, bindVariableName, [sliceTimecodes(:), dataValuesColumn(:)]');
                end
                
            end
        end   
    end
    
    %Perform the final operations
    %#1 : Set the datas as base according to mapping
    disp('Setting isBase attribute on datas...');
    for i = 0:1:dataMappings.getLength() - 1
        dataMapping = dataMappings.item(i);
        bindDataIsBase =  logical(str2double(dataMapping.getAttribute('bind_data_isbase')));
        bindDataName = char(dataMapping.getAttribute('bind_data_name'));
        disp(['--> set isBase ' bindDataName ' : ' num2str(bindDataIsBase)]);
        trip.setIsBaseData(bindDataName, bindDataIsBase);
    end
    
    disp('Adding the trip name attribute');
    trip.setAttribute('Trip name', name);
    
    %Closing the trip
    disp('Closing trip...');
    delete(trip);
    %Display execution time
    disp(['Converted in ' num2str(toc/60) 'mn']);
end

function createDataStructureFromMapping(trip, dataMappings)
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

            bindVariable = fr.lescot.bind.data.MetaDataVariable();
            bindVariable.setName(bindVariableName);
            bindVariable.setType(bindVariableType);
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

function out = getColumnIndiceForName(headerArray, columnName)
    out = find(strncmpi(columnName, headerArray, length(columnName)), 1);
    if isempty(out)
        error(['Could not find column ' columnName ' in header']);
    end
end