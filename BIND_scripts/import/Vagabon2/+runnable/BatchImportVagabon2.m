function BatchImportVagabon2()
%% PARTICIPANT FOLDERS LIST

MAIN_FOLDER = 'W:\PROJETS ACTUELS\THESE_GUILLAUME\VAGABON\VAGABON2\DONNEES_PARTICIPANTS\TESTS';
CONFIG_FOLDER = [MAIN_FOLDER '\@FICHIERS_CONFIG'];

folders_list = dir(MAIN_FOLDER);
folders_list = {folders_list(5:end).name};

file_id = fopen([CONFIG_FOLDER '\VAGABON2_FOLDERS.tsv'], 'w');
fprintf(file_id, '%s\n', MAIN_FOLDER, CONFIG_FOLDER, folders_list{:});

%% LOOP ON FOLDERS

i_trip = 0;
for i = 18 %1:1:length(folders_list)
    % check folder and create full directory by group
    if isdir([MAIN_FOLDER filesep folders_list{i}]) && isempty(strfind(folders_list{i}, '@'))
        full_directory = [MAIN_FOLDER filesep folders_list{i}];
        groupe_id = 'ALL';
    else
        disp(['"' folders_list{i} '" ne sera pas pris en compte : nom de dossier non conforme ou nom de fichier ...'])
        continue
    end
    
    % identify participant (ex : C01)
    reg_directory = regexp(full_directory,'\');
    participant_id = full_directory(reg_directory(end)+1:end);
    reg_participant = regexp(participant_id, '_');
    participant_name = participant_id(1:reg_participant(1)-1);
    
    % identify scenario (ex : EXP)
    if strfind(participant_id, 'BL')~=0
        scenario_id = 'BASELINE';
        scenario_case = '01BL';
    elseif strfind(participant_id, 'SO')~=0
        scenario_id = 'SANS_OBSTACLE';
        scenario_case = '02SO';
    elseif strfind(participant_id, 'AO')~=0
        scenario_id = 'AVEC_OBSTACLE';
        scenario_case = '03AO';
    end
    
    % identify date and time
    scenario_start_date = participant_id(strfind(participant_id, '2016'):strfind(participant_id, '2016')+7);
    scenario_start_time = participant_id(strfind(participant_id, '2016')+9:strfind(participant_id, '2016')+12);
    
    % identify needed files names
    trip_name = [participant_id '.trip'];
    simu_var_name = [participant_id '_Simu_Data.var'];
    simu_xml_name = ['VAGABON2_' scenario_case '_Simu_Data_Mapping.xml'];
    tobii_var_name = [participant_id '_Tobii_Data.tsv'];
    tobii_xml_name = ['VAGABON2_' scenario_case '_Tobii_Data_Mapping.xml'];
    MP150_mat_name = [participant_id '_Physio_MP150.mat'];
    
    % identify needed files full directories
    trip_file = [full_directory filesep trip_name];
    simu_var_file = [full_directory filesep simu_var_name];
    simu_xml_file = [CONFIG_FOLDER filesep 'FICHIERS_XML' filesep simu_xml_name];
    tobii_var_file = [full_directory filesep tobii_var_name];
    tobii_xml_file = [CONFIG_FOLDER filesep 'FICHIERS_XML' filesep tobii_xml_name];
    MP150_mat_file = [full_directory filesep MP150_mat_name];
    
    %% TRIP FILE CREATION
    
    if ~exist(trip_file, 'file')
        disp(['Cr?ation du fichier trip : "' trip_name '"...' ])
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        trip.setAttribute('MAIN_FOLDER', MAIN_FOLDER);
        trip.setAttribute('CONFIGURATION_FOLDER', CONFIG_FOLDER);
        trip.setAttribute('id_participant', participant_name);
        trip.setAttribute('id_groupe', groupe_id);
        trip.setAttribute('id_scenario', scenario_id);
        trip.setAttribute('session_date', scenario_start_date);
        trip.setAttribute('session_time', scenario_start_time);
        trip.setAttribute('import_tobii', '');
        trip.setAttribute('import_simu', '');
        trip.setAttribute('import_cardio', '');
        trip.setAttribute('import_videos', '');
        trip.setAttribute('add_events', '');
        trip.setAttribute('add_situations', '');
        trip.setAttribute('add_indicators', '');
        trip.setAttribute('deltaTC_ref', '');
        trip.setAttribute('calculate_fixite_regard', '');
        delete(trip);
    else
        disp(['Le fichier "' trip_name '" est d?j? pr?sent dans le dossier...' ])
    end
    
    disp(['V?rification du fichier "' trip_name '"...' ])
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    import_tobii_needed = ~check_trip_meta(trip,'import_tobii','OK');
    import_simu_needed = ~check_trip_meta(trip,'import_simu','OK');
    import_cardio_needed = ~check_trip_meta(trip,'import_cardio','OK');
    import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
    calculate_fixite_regard = ~check_trip_meta(trip,'calculate_fixite_regard','OK');
    delete(trip);
    
    %% IMPORT TOBII DATA TO THE TRIP FILE
    if import_tobii_needed
        if ~exist(tobii_var_file, 'file')
            disp(['Le fichier "' tobii_var_name '" est absent du dossier...'])
        elseif ~exist(tobii_xml_file, 'file')
            disp(['Le fichier "' tobii_xml_file '" est absent du dossier...'])
        else
            disp('Import des donn?es oculom?triques...')
            Vagabon2_TOBII2BIND(tobii_xml_file, tobii_var_file, full_directory, trip_file)
        end
    else
        disp('Les donn?es oculom?triques ont d?j? ?t? import?es...')
    end
    
    %% IMPORT SIMU DATA TO THE TRIP FILE
    if import_simu_needed
        if ~exist(simu_var_file, 'file')
            disp(['Le fichier "' simu_var_name '" est absent du dossier...'])
            continue
        elseif ~exist(simu_xml_file, 'file')
            disp(['Le fichier "' simu_xml_file '" est absent du dossier...'])
            continue
        else
            disp('Import des donn?es du simulateur...')
            Vagabon2_VAR2BIND(simu_xml_file, simu_var_file, full_directory, trip_file)
        end
    else
        disp('Les donn?es du simulateur ont d?j? ?t? import?es...')
    end
    
    %% IMPORT CARDIAC DATA TO THE TRIP
    if import_cardio_needed
        if ~exist(MP150_mat_file, 'file')
            disp(['Le fichier "' MP150_mat_file '" est absent du dossier...'])
            continue
        else
            disp('Import des donn?es cardiaques...')
            SaveTrip(full_directory);
            Vagabon2_import_MP150_2bind(MP150_mat_file, trip_file, participant_id)
        end
    else
        disp('Les donn?es cardiaques ont d?j? ?t? import?es...')
    end
    
    %% ADD VIDEO LINKS TO THE TRIP
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    if exist([full_directory filesep 'clap.txt'], 'file')
        convertVideo2MJPEG_alone(full_directory);         % convert simulator video if necessary
        if import_videos_needed
            disp('V?rification des fichiers vid?o et cr?ation des liens...')
            video_files = find_file_with_extension([full_directory filesep],'.avi');
            for i_video = 1:1:length(video_files)
                video_path = video_files{i_video};
                [~, video_name, video_ext] = fileparts(video_path);
                video_file = ['.' filesep video_name video_ext];
                REG_video = regexp(video_file,'_');
                video_description = video_file(REG_video(end-2)+1:REG_video(end)-1);
                metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,0.72,video_description); % -5 corresponds to the video offset
                trip.addVideoFile(metaVideo);
            end
            trip.setAttribute('import_videos','OK');
        end
    else
        disp('Attention, pas de fichier clap, la vid?o du simulateur ne sera pas synchronis?e, ni ajout?e...')
        trip.setAttribute('import_videos','');
    end
    delete(trip);
    i_trip = i_trip+1;
    
    %% CALCUL FIXITES REGARD
    if calculate_fixite_regard
        disp(['Calcule de la fixit? du regard pour le fichier : "' trip_name '"...'])
        Vagabon2FixiteRegard(trip_file)
    end
    
end
disp([num2str(i_trip) ' trips g?n?r?s.'])

%% ADD EVENTS, SITUATIONS AND INDICATORS
runnable.BatchIndicatorsVagabon2(MAIN_FOLDER)

% %% EXPORT SITUATIONS DATAS TO TSV FILE
% runnable.batchExportData2TSV_VAGABON2(MAIN_FOLDER)
% runnable.batchExportSituationTSV_VAGABON2(MAIN_FOLDER)

end