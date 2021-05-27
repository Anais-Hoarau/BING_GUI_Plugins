function BatchImportVortex()
%% PARTICIPANT FOLDERS LIST

MAIN_FOLDER = '\\vrlescot\THESE_GUILLAUME\VORTEX\Data\TESTS';
CONFIG_FOLDER = [MAIN_FOLDER '\~FICHIERS_CONFIG'];

folders_list = dir([MAIN_FOLDER '/**/*.acq']);

% file_id = fopen([CONFIG_FOLDER '\VORTEX_FOLDERS.tsv'], 'w');
% fprintf(file_id, '%s\n', MAIN_FOLDER, CONFIG_FOLDER, folders_list{:});

%% LOOP ON FOLDERS

i_trip = 0;
parfor i = 1:length(folders_list)
    % check folder and create full directory by group
    if ~contains(folders_list(i).folder(1), '~')
        full_directory = folders_list(i).folder;
        groupe_id = '';
    else
        disp(['"' folders_list(i).folder '" ne sera pas pris en compte : dossier ignoré.'])
        continue
    end
    
    % identify participant (ex : C01)
    reg_directory = regexp(full_directory,'\');
    participant_id = folders_list(i).name(1:end-4);
    participant_name = full_directory(reg_directory(end-1)+1:reg_directory(end)-1);
    
    % identify scenario (ex : EXP)
    if contains(full_directory, 'BL')~=0
        scenario_id = 'BASELINE';
        scenario_case = '01BL';
        continue
    else
        scenario_id = 'EXPERIMENTAL';
        scenario_case = '02EXP';
    end
    
    % identify date and time
    date_time = strsplit(strrep(folders_list(i).date,'.',''));
    scenario_start_date = date_time{1};
    scenario_start_time = date_time{2};
    
    % identify needed files names
    trip_name = [folders_list(i).name(1:end-4) '.trip'];
    simu_var_name = [folders_list(i).name(1:end-4) '.var'];
    simu_xml_name = ['VORTEX_' scenario_case '_Simu_Data_Mapping.xml'];
    MP150_mat_name = [folders_list(i).name(1:end-4) '.mat'];
    
    % identify needed files full directories
    trip_file = [full_directory filesep trip_name];
    simu_var_file = [full_directory filesep simu_var_name];
    simu_xml_file = [CONFIG_FOLDER filesep 'FICHIERS_XML' filesep simu_xml_name];
    MP150_mat_file = [full_directory filesep MP150_mat_name];
    
    %% TRIP FILE CREATION
    
    if ~exist(trip_file, 'file')
        disp(['Création du fichier trip : "' trip_name '"...' ])
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        trip.setAttribute('MAIN_FOLDER', MAIN_FOLDER);
        trip.setAttribute('CONFIGURATION_FOLDER', CONFIG_FOLDER);
        trip.setAttribute('id_participant', participant_name);
        trip.setAttribute('id_groupe', groupe_id);
        trip.setAttribute('id_scenario', scenario_id);
        trip.setAttribute('session_date', scenario_start_date);
        trip.setAttribute('session_time', scenario_start_time);
        trip.setAttribute('import_simu', '');
        trip.setAttribute('import_cardio', '');
        trip.setAttribute('add_events', '');
        trip.setAttribute('add_situations', '');
        trip.setAttribute('add_indicators', '');
        trip.setAttribute('deltaTC_ref', '');
        trip.setAttribute('add_comments2Events', '');
        delete(trip);
    else
        disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
%         trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
%         trip.setAttribute('add_comments2Events', '');
%         delete(trip);
    end
    
    disp(['Vérification du fichier "' trip_name '"...' ])
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    import_simu_needed = ~check_trip_meta(trip,'import_simu','OK');
    import_cardio_needed = ~check_trip_meta(trip,'import_cardio','OK');
    add_comments2Events_needed = ~check_trip_meta(trip,'add_comments2Events','OK');
    delete(trip);
    
    import_cardio_needed = 1;

    %% IMPORT SIMU DATA TO THE TRIP FILE
    if import_simu_needed
        if ~exist(simu_var_file, 'file')
            disp(['Le fichier "' simu_var_name '" est absent du dossier...'])
            continue
        elseif ~exist(simu_xml_file, 'file')
            disp(['Le fichier "' simu_xml_file '" est absent du dossier...'])
            continue
        else
            disp('Import des données du simulateur...')
            Vortex_VAR2BIND(simu_xml_file, simu_var_file, full_directory, trip_file)
        end
    else
        disp('Les données du simulateur ont déjà été importées...')
    end
    
    %% IMPORT CARDIAC DATA TO THE TRIP
    if import_cardio_needed
        if ~exist(MP150_mat_file, 'file')
            disp(['Le fichier "' MP150_mat_file '" est absent du dossier...'])
            continue
        else
            if contains(scenario_case, 'BL')
                vars = {'Respiration', '', 'EDA', 'Cardiaque', 'triggerStop', 'triggerPedale', '', 'Cardiaque_filtre'};
            elseif contains(scenario_case, 'EXP')
                vars = {'Respiration', '', '', 'Cardiaque', 'triggerStop', 'triggerPedale', '', 'Cardiaque_filtre'};
            end
            disp('Import des données cardiaques...')
            Vortex_import_MP150_2bind(MP150_mat_file, trip_file, participant_id, vars)
        end
    else
        disp('Les données cardiaques ont déjà été importées...')
    end
    
    %% ADD SIMU COMMENT AS EVENT
    if add_comments2Events_needed
        addComments2Events(trip_file, 'variables_simulateur', 'commentaires')
    end
    
end
disp([num2str(i_trip) ' trips générés.'])

%% ADD EVENTS, SITUATIONS AND INDICATORS
% runnable.BatchIndicatorsVortex(MAIN_FOLDER)

% %% EXPORT SITUATIONS DATAS TO TSV FILE
% runnable.batchExportData2TSV_VORTEX(MAIN_FOLDER)
% runnable.batchExportSituationTSV_VORTEX(MAIN_FOLDER)

end