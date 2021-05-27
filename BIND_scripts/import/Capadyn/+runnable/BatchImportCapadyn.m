function BatchImportCapadyn()
%% PARTICIPANT FOLDERS LIST

MAIN_FOLDER = '\\vrlescot\DKLESCOT\PROJETS ACTUELS\THESE_CAROLINE\CAPADYN\DONNEES_PARTICIPANTS\TESTS';

folders_list_ages = dir([MAIN_FOLDER '\GROUPE_AGES']);
folders_list_prec = dir([MAIN_FOLDER '\GROUPE_PREC']);
folders_list_tard = dir([MAIN_FOLDER '\GROUPE_TARD']);
folders_list = {folders_list_ages(3:end).name, folders_list_prec(3:end).name, folders_list_tard(3:end).name};
nb_errors = 0;
nb_stim = {};
i_dt = 0;

for i = 1:1:length(folders_list)
    % check folder and create full directory by group
    if isdir([MAIN_FOLDER '\GROUPE_AGES\' folders_list{i}]) && isempty(strfind(folders_list{i}, '@'))
        full_directory = [MAIN_FOLDER '\GROUPE_AGES\' folders_list{i}];
        groupe_id = 'GROUPE_AGES';
    elseif isdir([MAIN_FOLDER '\GROUPE_PREC\' folders_list{i}]) && isempty(strfind(folders_list{i}, '@'))
        full_directory = [MAIN_FOLDER '\GROUPE_PREC\' folders_list{i}];
        groupe_id = 'GROUPE_PREC';
    elseif isdir([MAIN_FOLDER '\GROUPE_TARD\' folders_list{i}]) && isempty(strfind(folders_list{i}, '@'))
        full_directory = [MAIN_FOLDER '\GROUPE_TARD\' folders_list{i}];
        groupe_id = 'GROUPE_TARD';
    else
        disp(['"' folders_list{i} '" ne sera pas pris en compte : nom de dossier non conforme ou nom de fichier ...'])
        continue
    end
    
    % identify participant (ex : C01)
    reg_directory = regexp(full_directory,'\');
    participant_id = full_directory(reg_directory(end)+1:end);
    
    % identify scenario (ex : EXP)
    reg_partID = regexp(participant_id,'_');
    scenario_id = participant_id(reg_partID(1)+3:reg_partID(2)-1);
    
    % identify needed files names
    trip_name = [participant_id '.trip'];
    data_name = [participant_id '.mat'];
    
    % identify needed files full directories
    trip_file = [full_directory filesep trip_name];
    data_file = [full_directory filesep data_name];
    
    %% TRIP FILE CREATION
    
    if ~exist(trip_file, 'file')
        disp(['Création du fichier trip : "' trip_name '"...' ])
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        trip.setAttribute('MAIN_FOLDER', MAIN_FOLDER);
        trip.setAttribute('SESSION_FOLDER', full_directory);
        trip.setAttribute('id_participant', participant_id);
        trip.setAttribute('id_scenario', scenario_id);
        trip.setAttribute('id_groupe', groupe_id);
        trip.setAttribute('format_data', '');
        trip.setAttribute('correct_data', '');
        trip.setAttribute('import_data', '');
        trip.setAttribute('import_videos', '');
        trip.setAttribute('import_timecode', '');
        trip.setAttribute('import_stim', '');
        trip.setAttribute('import_audio_stim_data', '');
        trip.setAttribute('import_audio_all_data', '');
        trip.setAttribute('correct_TC_situations', '');
        trip.setAttribute('import_DT_results', '');
        trip.setAttribute('import_Categ_Stim', '');
        trip.setAttribute('import_table_cond', '');
        trip.setAttribute('add_indicators', '');
        delete(trip);
    else
        disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
    end
    
    disp(['Vérification du fichier "' trip_name '"...' ])
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    format_data_needed = ~check_trip_meta(trip,'format_data','OK');
    correct_data_needed = ~check_trip_meta(trip,'correct_data','OK');
    import_data_needed = ~check_trip_meta(trip,'import_data','OK');
    import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
    import_timecode_needed = ~check_trip_meta(trip,'import_timecode','OK');
    import_stim_needed = ~check_trip_meta(trip,'import_stim','OK');
    correct_TC_situations_needed = ~check_trip_meta(trip,'correct_TC_situations','OK');
    import_audio_stim_data_needed = ~check_trip_meta(trip,'import_audio_stim_data','OK');
    import_audio_all_data_needed = ~check_trip_meta(trip,'import_audio_all_data','OK');
    import_DT_results_needed = ~check_trip_meta(trip,'import_DT_results','OK');
    import_Categ_Stim_needed = ~check_trip_meta(trip,'import_Categ_Stim','OK');
    import_table_cond_needed = ~check_trip_meta(trip,'import_table_cond','OK');
    add_indicators_needed = ~check_trip_meta(trip, 'add_indicators','OK');
    delete(trip);
    
    %% FORMAT BINARY DATA FILE TO MAT DATA FILE
    format_data_needed = 0;
    if format_data_needed
        SaveFile(full_directory, '.mat')
        nom_fichier = dirrec(full_directory, '.BIN');
        if isempty(nom_fichier)
            disp(['Le fichier "' nom_fichier '" est absent du dossier...'])
        else
            formater_data_tout_data_uwb(nom_fichier{:}, data_file);
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
            trip.setAttribute('format_data', 'OK');
            delete(trip);
        end
    else
        disp('Les données ont déjà été formatées...')
    end
    
    %% CORRECT DISTANCES IN MAT FILE
	correct_data_needed = 0;
    if correct_data_needed
        if ~exist(data_file, 'file')
            disp(['Le fichier "' data_name '" est absent du dossier...'])
        else
            SaveFile(full_directory, '.mat')
            disp('Correction des données en cours...')
            runnable.CapadynHGDataCorrection(data_file)
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
            trip.setAttribute('correct_data', 'OK');
            delete(trip);
        end
    else
        disp('Les données ont déjà été importées...')
    end
    
    %% IMPORT DATA TO THE TRIP FILE
    import_data_needed = 0;
    if import_data_needed
        if ~exist(data_file, 'file')
            disp(['Le fichier "' data_name '" est absent du dossier...'])
        else
            disp('Import des données en cours...')
            SaveTrip(full_directory);
            [data_file_timecoded] = CapadynAddTimecode(data_file,1);
            struct_matlab = CapadynImportMatlabFiles(data_file_timecoded);
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
            import_data_struct_in_bind_trip(struct_matlab, trip, '');
            trip.setAttribute('import_data', 'OK');
            delete(trip);
        end
    else
        disp('Les données ont déjà été importées...')
    end
    
    %% ADD VIDEO LINKS TO THE TRIP
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    convertVideo2MJPEG_alone_withoutClap(full_directory)
    if import_videos_needed
        disp('Vérification des fichiers vidéo et création des liens...')
        video_files = find_file_with_extension([full_directory filesep],'.avi');
        for i_video = 1:1:length(video_files)
            video_path = video_files{i_video};
            [~, video_name, video_ext] = fileparts(video_path);
            video_file = ['.' filesep video_name video_ext];
            REG_video = regexp(video_file,'_');
            video_description = video_file(REG_video(end-1)+1:end-4);
            metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,0,video_description); % 0 correspond to the video offset
            trip.addVideoFile(metaVideo);
        end
        trip.setAttribute('import_videos','OK');
    else
        disp('La vidéo a déjà été importée...')
    end
    
    %% Generate_timecode_data
    if import_timecode_needed
        time_step = 1/25;
        video_files = find_file_with_extension([full_directory filesep],'.avi');
        video_file_duration = VideoReader(video_files{1}).Duration;
        timecode_file.timecode_data = [(0:time_step:video_file_duration)',(0:time_step:video_file_duration)'];
        struct_matlab = import_MatlabFiles(timecode_file);
        import_data_struct_in_bind_trip(struct_matlab, trip, '');
        trip.setAttribute('import_timecode','OK');
    else
        disp('Les données ont déjà été importées')
    end
    delete(trip);
    
    %% FIND PEAKS IN AUDIO FILE
    audio_file = find_file_with_extension([full_directory filesep],'.mp3');
    import_stim_needed = 0;
    if ~isempty(audio_file) && import_stim_needed
        i_dt = i_dt+1;
        CapadynFindAudioFilePeaks(full_directory);
        nb_stim{i_dt} = calculate_nb_stim(trip_file);
    elseif ~isempty(audio_file)
        i_dt = i_dt+1;
        nb_stim{i_dt} = calculate_nb_stim(trip_file);
        disp('Les stimulations ont déjà été importées...')
    else
        disp('Il n''y a pas de stimulation à importer...')
    end
    
    %% A importer sur le PC
    %     %% Import audio stim data to the TRIP
    %     mp3_file = find_file_with_extension([full_directory filesep],'.mp3');
    %     if ~isempty(mp3_file) && import_audio_stim_data_needed
    %         audio_stim = audioread(cell2mat(dirrec(full_directory,'.mp3')));
    %         save([trip_file(1:end-5) '_audio_stim.mat'],'audio_stim')
    %         [data_file_timecoded] = CapadynAddTimecode([trip_file(1:end-5) '_audio_stim.mat'],441);
    %         struct_matlab = CapadynImportMatlabFiles(data_file_timecoded);
    %         trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    %         import_data_struct_in_bind_trip(struct_matlab, trip, '');
    %         trip.setAttribute('import_audio_stim_data', 'OK');
    %         delete(trip);
    %     elseif ~isempty(audio_file)
    %         disp('Les données audio des stimulations ont déjà été importées...')
    %     else
    %         disp('Il n''y a pas de données audio à importer...')
    %     end
    %
    %     %% Import audio stereo data to the TRIP
    %     mp4_file = find_file_with_extension([full_directory filesep],'.mp4');
    %     if ~isempty(mp4_file) && import_audio_all_data_needed
    %         audio_all = audioread(cell2mat(dirrec(full_directory,'.mp4')));
    %         save([trip_file(1:end-5) '_audio_all.mat'],'audio_all')
    %         [data_file_timecoded] = CapadynAddTimecode([trip_file(1:end-5) '_audio_all.mat'],480);
    %         struct_matlab = CapadynImportMatlabFiles(data_file_timecoded);
    %         trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    %         import_data_struct_in_bind_trip(struct_matlab, trip, '');
    %         trip.setAttribute('import_audio_all_data', 'OK');
    %         delete(trip);
    %     elseif ~isempty(audio_file)
    %         disp('Les données audio générales ont déjà été importées...')
    %     else
    %         disp('Il n''y a pas de données audio à importer...')
    %     end
    
    %% Correct TC situations according to start/endTC situation_essai_complet
    if correct_TC_situations_needed
        SaveTrip(full_directory);
        CapadynCorrectSituationsTC(trip_file);
    end
    %% Import DT results
    mp3_file = find_file_with_extension([full_directory filesep],'.mp3');
    if ~isempty(mp3_file) && import_DT_results_needed && exist([trip_file(1:end-4) 'csv'],'file')
        SaveTrip(full_directory);
        error = CapadynImportDTResults(trip_file);
        if error
            nb_errors = nb_errors + 1;
            disp(['le nombre d''erreurs est de : ' num2str(nb_errors)])
        end
    end
    
    %% Import Categorization of DT Stimulations
    if ~isempty(mp3_file) && import_Categ_Stim_needed
        SaveTrip(full_directory);
        CapadynImportCategStim(trip_file);
    end
    
    %% Import data table of masks conditions
    if import_table_cond_needed
        SaveTrip(full_directory);
        CapadynImportTableConditions(trip_file);
    end
    
    %% ADD INDICATORS
    if add_indicators_needed
        SaveTrip(full_directory);
        CapadynAddIndicators(trip_file);
    end
    
end

%% CAPADYN HG DATA Correction
% runnable.CapadynHGDataVerification(MAIN_FOLDER)

%% EXPORT SITUATIONS DATAS TO TSV FILE
% runnable.batchExportTSV_CAPADYN(MAIN_FOLDER)
% runnable.batchExportSituationTSV_CAPADYN(MAIN_FOLDER)

%% Check number of stimulations
nb_stim = cell2mat(nb_stim);
mask_stim = nb_stim>1;
nb_stim_mean = mean(nb_stim(mask_stim));
nb_stim_min = min(nb_stim(mask_stim));
nb_stim_max = max(nb_stim(mask_stim));
disp(['le nombre d''erreurs est de : ' num2str(nb_errors)])
end

%% Other functions
% calculate nb_stim_mean/min/max
function [nb_stim] = calculate_nb_stim(trip_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
try
    nb_stim = str2double(trip.getAttribute('nb_stim'));
catch
    nb_stim = [];
end
delete(trip);
end