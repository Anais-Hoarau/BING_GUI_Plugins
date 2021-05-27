function CapadynHGDataVerification(MAIN_FOLDER)
MAIN_FOLDER = 'E:\PROJETS ACTUELS\THESE_CAROLINE\CAPADYN\DONNEES_PARTICIPANTS\TESTS';
trip_files = dirrec(MAIN_FOLDER, '.trip');
indices_dev_max_sum = 0;
indices_dev_max_duree_sum = 0;
indices_dev_max_distance_sum = 0;
indices_dev_max_vitesse_sum = 0;
indices_dev_max_vitesse_bis_sum = 0;
indices_dev_sum = 0;
indices_dev_duree_sum = 0;
indices_dev_distance_sum = 0;
indices_dev_vitesse_sum = 0;
indices_dev_vitesse_bis_sum = 0;
distance_parcours = 39.5;
distance_essai_min = 33;

%% loop on participants
for i_part = 1:6:length(trip_files)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_files{i_part}, 0.04, false);
    participant_id = strsplit(trip.getAttribute('id_participant'),'_');
    participant_name = participant_id{1};
    data_in.(participant_name).mask_indices_dev_OK = ones(1,5);
    delete(trip)
    
    if ~isempty(strfind(['P04','P05','P08','P19','P20','P21','P22'], participant_name))
        continue
    end
    
    %% loop on trips
    for i_trip = 1:5
        trip_file = trip_files{i_part+i_trip-1};
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        data_in.(participant_name).scenario_ids{i_trip} = trip.getAttribute('id_scenario');
        data_in.(participant_name).indices_dev(i_trip) = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('indice_dev'));
        data_in.(participant_name).durees(i_trip) = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('duree'));
        data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).indice_dev = data_in.(participant_name).indices_dev(i_trip);
        data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).duree = data_in.(participant_name).durees(i_trip);
        
        % get distance_pas data
        if trip.getMetaInformations().existData('distance_pas_x') && trip.getMetaInformations().existDataVariable('distance_pas_x','distance_pas_x_correc')
            startTimecode = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('startTimecode'));
            endTimecode = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('endTimecode'));
            distance_pas = cell2mat(trip.getDataOccurencesInTimeInterval('distance_pas_x', startTimecode, endTimecode).getVariableValues('distance_pas_x_correc'));
            vitesse_pas = cell2mat(trip.getDataOccurencesInTimeInterval('vitesse_pas_x', startTimecode, endTimecode).getVariableValues('vitesse_pas_x_correc'));
            mask_distance_pas = find(diff(distance_pas));
            data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).distance_pas = sum([distance_pas(mask_distance_pas),distance_pas(end)]);
            data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).vitesse_pas = mean([vitesse_pas(mask_distance_pas),vitesse_pas(end)]);
            
        elseif trip.getMetaInformations().existData('distance_pas_x') && ~trip.getMetaInformations().existDataVariable('distance_pas_x','distance_pas_x_correc')
            startTimecode = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('startTimecode'));
            endTimecode = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('endTimecode'));
            distance_pas = cell2mat(trip.getDataOccurencesInTimeInterval('distance_pas_x', startTimecode, endTimecode).getVariableValues('distance_pas_x'));
            vitesse_pas = cell2mat(trip.getDataOccurencesInTimeInterval('vitesse_pas_x', startTimecode, endTimecode).getVariableValues('vitesse_pas_x'));
            mask_distance_pas = find(diff(distance_pas));
            data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).distance_pas = sum([distance_pas(mask_distance_pas),distance_pas(end)]);
            data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).vitesse_pas = mean([vitesse_pas(mask_distance_pas),vitesse_pas(end)]);
            
        else
            data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).indice_dev = 0;
            data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).duree = 0;
            data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).distance_pas = 0;
            data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).vitesse_pas = 0;
        end
        
        data_in.(participant_name).distances(i_trip) = data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).distance_pas;
        data_in.(participant_name).vitesses(i_trip) = data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).vitesse_pas;
        
        if data_in.(participant_name).distances(i_trip) < distance_essai_min || ~isempty(strfind(trip.getAttribute('id_participant'),'P15_05DT1AO')) || ~isempty(strfind(trip.getAttribute('id_participant'),'P17_03DT1SO'))
            data_in.(participant_name).mask_indices_dev_OK(1,i_trip) = 0;
        end
        
        % display informations from each trip
        disp([participant_name ' | ' data_in.(participant_name).scenario_ids{i_trip} ...
            ' - indice_dev : ' num2str(data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).indice_dev) ...
            ' - duree : ' num2str(data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).duree) ' s' ...
            ' - distance : ' num2str(data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).distance_pas) ' m' ...
            ' - vitesse : ' num2str(data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).vitesse_pas) ' km/h' ...
            ' - vitesse_bis : ' num2str(data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).distance_pas/data_in.(participant_name).(data_in.(participant_name).scenario_ids{i_trip}).duree*3.6) ' km/h']);
        
        delete(trip)
    end
    
    %% INDICE_DEV INFORMATIONS
    % indice_dev_max informations
    [data_in.(participant_name).indice_dev_max,data_in.(participant_name).indice_dev_max_id] = max(data_in.(participant_name).indices_dev(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).indice_dev_max_scenario = cell2mat(data_in.(participant_name).scenario_ids(data_in.(participant_name).indice_dev_max_id));
    data_in.(participant_name).indice_dev_max_duree = data_in.(participant_name).(data_in.(participant_name).indice_dev_max_scenario).duree;
    data_in.(participant_name).indice_dev_max_distance = data_in.(participant_name).(data_in.(participant_name).indice_dev_max_scenario).distance_pas;
    data_in.(participant_name).indice_dev_max_vitesse = data_in.(participant_name).(data_in.(participant_name).indice_dev_max_scenario).vitesse_pas;
    data_in.(participant_name).indice_dev_max_vitesse_bis = data_in.(participant_name).indice_dev_max_distance/data_in.(participant_name).indice_dev_max_duree*3.6;
    
    % indice_dev_moy informations
    data_in.(participant_name).indice_dev_moy = mean(data_in.(participant_name).indices_dev(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).duree_moy = mean(data_in.(participant_name).durees(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).distance_moy = mean(data_in.(participant_name).distances(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).vitesse_moy = mean(data_in.(participant_name).vitesses(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).vitesse_moy_bis = mean(data_in.(participant_name).distances(logical(data_in.(participant_name).mask_indices_dev_OK)))/mean(data_in.(participant_name).durees(logical(data_in.(participant_name).mask_indices_dev_OK)))*3.6;
    
    % indice_dev_std informations
    data_in.(participant_name).indice_dev_std = std(data_in.(participant_name).indices_dev(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).duree_std = std(data_in.(participant_name).durees(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).distance_std = std(data_in.(participant_name).distances(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).vitesse_std = std(data_in.(participant_name).vitesses(logical(data_in.(participant_name).mask_indices_dev_OK)));
    data_in.(participant_name).vitesse_std_bis = std(data_in.(participant_name).distances(logical(data_in.(participant_name).mask_indices_dev_OK)))/std(data_in.(participant_name).durees(logical(data_in.(participant_name).mask_indices_dev_OK)))*3.6;
    
    %% DISPLAY INDICE_DEV INFORMATIONS
    
    disp('---------------------------------------------------------------------------------------------------------------');
    % display indice_dev_max informations
    disp([participant_name ' | ' data_in.(participant_name).indice_dev_max_scenario ...
        ' - indice_dev_max : ' num2str(data_in.(participant_name).indice_dev_max) ...
        ' - duree : ' num2str(data_in.(participant_name).indice_dev_max_duree) ' s' ...
        ' - distance : ' num2str(data_in.(participant_name).indice_dev_max_distance) ' m' ...
        ' - vitesse : ' num2str(data_in.(participant_name).indice_dev_max_vitesse) ' km/h' ...
        ' - vitesse_bis : ' num2str(data_in.(participant_name).indice_dev_max_vitesse_bis) ' km/h']);
    % display indice_dev_moy informations
    disp([participant_name ...
        ' - indice_dev_moy : ' num2str(data_in.(participant_name).indice_dev_moy) ...
        ' - duree_moy : ' num2str(data_in.(participant_name).duree_moy) ' s' ...
        ' - distance_moy : ' num2str(data_in.(participant_name).distance_moy) ' m' ...
        ' - vitesse_moy : ' num2str(data_in.(participant_name).vitesse_moy) ' km/h' ...
        ' - vitesse_moy_bis : ' num2str(data_in.(participant_name).vitesse_moy_bis) ' km/h']);
    % display indice_dev_std informations
    disp([participant_name ...
        ' - indice_dev_std : ' num2str(data_in.(participant_name).indice_dev_std) ...
        ' - duree_std : ' num2str(data_in.(participant_name).duree_std) ' s' ...
        ' - distance_std : ' num2str(data_in.(participant_name).distance_std) ' m' ...
        ' - vitesse_std : ' num2str(data_in.(participant_name).vitesse_std) ' km/h' ...
        ' - vitesse_std_bis : ' num2str(data_in.(participant_name).vitesse_std_bis) ' km/h']);
    disp('---------------------------------------------------------------------------------------------------------------');
    
    %% CALCULATE AND APPLY FINAL CORRECTION RATIO
    data_in.(participant_name).distance_min = min(data_in.(participant_name).distances(logical(data_in.(participant_name).mask_indices_dev_OK)));
    if ~isempty(strfind(participant_name,'P09'))
        data_in.(participant_name).ratio_correc_finale = 1.11384455247102;
    elseif ~isempty(strfind(participant_name,'P24'))
        data_in.(participant_name).ratio_correc_finale = 1.04924701924759;
    elseif ~isempty(strfind(participant_name,'P13')) || ~isempty(strfind(participant_name,'P18'))
        data_in.(participant_name).ratio_correc_finale = 1.0;
    else
        data_in.(participant_name).ratio_correc_finale = 1+(distance_parcours-(data_in.(participant_name).distance_moy-data_in.(participant_name).distance_std))/data_in.(participant_name).distance_min;
    end
    
    for i_trip = 1:5
        trip_file = trip_files{i_part+i_trip-1};
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        
        if trip.getMetaInformations().existData('distance_pas_x') && trip.getMetaInformations().existDataVariable('distance_pas_x','distance_pas_x_correc')
            timecode = trip.getAllDataOccurences('distance_pas_x').getVariableValues('timecode');
            distance_pas_x = cell2mat(trip.getAllDataOccurences('distance_pas_x').getVariableValues('distance_pas_x_correc'));
            vitesse_pas_x = cell2mat(trip.getAllDataOccurences('vitesse_pas_x').getVariableValues('vitesse_pas_x_correc'));
        elseif trip.getMetaInformations().existData('distance_pas_x') && ~trip.getMetaInformations().existDataVariable('distance_pas_x','distance_pas_x_correc')
            timecode = trip.getAllDataOccurences('distance_pas_x').getVariableValues('timecode');
            distance_pas_x = cell2mat(trip.getAllDataOccurences('distance_pas_x').getVariableValues('distance_pas_x'));
            vitesse_pas_x = cell2mat(trip.getAllDataOccurences('vitesse_pas_x').getVariableValues('vitesse_pas_x'));
        end
        
        distance_pas_x_correc_finale = num2cell(distance_pas_x * data_in.(participant_name).ratio_correc_finale);
        vitesse_pas_x_correc_finale = num2cell(vitesse_pas_x * data_in.(participant_name).ratio_correc_finale);
        
        addDataVariable2Trip(trip,'distance_pas_x','distance_pas_x_correc_finale','REAL','unit','m','comment','distance corrigee manuellement')
        addDataVariable2Trip(trip,'vitesse_pas_x','vitesse_pas_x_correc_finale','REAL','unit','km/h','comment','vitesse corrigee manuellement')
        
        trip.setBatchOfTimeDataVariablePairs('distance_pas_x','distance_pas_x_correc_finale',[timecode(:),distance_pas_x_correc_finale(:)]');
        trip.setBatchOfTimeDataVariablePairs('vitesse_pas_x','vitesse_pas_x_correc_finale',[timecode(:),vitesse_pas_x_correc_finale(:)]');
        
        delete(trip)
        clearvars timecode distance_pas* vitesse_pas*
        
    end
    
    %% INDICES_DEV_MAX INFORMATIONS
    indices_dev_max_sum = indices_dev_max_sum + data_in.(participant_name).indice_dev_max;
    indices_dev_max_duree_sum = indices_dev_max_duree_sum + data_in.(participant_name).indice_dev_max_duree;
    indices_dev_max_distance_sum = indices_dev_max_distance_sum + data_in.(participant_name).indice_dev_max_distance;
    indices_dev_max_vitesse_sum = indices_dev_max_vitesse_sum + data_in.(participant_name).indice_dev_max_vitesse;
    indices_dev_max_vitesse_bis_sum = indices_dev_max_vitesse_bis_sum + indices_dev_max_distance_sum/indices_dev_max_duree_sum*3.6;
    
    %% INDICES_DEV INFORMATIONS
    indices_dev_sum = indices_dev_sum + mean(data_in.(participant_name).indices_dev);
    indices_dev_duree_sum = indices_dev_duree_sum + mean(data_in.(participant_name).durees);
    indices_dev_distance_sum = indices_dev_distance_sum + mean(data_in.(participant_name).distances);
    indices_dev_vitesse_sum = indices_dev_vitesse_sum + mean(data_in.(participant_name).vitesses);
    indices_dev_vitesse_bis_sum = indices_dev_vitesse_bis_sum + indices_dev_distance_sum/indices_dev_duree_sum*3.6;
    
end

%% DISPLAY INDICES_DEV_MAX INFORMATIONS
disp('---------------------------------------------------------------------------------------------------------------');
disp(['indice_dev_max_moy = ' num2str(indices_dev_max_sum/25)]);
disp(['indice_dev_max_duree_moy = ' num2str(indices_dev_max_duree_sum/25) ' s']);
disp(['indice_dev_max_distance_moy = ' num2str(indices_dev_max_distance_sum/25) ' m']);
disp(['indice_dev_max_vitesse_moy = ' num2str(indices_dev_max_vitesse_sum/25) ' km/h']);
disp(['indice_dev_max_vitesse_bis_moy = ' num2str(indices_dev_max_vitesse_bis_sum/25) ' km/h']);
disp('---------------------------------------------------------------------------------------------------------------');

%% DISPLAY INDICES_DEV_MAX INFORMATIONS
disp('---------------------------------------------------------------------------------------------------------------');
disp(['indices_dev_moy = ' num2str(indices_dev_sum/25)]);
disp(['indices_dev_duree_moy = ' num2str(indices_dev_duree_sum/25) ' s']);
disp(['indices_dev_distance_moy = ' num2str(indices_dev_distance_sum/25) ' m']);
disp(['indices_dev_vitesse_moy = ' num2str(indices_dev_vitesse_sum/25) ' km/h']);
disp(['indices_dev_vitesse_bis_moy = ' num2str(indices_dev_vitesse_bis_sum/25) ' km/h']);
disp('---------------------------------------------------------------------------------------------------------------');

end