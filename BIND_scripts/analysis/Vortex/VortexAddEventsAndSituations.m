function VortexAddEventsAndSituations(trip_file, event_xml_file, situation_xml_file)
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
    scenario_ids = {'BASELINE', 'EXPERIMENTAL'};
    if strcmp(scenario_id,scenario_ids{1})
        scenario_case = '01BL';
        eventList = {''};
        situationList = {'scenario_complet'};
    elseif strcmp(scenario_id,scenario_ids{2})
        scenario_case = '02EXP';
        eventList = {'synchro_clap', 'feu_stop_on'};
        situationList = {'scenario_complet', 'feu_stop_on', 'feu_stop_on_before', 'feu_stop_on_after'};
    end
    %     removeEventsTables(trip, eventList)
    %     removeSituationsTables(trip, situationList)
    
    if ~strcmp(scenario_case, '01BL')
        
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
        
    end
    
    switch scenario_case
        % 'BASELINE' CASES
        case '01BL'
            meta = trip.getMetaInformations();
            startTimecode = trip.getDataVariableMinimum('MP150_data','timecode');
            endTimecode = trip.getDataVariableMaximum('MP150_data','timecode');
            if ~existSituation(meta, 'scenario_complet')
                addSituationTable2Trip(trip,'scenario_complet')
            end
            if ~existSituationVariable(meta, 'nb_EDAFluctSpont')
                addSituationVariable2Trip(trip,'scenario_complet','nb_EDAFluctSpont','REAL')
            end
            trip.setSituationVariableAtTime('scenario_complet', 'name', startTimecode, endTimecode, 'scenario_complet');
            
        % 'EXPERIMENTAL' CASES
        case '02EXP'
            %ADD EVENTS AND SITUATIONS
            
            addEventsAndSituationsByWindow(trip, data_use, 'synchro_clap', 'scenario_complet', 'CLAP', [], [])        % add "synchro_clap" events and "scenario_complet" situation
            addEventsAndSituationsByWindow(trip, data_use, 'feu_stop_on', 'feu_stop_on', 'feu_stop_on', 6, [])        % add "feu_stop_on" events and "feu_stop_on" situations
            addEventsAndSituationsByWindow(trip, data_use, '', 'feu_stop_on', 'feu_stop_on', 6, 0)        % add "feu_stop_on" events and "feu_stop_on" situations
            
    end
    
    trip.setAttribute('add_events','OK');
    trip.setAttribute('add_situations','OK');
    delete(trip);
    
end

%% SUBFONCTIONS

% add event and situation from a defined variable with or without delta time around
function addEventsAndSituationsByWindow(trip, data_use, event_name, situation_name, var_name, delta_max, delta_min)
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