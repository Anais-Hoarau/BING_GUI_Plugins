function BatchIndicatorsCapachien(MAIN_FOLDER)
MAIN_FOLDER = 'E:\PROJETS ACTUELS\THESE_CAROLINE\CAPACHIEN\Participant\TEST';
trip_list = dirrec(MAIN_FOLDER, '.trip');

%% CALCULATE INDICATORS
for i_trip = 1:length(trip_list)
    
    trip_file = trip_list{i_trip};
    reg_file = regexp(trip_file, '\');
    trip_name = trip_file(reg_file(end)+1:end);
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
%     scenario_id = trip.getAttribute('id_scenario');
    
%     if strcmp(scenario_id,'EXPERIMENTAL')
%         scenario_case = 'EXP';
%         %uncomment this 3 lines to calculate again
% %         trip.setAttribute('add_events','');
% %         trip.setAttribute('add_situations','');
% %         trip.setAttribute('add_indicators','');
%     end
    
    disp(['Vérification du fichier "' trip_name '"...'])
    add_indicators_needed = ~check_trip_meta(trip, 'add_indicators','OK');
    delete(trip);
    
    try
        disp(['------------------------------------ ' trip_name ' ------------------------------------']);
        
        if add_indicators_needed
            CapachienAddIndicators(trip_file);
        end
        
    catch ME
        disp('Error caught, logging and skipping to next file');
        log = fopen('BatchIndicatorsCapadyn.log', 'a+');
        fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' trip_name]);
        fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
        fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
        fclose(log);
    end
end
disp([num2str(length(trip_list)) ' trips traités.'])
end