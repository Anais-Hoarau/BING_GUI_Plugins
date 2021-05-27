function BatchImportRCE2()
%% SPECIFY FOLDERS AND PARTICIPANT FOLDERS LIST

MAIN_FOLDER = '\\vrlescot.ifsttar.fr\DKLESCOT\PROJETS ACTUELS\THESE_GUILLAUME\RCE2\DONNEES_PARTICIPANTS\TESTS';
CONFIG_FOLDER = [MAIN_FOLDER '\FICHIERS_CONFIG'];

folders_list_flowMoins = dir([MAIN_FOLDER '\GROUPE_FLOW-']);
folders_list_flowPlus = dir([MAIN_FOLDER '\GROUPE_FLOW+']);
folders_list = {folders_list_flowMoins(3:end).name, folders_list_flowPlus(3:end).name};

file_id = fopen([CONFIG_FOLDER '\RCE2_FOLDERS.tsv'], 'w');
fprintf(file_id, '%s\n', MAIN_FOLDER, CONFIG_FOLDER, folders_list{:});

%% LOOP ON FOLDERS

i_trip = 0;
for i_folder = 1:1:length(folders_list)
    % check folder and create full directory by group
    if isdir([MAIN_FOLDER '\GROUPE_FLOW-\' folders_list{i_folder}]) && strncmp(folders_list{i_folder}, 'P',1)~=0
        participant_folder = [MAIN_FOLDER '\GROUPE_FLOW-\' folders_list{i_folder}];
        groupe_id = 'Flow-';
    elseif isdir([MAIN_FOLDER '\GROUPE_FLOW+\' folders_list{i_folder}]) && strncmp(folders_list{i_folder}, 'P',1)~=0
        participant_folder = [MAIN_FOLDER '\GROUPE_FLOW+\' folders_list{i_folder}];
        groupe_id = 'Flow+';
    else
        disp(['"' folders_list{i_folder} '" ne sera pas pris en compte : nom de dossier non conforme ou nom de fichier ...'])
        continue
    end
    
    var_files = dirrec(participant_folder, '.var');
    
    for i_var = 1:length(var_files)
        %% IDENTIFY EACH SESSION
        
        % identify participant and scenario (ex : C01)
        reg_directory = regexp(var_files{i_var},'\');
        full_directory = var_files{i_var}(1:reg_directory(end)-1);
        session_id = var_files{i_var}(reg_directory(end)+1:end-4);
        reg_session = regexp(session_id, '_');
        participant_id = session_id(1:reg_session(1)-1);
        scenario_id = session_id(reg_session(1)+1:reg_session(2)-1);

        if strcmp(scenario_id,'PILAUT')
            scenario_case = 'PILAUT';
        else
            scenario_case = 'AUDVSP';
        end
        
        % identify date and time
        scenario_start_date = session_id(reg_session(end)+1:reg_session(end)+4);
        scenario_start_time = session_id(reg_session(end)+5:reg_session(end)+8);
        
        % identify needed files names
        trip_name = [session_id '.trip'];
        simu_var_name = [session_id '.var'];
        simu_xml_name = ['RCE2_' scenario_case '_Simu_Data_Mapping.xml'];
        MP150_mat_name = [session_id '_MP150.mat'];
        
        % identify needed files full directories
        trip_file = [full_directory filesep trip_name];
        simu_var_file = [full_directory filesep simu_var_name];
        simu_xml_file = [CONFIG_FOLDER '\FICHIERS_XML\' simu_xml_name];
        MP150_mat_file = [full_directory filesep MP150_mat_name];
        
        %% TRIP FILE CREATION
        
        if ~exist(trip_file, 'file')
            disp(['Création du fichier trip : "' trip_name '"...' ])
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
            trip.setAttribute('trip_name', trip_name);
            trip.setAttribute('id_participant', participant_id);
            trip.setAttribute('id_groupe', groupe_id);
            trip.setAttribute('id_scenario', scenario_id);
            trip.setAttribute('session_date', scenario_start_date);
            trip.setAttribute('session_time', scenario_start_time);
            trip.setAttribute('main_folder', MAIN_FOLDER);
            trip.setAttribute('configuration_folder', CONFIG_FOLDER);
            trip.setAttribute('import_simu', '');
            trip.setAttribute('import_cardio', '');
            trip.setAttribute('import_videos', '');
            trip.setAttribute('add_events', '');
            trip.setAttribute('add_situations', '');
            trip.setAttribute('add_indicators', '');
            trip.setAttribute('deltaTC_ref', '');
            delete(trip);
        else
            disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
        end
        
        disp(['Vérification du fichier "' trip_name '"...' ])
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        trip.setAttribute('trip_name', trip_name);
        import_simu_needed = ~check_trip_meta(trip,'import_simu','OK');
        import_cardio_needed = ~check_trip_meta(trip,'import_cardio','OK');
        import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
        delete(trip);
        
        %% IMPORT SIMU DATA TO THE TRIP FILE
        if import_simu_needed
            info_var_file = dir(simu_var_file);
            if ~exist(simu_var_file, 'file')
                disp(['Le fichier "' simu_var_name '" est absent du dossier...'])
                continue
            elseif ~exist(simu_xml_file, 'file')
                disp(['Le fichier "' simu_xml_file '" est absent du dossier...'])
                continue
            elseif exist(simu_var_file, 'file') && exist(simu_xml_file, 'file') && info_var_file.bytes ~= 0
                disp('Import des données du simulateur...')
                RCE2_VAR2BIND(simu_xml_file, simu_var_file, full_directory, trip_file)
            end
        else
            disp('Les données du simulateur ont déjà été importées...')
        end
        
        %% IMPORT CARDIAC DATA TO THE TRIP
        if import_cardio_needed
            disp('Import des données cardiques...')
            RCE2_import_MP150_2bind(MP150_mat_file, trip_file, participant_id)
        else
            disp('Les données cardiaques ont déjà été importées...')
        end
        
        %% ADD VIDEO LINKS TO THE TRIP
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        if exist([full_directory 'clap.txt'], 'file')
            convertVideo2MJPEG_alone(full_directory)                                % convert simulator video if necessary
            if import_videos_needed
                disp('Vérification des fichiers vidéo et création des liens...')
                video_files = find_file_with_extension([full_directory filesep],'.avi');
                for i_video = 1:1:length(video_files)
                    video_path = video_files{i_video};
                    [~, video_name, video_ext] = fileparts(video_path);
                    video_file = ['.' filesep video_name video_ext];
                    REG_video = regexp(video_file,'_');
                    video_description = video_file(REG_video(end-2)+1:REG_video(end)-1);
                    metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,-5,video_description); % -5 correspond to the video offset
                    trip.addVideoFile(metaVideo);
                end
                trip.setAttribute('import_videos','OK');
            end
        else
            disp('Attention, pas de fichier clap, la vidéo du simulateur ne sera pas synchronisée, ni ajoutée...')
            trip.setAttribute('import_videos','');
        end
        delete(trip);
        i_trip = i_trip+1;
        
    end
end
disp([num2str(i_trip) ' trips générés.'])

%% ADD EVENTS, SITUATIONS AND INDICATORS
%runnable.BatchIndicatorsRCE2(MAIN_FOLDER)

%% EXPORT SITUATIONS DATAS TO TSV FILE
%runnable.batchExportTSV(MAIN_FOLDER)

end