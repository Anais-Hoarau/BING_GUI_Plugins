function MagicBatchImportAtlas(dir_root,subject_scenario_cell)

    % TODO: log importation time

    previous_path = pwd;
    cd(dir_root);
    log_csv = fopen('LogImportAtlas.csv', 'a+');
    
    log_write(log_csv, 'Sujet', 'Scenario', 'DistractionType', 'VAR', 'VAR infos', 'VIDEO', 'VIDEO infos', 'CARDIO', 'CARDIO infos', 'TRIP_CONVERSTION_TIME');
    
    % On boucle sur les scenarios
    for i = 1:length(subject_scenario_cell)
        % Initialise où on est.
        dossier_sujet = subject_scenario_cell{i,1};
        dossier_sc = subject_scenario_cell{i,2};
        num_sujet = subject_scenario_cell{i,3};
        num_scenario = subject_scenario_cell{i,4};
        type_distraction = subject_scenario_cell{i,5};
        path_trip_dir = [dir_root dossier_sujet filesep dossier_sc filesep];
        trip_file = [path_trip_dir dossier_sc '.trip'];
        disp(['Sujet ' num_sujet ', scenario ' num_scenario ' :']);
%         lg_var =  '';
%         lg_video =  '';
%         lg_cardio =  '';
%         lg_time = '';
         
        % open the trip (create the trip if it doesn't exist)
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        % 
        [proc_var, lg_time, lg_var] = magic_process('test_magic_import_var',trip,path_trip_dir,trip_file,num_sujet,num_scenario,type_distraction);
        [proc_video, ~, lg_video] = magic_process('test_magic_import_video',trip,path_trip_dir);
        [proc_cardio, ~, lg_cardio] = magic_process('test_magic_import_cardio',trip,dir_root,dossier_sujet,num_sujet);

        delete(trip)

        log_write(log_csv, num_sujet, num_scenario, type_distraction, proc_var, lg_var, proc_video, lg_video, proc_cardio, lg_cardio, lg_time);
    end
    fclose(log_csv);

    % go back to previous path
    cd(previous_path);
end