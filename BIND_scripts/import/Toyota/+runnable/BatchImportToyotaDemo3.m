function BatchImportToyotaDemo3()
%% PARTICIPANT FOLDERS LIST
MAIN_FOLDER = 'D:\LESCOT\PROJETS DE RECHERCHE\TOYOTA_DISCO+\DEMOS';
files_list = dirrec(MAIN_FOLDER, '.mat');

for i = 1:1:length(files_list)
    if strfind(files_list{i}, 'timecoded')
        continue;
    end
    % identify participant (ex : C01)
    full_directory = files_list{i};
    reg_directory = regexp(full_directory,'\');
    participant_id = full_directory(reg_directory(end)+1:end-4);
       
    % identify needed files names
    trip_name = [participant_id '.trip'];
    data_name = [participant_id '.mat'];
    
    % identify needed files full directories
    trip_file = [full_directory(1:reg_directory(end)-1) filesep trip_name];
    data_file = [full_directory(1:reg_directory(end)-1) filesep data_name];
    
    %% TRIP FILE CREATION
    
    if ~exist(trip_file, 'file')
        disp(['Création du fichier trip : "' trip_name '"...' ])
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        trip.setAttribute('MAIN_FOLDER', MAIN_FOLDER);
        trip.setAttribute('id_participant', participant_id);
        trip.setAttribute('import_data', '');
        trip.setAttribute('import_videos', '');
        delete(trip);
    else
        disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
    end
    
    disp(['Vérification du fichier "' trip_name '"...' ])
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    import_data_needed = ~check_trip_meta(trip,'import_data','OK');
    import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
    delete(trip);
    
    %% IMPORT DATA TO THE TRIP FILE
    import_data_needed = 1;
    if import_data_needed
        if ~exist(data_file, 'file')
            disp(['Le fichier "' data_name '" est absent du dossier...'])
        else
            disp('Import des données en cours...')
            [data_file_timecoded] = convertFile(data_file);
            struct_matlab = import_MatlabFiles(data_file_timecoded);
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
            import_data_struct_in_bind_trip(struct_matlab, trip, '');
            trip.setAttribute('import_data', 'OK');
            delete(trip);
        end
    else
        disp('Les données ont déjà été importées...')
    end
    
    %% ADD VIDEO LINKS TO THE TRIP
    % trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    % if exist([full_directory 'clap.txt'], 'file')
    %     convertVideo2MJPEG_alone(full_directory)                                % convert simulator video if necessary
    %     if import_videos_needed
    %         disp('Vérification des fichiers vidéo et création des liens...')
    %         video_files = find_file_with_extension([full_directory filesep],'.avi');
    %         for i_video = 1:1:length(video_files)
    %             video_path = video_files{i_video};
    %             [~, video_name, video_ext] = fileparts(video_path);
    %             video_file = ['.' filesep video_name video_ext];
    %             REG_video = regexp(video_file,'_');
    %             video_description = video_file(REG_video(end-2)+1:REG_video(end)-1);
    %             metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,-5,video_description); % -5 correspond to the video offset
    %             trip.addVideoFile(metaVideo);
    %         end
    %         trip.setAttribute('import_videos','OK');
    %     end
    % else
    %     disp('Attention, pas de fichier clap, la vidéo du simulateur ne sera pas synchronisée, ni ajoutée...')
    %     trip.setAttribute('import_videos','');
    % end
    % delete(trip);
    
end
end

function file_path_out = convertFile(matlab_file_path)
load(matlab_file_path)
reg_directory = regexp(matlab_file_path,'\');
matlab_file_name = matlab_file_path(reg_directory(end)+1:end-4);
timecode_final = 0:0.03333333333333333333333333333333:datavideo(end,1);
seuil_DI = ones(length(timecode_final),1)*0.25;

data_timecoded = struct();
data_timecoded.SCR = [timecode_final', interp1(datavideo(:,1),datavideo(:,2),timecode_final)'];
data_timecoded.HR = [timecode_final', interp1(datavideo(:,1),datavideo(:,3),timecode_final)'];
data_timecoded.SDS = [timecode_final', interp1(datavideo(:,1),datavideo(:,4),timecode_final)'];
data_timecoded.DI = [timecode_final', interp1(datavideo(:,1),datavideo(:,5),timecode_final)', seuil_DI];

file_path_out = fullfile(matlab_file_path(1:reg_directory(end)), [matlab_file_name '_timecoded.mat']);
save(file_path_out, 'data_timecoded');
end