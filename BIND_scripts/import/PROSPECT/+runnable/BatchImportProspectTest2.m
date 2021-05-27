function BatchImportProspectTest2()
	close all; clc;
	figure('units','normalized','outerposition',[0 0 1 1])
        %% PATHS DEFINITION
        TRIPS_FOLDER = '\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP5';
        load('\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP5\Videos_brutes_non_conflits_version_Bind_V4.mat');
        
        cmpt = 0;
        folder_num_list = {};
        for i_video = 2
            folder_num = VideosbrutesnonconflitsversionBindV4{i_video,1};
            input_video_file_path = VideosbrutesnonconflitsversionBindV4{i_video,2};
            input_video_file_path_splitted = strsplit(input_video_file_path, '\');
            
            folder_name = [folder_num '_' input_video_file_path_splitted{end}(1:end-4)];
            trip_name = [folder_name '.trip'];
            
            full_directory = [TRIPS_FOLDER filesep folder_name];
            mkdir(full_directory); mkdir([full_directory filesep 'Figures']);
            
            output_video_file_path = [full_directory filesep folder_name];
            trip_file = [full_directory filesep trip_name];
            
            %% INSTANCIATE TRIP
            if ~exist(trip_file, 'file')
                disp(['Création du fichier trip : "' trip_name '"...' ])
                trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
                trip.setAttribute('MAIN_FOLDER', TRIPS_FOLDER);
                trip.setAttribute(upper('trip_name'), trip_name);
                trip.setAttribute('import_data', '');
                trip.setAttribute('import_videos', '');
                trip.setAttribute('import_coding', '');
                trip.setAttribute('import_trajectories_data', '');
                trip.setAttribute('calculate_distance_vitesse', '');
                trip.setAttribute('calculate_indicators', '');
                trip.setAttribute('calculate_PSD', '');
                delete(trip)
            else
                disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
            end
            
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
            disp(['Vérification du fichier "' trip_name])
            
            % check processes not completed yet
            import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
            import_data_needed = ~check_trip_meta(trip,'import_data','OK');
            import_coding_needed = ~check_trip_meta(trip,'import_coding','OK');
            import_trajectories_data2_needed = ~check_trip_meta(trip,'import_trajectories_data2','OK');
            calculate_distance_vitesse_needed = ~check_trip_meta(trip,'calculate_distance_vitesse','OK');
            calculate_indicators_needed = ~check_trip_meta(trip,'calculate_indicators','OK');
            calculate_PSD_needed = ~check_trip_meta(trip,'calculate_PSD','OK');
            plot_VRU_traj_needeed = ~check_trip_meta(trip,'plot_VRU_traj','OK');

            
            % force or avoid processes
            %         import_videos_needed = 1;
                    import_data_needed = 1;
            %         import_coding_needed = 1;
                    import_trajectories_data2_needed = 1;
            %         calculate_distance_vitesse_needed = 1;
            %         calculate_indicators_needed = 1;
%             calculate_PSD_needed = 0;
            plot_VRU_traj_needeed = 0;
            
            %% ADD VIDEO LINKS TO THE TRIP
%             convertVideo2MJPEG_alone_withoutClap_withPath(input_video_file_path, VideosbrutesnonconflitsversionBindV4{i_video,4}, VideosbrutesnonconflitsversionBindV4{i_video,5}, output_video_file_path)
            if import_videos_needed
                disp('Vérification des fichiers vidéo et création des liens...')
                video_files = find_file_with_extension([full_directory filesep],'.avi');
                for i_vid = 1:1:length(video_files)
                    video_path = video_files{i_vid};
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
                        video_file_duration = VideoReader(video_files{1}).Duration;
                        timecode_file.timecode_data = [(0:time_step:video_file_duration)',(0:time_step:video_file_duration)'];
                        struct_matlab = import_MatlabFiles(timecode_file);
                        import_data_struct_in_bind_trip(struct_matlab, trip, '');
                        trip.setAttribute('import_data','OK');
                    end
                end
            else
                disp('Les données ont déjà été importées')
            end
            
            %% ADD_CODING_DATA
            if import_coding_needed
                timecodes = cell2mat(trip.getAllDataOccurences('timecode_data').getVariableValues('timecode'));
                addSituationTable2Trip(trip,{'VRU_characteristics'})
                addSituationVariable2Trip(trip,'VRU_characteristics','VRU_type','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','Multiple_presence','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','Car_presence','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','Age','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','VRU_description','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','Children','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','VRU_meeting','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','Waiting','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','Other_than_walking','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','Speed_modification','TEXT');
                addSituationVariable2Trip(trip,'VRU_characteristics','Traj_modification','TEXT');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','name',[num2cell(timecodes(1)),num2cell(timecodes(end)),'Complete situation']');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','VRU_type',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,3}]');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','Multiple_presence',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,6}]');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','Car_presence',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,7}]');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','Age',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,8}]');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','VRU_description',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,9}]');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','Children',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,10}]');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','VRU_meeting',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,11}]');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','Waiting',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,12}]');
                if ~isempty(VideosbrutesnonconflitsversionBindV4{i_video,13})
                    trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','Other_than_walking',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,13}]');
                end
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','Speed_modification',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,14}]');
                trip.setBatchOfTimeSituationVariableTriplets('VRU_characteristics','Traj_modification',[num2cell(timecodes(1)),num2cell(timecodes(end)),VideosbrutesnonconflitsversionBindV4{i_video,15}]');
                trip.setAttribute('import_coding','OK');
            end
            
            %% SAVE TRIP
%             disp(['Sauvegarde du fichier trip : ' trip_file]);
%             SaveTrip(full_directory);
            
            %% CONVERT TRAJECTORIES POINTS IN VIDEO REF TO TRAJECTORIES SHAPES IN WORLD REF AND IMPORT IT IN TRIP
            if import_trajectories_data2_needed
                TrajConvVideoToWorldProspect_test2(trip_file, i_video);
            else
                disp('Les données de trajectoire par tracking manuel ont déjà été importées')
            end
            
            %% CALCUL DISTANCE ET VITESSE
            if calculate_distance_vitesse_needed && existData(trip.getMetaInformations(), 'VRU_trajectories2')
                calculate_distance_speed_accel(trip);
                trip.setAttribute('calculate_distance_vitesse', 'OK');
            end
            
            %% CALCUL INDICATORS
            if calculate_indicators_needed && existData(trip.getMetaInformations(), 'VRU_trajectories2')
                calculate_indicators_withoutConflicts(trip, full_directory);
                trip.setAttribute('calculate_indicators', 'OK');
            end
            
            %% CALCUL PEDALING STOP DISTANCE
            if calculate_PSD_needed && existSituation(trip.getMetaInformations(), 'pedalling') && existData(trip.getMetaInformations(), 'VRU_trajectories2')
                calculate_PSD_withoutConflicts(trip);
                trip.setAttribute('calculate_PSD', 'OK');
            end
            
            %% PLOT speed=f(x) by VRU_characteristics
            if plot_VRU_traj_needeed && existData(trip.getMetaInformations(), 'VRU_trajectories2') && existSituation(trip.getMetaInformations(), 'VRU_characteristics')
                % get data
                traj_x = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('VRU_trajectories2_1'));
                traj_y = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('VRU_trajectories2_2'));
                speed = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('speed'))*3.6;
                speed = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('accel'));
                var(:,1) = trip.getMetaInformations().getSituationVariablesNamesList('VRU_characteristics');
                var(:,2) = trip.getAllSituationOccurences('VRU_characteristics').buildCellArrayWithVariables(var(:,1));
                VRU_type = var{4,2};
                %             sidewalk_line_start_P1 = ;
                %             sidewalk_line_end_P1 = ;
                %             sidewalk_line_start_P2 = ;
                %             sidewalk_line_end_P2 = ;
                
                %% set VRU case
                switch n
                    case 1
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'none','adult'}; %,'no','no',[]};
                    case 2
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'none','elderly'}; %,'no','no',[]};
                    case 3
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'none','family'}; %,'no','no',[]};
                    case 4
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'no','adult'}; %,'no','no',[]};
                    case 5
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'no','elderly'}; %,'no','no',[]};
                    case 6
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'no','family'}; %,'no','no',[]};
                    case 7
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'yes','adult'}; %,'no','no',[]};
                    case 8
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'yes','elderly'}; %,'no','no',[]};
                    case 9
                        variables(:,1) = {'Car_presence','Age'}; %,'VRU_description','Waiting','Other_than_walking'};
                        variables(:,2) = {'yes','family'}; %,'no','no',[]};
                end

                %% C2 ALL speed
                if strcmp(VRU_type, 'C2')% && check_group_charact(var, variables(:,1), variables(:,2))
                    cmpt = cmpt + 1;
                    folder_num_list{cmpt} = folder_num;
                    short_title = VRU_type;
                    full_title = [VRU_type '__nb_fig=' num2str(cmpt)];
                    plot(traj_x, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
                    savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE' filesep 'Speed_' short_title '.fig'])
                    saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE' filesep 'Speed_' short_title '.png']);
                    hold on
                    pause(1)
                end

                %% P2 ALL accel
                if strcmp(VRU_type, 'P2')% && check_group_charact(var, variables(:,1), variables(:,2))
                    cmpt = cmpt + 1;
                    folder_num_list{cmpt} = folder_num;
                    short_title = VRU_type;
                    full_title = [VRU_type '__nb_fig=' num2str(cmpt)];
                    plot(traj_x, accel); title(full_title); xlabel('Distance (m)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
                    savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE' filesep 'Accel_' short_title '.fig'])
                    saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE' filesep 'Accel_' short_title '.png']);
                    hold on
                    pause(1)
                end
                
%                 %% C1
%                 if strcmp(VRU_type, 'C1') && check_group_charact(var, variables(:,1), variables(:,2))
%                     cmpt = cmpt + 1;
%                     folder_num_list{cmpt} = folder_num;
%                     short_title = [VRU_type '_' build_title(variables(1:2,:))]; % '_Running=no'];
%                     full_title = [VRU_type '_' build_title(variables(1:2,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                     plot(traj_x, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                     savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.fig'])
%                     saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.png']);
%                     hold on
%                     pause(1)
%                 end

%                 %% C2
%                 if strcmp(VRU_type, 'C2') && check_group_charact(var, variables(:,1), variables(:,2))
%                     cmpt = cmpt + 1;
%                     folder_num_list{cmpt} = folder_num;
%                     short_title = [VRU_type '_' build_title(variables(1:2,:))]; % '_Running=no'];
%                     full_title = [VRU_type '_' build_title(variables(1:2,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                     plot(traj_x, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                     savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.fig'])
%                     saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.png']);
%                     hold on
%                     pause(1)
%                 end

%                 %% P1
%                 if strcmp(VRU_type, 'P1') && check_group_charact(var, variables(:,1), variables(:,2))
%                     cmpt = cmpt + 1;
%                     folder_num_list{cmpt} = folder_num;
%                     short_title = [VRU_type '_' build_title(variables(1:2,:))]; % '_Running=no'];
%                     full_title = [VRU_type '_' build_title(variables(1:2,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                     plot(traj_y, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                     savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.fig'])
%                     saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.png']);
%                     hold on
%                     pause(1)
%                 end

%                 %% P2
%                 if strcmp(VRU_type, 'P2') && check_group_charact(var, variables(:,1), variables(:,2))
%                     cmpt = cmpt + 1;
%                     folder_num_list{cmpt} = folder_num;
%                     short_title = [VRU_type '_' build_title(variables(1:2,:))]; % '_Running=no'];
%                     full_title = [VRU_type '_' build_title(variables(1:2,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                     plot(traj_x, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                     savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.fig'])
%                     saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.png']);
%                     hold on
%                     pause(1)
%                 end

%                 %% P3
%                 if strcmp(VRU_type, 'P3') && check_group_charact(var, variables(:,1), variables(:,2))
%                     cmpt = cmpt + 1;
%                     folder_num_list{cmpt} = folder_num;
%                     short_title = [VRU_type '_' build_title(variables(1:2,:))]; % '_Running=no'];
%                     full_title = [VRU_type '_' build_title(variables(1:2,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                     plot(traj_y, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                     savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.fig'])
%                     saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.png']);
%                     hold on
%                     pause(1)
%                 end

%                 %% P4
%                 if strcmp(VRU_type, 'P4') && check_group_charact(var, variables(:,1), variables(:,2))
%                     cmpt = cmpt + 1;
%                     folder_num_list{cmpt} = folder_num;
%                     short_title = [VRU_type '_' build_title(variables(1:2,:))]; % '_Running=no'];
%                     full_title = [VRU_type '_' build_title(variables(1:2,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                     plot(traj_x, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                     savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.fig'])
%                     saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPE_AND_VARIABLES' filesep 'Speed_' short_title(1:end-1) '.png']);
%                     hold on
%                     pause(1)
%                 end
            end
            
            delete(trip)
        end
%     end
    % runnable.batchExportSituationTSV_PROSPECT()
end

function state = check_group_charact(variables, usefull_variables, characteristics)
    state = false;
    states = false(length(usefull_variables),1);
    for i_usefull_var = 1:length(usefull_variables)
        usefull_variable = usefull_variables(i_usefull_var);
        characteristic = characteristics(i_usefull_var);
        for i_var = 1:length(variables)
            if strcmp(variables(i_var,1), usefull_variable) && or(strcmp(variables(i_var,2), characteristic), and(isempty(variables{i_var,2}), isempty(characteristic{:})))
                states(i_usefull_var) = true;
                break
            end
        end
    end
    if mean(states) == true
        state = true;
    end
end

function title = build_title(charact)
    title = [];
    for i_charact = 1:length(charact)
        title = [title, '_' charact{i_charact,1} '=' charact{i_charact,2} '_'];
    end
end