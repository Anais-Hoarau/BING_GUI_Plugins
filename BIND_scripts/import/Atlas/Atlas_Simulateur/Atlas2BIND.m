function Atlas2BIND(varFile, num_scenario)
    mappingFile = ['mapping_' num_scenario '.xml'];
    disp(['Processing file ' varFile '...']);
    [varPath, varName, ~] = fileparts(varFile);

    tripFile = [varPath '/' varName '.trip'];

    if exist(tripFile, 'file')
        delete(tripFile);
    end

    fixHeaders(varFile, num_scenario);
    try
        LEPSIS2BIND(mappingFile, varFile, varPath);
    catch ME
        % If an error occured: write info about it in the meta attributes
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile, 0.04, true);
        trip.setAttribute('import_trip','failed');
        rethrow(ME) % rethrow for logging
    end
    
%    addPOIFromXLS(tripFile, ['./POI/POIS' scenario '.xls']);
end