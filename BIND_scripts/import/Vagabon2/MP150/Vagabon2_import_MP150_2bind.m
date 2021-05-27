function Vagabon2_import_MP150_2bind(MP150_mat_file, trip_file, participant_name)
try
    
    %Import and syncing MP150 data
    vagabon2.(participant_name).MP150 = import_MP150_struct_simu(MP150_mat_file);
    [vagabon2.(participant_name).MP150, IDs_tops] = sync_MP150_simu(vagabon2.(participant_name).MP150, trip_file, 'data', 'triggerSync');
    struct_MP150 = vagabon2.(participant_name).MP150;
    
    %Adding MP150 data to the trip file
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    removeDataTables(trip,{'MP150_data'})
    import_data_struct_in_bind_trip_MP150_2Simax(struct_MP150, trip, 'MP150', IDs_tops);
    trip.setAttribute('import_cardio', 'OK');
    delete(trip);
    
catch ME
    disp(['error with : ' trip_file]);
    disp('Error caught, logging and skipping to next file');
    log = fopen('vagabon2_import_MP150_2bind.log', 'a+');
    fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' trip_file]);
    fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
    fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
    fclose(log);
end
end