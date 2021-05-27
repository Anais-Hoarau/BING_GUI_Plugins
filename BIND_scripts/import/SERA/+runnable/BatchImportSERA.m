function BatchImportSERA()
    %%
    MAIN_FOLDER = 'Y:\DONNEES_PARTICIPANTS\PRE-TESTS';
    folders_list = dirrec(MAIN_FOLDER, '.rec')';
    
    for i_rec = 1:length(folders_list)
        rec_file_path = folders_list{i_rec};
        rec_file_path_split = strsplit(rec_file_path,'\');
        rec_name = rec_file_path_split{end};
        trip_name = [rec_name(1:end-4) '.trip'];
        video_name_GOPRO = [rec_name(1:end-4), '_Data_Video_GoPro_MJPEG.avi'];

        full_directory = fullfile(MAIN_FOLDER,rec_file_path_split{end-2},rec_file_path_split{end-1});
        rec_file = [full_directory filesep rec_name];
        trip_file = [full_directory filesep trip_name];
        video_file_GORPRO = [full_directory filesep video_name_GOPRO];
        video_folder_GOPROCAM = [full_directory filesep 'Go-Pro_' rec_file_path_split{end-2}(7:end)];
        
        %% Instanciate trip
        if ~exist(trip_file, 'file')
            disp(['Création du fichier trip : "' trip_name '"...' ])
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
            trip.setAttribute('MAIN_FOLDER', MAIN_FOLDER);
            trip.setAttribute(upper('trip_name'), trip_name);
            trip.setAttribute('import_videos', '');
            trip.setAttribute('create_timecodes', '');
            trip.setAttribute('import_data', '');
            delete(trip);
        else
            disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
        end
        
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        
        import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
        create_timecodes_needed = ~check_trip_meta(trip,'create_timecodes','OK');
        import_data_needed = ~check_trip_meta(trip,'import_data','OK');

%         import_videos_needed = 1;
%         create_timecodes_needed = 1;
%         import_data_needed = 1;
        
        %% CONVERT AND ADD VIDEO LINKS TO THE TRIP
        convertVideo2MJPEG_alone_withoutClap(full_directory)
        convertVideo2MJPEG_alone_withoutClap_withPath_SERA(video_folder_GOPROCAM,video_file_GORPRO)
        if import_videos_needed
            disp('Vérification des fichiers vidéo et création des liens...')
            video_files = find_file_with_extension([full_directory filesep],'.avi');
            for i_video = 2:1:length(video_files)
                video_path = video_files{i_video};
                [~, video_name, video_ext] = fileparts(video_path);
                video_file = ['.' filesep video_name video_ext];
                REG_video = regexp(video_file,'_');
                video_description = video_file(REG_video(end-1)+1:end-4);
                metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,0,video_description); % 0 correspond to the video offset
                trip.addVideoFile(metaVideo);
            end
            trip.setAttribute('import_videos','OK');
        end
        
        %% Generate_timecode_data
        if create_timecodes_needed && ~isempty(find_file_with_extension([full_directory filesep],'.avi'))
            time_step = 1/25;
            video_files = find_file_with_extension([full_directory filesep],'.avi');
            video_file_duration = VideoReader(video_files{3}).Duration;
            timecode_file.timecode_data = [(0:time_step:video_file_duration)',(0:time_step:video_file_duration)'];
            struct_matlab = import_MatlabFiles(timecode_file);
            import_data_struct_in_bind_trip(struct_matlab, trip, '');
            trip.setAttribute('create_timecodes','OK');
        else
            disp('Les timecodes ont déjà été importées')
        end
        
        %% Import data
        if import_data_needed
            SERA_REC2BIND(trip,rec_file)
            trip.setAttribute('import_data','OK');
        else
            disp('Les données ont déjà été importées')
        end
        
        delete(trip);
    end
end