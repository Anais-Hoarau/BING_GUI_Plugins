function BatchImportProspectConflicts()
    %% PATHS DEFINITION
    MAIN_FOLDER = '\\vrlescot\PROSPECT\CODAGE';
    TRIPS_FOLDER = '\\vrlescot\PROSPECT\CODAGE\TRIPSALL';
    %     TRIPS_FOLDER = '\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\TEST';
    load('\\vrlescot\PROSPECT\CODAGE\trip_input_list_all.mat');
    i_VRU = 0;
    i_voiture = 0;
    i_TTC_null = 0;
    i_intersect = 0;
    trips_with_TTC_null = {};
    trips_without_intersect = {};
    trips_with_problems = {};
    
    for i_video = 1:length(tripinputlistall) %32 %14 %25 % //doublons_liste1:14=>OK|20=>OK|39=>OK|60=>OK //doublons_liste2:34|44 // specific_crop_liste1:A0B1(21)|2344(56)|4F33(33)|1759(24)|D29F(29)|401A(28) // pbs : 19 | 34
        folder_num = tripinputlistall{i_video,1};
        folder_name = tripinputlistall{i_video,2};
        input_video_file_path = tripinputlistall{i_video,3};
        
        trip_name = [folder_name '.trip'];
        csv_name = [folder_name '.csv.3d'];
        ttc_name = [folder_name '.csv.ttc'];
        
        full_directory = [TRIPS_FOLDER filesep folder_num '_' folder_name];
        mkdir(full_directory); mkdir([full_directory filesep 'Figures']);
        
        output_video_file_path = [full_directory filesep folder_name];
        trip_file = [full_directory filesep trip_name];
        csv_file = [full_directory filesep csv_name];
        ttc_file = [full_directory filesep ttc_name];
        
        %% INSTANCIATE TRIP
        if ~exist(trip_file, 'file')
            disp(['Création du fichier trip : "' trip_name '"...' ])
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
            trip.setAttribute('MAIN_FOLDER', TRIPS_FOLDER);
            trip.setAttribute(upper('trip_name'), trip_name);
            trip.setAttribute('import_data', '');
            trip.setAttribute('import_videos', '');
            trip.setAttribute('import_trajectories_data', '');
            trip.setAttribute('calculate_distance_vitesse', '');
            trip.setAttribute('calculate_TDTC', '');
        else
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
            disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
            disp(['Vérification du fichier "' trip_name])
            
            % check processes not completed yet
            import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
            import_data_needed = ~check_trip_meta(trip,'import_data','OK');
            import_trajectories_data_needed = ~check_trip_meta(trip,'import_trajectories_data','OK');
            import_trajectories_data2_needed = ~check_trip_meta(trip,'import_trajectories_data2','OK');
            import_TTC_data_needed = ~check_trip_meta(trip,'import_TTC_data','OK');
            calculate_distance_vitesse_needed = ~check_trip_meta(trip,'calculate_distance_vitesse','OK');
            calculate_TDTC_needed = ~check_trip_meta(trip,'calculate_TDTC','OK');
            calculate_TTC_needed = ~check_trip_meta(trip,'calculate_TTC','OK');
            calculate_INDICATORS_needed = ~check_trip_meta(trip,'calculate_INDICATORS','OK');
            
            % force or avoid processes
%             import_videos_needed = 0;
%             import_data_needed = 0;
            import_trajectories_data_needed = 0;
            import_TTC_data_needed = 0;
            calculate_TDTC_needed = 0;
            calculate_TTC_needed = 0;
            import_trajectories_data2_needed = 0;
            calculate_distance_vitesse_needed = 0;
            calculate_INDICATORS_needed = 0;
        
        end
        
        %% ADD VIDEO LINKS TO THE TRIP
%         convertVideo2MJPEG_alone_withoutClap_withPath(input_video_file_path, tripinputlistall{i_video,4}, tripinputlistall{i_video,5}, output_video_file_path)
        if import_videos_needed
            disp('Vérification des fichiers vidéo et création des liens...')
            video_files = find_file_with_extension([full_directory filesep],'.avi');
            for i_video = 1:1:length(video_files)
                video_path = video_files{i_video};
                [~, video_name, video_ext] = fileparts(video_path);
                output_video_file_path = ['.' filesep video_name video_ext];
                REG_video = regexp(output_video_file_path,'_');
                if ~isempty(strfind(output_video_file_path, 'CROPED'))
                    video_description = output_video_file_path(REG_video(end-2)+1:end-4);
                else
                    video_description = output_video_file_path(REG_video(end)+1:end-4);
                end
                metaVideo = fr.lescot.bind.data.MetaVideoFile(output_video_file_path,0,video_description); % 0 correspond to the video offset
                trip.addVideoFile(metaVideo);
            end
            trip.setAttribute('import_videos','OK');
        end
        
        %% GENERATE_TIMECODE_DATA
        if import_data_needed && ~isempty(find_file_with_extension([full_directory filesep],'.avi'))
            time_step = 1/25;
            video_files = find_file_with_extension([full_directory filesep],'.avi');
            for i_vid = 1:length(video_files)
                if ~isempty(strfind(video_files{i_vid},'_MJPEG4K.avi'))
                    video_file_duration = VideoReader(video_files{2}).Duration;
                    timecode_file.timecode_data = [(0:time_step:video_file_duration)',(0:time_step:video_file_duration)'];
                    struct_matlab = import_MatlabFiles(timecode_file);
                    import_data_struct_in_bind_trip(struct_matlab, trip, '');
                    trip.setAttribute('import_data','OK');
                end
            end
        else
            disp('Les données ont déjà été importées')
        end
        
        %% SAVE TRIP
        %     disp('Sauvegarde du fichier trip : ' trip_file)
        %     SaveTrip(full_directory)
        
        %% IMPORT TRAJECTORIES DATA
        if import_trajectories_data_needed && exist(csv_file,'file') == 2
            split_offset = strsplit(tripinputlistall{i_video,4},':');
            offset = str2num(split_offset{1})*60+str2num(split_offset{2});
            trajectories_data = PROSPECT_import_CSV_file(csv_file, 1, inf);
            trajectories_data(:,2) = trajectories_data(:,2)-offset;
            values_sep = find(diff(trajectories_data(:,1)));
            if exist(csv_file(1:end-3),'file') == 2
                commentaires = PROSPECT_import_CSV_file_3(csv_file(1:end-3), 1, 4);
                if  ~isempty(strfind(commentaires{1},'Voiture')) || ~isempty(strfind(commentaires{1},'Bus'))
                    CAR.CAR_trajectories = trajectories_data(1:values_sep,2:4);
                    CAR.CAR_trajectories(:,2:3) = CAR.CAR_trajectories(:,2:3)/1000;
                    VRU.VRU_trajectories = trajectories_data(values_sep+1:end,2:4);
                    VRU.VRU_trajectories(:,2:3) = VRU.VRU_trajectories(:,2:3)/1000;
                    i_voiture = i_voiture+1;
                elseif isempty(strfind(commentaires{1},'Voiture')) && isempty(strfind(commentaires{1},'Bus'))
                    VRU.VRU_trajectories = trajectories_data(1:values_sep,2:4);
                    VRU.VRU_trajectories(:,2:3) = VRU.VRU_trajectories(:,2:3)/1000;
                    CAR.CAR_trajectories = trajectories_data(values_sep+1:end,2:4);
                    CAR.CAR_trajectories(:,2:3) = CAR.CAR_trajectories(:,2:3)/1000;
                    i_VRU = i_VRU+1;
                end
                
                %% INTERPOLATION DES DONNEES POUR CORRIGER SAUTES D'IMAGES
                
                CAR.CAR_trajectories_interp(:,1) = (CAR.CAR_trajectories(1,1):0.04:(CAR.CAR_trajectories(1,1)+(CAR.CAR_trajectories(end,1)-CAR.CAR_trajectories(1,1))*25/23))';
                CAR.CAR_trajectories_interp(:,2) = interp1(CAR.CAR_trajectories(:,1), CAR.CAR_trajectories(:,2), (CAR.CAR_trajectories(1,1):0.04*23/25:CAR.CAR_trajectories(end,1))','pchip'); %,'pchip','extrap');
                CAR.CAR_trajectories_interp(:,3) = interp1(CAR.CAR_trajectories(:,1), CAR.CAR_trajectories(:,3), (CAR.CAR_trajectories(1,1):0.04*23/25:CAR.CAR_trajectories(end,1))','pchip'); %,'pchip','extrap');
                VRU.VRU_trajectories_interp(:,1) = (VRU.VRU_trajectories(1,1):0.04:(VRU.VRU_trajectories(1,1)+(VRU.VRU_trajectories(end,1)-VRU.VRU_trajectories(1,1))*25/23))';
                VRU.VRU_trajectories_interp(:,2) = interp1(VRU.VRU_trajectories(:,1), VRU.VRU_trajectories(:,2), (VRU.VRU_trajectories(1,1):0.04*23/25:VRU.VRU_trajectories(end,1))','pchip'); %,'pchip','extrap');
                VRU.VRU_trajectories_interp(:,3) = interp1(VRU.VRU_trajectories(:,1), VRU.VRU_trajectories(:,3), (VRU.VRU_trajectories(1,1):0.04*23/25:VRU.VRU_trajectories(end,1))','pchip'); %,'pchip','extrap');
                
                %             hold on
                %             plot(VRU.VRU_trajectories(:,2))
                %             plot(VRU.VRU_trajectories_interp(:,2))
                %             plot(diff(VRU.VRU_trajectories(:,2)))
                %             plot(diff(VRU.VRU_trajectories_interp(:,2)))
                %             plot(medfilt1(diff(VRU.VRU_trajectories_interp(:,2)),5))
                %             plot(smooth(medfilt1(diff(VRU.VRU_trajectories_interp(:,2)),9)))
                
                %% import des données CAR & VRU
                struct_matlab_VRU = import_MatlabFiles(VRU);
                import_data_struct_in_bind_trip(struct_matlab_VRU, trip, '');
                struct_matlab_CAR = import_MatlabFiles(CAR);
                import_data_struct_in_bind_trip(struct_matlab_CAR, trip, '');
                trip.setAttribute('import_trajectories_data','OK');
                clearvars CAR VRU;
            end
        else
            disp('Les données de trajectoire par tracking automatique ont déjà été importées')
        end
        
        %% SAVE TRACKING MAT FILE
%         disp(['Sauvegarde du fichier de tracking : ' trip_file(1:end-5) '_MJPEG4K.mat'])
%         SaveFile(full_directory,'.mat')
        
        %% CONVERT TRAJECTORIES POINTS IN VIDEO REF TO TRAJECTORIES SHAPES IN WORLD REF AND IMPORT IT IN TRIP
        if import_trajectories_data2_needed
            [TTC_null, Intersect, trip_problem] = TrajConvVideoToWorldProspect(trip_file, i_video);
            i_TTC_null = i_TTC_null + TTC_null;
            if TTC_null == 1
                trips_with_TTC_null = [trips_with_TTC_null, {[folder_num '_' folder_name]}];
            end
            i_intersect = i_intersect + Intersect;
            if Intersect == 0
                trips_without_intersect = [trips_without_intersect, {[folder_num '_' folder_name]}];
            end
            if trip_problem == 1
                trips_with_problems = [trips_with_problems, {[folder_num '_' folder_name]}];
            end
        else
            disp('Les données de trajectoire par tracking manuel ont déjà été importées')
        end
        
        %% IMPORT TTC DATA
        if import_TTC_data_needed && exist(ttc_file,'file') == 2
            split_offset = strsplit(tripinputlistall{i_video,4},':');
            offset = str2num(split_offset{1})*60+str2num(split_offset{2});
            TTC_data = PROSPECT_import_CSV_file(ttc_file, 1, inf);
            TTC_data(:,1) = round((TTC_data(:,1)-offset)*100)/100;
            TTC.TTC = abs(TTC_data(:,1:3));
            TTC.TTC_smooth = TTC.TTC;
            TTC.TTC_smooth(:,2) = smooth(medfilt1(TTC.TTC(:,2),5),5,'rlowess');
            TTC.TTC_smooth(:,3) = smooth(medfilt1(TTC.TTC(:,3),5),5,'rlowess');
            
            %% INTERPOLATION DES DONNEES POUR CORRIGER SAUTES D'IMAGES
            TTC.TTC_smooth_interp(:,1) = (TTC.TTC_smooth(1,1):0.04:(TTC.TTC_smooth(1,1)+(TTC.TTC_smooth(end,1)-TTC.TTC_smooth(1,1))*25/23))';
            TTC.TTC_smooth_interp(:,2) = interp1(TTC.TTC_smooth(:,1), TTC.TTC_smooth(:,2), (TTC.TTC_smooth(1,1):0.04*23/25:TTC.TTC_smooth(end,1))','pchip'); %,'pchip','extrap');
            TTC.TTC_smooth_interp(:,3) = interp1(TTC.TTC_smooth(:,1), TTC.TTC_smooth(:,3), (TTC.TTC_smooth(1,1):0.04*23/25:TTC.TTC_smooth(end,1))','pchip'); %,'pchip','extrap');
            
            %% SUPPR TTC WHEN FALSE
            TTC.TTC_smooth(84:332,2) = NaN(249,1);
            TTC.TTC_smooth(84:332,3) = NaN(249,1);
            
            %% import des données CAR & VRU
            struct_matlab_TTC = import_MatlabFiles(TTC);
            import_data_struct_in_bind_trip(struct_matlab_TTC, trip, '');
            trip.setAttribute('import_TTC_data','OK');
            clearvars TTC;
        else
            disp('Les données de TTC ont déjà été importées')
        end
        
        %% CALCUL DISTANCE ET VITESSE
        if calculate_distance_vitesse_needed && existData(trip.getMetaInformations(), 'CAR_trajectories2')
            calculate_distance_speed_accel(trip);
            trip.setAttribute('calculate_distance_vitesse', 'OK');
        end
        
        %% CALCUL TTC
        if calculate_TDTC_needed && existData(trip.getMetaInformations(), 'CAR_trajectories')
            calculate_TDTC(trip);
            trip.setAttribute('calculate_TDTC', 'OK');
        end
        
        %% CALCUL TTC
        if calculate_TTC_needed && existData(trip.getMetaInformations(), 'CAR_trajectories')
            calculate_TTC(trip);
            trip.setAttribute('calculate_TTC', 'OK');
        end
        
        %% CALCUL INDICATORS
        if calculate_INDICATORS_needed && existData(trip.getMetaInformations(), 'CAR_trajectories2')
            calculate_indicators(trip, full_directory);
            trip.setAttribute('calculate_INDICATORS', 'OK');
        end
        
        delete(trip)
    end
    disp(['i_VRU : ' num2str(i_VRU)])
    disp(['i_voiture : ' num2str(i_voiture)])
    disp(['i_intersect : ' num2str(i_intersect)])
    disp(['i_TTC_null : ' num2str(i_TTC_null)])
    
%     trips_with_TTC_null = trips_with_TTC_null';
%     save([MAIN_FOLDER filesep 'trips_with_TTC_null'],'trips_with_TTC_null')
%     trips_without_intersect = trips_without_intersect';
%     save([MAIN_FOLDER filesep 'trips_without_intersect'],'trips_without_intersect')
%     trips_with_problems = trips_with_problems';
%     save([MAIN_FOLDER filesep 'trips_with_problems'],'trips_with_problems')
    
    % runnable.batchExportSituationTSV_PROSPECT()
end

%% CORRECTION PAS DE TEMPS MANQUANTS PAR FRAMES MANQUANTES
%             frame_file = [full_directory filesep 'frames.txt'];
%             frame_init_file = [full_directory filesep 'frames_init.txt'];
%             ffmpeg_command_line = ['ffprobe -show_frames ' video_file(1:end-4) '_MJPEG.avi > ' frame_file];
%             system(ffmpeg_command_line);
%
%             % frames from video converted
%             frames = fopen(frame_file);
%             tline = fgetl(frames);
%             idx_missing_frames = [];
%             i = 0;
%             while ischar(tline)
%                 if ~isempty(strfind(tline, 'best_effort_timestamp='))
%                     split_line = strsplit(tline, '=');
%                     ii = str2num(split_line{end});
%                     if (i ~= ii)
%                         idx_missing_frames = [idx_missing_frames i];
%                         i=i+1;
%                     end
%                     i=i+1;
%                 end
%                 tline = fgetl(frames);
%             end
%             fclose(frames);
%
%             % frames from video before conversion
%             frames_init = fopen(frame_init_file);
%             tline = fgetl(frames_init);
%             idx_missing_frames_init = [];
%             offset_min = 139020;
%             offset_max = 149000;
%             i = 0;
%             while ischar(tline)
%                 if ~isempty(strfind(tline, 'best_effort_timestamp='))
%                     split_line = strsplit(tline, '=');
%                     ii = floor(str2num(split_line{end})/10)*10;
%                     if ii>=offset_min && ii<offset_max
%                         ii = ii-offset_min;
%                         if i~=ii
%                             idx_missing_frames_init = [idx_missing_frames_init i/40+1];
%                             i=i+40;
%                         end
%                         i=i+40;
%                     end
%                 end
%                 tline = fgetl(frames_init);
%             end
%             fclose(frames);
%
%             CAR.CAR_trajectories2 = CAR.CAR_trajectories;
%             VRU.VRU_trajectories2 = VRU.VRU_trajectories;
%             for i=1:length(idx_missing_frames)
%                 idx = idx_missing_frames(i)+1;
%                 if idx+1 < length(CAR.CAR_trajectories2)
%                     CAR.CAR_trajectories2 = [CAR.CAR_trajectories2(1:idx-1,1:3)', [CAR.CAR_trajectories2(idx,1),mean(CAR.CAR_trajectories2(idx-1:idx,2)),mean(CAR.CAR_trajectories2(idx-1:idx,3))]', CAR.CAR_trajectories2(idx:end,1:3)']';
%                     CAR.CAR_trajectories2(idx+1:end,1) = CAR.CAR_trajectories2(idx+1:end,1)+0.04;
%                 end
%                 if idx+1 < length(VRU.VRU_trajectories2)
%                     VRU.VRU_trajectories2 = [VRU.VRU_trajectories2(1:idx-1,1:3)', [VRU.VRU_trajectories2(idx,1),mean(VRU.VRU_trajectories2(idx-1:idx,2)),mean(VRU.VRU_trajectories2(idx-1:idx,3))]', VRU.VRU_trajectories2(idx:end,1:3)']';
%                     VRU.VRU_trajectories2(idx+1:end,1) = VRU.VRU_trajectories2(idx+1:end,1)+0.04;
%                 end
%             end
%
%             MinPP = 0.1;
%             WR = 'halfprom';
%             plot(CAR.CAR_trajectories(:,2))
%             hold on
%             plot(CAR.CAR_trajectories2(:,2))
%             plot(abs(diff(CAR.CAR_trajectories(:,2))))
%             plot(abs(diff(CAR.CAR_trajectories2(:,2))))

%             plot(abs(diff(diff(CAR.CAR_trajectories(:,2)))))
%             findpeaks(abs(diff(CAR.CAR_trajectories(:,2))),'MinPeakProminence',MinPP,'WidthReference',WR)
%             [pks_toCorrect, locs_toCorrect] = findpeaks(abs(diff(CAR.CAR_trajectories(:,2))),'MinPeakProminence',MinPP,'WidthReference',WR);
%             findpeaks(abs(diff(VRU.VRU_trajectories(:,2))),'MinPeakProminence',MinPP,'WidthReference',WR)
%             [pks_toCorrect, locs_toCorrect] = findpeaks(abs(diff(VRU.VRU_trajectories(:,2))),'MinPeakProminence',MinPP,'WidthReference',WR);
%             plot(VRU.VRU_trajectories(:,2))
%             findpeaks(abs(diff(VRU.VRU_trajectories(:,2))),'MinPeakProminence',MinPP,'WidthReference',WR);
%             [pks_toCorrect, locs_toCorrect] = findpeaks(abs(diff(VRU.VRU_trajectories(:,2))),'MinPeakProminence',MinPP,'WidthReference',WR);
%             plot(medfilt1(CAR.CAR_trajectories(:,2)))