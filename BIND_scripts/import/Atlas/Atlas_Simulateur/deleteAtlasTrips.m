function deleteAtlasTrips(dir_root,subject_scenario_cell)

    for i = 1:length(subject_scenario_cell)
        % Initialise où on est.
        dossier_sujet = subject_scenario_cell{i,1};
        dossier_sc = subject_scenario_cell{i,2};
        %num_sujet = subject_scenario_cell{i,3};
        %num_scenario = subject_scenario_cell{i,4};
        %type_distraction = subject_scenario_cell{i,5};
        path_trip_dir = [dir_root dossier_sujet filesep dossier_sc filesep];
        trip_file = [path_trip_dir dossier_sc '.trip'];
        
        choice = questdlg(['Êtes-vous sûr de vouloir supprimer le fichier suivant ?\n' trip_file]);
        % Handle response
        switch choice
            case 'Yes'
                disp(['deleting trip' trip_file '...']);
                delete(trip_file);
        end
    end
end