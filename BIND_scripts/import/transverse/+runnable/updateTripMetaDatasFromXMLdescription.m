%{
This script will update all the meta informations of the trips located in a
folder with new metas informations contained in an XML file. This XML file is
design to mirror BIND format, so it includes all possibles meta informations
about the trip.
This scripts works in overwrite mode : previous meta informations will be
overwritten, and if the XML file does not show a complete description of
the meta variables (for example if some meta variables descriptions are
blank), the previous information will be blanked according to the XML description.

The XML have to be be carefully built.

An example XML file can be found on the redmine of the project
http://redmine.inrets.fr/projects/import/wiki

%}

% Select trip folder
directoryToRelabel = uigetdir('c:\','Your are about to select a trip folder for major MetaData overwriting. Select with care!');
if isequal(directoryToRelabel,0)
   disp('User selected Cancel')
   break; 
end

% Select XML file
[xmlFile, xmlPath] = uigetfile('*.xml', 'Select an XML file, valid for BIND format, that describe the target meta informations');
if isequal(xmlPath,0)
   disp('User selected Cancel')
   break;
end
fileWithUpdatedMetasInfos = [xmlPath filesep xmlFile];

% load all the trips in the folder and subfolders
disp('Loading the trips in all subdirectories. It may take a while, so please wait.')
theTripSet = fr.lescot.bind.utils.TripSetUtils.loadAllSQLiteTripsInSubdirectory(directoryToRelabel);
theTrips = theTripSet.getTrips();

for k = 1:length(theTrips)
    
    metas =  theTrips{k}.getMetaInformations();
    
    % parse the XML file to obtain structured information for easy handling
    % in matlab of the DATA!!!
    parsedXMLMappingFile = xmlread(fileWithUpdatedMetasInfos);
    dataMappings = parsedXMLMappingFile.getElementsByTagName('data_mapping');
    for i = 0:1:dataMappings.getLength() - 1
        dataMapping = dataMappings.item(i);
        bindDataName = char(dataMapping.getAttribute('bind_data_name'));
        bindDataIsBase = char(dataMapping.getAttribute('bind_data_isbase'));
        bindDataComment = char(dataMapping.getAttribute('bind_data_comment'));
        bindDataFrequency = char(dataMapping.getAttribute('bind_data_frequency'));
        bindDataType = char(dataMapping.getAttribute('bind_data_type'));
        
        % before continuing to the variables, check if the data exist in
        % the trip and if it worth to continue
        if metas.existData(bindDataName)
            dataToUpdate = fr.lescot.bind.data.MetaData();
            dataToUpdate.setName(bindDataName);
            dataToUpdate.setType(bindDataType);
            dataToUpdate.setComments(bindDataComment);
            dataToUpdate.setFrequency(bindDataFrequency);
            dataToUpdate.setIsBase(bindDataIsBase);
        else
            disp(['Error : One of the MetaData, described in the "Expected Meta Datas" file - ' bindDataName ' -  does not exist in the trip file : udpate will not possible. Declared MetaDatas must be available for update to work properly.']);
            continue;
        end
        
        %if we are there, we can continue to deal with the variables
        variableMappings = dataMapping.getElementsByTagName('variable_mapping');
        variableList = {};
        for j = 0:1:variableMappings.getLength() - 1
            variableMapping = variableMappings.item(j);
            bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
            bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));
            bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
            bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
            
            % This works in overwrite mode : all previous comments
            % will be replaced by the new ones from the XML description
            % New meta variables are being built that will update the
            % previous one.
            if metas.existDataVariable(bindDataName,bindVariableName)
                variableToUpdate = fr.lescot.bind.data.MetaDataVariable();
                variableToUpdate.setName(bindVariableName);
                variableToUpdate.setType(bindVariableType);
                variableToUpdate.setComments(bindVariableComments);
                variableToUpdate.setUnit(bindVariableUnit);
                variableList = { variableList{:} variableToUpdate };
            else
                disp(['Warning : One of the MetaDataVariable, described in the "Expected Meta Datas" file - ' bindDataName '.' bindVariableName ' -  does not exist in the trip file.']);
            end
        end
        
        % once all the variable are processed and the new metaDataVariable
        % have been prepared, they can be added to the the new metaData
        % that will be used to update the information
        dataToUpdate.setVariables(variableList);
        
        % Force updating of base Data : unlock the isBase setting
        if dataToUpdate.isBase()
            theTrips{k}.setIsBaseData(dataToUpdate.getName(),0);
        end
        
        disp(['Updating MetaData information on Data ' dataToUpdate.getName() ' and all associated DataVariables']);
        % the data can be updated in the trip
        try 
            theTrips{k}.updateMetaData(dataToUpdate);  
        catch ME
            Disp(['Error while updating MetaDatas : ' ME.getReport()]);
        end
        
        % Lock the isBase setting
        if dataToUpdate.isBase()
            theTrips{k}.setIsBaseData(dataToUpdate.getName(),1);
        end        
    end
    
    % parse the XML file to obtain structured information for easy handling
    % in matlab of the EVENTS!!!
    parsedXMLMappingFile = xmlread(fileWithUpdatedMetasInfos);
    eventMappings = parsedXMLMappingFile.getElementsByTagName('event_mapping');
    for i = 0:1:eventMappings.getLength() - 1
        eventMapping = eventMappings.item(i);
        bindEventName = char(eventMapping.getAttribute('bind_event_name'));
        bindEventIsBase = char(eventMapping.getAttribute('bind_event_isbase'));
        bindEventComment = char(eventMapping.getAttribute('bind_event_comment'));
        
        % before continuing to the variables, check if the data exist in
        % the trip and if it worth to continue
        if metas.existEvent(bindEventName)
            eventToUpdate = fr.lescot.bind.data.MetaEvent();
            eventToUpdate.setName(bindEventName);
            eventToUpdate.setComments(bindEventComment);
            eventToUpdate.setIsBase(bindEventIsBase);
        else
            disp(['Error : One of the MetaEvent, described in the "Expected Meta Datas" file - ' bindEventName ' -  does not exist in the trip file : udpate will not possible. Declared MetaEvents must be available for update to work properly.']);
            continue;
        end
        
        %if we are there, we can continue to deal with the variables
        variableMappings = eventMapping.getElementsByTagName('variable_mapping');
        variableList = {};
        for j = 0:1:variableMappings.getLength() - 1
            variableMapping = variableMappings.item(j);
            bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
            bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));
            bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
            bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
            
            % This works in overwrite mode : all previous comments
            % will be replaced by the new ones from the XML description
            % New meta variables are being built that will update the
            % previous one.
            if metas.existEventVariable(bindEventName,bindVariableName)
                variableToUpdate = fr.lescot.bind.data.MetaDataVariable();
                variableToUpdate.setName(bindVariableName);
                variableToUpdate.setType(bindVariableType);
                variableToUpdate.setComments(bindVariableComments);
                variableToUpdate.setUnit(bindVariableUnit);
                variableList = { variableList{:} variableToUpdate };
            else
                disp(['Warning : One of the MetaEventVariable, described in the "Expected Meta Datas" file - ' bindEventName '.' bindVariableName ' -  does not exist in the trip file.']);                
            end
        end
        
        % once all the variable are processed and the new metaDataVariable
        % have been prepared, they can be added to the the new metaData
        % that will be used to update the information
        eventToUpdate.setVariables(variableList);
        
        % Force updating of base Event : unlock the isBase setting
        if eventToUpdate.isBase()
            theTrips{k}.setIsBaseEvent(eventToUpdate.getName(),0);
        end
        disp(['Updating MetaData information on Event ' eventToUpdate.getName() ' and all associated EventVariables']);
        % the data can be updated in the trip
        try
            theTrips{k}.updateMetaEvent(eventToUpdate);  
        catch ME
            Disp('Error with low level trip handling while updating MetaEvents');
        end
        
        % Lock the isBase setting
        if eventToUpdate.isBase()
            theTrips{k}.setIsBaseEvent(eventToUpdate.getName(),1);
        end 
    end
    
    % parse the XML file to obtain structured information for easy handling
    % in matlab of the SITUATIONS!!!
    parsedXMLMappingFile = xmlread(fileWithUpdatedMetasInfos);
    situationMappings = parsedXMLMappingFile.getElementsByTagName('situation_mapping');
    for i = 0:1:situationMappings.getLength() - 1
        situationMapping = situationMappings.item(i);
        bindSituationName = char(situationMapping.getAttribute('bind_situation_name'));
        bindSituationIsBase = char(situationMapping.getAttribute('bind_situation_isbase'));
        bindSituationComment = char(situationMapping.getAttribute('bind_situation_comment'));
        
        % before continuing to the variables, check if the data exist in
        % the trip and if it worth to continue
        if metas.existSituation(bindSituationName)
            situationToUpdate = fr.lescot.bind.data.MetaSituation();
            situationToUpdate.setName(bindSituationName);
            situationToUpdate.setComments(bindSituationComment);
            situationToUpdate.setIsBase(bindSituationIsBase);
        else
            disp(['Error : One of the MetaSituation, described in the "Expected Meta Datas" file - ' bindSituationName ' -  does not exist in the trip file : udpate will not possible. Declared MetaSituations must be available for update to work properly.']);
            continue;
        end
        
        %if we are there, we can continue to deal with the variables
        variableMappings = situationMapping.getElementsByTagName('variable_mapping');
        variableList = {};
        for j = 0:1:variableMappings.getLength() - 1
            variableMapping = variableMappings.item(j);
            bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
            bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));
            bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
            bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
            
            % This works in overwrite mode : all previous comments
            % will be replaced by the new ones from the XML description
            % New meta variables are being built that will update the
            % previous one.
            if metas.existSituationVariable(bindSituationName,bindVariableName)
                variableToUpdate = fr.lescot.bind.data.MetaDataVariable();
                variableToUpdate.setName(bindVariableName);
                variableToUpdate.setType(bindVariableType);
                variableToUpdate.setComments(bindVariableComments);
                variableToUpdate.setUnit(bindVariableUnit);
                variableList = { variableList{:} variableToUpdate };
            else
                disp(['Warning : One of the MetaEventSituation, described in the "Expected Meta Datas" file - ' bindSituationName '.' bindVariableName ' -  does not exist in the trip file.']);                
            end
        end
        
        % once all the variable are processed and the new metaDataVariable
        % have been prepared, they can be added to the the new metaData
        % that will be used to update the information
        situationToUpdate.setVariables(variableList);
        
        % Force updating of base Situation  : unlock the isBase setting
        if situationToUpdate.isBase()
            theTrips{k}.setIsBaseSituation(situationToUpdate.getName(),0);
        end
        disp(['Updating MetaData information on Situation ' situationToUpdate.getName() ' and all associated SituationVariables']);
        % the data can be updated in the trip
        try
            theTrips{k}.updateMetaSituation(situationToUpdate);  
        catch ME
            Disp(['Error while updating MetaSituations : ' ME.getReport()]);
        end
        
        % Lock the isBase setting
        if situationToUpdate.isBase()
            theTrips{k}.setIsBaseSituation(situationToUpdate.getName(),1);
        end 
    end
    
    delete(theTrips{k});
end