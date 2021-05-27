function CcompoteAddEventsAndSituations(trip_file, event_xml_file, situation_xml_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
%% GET TRIP DATA
meta_info = trip.getMetaInformations;
meta_data_names = meta_info.getDatasNamesList';
scenario_id = trip.getAttribute('id_scenario');

for i_data = 1:1:length(meta_data_names)
    if ~isempty(meta_info.getDataVariablesNamesList(meta_data_names{i_data}))
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
scenario_cases = {'EXPERIMENTAL'};
if strcmp(scenario_id,scenario_cases{1})
    scenario_case = 'EXP';
    eventList = {'synchro_clap', 'debFin_essais', 'debFin_essais_A', 'debFin_essais_B', 'debFin_essais_C', 'alertes_sonores', 'feux_stop_OnOff'};
    situationList = {'scenario_complet', 'essais', 'essais_A', 'essais_B', 'essais_C', 'feux_stop', 'franchissement'};
end
removeEventsTables(trip, eventList)
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
    %% 'EXPERIMENTAL' CASE
    case 'EXP'
        %% ADD EVENTS AND SITUATIONS
        
        addEventsAndSituation(trip, data_use, scenario_id, 'synchro_clap', 'scenario_complet', 'clap')        % add "synchro_clap" events and "scenario_complet" situation
        addEventsAndSituation(trip, data_use, scenario_id, 'debFin_essais', 'essais', 'essai')             % add "debFin_essais" events and "essais" situation
        addEventsAndSituation(trip, data_use, scenario_id, 'debFin_essais_A', 'essais_A', 'essai_A')             % add "debFin_essais_A" events and "essais_A" situation
        addEventsAndSituation(trip, data_use, scenario_id, 'debFin_essais_B', 'essais_B', 'essai_B')             % add "debFin_essais_B" events and "essais_B" situation
        addEventsAndSituation(trip, data_use, scenario_id, 'debFin_essais_C', 'essais_C', 'essai_C')             % add "debFin_essais_C" events and "essais_C" situation
        addEventsAndSituation(trip, data_use, scenario_id, 'alertes_sonores', '', 'alerte_sonore')             % add "alertes_sonores" events and "alerte_sonore" situation
        addEventsAndSituation(trip, data_use, scenario_id, 'feux_stop_OnOff', 'feux_stop', 'feu_stop')             % add "feux_stop_OnOff" events and "feux_stop" situation
        
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
    disp(['Creating ' bindEventName ' and his variables']);
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
end
end

% création des tables de situations
function createSituationStructureFromMapping(trip, situationMappings)
for i = 0:1:situationMappings.getLength() - 1
    situationMapping = situationMappings.item(i);
    bindSituationName = char(situationMapping.getAttribute('bind_situation_name'));
    disp(['Creating ' bindSituationName ' and his variables']);
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
function addEventsAndSituation(trip, data_use, scenario_id, event_name, situation_name, var_name)
if strcmpi(var_name, 'clap')
    comment_name = upper(var_name);
else
    comment_name = var_name;
end

i_var = 0;
i_event = 1;
i_situation = 1;
for i_com = 1:length(data_use.commentaires.simu)
    if ~isempty(strfind(data_use.commentaires.simu{i_com,3},['__' comment_name]))
        i_var = i_var +1;
        data_out.commentaire_var{i_var,1} = data_use.commentaires.simu{i_com,1};
        data_out.commentaire_var{i_var,2} = data_use.commentaires.simu{i_com,2};
        data_out.commentaire_var{i_var,3} = data_use.commentaires.simu{i_com,3};
        message_var = validatestring(['__' var_name],strsplit(data_use.commentaires.simu{i_com,3}, '|'));
        reg_message_var = regexp(message_var,'_');
        if mod(i_var,2) == 0 && strcmpi(var_name, 'clap') && ~isempty(situation_name)
            trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[message_var(3:end) '_' num2str(i_situation)]}]');
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, scenario_id);
            trip.setAttribute(['nb_' event_name], num2str(i_var));
        elseif mod(i_var,2) == 0 && ~strcmpi(var_name, 'clap') && ~isempty(situation_name)
            trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[message_var(3:end) '_' num2str(i_situation)]}]');
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, [message_var(3:reg_message_var(end)-1) '_' num2str(i_situation)]);
            trip.setAttribute(['nb_' situation_name], num2str(i_var/2));
            i_situation = i_situation+1;
        else
            trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[message_var(3:end) '_' num2str(i_event)]}]');
            i_event = i_event+1;
        end
    elseif strcmpi(var_name, 'clap') && ~isempty(strfind(data_use.commentaires.simu{i_com,3},'__TERMINE'))
        i_var = i_var +1;
        data_out.commentaire_var{i_var,1} = data_use.commentaires.simu{i_com,1};
        data_out.commentaire_var{i_var,2} = data_use.commentaires.simu{i_com,2};
        data_out.commentaire_var{i_var,3} = data_use.commentaires.simu{i_com,3};
        message_var = validatestring('__TERMINE', strsplit(data_use.commentaires.simu{i_com,3}, '|'));
        if mod(i_var,2) == 0 && ~isempty(situation_name)
            trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {message_var(3:end)}]');
            trip.setSituationVariableAtTime(situation_name, 'name', data_use.commentaires.simu{i_var,2}, data_use.commentaires.simu{end-1,2}, scenario_id);
            trip.setAttribute(['nb_' event_name], num2str(i_var));
        else
            trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {message_var(3:end)}]');
        end
    end
end
end