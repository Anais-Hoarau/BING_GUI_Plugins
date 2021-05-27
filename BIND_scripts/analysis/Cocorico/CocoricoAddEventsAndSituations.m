function CocoricoAddEventsAndSituations(trip_file, event_xml_file, situation_xml_file)
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

%Placements des piétons (pk en dm) pour calcul des distances de détection
PKs_pietons_BL_N5 = [6510, 13730, 19700, 29900, 39580, 43290];
PKs_pietons_BL_N7 = [8200, 21735, 31250, 36900, 47590, 54631];
PKs_pietons_EXP_N5 = [6550, 13730, 19950, 30380, 40000, 44040];
PKs_pietons_EXP_N7 = [7790, 21090, 30900, 37080, 47550, 54590];

%% INITIALISE EVENTS AND SITUATIONS

%Identify cases conditions, remove events and situations tables
scenario_cases = {'BASELINE', 'EXPERIMENTAL', 'INDUCTION'};
if strcmp(scenario_id,scenario_cases{1}) || strcmp(scenario_id,scenario_cases{2})
    scenario_case = 'BASEXP';
    eventList = {'synchro_clap', 'suivi_cible', 'apparition_pieton', 'detection_pieton'};
    situationList = {'scenario_complet', 'suivi_cible'}; %, 'pieton', 'franchissement'};
elseif strcmp(scenario_id,scenario_cases{3})
    scenario_case = 'INDUCT';
    eventList = {'synchro_clap', 'section_libre', 'section_contrainte', 'feu', 'gap'};
    situationList = {'scenario_complet', 'section_libre', 'section_contrainte', 'franchissement', 'feu', 'gap'};
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
    %% 'BASELINE' AND 'EXPERIMENTAL' CASES
    case 'BASEXP'
        %% ADD EVENTS AND SITUATIONS
        
        addEventsAndSituation(trip, data_use, scenario_id, 'synchro_clap', 'scenario_complet', 'clap')        % add "synchro_clap" events and "scenario_complet" situation
        addEventsAndSituation(trip, data_use, scenario_id, 'suivi_cible', 'suivi_cible', 'suivi')             % add "suivi_cible" events and "suivi_cible" situation
        
        % add "apparition/detection_pieton" events, situations and indicators
%         trip.setAttribute('mesure_detectionsPietons','');
        %if ~check_trip_meta(trip,'calcul_detection_pieton','OK') && check_trip_meta(trip,'import_tobii','OK')
            nb_pietons = length(find(strncmp(fieldnames(data_in.tobii),'pieton_',7)));
            [~,kl_remain] = strtok(data_in.adaptation_comportementale.indics,'kl'); %detection commande klaxon
            IDs_klaxon = find(diff(strcmpi('l', kl_remain))>0)+1;
            for i_pieton = 1:nb_pietons
                nom_pieton = ['pieton_' num2str(i_pieton)];
                
                % apparition & disparition piéton
                IDs_pieton = find(diff(cell2mat(cellfun(@(x) isequal(x,0), data_in.tobii.(nom_pieton),'UniformOutput', false))))+1;
                TC_apparition_pieton = data_in.tobii.timecode{IDs_pieton(1)};
                TC_disparition_pieton = data_in.tobii.timecode{IDs_pieton(end)};
                
                % détection piéton (instant, temps et distance de détection)
                for i_klaxon = 1:1:length(IDs_klaxon)
                    TC_klaxon = data_in.adaptation_comportementale.timecode{IDs_klaxon(i_klaxon)};
                    if TC_klaxon >= TC_apparition_pieton %&& TC_klaxon <= TC_apparition_pieton + 5 % détection dans les 5 secondes après apparition
                        TC_detection_pieton = TC_klaxon;
                        TR_detection_pieton = TC_detection_pieton - TC_apparition_pieton;
                        route_vp = data_in.localisation.route{IDs_klaxon(i_klaxon)};
                        if strcmp(scenario_id, 'BASELINE') && strcmp(route_vp, '14')
                            PKs_pietons = PKs_pietons_BL_N5;
                        elseif strcmp(scenario_id, 'BASELINE') && strcmp(route_vp, '37')
                            PKs_pietons = PKs_pietons_BL_N7;
                        elseif strcmp(scenario_id, 'EXPERIMENTAL') && strcmp(route_vp, '14')
                            PKs_pietons = PKs_pietons_EXP_N5;
                        elseif strcmp(scenario_id, 'EXPERIMENTAL') && strcmp(route_vp, '37')
                            PKs_pietons = PKs_pietons_EXP_N7;
                        end
                        PKvp_detection_pieton = data_in.localisation.pk{IDs_klaxon(i_klaxon)}/1000;
                        distance_detection_pieton = min(abs(PKs_pietons/10 - PKvp_detection_pieton));
                        vitesseVP_detection_pieton = data_in.vitesse.vitesse{IDs_klaxon(i_klaxon)};
                        temps_atteinte_pieton = distance_detection_pieton / vitesseVP_detection_pieton;
                        break
                    else
                        TC_detection_pieton = TC_klaxon;
                        TR_detection_pieton = NaN;
                        distance_detection_pieton = NaN;
                        vitesseVP_detection_pieton = NaN;
                        temps_atteinte_pieton = NaN;
                        %elseif i_klaxon == length(IDs_klaxon)
                        %   TC_detection_pieton = TC_apparition_pieton;
                        %   TR_detection_pieton = TC_detection_pieton - TC_apparition_pieton;
                    end
                end
                if TR_detection_pieton > 10
                    TR_detection_pieton = NaN;
                    distance_detection_pieton = NaN;
                    vitesseVP_detection_pieton = NaN;
                    temps_atteinte_pieton = NaN;
                end
                
                % visites pieton
                if length(IDs_pieton) > 2
                    nb_visites = round((length(IDs_pieton)-2)/2);
                    TC_premiere_visite = data_in.tobii.timecode{IDs_pieton(2)};
                    temps_premiere_visite = TC_premiere_visite - TC_apparition_pieton;
                    ID_visites_pieton = find(diff(cell2mat(cellfun(@(x) isequal(x,1), data_in.tobii.(nom_pieton),'UniformOutput', false))))+1;
                    duree_totale_visites = 0;
                    for i_visite = 1:2:length(ID_visites_pieton)
                        duree_visite_pieton = data_in.tobii.timecode{ID_visites_pieton(i_visite+1)} - data_in.tobii.timecode{ID_visites_pieton(i_visite)};
                        duree_totale_visites = duree_totale_visites + duree_visite_pieton;
                    end
                    duree_moyenne_visites = duree_totale_visites/nb_visites;
                else
                    nb_visites = NaN;
                    temps_premiere_visite = NaN;
                    duree_totale_visites = NaN;
                    duree_moyenne_visites = NaN;
                end
                
                % set values in trip file
                trip.setBatchOfTimeEventVariablePairs('apparition_pieton', 'name', [TC_apparition_pieton, {nom_pieton}]');
                trip.setBatchOfTimeEventVariablePairs('detection_pieton', 'name', [TC_detection_pieton, {nom_pieton}]');
                %if TC_detection_pieton > TC_apparition_pieton
                    trip.setSituationVariableAtTime('pieton', 'name', TC_apparition_pieton, TC_disparition_pieton, nom_pieton);
                    trip.setSituationVariableAtTime('pieton', 'tc_detect', TC_apparition_pieton, TC_disparition_pieton, TC_detection_pieton);
                    trip.setSituationVariableAtTime('pieton', 'tps_detect', TC_apparition_pieton, TC_disparition_pieton, TR_detection_pieton);
                    trip.setSituationVariableAtTime('pieton', 'dist_detect', TC_apparition_pieton, TC_disparition_pieton, distance_detection_pieton);
                    trip.setSituationVariableAtTime('pieton', 'vitVP_detect', TC_apparition_pieton, TC_disparition_pieton, vitesseVP_detection_pieton);
                    trip.setSituationVariableAtTime('pieton', 'tps_atteinte', TC_apparition_pieton, TC_disparition_pieton, temps_atteinte_pieton);
                    trip.setSituationVariableAtTime('pieton', 'nb_visites', TC_apparition_pieton, TC_disparition_pieton, nb_visites);
                    trip.setSituationVariableAtTime('pieton', 'tps_1ereVisite', TC_apparition_pieton, TC_disparition_pieton, temps_premiere_visite);
                    trip.setSituationVariableAtTime('pieton', 'duree_visites_tot', TC_apparition_pieton, TC_disparition_pieton, duree_totale_visites);
                    trip.setSituationVariableAtTime('pieton', 'duree_visites_moy', TC_apparition_pieton, TC_disparition_pieton, duree_moyenne_visites);
                %end
                
            end
            trip.setAttribute('calcul_detection_pieton', 'OK');
            trip.setAttribute('nb_pietons',num2str(nb_pietons));
        %end
        
        trip.setAttribute('add_events','OK');
        trip.setAttribute('add_situations','OK');
        delete(trip);
        
        %% 'INDUCTION' CASE
    case 'INDUCT'
        %% ADD EVENTS AND SITUATIONS
        
        addEventsAndSituation(trip, data_use, scenario_id, 'synchro_clap', 'scenario_complet', 'clap')           % add "CLAP_DEB/FIN" events and "scenario_complet" situation
        addEventsAndSituation(trip, data_use, scenario_id, 'section_libre', 'section_libre', 'SL')               % add "SL_deb/fin" events and "sections_libres" situations
        addEventsAndSituation(trip, data_use, scenario_id, 'section_contrainte', 'section_contrainte', 'SC')     % add "SC_deb/fin" events and "sections_contraintes" situations
        addEventsAndSituation(trip, data_use, scenario_id, 'feu', 'feu', 'feu')                                  % add "feu_deb/fin" events and "feux" situations
        addEventsAndSituation(trip, data_use, scenario_id, 'gap', 'gap', 'gap')                                  % add "GAP_deb/fin" events and "GAP" situations
        
        trip.setAttribute('add_events','OK');
        trip.setAttribute('add_situations','OK');
        delete(trip);
        
        %         % find event comments
        %         i_feu = 0;
        %         i_gap = 0;
        %         for i_com = 1:length(data_use.commentaires.simu)
        %
        %             % add "feu_deb/fin" events and "feux" situations
        %             if ~isempty(strfind(data_use.commentaires.simu{i_com,3},'__feu'))
        %                 i_feu = i_feu +1;
        %                 data_out.commentaire_feu{i_feu,1} = data_use.commentaires.simu{i_com,1};
        %                 data_out.commentaire_feu{i_feu,2} = data_use.commentaires.simu{i_com,2};
        %                 data_out.commentaire_feu{i_feu,3} = data_use.commentaires.simu{i_com,3};
        %                 message_feu = validatestring('__feu',strsplit(data_use.commentaires.simu{i_com,3}, '|'));
        %                 regexp_message_feu = regexp(message_feu,'_');
        %                 trip.setBatchOfTimeEventVariablePairs('feu', 'name', [data_out.commentaire_feu(i_feu,2), {message_feu(3:end)}]');
        %                 if mod(i_feu,2) == 0
        %                     trip.setSituationVariableAtTime('feu', 'name', data_out.commentaire_feu{i_feu-1,2}, data_out.commentaire_feu{i_feu,2}, message_feu(3:regexp_message_feu(end)-1));
        %                 end
        %                 trip.setAttribute('nb_feu',num2str(i_feu/2));
        %             end
        %
        %             % add "GAP_deb/fin" events and "GAP" situations
        %             if ~isempty(strfind(data_use.commentaires.simu{i_com,3},'__gap'))
        %                 i_gap = i_gap +1;
        %                 data_out.commentaire_gap{i_gap,1} = data_use.commentaires.simu{i_com,1};
        %                 data_out.commentaire_gap{i_gap,2} = data_use.commentaires.simu{i_com,2};
        %                 data_out.commentaire_gap{i_gap,3} = data_use.commentaires.simu{i_com,3};
        %                 message_gap = validatestring('__gap',strsplit(data_use.commentaires.simu{i_com,3}, '|'));
        %                 regexp_message_gap = regexp(message_gap,'_');
        %                 trip.setBatchOfTimeEventVariablePairs('gap', 'name', [data_out.commentaire_gap(i_gap,2), {message_gap(3:end)}]');
        %                 if mod(i_gap,2) == 0
        %                     trip.setSituationVariableAtTime('gap', 'name', data_out.commentaire_gap{i_gap-1,2}, data_out.commentaire_gap{i_gap,2}, message_gap(3:regexp_message_gap(end)-1));
        %                 end
        %                 trip.setAttribute('nb_gap',num2str(i_gap/2));
        %             end
        %
        %         end
        
end

end

%% SUBFONCTIONS

% add event and situation from a defined variable
function addEventsAndSituation(trip, data_use, scenario_id, event_name, situation_name, var_name)
if strcmpi(var_name, 'clap')
    comment_name = upper(var_name);
else
    comment_name = var_name;
end

i_var = 0;
for i_com = 1:length(data_use.commentaires.simu)
    if ~isempty(strfind(data_use.commentaires.simu{i_com,3},['__' comment_name]))
        i_var = i_var +1;
        data_out.commentaire_var{i_var,1} = data_use.commentaires.simu{i_com,1};
        data_out.commentaire_var{i_var,2} = data_use.commentaires.simu{i_com,2};
        data_out.commentaire_var{i_var,3} = data_use.commentaires.simu{i_com,3};
        message_var = validatestring(['__' var_name],strsplit(data_use.commentaires.simu{i_com,3}, '|'));
        reg_message_var = regexp(message_var,'_');
        trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {message_var(3:end)}]');
        if mod(i_var,2) == 0 && strcmpi(var_name, 'clap')
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, scenario_id);
            trip.setAttribute(['nb_' event_name], num2str(i_var));
        elseif mod(i_var,2) == 0 && ~strcmpi(var_name, 'clap')
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, message_var(3:reg_message_var(end)-1));
            trip.setAttribute(['nb_' situation_name], num2str(i_var/2));
        end
    elseif strcmpi(var_name, 'clap') && ~isempty(strfind(data_use.commentaires.simu{i_com,3},'__TERMINE'))
        i_var = i_var +1;
        data_out.commentaire_var{i_var,1} = data_use.commentaires.simu{i_com,1};
        data_out.commentaire_var{i_var,2} = data_use.commentaires.simu{i_com,2};
        data_out.commentaire_var{i_var,3} = data_use.commentaires.simu{i_com,3};
        message_var = validatestring('__TERMINE', strsplit(data_use.commentaires.simu{i_com,3}, '|'));
        trip.setBatchOfTimeEventVariablePairs(event_name, 'name', [data_out.commentaire_var(i_var,2), {message_var(3:end)}]');
        if mod(i_var,2) == 0
            trip.setSituationVariableAtTime(situation_name, 'name', data_out.commentaire_var{i_var-1,2}, data_out.commentaire_var{i_var,2}, scenario_id);
            trip.setAttribute(['nb_' event_name], num2str(i_var));
        end
    end
end
end