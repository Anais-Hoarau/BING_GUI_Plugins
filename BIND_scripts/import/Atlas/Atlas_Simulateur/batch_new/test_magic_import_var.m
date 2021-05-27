function out = test_magic_import_var(trip,path_trip_dir,trip_file,num_sujet,num_scenario,type_distraction)

    disp('Looking for var files...');
    var_files = find_file_with_extension(path_trip_dir,'.var');
    if length(var_files) < 1
        % Pas de fichier VAR
        out = 'No file';
        disp('No var file found');
    elseif length(var_files) > 1
        % Plusieurs fichiers VAR
        out = [num2str(length(var_files)) ' files'];
        disp([num2str(length(var_files))  'var files found']);
    else
        % Si un seul VAR, converti le TRIP
        var_file = var_files{1};
        disp('var file found');

        disp('creating the trip file');
        tic_trip_conv = tic;
        Atlas2BIND(var_file, num_scenario);
        initMeta(trip_file,num_sujet,num_scenario,type_distraction,tic_trip_conv); % now trip_file is a file;
        toc(tic_trip_conv) % for display
        % LOG: trip OK
        out = 'Ok';
        disp('trip file was created');                    
    end
    
end