function CapadynHGDataSpecificCorrection(MAIN_FOLDER)
MAIN_FOLDER = 'E:\PROJETS ACTUELS\THESE_CAROLINE\CAPADYN\DONNEES_PARTICIPANTS\TESTS';
trip_files = dirrec(MAIN_FOLDER, '.trip');

tripFiles2Correc = {74, 49, 29}; %74:P12_03DT1SO_20151012_PM | 49:P25_01BASE_20151215_PM | 29
ratioValues2Correc = {1.06,1.10,1.08};

%% LOOP ON TRIP FILES
for i_trip = 1:length(tripFiles2Correc)
    
    trip_file = trip_files{tripFiles2Correc{i_trip}};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    % participant_id = trip_1.getAttribute('id_participant');
    ratio_correc = ratioValues2Correc{i_trip};
    
    % startTimecode = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('startTimecode'));
    % endTimecode = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('endTimecode'));
    % duree_essai = cell2mat(trip.getAllSituationOccurences('essai_complet').getVariableValues('duree'));
    
    timecode = trip.getAllDataOccurences('distance_pas_x').getVariableValues('timecode');
    distance_pas_x = cell2mat(trip.getAllDataOccurences('distance_pas_x').getVariableValues('distance_pas_x'));
    vitesse_pas_x = cell2mat(trip.getAllDataOccurences('vitesse_pas_x').getVariableValues('vitesse_pas_x'));
    % mask_distance_pas = find(diff(distance_pas_x));
    
    distance_pas_x_correc = num2cell(distance_pas_x * ratio_correc);
    vitesse_pas_x_correc = num2cell(vitesse_pas_x * ratio_correc);
    
    addDataVariable2Trip(trip,'distance_pas_x','distance_pas_x_correc','REAL','unit','m','comment','distance corrigee manuellement')
    addDataVariable2Trip(trip,'vitesse_pas_x','vitesse_pas_x_correc','REAL','unit','km/h','comment','vitesse corrigee manuellement')
    
    trip.setBatchOfTimeDataVariablePairs('distance_pas_x','distance_pas_x_correc',[timecode(:),distance_pas_x_correc(:)]');
    trip.setBatchOfTimeDataVariablePairs('vitesse_pas_x','vitesse_pas_x_correc',[timecode(:),vitesse_pas_x_correc(:)]');
    
    % data_in.(participant_id).duree_essai = duree_essai;
    % data_in.(participant_id).distance_pas_x = sum([distance_pas_x(mask_distance_pas),distance_pas_x(end)]);
    % data_in.(participant_id).vitesse_pas_x = mean([vitesse_pas_x(mask_distance_pas),vitesse_pas_x(end)]);
    % data_in.(participant_id).distance_pas_x_bis = sum([distance_pas_x_bis(mask_distance_pas),distance_pas_x_bis(end)]);
    % data_in.(participant_id).vitesse_pas_x_bis = mean([vitesse_pas_x_bis(mask_distance_pas),vitesse_pas_x_bis(end)]);
    
    delete(trip)
    clearvars timecode distance_pas* vitesse_pas*
    
end
end