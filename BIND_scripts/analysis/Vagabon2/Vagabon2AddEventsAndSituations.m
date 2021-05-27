function Vagabon2AddEventsAndSituations(trip_file, event_xml_file, situation_xml_file)
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
scenario_ids = {'BASELINE', 'SANS_OBSTACLE', 'AVEC_OBSTACLE'};
if strcmp(scenario_id,scenario_ids{1})
    scenario_case = '01BL';
    eventList = {'synchro_clap'};
    situationList = {'scenario_complet'};
elseif strcmp(scenario_id,scenario_ids{2})
    scenario_case = '02SO';
    eventList = {'synchro_clap', 'self_report', 'self_report_filtre'};
    situationList = {'scenario_complet', 'self_report_before', 'self_report_after', 'conduite_libre', 'tache_prospective','rep_stop_before','rep_stop_after'};
elseif strcmp(scenario_id,scenario_ids{3})
    scenario_case = '03AO';
    eventList = {'synchro_clap', 'self_report', 'self_report_filtre'};
    situationList = {'scenario_complet', 'self_report_before', 'self_report_after', 'conduite_libre', 'tache_prospective','rep_stop_before','rep_stop_after','obstacle'};
end
% removeEventsTables(trip, eventList)
% removeSituationsTables(trip, situationList)

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

%% FILTRAGE DES COMMENTAIRES
%filtrage des commentaires en doublon
nb_SR_doublons = 0;
for i_com = 1:length(data_use.commentaires.simu)-1
    first_comment = data_use.commentaires.simu{i_com,3};
    second_comment = data_use.commentaires.simu{i_com+1,3};
    TC_first_comment = data_use.commentaires.simu{i_com,2};
    TC_second_comment = data_use.commentaires.simu{i_com+1,2};

    if ~isempty(strfind(first_comment,'__PHARE')) && ~isempty(strfind(second_comment,'__PHARE')) && (TC_second_comment - TC_first_comment < 1)
        data_use.commentaires.simu{i_com+1,3} = [second_comment(1:end-5) 'DOUBLON'];
        nb_SR_doublons = nb_SR_doublons + 1;
    end
end

%filtrage des commentaires trop proches
nb_SR_validated = 0;
nb_SR_filtres = 0;
for i_com = 1:length(data_use.commentaires.simu)-1
    first_comment = data_use.commentaires.simu{i_com,3};
    second_comment = data_use.commentaires.simu{i_com+1,3};
    TC_first_comment = data_use.commentaires.simu{i_com,2};
    TC_second_comment = data_use.commentaires.simu{i_com+1,2};
    
    if  ~isempty(strfind(first_comment,'__PHARE')) && ~isempty(strfind(second_comment,'__PHARE')) && isempty(strfind(first_comment,'__PHARE_FILTRE')) && isempty(strfind(first_comment,'__PHARE_DOUBLON')) && isempty(strfind(second_comment,'__PHARE_DOUBLON')) && (TC_second_comment - TC_first_comment < 12)
        data_use.commentaires.simu{i_com,3} = [first_comment '_FILTRE'];
        data_use.commentaires.simu{i_com+1,3} = [second_comment '_FILTRE'];
        nb_SR_filtres = nb_SR_filtres + 2;
    elseif ~isempty(strfind(first_comment,'__PHARE')) && ~isempty(strfind(second_comment,'__PHARE')) && ~isempty(strfind(first_comment,'__PHARE_FILTRE')) && isempty(strfind(first_comment,'__PHARE_DOUBLON')) && isempty(strfind(second_comment,'__PHARE_DOUBLON')) && (TC_second_comment - TC_first_comment < 12)
        data_use.commentaires.simu{i_com+1,3} = [second_comment '_FILTRE'];
        nb_SR_filtres = nb_SR_filtres + 1;
    elseif ~isempty(strfind(first_comment,'__PHARE')) && ~isempty(strfind(second_comment,'__PHARE')) && isempty(strfind(first_comment,'__PHARE_FILTRE')) && isempty(strfind(first_comment,'__PHARE_DOUBLON')) && isempty(strfind(second_comment,'__PHARE_DOUBLON')) && (TC_second_comment - TC_first_comment > 12)
        data_use.commentaires.simu{i_com,3} = [first_comment '_VALIDATED'];
        nb_SR_validated = nb_SR_validated + 1;
    elseif ~isempty(strfind(first_comment,'__PHARE')) && isempty(strfind(second_comment,'__PHARE')) && isempty(strfind(first_comment,'__PHARE_DOUBLON')) && isempty(strfind(first_comment,'__PHARE_FILTRE'))
        data_use.commentaires.simu{i_com,3} = [first_comment '_VALIDATED'];
        nb_SR_validated = nb_SR_validated + 1;
    end
end

trip.setAttribute('nb_self_report',num2str(nb_SR_validated));
trip.setAttribute('nb_self_report_filtre',num2str(nb_SR_filtres));
trip.setAttribute('nb_self_report_doublon',num2str(nb_SR_doublons));

switch scenario_case
    %% 'SANS_OBSTACLE' AND 'EXPERIMENTAL' CASES
    case '02SO'
        %% ADD EVENTS AND SITUATIONS
        
        addEventsAndSituationsByWindow(trip, data_use, 'synchro_clap', 'scenario_complet', 'CLAP',[],[])        % add "synchro_clap" events and "scenario_complet" situation
        addEventsAndSituationsByWindow(trip, data_use, 'self_report', 'self_report', 'PHARE_VALIDATED',5.5,0.5)           % add "self_report" events and "self_report" situations
        addEventsAndSituationsByWindow(trip, data_use, 'self_report_filtre', '', 'PHARE_FILTRE',5.5,0.5)           % add "self_report" events and "self_report" situations
%         addEventsAndSituationsByWindow(trip, data_use, 'rep_stop', '', 'REP_STOP',[],[])                      % add "rep_stop" events
        addEventsAndSituationsByWindow(trip, data_use, '', 'conduite_libre', 'CL',[],[])                        % add "conduite_libre" situations
        addEventsAndSituationsByWindow(trip, data_use, '', 'tache_prospective', 'TP',[],[])                     % add "tache_prospective" situations   
        
        %add situation rep_stop
        delta_max = 15;
        delta_min = 1;
        timecodes = trip.getAllEventOccurences('rep_stop').getVariableValues('timecode');
        for i_rep = 1:length(timecodes)
            trip.setSituationVariableAtTime('rep_stop_before', 'name', timecodes{i_rep}-delta_max, timecodes{i_rep}-delta_min, ['rep_stop_before_' num2str(i_rep)]);
            trip.setSituationVariableAtTime('rep_stop_after', 'name', timecodes{i_rep}+delta_min, timecodes{i_rep}+delta_max, ['rep_stop_after_' num2str(i_rep)]);
        end        
        
        trip.setAttribute('add_events','OK');
        trip.setAttribute('add_situations','OK');
        delete(trip);
        
        %% 'AVEC_OBSTACLE' CASE
    case '03AO'
        %% ADD EVENTS AND SITUATIONS
        
        addEventsAndSituationsByWindow(trip, data_use, 'synchro_clap', 'scenario_complet', 'CLAP',[],[])        % add "synchro_clap" events and "scenario_complet" situation
        addEventsAndSituationsByWindow(trip, data_use, 'self_report', 'self_report', 'PHARE_VALIDATED',5.5,0.5)           % add "self_report" events and "self_report" situations
        addEventsAndSituationsByWindow(trip, data_use, 'self_report_filtre', '', 'PHARE_FILTRE',5.5,0.5)           % add "self_report" events and "self_report" situations
%         addEventsAndSituationsByWindow(trip, data_use, 'rep_stop', '', 'REP_STOP',[],[])                      % add "rep_stop" events
        addEventsAndSituationsByWindow(trip, data_use, '', 'conduite_libre', 'CL',[],[])                        % add "conduite_libre" situations
        addEventsAndSituationsByWindow(trip, data_use, '', 'tache_prospective', 'TP',[],[])                     % add "tache_prospective" situations        

        %add situation rep_stop
        delta_max = 15;
        delta_min = 1;
        timecodes = trip.getAllEventOccurences('rep_stop').getVariableValues('timecode');
        for i_rep = 1:length(timecodes)
            trip.setSituationVariableAtTime('rep_stop_before', 'name', timecodes{i_rep}-delta_max, timecodes{i_rep}-delta_min, ['rep_stop_before_' num2str(i_rep)]);
            trip.setSituationVariableAtTime('rep_stop_after', 'name', timecodes{i_rep}+delta_min, timecodes{i_rep}+delta_max, ['rep_stop_after_' num2str(i_rep)]);
        end
        
        %add situation obstacle
        if ~isempty(find(cell2mat(data_in.variables_simulateur.numInstruction)==304,1))
        AlerteAutoOffTimecode = data_in.variables_simulateur.timecode{find(cell2mat(data_in.variables_simulateur.numInstruction)==304,1)};
        else
        AlerteAutoOffTimecode = data_in.variables_simulateur.timecode{find(cell2mat(data_in.variables_simulateur.indEssai)==21,1)+1};
        end
        LastClapTimecode = trip.getEventVariableMaximum('synchro_clap', 'timecode');
        trip.setSituationVariableAtTime('obstacle', 'name', AlerteAutoOffTimecode, LastClapTimecode, 'obstacle');
        trip.setSituationVariableAtTime('obstacle_before', 'name', AlerteAutoOffTimecode-5.5, AlerteAutoOffTimecode-0.5, 'obstacle_before');
        
        trip.setAttribute('add_events','OK');
        trip.setAttribute('add_situations','OK');
        delete(trip);
        
end

end

%% SUBFONCTIONS

% add event and situation from a defined variable with or without delta time around
function addEventsAndSituationsByWindow(trip, data_use, event_name, situation_name, var_name,delta_max,delta_min)
i_var = 0;
i_event = 1;
i_situation = 1;
for i_com = 1:length(data_use.commentaires.simu)
    if ~isempty(strfind(data_use.commentaires.simu{i_com,3},['__' var_name])) && isempty(strfind(data_use.commentaires.simu{i_com,3},'__CLAP'))
        i_var = i_var +1;
        data_out.commentaire_var{i_var,1} = data_use.commentaires.simu{i_com,1};
        data_out.commentaire_var{i_var,2} = data_use.commentaires.simu{i_com,2};
        data_out.commentaire_var{i_var,3} = data_use.commentaires.simu{i_com,3};
        if mod(i_var,2) == 0 && ~isempty(situation_name) && isempty(delta_max) && isempty(delta_min)
            if ~isempty(event_name)
                trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[event_name '_' num2str(i_event)]}]');
            end
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, [situation_name '_' num2str(i_situation)]);
            trip.setAttribute(['nb_' situation_name], num2str(i_var/2));
            i_situation = i_situation+1;
            i_event = i_event+1;
        elseif ~isempty(situation_name) && xor(isempty(delta_max), isempty(delta_min))
            if isempty(delta_max)
            delta = delta_min;
            elseif isempty(delta_min)
            delta = delta_max;
            end
            if ~isempty(event_name)
                trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[event_name '_' num2str(i_event)]}]');
            end
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var,2}-delta, data_out.commentaire_var{i_var,2}+delta, [situation_name 'around_' num2str(i_situation)]);
            trip.setAttribute(['nb_' situation_name], num2str(i_var));
            i_situation = i_situation+1;
            i_event = i_event+1;
        elseif ~isempty(situation_name) && ~isempty(delta_max) && ~isempty(delta_min)
            if ~isempty(event_name)
                trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[event_name '_' num2str(i_event)]}]');
            end
            trip.setSituationVariableAtTime([situation_name '_before'], 'name', data_out.commentaire_var{i_var,2}-delta_max, data_out.commentaire_var{i_var,2}-delta_min, [situation_name '_before_' num2str(i_situation)]);
            trip.setSituationVariableAtTime([situation_name '_after'], 'name', data_out.commentaire_var{i_var,2}+delta_min, data_out.commentaire_var{i_var,2}+delta_max, [situation_name '_after_' num2str(i_situation)]);
            trip.setAttribute(['nb_' situation_name], num2str(i_var));
            i_situation = i_situation+1;
            i_event = i_event+1;
        else
            if ~isempty(event_name)
                trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[event_name '_' num2str(i_event)]}]');
                i_event = i_event+1;
            end
        end
    elseif ~isempty(strfind(data_use.commentaires.simu{i_com,3},['__' var_name])) && strcmp(var_name, 'CLAP')
        i_var = i_var +1;
        data_out.commentaire_var{i_var,1} = data_use.commentaires.simu{i_com,1};
        data_out.commentaire_var{i_var,2} = data_use.commentaires.simu{i_com,2};
        data_out.commentaire_var{i_var,3} = data_use.commentaires.simu{i_com,3};
        if mod(i_var,2) == 0 && ~isempty(situation_name) && isempty(delta_max) && isempty(delta_min)
            if ~isempty(event_name)
                trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[event_name '_' num2str(i_event)]}]');
            end
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, [situation_name '_' num2str(i_situation)]);
            trip.setAttribute(['nb_' situation_name], num2str(i_var/2));
            i_situation = i_situation+1;
            i_event = i_event+1;
        else
            if ~isempty(event_name)
                trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {[event_name '_' num2str(i_event)]}]');
                i_event = i_event+1;
            end
        end
    end
end
end