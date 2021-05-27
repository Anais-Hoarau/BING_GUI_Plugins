function RCE2AddEventsAndSituations(trip_file, event_xml_file, situation_xml_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
%% GET TRIP DATA
meta_info = trip.getMetaInformations;
meta_data_names = meta_info.getDatasNamesList';
scenario_id = trip.getAttribute('id_scenario');

for i_data = 1:1:length(meta_data_names)
    if ~isempty(meta_info.getDataVariablesNamesList(meta_data_names{i_data})) && ~strcmp(meta_data_names{i_data}, 'MP150_data')
        meta_data_names{i_data,2} = trip.getAllDataOccurences(meta_data_names{i_data})';
        MetaVarNames = meta_info.getDataVariablesNamesList(meta_data_names{i_data});
        for i_var = 1:1:length(MetaVarNames)
            if ~isempty(meta_data_names{i_data,2}.getVariableValues(MetaVarNames{i_var}))
                data_in.(meta_data_names{i_data}).(MetaVarNames{i_var}) = meta_data_names{i_data,2}.getVariableValues(MetaVarNames{i_var})';
            end
        end
    end
end

%% INITIALISE EVENTS AND SITUATIONS

%Identify cases conditions, remove events and situations tables
scenario_cases = {'PILAUT', 'AUDVSP'};
if strcmp(scenario_id, scenario_cases{1})
    scenario_case = scenario_cases{1};
    eventList = {'synchro_clap', 'pilote_auto'};
    situationList = {'scenario', 'pilote_auto', 'franchissement'};
else
    scenario_case = scenario_cases{2};
    eventList = {'synchro_clap', 'stimulation'};
    situationList = {'scenario', 'stimulation_avant', 'stimulation_apres'};
end
%removeEventsTables(trip, eventList)
removeSituationsTables(trip, situationList)

%Create events tables
parsedXMLEventMappingFile = xmlread(event_xml_file);
eventMappings = parsedXMLEventMappingFile.getElementsByTagName('event_mapping');
createEventStructureFromMapping(trip, eventMappings);

%Create situations tables
parsedXMLSituationMappingFile = xmlread(situation_xml_file);
situationMappings = parsedXMLSituationMappingFile.getElementsByTagName('situation_mapping');
createSituationStructureFromMapping(trip, situationMappings);

%Create mask for the comments
mask_commentaires_simu = find(~cellfun(@isempty, data_in.variables_simulateur.commentaires)); % ~strcmp('0', data.variables_simulateur.commentaires);
data_use.timecodes.simu = data_in.variables_simulateur.timecode;
data_use.indices.simu = (1:1:length(data_use.timecodes.simu))';
data_use.commentaires.simu = [num2cell(data_use.indices.simu(mask_commentaires_simu)) data_use.timecodes.simu(mask_commentaires_simu) data_in.variables_simulateur.commentaires(mask_commentaires_simu)];

switch scenario_case
    %% 'PILAUT' CASE
    case scenario_cases{1}
        %% ADD EVENTS AND SITUATIONS
        
        addEventsAndSituations(trip, data_use, scenario_id, 'synchro_clap', 'scenario', 'CLAP')        % add "synchro_clap" events and "scenario_complet" situation
        addEventsAndSituations(trip, data_use, scenario_id, 'pilote_auto', 'pilote_auto', 'AUTO')             % add "pilote_auto" events and "pilote_auto" situation
        
        %add situation pilote_auto
        LastPiloteAutoTimecode = trip.getEventVariableMaximum('pilote_auto', 'timecode');
        LastClapTimecode = trip.getEventVariableMaximum('synchro_clap', 'timecode');
        trip.setSituationVariableAtTime('pilote_auto', 'name', LastPiloteAutoTimecode, LastClapTimecode, 'AutoOff');
        
        trip.setAttribute('add_events','OK');
        trip.setAttribute('add_situations','OK');
        delete(trip);
        
        %% 'AUDVSP' CASE
    case scenario_cases{2}
        %% ADD EVENTS AND SITUATIONS
        
        addEventsAndSituations(trip, data_use, scenario_id, 'synchro_clap', 'scenario', 'CLAP')           % add "CLAP_DEB/FIN" events and "scenario_complet" situation
        addEventsAndSituations(trip, data_use, scenario_id, 'stimulation', 'stimulation', 'STIM')               % add "stimulation" events and "stimulation" situations
        
        trip.setAttribute('add_events','OK');
        trip.setAttribute('add_situations','OK');
        delete(trip);
        
end

end

%% SUBFONCTIONS

% création des tables d'évènements
function createEventStructureFromMapping(trip, eventMappings)
for i = 0:1:eventMappings.getLength() - 1
    eventMapping = eventMappings.item(i);
    bindEventName = char(eventMapping.getAttribute('bind_event_name'));
    meta_info = trip.getMetaInformations;
    if ~meta_info.existEvent(bindEventName)
        disp(['Creating event ' bindEventName ' and his variables']);
        bindEventComment = char(eventMapping.getAttribute('bind_event_comment'));
        variableMappings = eventMapping.getElementsByTagName('variable_mapping');
        bindEventIsBase =  logical(str2double(eventMapping.getAttribute('bind_event_isbase')));
        bindVariables = cell(1, variableMappings.length);
        for j = 0:1:variableMappings.getLength() - 1
            variableMapping =  variableMappings.item(j);
            bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
            bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
            bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
            bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));
            
            bindVariable = fr.lescot.bind.data.MetaEventVariable();
            bindVariable.setName(bindVariableName);
            bindVariable.setType(bindVariableType);
            bindVariable.setUnit(bindVariableUnit);
            bindVariable.setComments(bindVariableComments);
            bindVariables{j+1} = bindVariable;
        end
        bindEvent = fr.lescot.bind.data.MetaEvent;
        bindEvent.setName(bindEventName);
        bindEvent.setComments(bindEventComment);
        bindEvent.setVariables(bindVariables);
        
        trip.addEvent(bindEvent);
        disp(['--> set isBase ' bindEventName ' : ' num2str(bindEventIsBase)]);
        trip.setIsBaseEvent(bindEventName, bindEventIsBase);
    else
        disp([bindEventName ' event already exists and won''t be created again']);
    end
end
end

% création des tables de situations
function createSituationStructureFromMapping(trip, situationMappings)
for i = 0:1:situationMappings.getLength() - 1
    situationMapping = situationMappings.item(i);
    bindSituationName = char(situationMapping.getAttribute('bind_situation_name'));
    meta_info = trip.getMetaInformations;
    if ~meta_info.existSituation(bindSituationName)
        disp(['Creating situation' bindSituationName ' and his variables']);
        bindSituationComment = char(situationMapping.getAttribute('bind_situation_comment'));
        variableMappings = situationMapping.getElementsByTagName('variable_mapping');
        bindSituationIsBase =  logical(str2double(situationMapping.getAttribute('bind_situation_isbase')));
        bindVariables = cell(1, variableMappings.length);
        for j = 0:1:variableMappings.getLength() - 1
            variableMapping =  variableMappings.item(j);
            bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
            bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
            bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
            bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));
            
            bindVariable = fr.lescot.bind.data.MetaSituationVariable();
            bindVariable.setName(bindVariableName);
            bindVariable.setType(bindVariableType);
            bindVariable.setUnit(bindVariableUnit);
            bindVariable.setComments(bindVariableComments);
            bindVariables{j+1} = bindVariable;
        end
        bindSituation = fr.lescot.bind.data.MetaSituation;
        bindSituation.setName(bindSituationName);
        bindSituation.setComments(bindSituationComment);
        bindSituation.setVariables(bindVariables);
        
        trip.addSituation(bindSituation);
        disp(['--> set isBase ' bindSituationName ' : ' num2str(bindSituationIsBase)]);
        trip.setIsBaseSituation(bindSituationName, bindSituationIsBase);
    else
        disp([bindSituationName ' situation already exists and won''t be created again']);
    end
end
end

% remove events tables from trip file
function removeEventsTables(trip, eventList)
meta_info = trip.getMetaInformations;
for i_event = 1:length(eventList)
    if meta_info.existEvent(eventList{i_event}) && ~isBase(meta_info.getMetaEvent(eventList{i_event}))
        trip.removeEvent(eventList{i_event});
    else
        disp([eventList{i_event} ' event is locked by "isBase" protocole']);
    end
end
end

% remove situations tables from trip file
function removeSituationsTables(trip, situationList)
meta_info = trip.getMetaInformations;
for i_situation = 1:length(situationList)
    if meta_info.existSituation(situationList{i_situation}) && ~isBase(meta_info.getMetaSituation(situationList{i_situation}))
        trip.removeSituation(situationList{i_situation});
    else
        disp([situationList{i_situation} ' situation is locked by "isBase" protocole or is already deleted']);
    end
end
end

% add event and situation from a defined variable
function addEventsAndSituations(trip, data_use, scenario_id, event_name, situation_name, var_name)
meta_info = trip.getMetaInformations;
i_var = 0;
for i_com = 1:length(data_use.commentaires.simu)
    if ~isempty(strfind(data_use.commentaires.simu{i_com,3},['__' var_name]))
        i_var = i_var +1;
        data_out.commentaire_var{i_var,1} = data_use.commentaires.simu{i_com,1};
        data_out.commentaire_var{i_var,2} = data_use.commentaires.simu{i_com,2};
        data_out.commentaire_var{i_var,3} = data_use.commentaires.simu{i_com,3};
        message_var = validatestring(['__' var_name],strsplit(data_use.commentaires.simu{i_com,3}, '|'));
        reg_message_var = regexp(message_var,'_');
        if ~isBase(meta_info.getMetaEvent(event_name))
            trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {message_var(3:end)}]');
        end
        if mod(i_var,2) == 0 && strcmpi(var_name, 'CLAP')
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, scenario_id);
            trip.setAttribute(['nb_' event_name], num2str(i_var));
        elseif mod(i_var,2) == 0 && ~strcmpi(var_name, 'CLAP') && ~strcmpi(var_name, 'STIM') && ~strcmpi(var_name, 'AUTO')
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, message_var(3:reg_message_var(end)-1));
            trip.setAttribute(['nb_' situation_name], num2str(i_var/2));
        elseif strcmpi(var_name, 'STIM') %Comparaison 6s avant/après stimulation
            trip.setSituationVariableAtTime([situation_name '_avant'], 'name', data_out.commentaire_var{i_var,2}-6, data_out.commentaire_var{i_var,2}, message_var(3:end));
            trip.setSituationVariableAtTime([situation_name '_apres'], 'name', data_out.commentaire_var{i_var,2}, data_out.commentaire_var{i_var,2}+6, message_var(3:end));
        end
    elseif strcmpi(var_name, 'CLAP') && ~isempty(strfind(data_use.commentaires.simu{i_com,3},'__TERMINE'))
        i_var = i_var +1;
        data_out.commentaire_var{i_var,1} = data_use.commentaires.simu{i_com,1};
        data_out.commentaire_var{i_var,2} = data_use.commentaires.simu{i_com,2};
        data_out.commentaire_var{i_var,3} = data_use.commentaires.simu{i_com,3};
        message_var = validatestring('__TERMINE', strsplit(data_use.commentaires.simu{i_com,3}, '|'));
        if ~isBase(meta_info.getMetaEvent(event_name))
            trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {message_var(3:end)}]');
        end
        if mod(i_var,2) == 0
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, scenario_id);
            trip.setAttribute(['nb_' event_name], num2str(i_var));
        end
    end
end
end