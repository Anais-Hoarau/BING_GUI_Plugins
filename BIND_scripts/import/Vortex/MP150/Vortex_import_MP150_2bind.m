function Vortex_import_MP150_2bind(MP150_mat_file, trip_file, participant_name, vars)
try
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);

    
    %Import and syncing MP150 data
    vortex.(participant_name).MP150 = import_MP150_struct_simu(MP150_mat_file, vars);
    if check_trip_meta(trip,'id_scenario', 'EXPERIMENTAL')
        [vortex.(participant_name).MP150, IDs_tops] = Vortex_sync_MP150_simu(vortex.(participant_name).MP150, trip_file, 'data', 'triggerStop');
    else
        [vortex.(participant_name).MP150] = sync_MP150_alone(vortex.(participant_name).MP150, 'data');
    end
    struct_MP150 = vortex.(participant_name).MP150;
    
    %Adding MP150 data to the trip file
    removeDataTables(trip,{'MP150_data'})
    if check_trip_meta(trip,'id_scenario', 'EXPERIMENTAL')
        import_data_struct_in_bind_trip_MP150_2Simax(struct_MP150, trip, 'MP150', IDs_tops);
    else
        import_data_struct_in_bind_trip(struct_MP150, trip, 'MP150');
    end
    trip.setAttribute('import_cardio', 'OK');
    delete(trip);
    
catch ME
    disp(['error with : ' trip_file]);
    disp('Error caught, logging and skipping to next file');
    log = fopen('vortex_import_MP150_2bind.log', 'a+');
    fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' trip_file]);
    fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
    fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
    fclose(log);
end
end