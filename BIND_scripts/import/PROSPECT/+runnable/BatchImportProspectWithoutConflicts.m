function BatchImportProspectWithoutConflicts()
%     for i_type = 2 %1:6
%         n = 0;
%         for n = 1:3
%             ymin = 0;
%             ymax = 0;
%             close all; clc;
%             figure('units','normalized','outerposition',[0 0 1 1])

            %% PATHS DEFINITION
            TRIPS_FOLDER = '\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts';
            load('\\vrlescot\PROSPECT\CODAGE\SANS_CONFLIT\Videos_brutes_non_conflits_version_Bind_V4.mat');

            cmpt = 0;
            folder_num_list = {};
            for i_video = 1:length(VideosbrutesnonconflitsversionBindV4)
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

                % force or avoid processes
                %         import_videos_needed = 1;
                %         import_data_needed = 1;
                %         import_coding_needed = 1;
                %         import_trajectories_data2_needed = 1;
                %         calculate_distance_vitesse_needed = 1;
%                         calculate_indicators_needed = 1;
                calculate_PSD_needed = 1;
                plot_VRU_traj_needeed = 0;

                %% ADD VIDEO LINKS TO THE TRIP
                convertVideo2MJPEG_alone_withoutClap_withPath(input_video_file_path, VideosbrutesnonconflitsversionBindV4{i_video,4}, VideosbrutesnonconflitsversionBindV4{i_video,5}, output_video_file_path)
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
                    TrajConvVideoToWorldProspectWithoutConflict(trip_file, i_video);
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

                %% PLOT trajectories, speeds=f(x), accels=f(x) by types and/or VRU_characteristics
                if plot_VRU_traj_needeed && existData(trip.getMetaInformations(), 'VRU_trajectories2') && existSituation(trip.getMetaInformations(), 'VRU_characteristics')
                    % get data
                    timecodes = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('timecode'));
                    traj_x = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('VRU_trajectories2_1'));
                    traj_y = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('VRU_trajectories2_2'));
                    speed = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('speed'))*3.6;
                    accel = cell2mat(trip.getAllDataOccurences('VRU_trajectories2').getVariableValues('accel'));
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
                            variables(:,1) = {'Age'}; % 'comment'}; % %,'Car_presence','VRU_description','Waiting','Other_than_walking'};
                            variables(:,2) = {'adult'}; % 'not go along'}; %,'none','no','no',[]};
                        case 2
                            variables(:,1) = {'Age'}; %,'Car_presence','VRU_description','Waiting','Other_than_walking'};
                            variables(:,2) = {'elderly'}; %,'none','no','no',[]};
                        case 3
                            variables(:,1) = {'Age'}; %,'Car_presence','VRU_description','Waiting','Other_than_walking'};
                            variables(:,2) = {'family'}; %,'none','no','no',[]};
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
                    n_var = 1;
                    types = {'C1', 'C2', 'P1', 'P2', 'P3', 'P4'}; % types : C1, C2, P2, P4 => horizontal trajectories
                                                                  % types : P1, P3 => vertical trajectories

                    %% 1/ By types

%                     % Plot trajectories
%                     if strcmp(VRU_type, types{i_type})
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         short_title = [VRU_type '_traj'];
%                         full_title = [VRU_type '_traj__nb_fig=' num2str(cmpt)];
%                         plot(traj_x, traj_y); title(full_title); xlabel('Distance (m)'); ylabel('Distance (m)'); legend(folder_num_list{:}); legend('show');
%                         xlim([-5 55]);
%                         ylim([-20 10]);
%                         set(gca,'Ydir','reverse')
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES' filesep VRU_type filesep 'fig' filesep short_title '.fig'])
%                         saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES' filesep VRU_type filesep short_title '.png']);
%                         hold on
%                         pause(1)
%                     end

%                     % Plot speeds
%                     if strcmp(VRU_type, types{i_type})
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         short_title = [VRU_type '_speed'];
%                         full_title = [VRU_type '_speed__nb_fig=' num2str(cmpt)];
%                         if strfind([types{1},types{2},types{4},types{6}], VRU_type) % horizontal trajectories
%                             plot(traj_x, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-5 55]);
%                         elseif strfind([types{3},types{5}], VRU_type) % vertical trajectories
%                             plot(traj_y, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-20 10]);
%                         end
%                         if strfind([types{1},types{2}], VRU_type)
%                             ylim([0 52]);
%                         else
%                             ylim([0 12]);
%                         end
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES' filesep VRU_type filesep 'fig' filesep short_title '.fig'])
%                         saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES' filesep VRU_type filesep short_title '.png']);
%                         hold on
%                         pause(1)
%                     end

%                     % Plot accels
%                     if strcmp(VRU_type, types{i_type})
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         short_title = [VRU_type '_accel'];
%                         full_title = [VRU_type '_accel__nb_fig=' num2str(cmpt)];
%                         if strfind([types{1},types{2},types{4},types{6}], VRU_type) % horizontal trajectories
%                             plot(traj_x, accel); title(full_title); xlabel('Distance (m)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-5 55]);
%                         elseif strfind([types{3},types{5}], VRU_type) % vertical trajectories
%                             plot(traj_y, accel); title(full_title); xlabel('Distance (m)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-20 10]);
%                         end
%                         if strfind([types{1},types{2}], VRU_type)
%                             ylim([-3 4]);
%                         else
%                             ylim([-3 2]);
%                         end
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES' filesep VRU_type filesep 'fig' filesep short_title '.fig'])
%                         saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES' filesep VRU_type filesep short_title '.png']);
%                         hold on
%                         pause(1)
%                     end

                    %% By types and categories

%                     % Plot trajectories
%                     if strcmp(VRU_type, types{i_type}) && check_group_charact(var, variables(:,1), variables(:,2)) % && max(traj_y) > -11
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         short_title = [VRU_type '_traj_' build_title(variables(1:n_var,:))]; % '_Running=no'];
%                         full_title = [VRU_type '_traj_' build_title(variables(1:n_var,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                         plot(traj_x, traj_y); title(full_title); xlabel('Distance (m)'); ylabel('Distance (m)'); legend(folder_num_list{:}); legend('show');
%                         xlim([-5 55]);
%                         ylim([-20 10]);
%                         set(gca,'Ydir','reverse')
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_VARIABLES' filesep VRU_type filesep 'traj' filesep 'fig' filesep short_title(1:end-1) '.fig']) %_ytrajSup-11
%                         saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_VARIABLES' filesep VRU_type filesep 'traj' filesep short_title(1:end-1) '.png']); %_ytrajSup-11
%                         hold on
%                         pause(1)
%                     end

%                     % Plot speeds
%                     if strcmp(VRU_type, types{i_type}) && check_group_charact(var, variables(:,1), variables(:,2)) && max(traj_y) > -11
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         short_title = [VRU_type '_speed_' build_title(variables(1:n_var,:))]; % '_Running=no'];
%                         full_title = [VRU_type '_speed_' build_title(variables(1:n_var,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                         if strfind([types{1},types{2},types{4},types{6}], VRU_type) % horizontal trajectories
%                             plot(traj_x, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-5 55]);
%                         elseif strfind([types{3},types{5}], VRU_type) % vertical trajectories
%                             plot(traj_y, speed); title(full_title); xlabel('Distance (m)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-20 10]);
%                         end
%                         if ymax < max(speed)+2
%                             ymax = max(speed)+2;
%                         end
%                         ylim([0 ymax]);
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_VARIABLES' filesep VRU_type filesep 'speed' filesep 'fig' filesep short_title(1:end-1) '_ytrajSup-11.fig'])
%                         saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_VARIABLES' filesep VRU_type filesep 'speed' filesep short_title(1:end-1) '_ytrajSup-11.png']);
%                         hold on
%                         pause(1)
%                     end

%                     % Plot accels
%                     if strcmp(VRU_type, types{i_type}) && check_group_charact(var, variables(:,1), variables(:,2))
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         short_title = [VRU_type '_accel_' build_title(variables(1:n_var,:))]; % '_Running=no'];
%                         full_title = [VRU_type '_accel_' build_title(variables(1:n_var,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                         if strfind([types{1},types{2},types{4},types{6}], VRU_type) % horizontal trajectories
%                             plot(traj_x, accel); title(full_title); xlabel('Distance (m)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-5 55]);
%                         elseif strfind([types{3},types{5}], VRU_type) % vertical trajectories
%                             plot(traj_y, accel); title(full_title); xlabel('Distance (m)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-20 10]);
%                         end
%                         if ymax < max(accel)+1
%                             ymax = max(accel)+1;
%                         end
%                         if min(accel) < 0 && ymin > min(accel)-1
%                             ymin = min(accel)-1;
%                         end
%                         ylim([ymin, ymax]);  
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_VARIABLES' filesep VRU_type filesep 'accel' filesep 'fig' filesep short_title(1:end-1) '.fig'])
%                         saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_VARIABLES' filesep VRU_type filesep 'accel' filesep short_title(1:end-1) '.png']);
%                         hold on
%                         pause(1)
%                     end

                    %% By types and categories for pedestrians 3s before/after slow down/stop walking

%                     % Plot speeds and accels around 0km/h
%                     if ~isempty(strfind(VRU_type, 'P')) && min(round(speed)) == 0 && check_group_charact(var, variables(:,1), variables(:,2))
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         [~, idx] = min(speed);
%                         speeds_around0 = speed(max(1,idx-75):min(length(speed),idx+75));
%                         accels_around0 = accel(max(1,idx-75):min(length(speed),idx+75));
%                         timecodes_around0 = timecodes(max(1,idx-75):min(length(speed),idx+75))-timecodes(idx);
%                         
%                         %plot speeds
%                         short_title = [VRU_type(1:1) '_speed_' build_title(variables(1:n_var,:))]; % '_Running=no'];
%                         full_title = [VRU_type(1:1) '_speed_' build_title(variables(1:n_var,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                         plot(timecodes_around0, speeds_around0); title(full_title); xlabel('Time (s)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                         xlim([-3 3]);
%                         ylim([0 10]);
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'speed' filesep 'fig' filesep short_title(1:end-1) '_speedAround0.fig'])
%                         saveas(gcf, ['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'speed' filesep short_title(1:end-1) '_speedAround0.png']);
%                         
%                         %plot accels
%                         short_title = [VRU_type(1:1) '_accel_' build_title(variables(1:n_var,:))]; % '_Running=no'];
%                         full_title = [VRU_type(1:1) '_accel_' build_title(variables(1:n_var,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                         plot(timecodes_around0, accels_around0); title(full_title); xlabel('Time (s)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
%                         xlim([-3 3]);
%                         ylim([-3 2]);
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'accel' filesep 'fig' filesep short_title(1:end-1) '_speedAround0.fig'])
%                         saveas(gcf, ['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'accel' filesep short_title(1:end-1) '_speedAround0.png']);
%                         
%                         hold on
%                         pause(1)
%                     end
                    
%                     % Plot speeds and accels less than 1km/h
%                     if ~isempty(strfind(VRU_type, 'P')) && min(speed) < 1 && check_group_charact(var, variables(:,1), variables(:,2)) % && strcmp(VRU_type, types{i_type}) 
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         [~, idx] = min(speed);
%                         speeds_around0 = speed(max(1,idx-75):min(length(speed),idx+75));
%                         accels_around0 = accel(max(1,idx-75):min(length(speed),idx+75));
%                         timecodes_around0 = timecodes(max(1,idx-75):min(length(speed),idx+75))-timecodes(idx);
%                         
%                         %plot speeds
%                         short_title = [VRU_type(1:1) '_speed_' build_title(variables(1:n_var,:))]; % '_Running=no'];
%                         full_title = [VRU_type(1:1) '_speed_' build_title(variables(1:n_var,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                         plot(timecodes_around0, speeds_around0); title(full_title); xlabel('Time (s)'); ylabel('Speed (km/h)'); legend(folder_num_list{:}); legend('show');
%                         xlim([-3 3]);
%                         ylim([0 10]);
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'speed' filesep 'fig' filesep short_title(1:end-1) '_speedInf1kmh.fig'])
%                         saveas(gcf, ['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'speed' filesep short_title(1:end-1) '_speedInf1kmh.png']);
%                         
% %                         %plot accels
% %                         short_title = [VRU_type(1:1) '_accel_' build_title(variables(1:n_var,:))]; % '_Running=no'];
% %                         full_title = [VRU_type(1:1) '_accel_' build_title(variables(1:n_var,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
% %                         plot(timecodes_around0, accels_around0); title(full_title); xlabel('Time (s)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
% %                         xlim([-3 3]);
% %                         ylim([-3 2]);
% %                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'accel' filesep 'fig' filesep short_title(1:end-1) '_speedInf1kmh.fig'])
% %                         saveas(gcf, ['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'accel' filesep short_title(1:end-1) '_speedInf1kmh.png']);
%                         
%                         hold on
%                         pause(1)
% 
%                         %save values
%                         if all(and(speeds_around0 < 151, idx < 76))
%                             nb_NAN = 151 - length(speeds_around0);
%                             speeds_around0_out = [str2num(folder_num), NaN(nb_NAN, 1)', speeds_around0];
%                             accels_around0_out = [str2num(folder_num), NaN(nb_NAN, 1)', accels_around0];
%                         elseif all(and(speeds_around0 < 151, idx >= 76))
%                             nb_NAN = 151 - length(speeds_around0);
%                             speeds_around0_out = [str2num(folder_num), speeds_around0, NaN(nb_NAN, 1)'];
%                             accels_around0_out = [str2num(folder_num), accels_around0, NaN(nb_NAN, 1)'];
%                         else
%                             speeds_around0_out = [str2num(folder_num), speeds_around0];
%                             accels_around0_out = [str2num(folder_num), accels_around0];
%                         end
% 
%                         speeds_file_name = ['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'speed' filesep short_title(1:end-1) '_speedInf1kmh'];
%                         speeds_around0_out_all(cmpt,:) = speeds_around0_out;
%                         
% %                         accels_file_name = ['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_SD_SW' filesep 'accel' filesep short_title(1:end-1) '_speedInf1kmh'];
% %                         accels_around0_out_all(cmpt,:) = accels_around0_out;
%                     end
                    
%                     % Plot accels
%                     if ~isempty(strfind(VRU_type, 'P')) && strcmp(VRU_type, types{i_type}) && min(speed) < 2 % && check_group_charact(var, variables(:,1), variables(:,2))
%                         cmpt = cmpt + 1;
%                         folder_num_list{cmpt} = folder_num;
%                         short_title = [VRU_type '_accel_' build_title(variables(1:n_var,:))]; % '_Running=no'];
%                         full_title = [VRU_type '_accel_' build_title(variables(1:n_var,:)) '_nb_fig=' num2str(cmpt)]; % '_Running=no'];
%                         if strfind([types{1},types{2},types{4},types{6}], VRU_type) % horizontal trajectories
%                             plot(traj_x, accel); title(full_title); xlabel('Distance (m)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-5 55]);
%                         elseif strfind([types{3},types{5}], VRU_type) % vertical trajectories
%                             plot(traj_y, accel); title(full_title); xlabel('Distance (m)'); ylabel('Accel (m/s²)'); legend(folder_num_list{:}); legend('show');
%                             xlim([-20 10]);
%                         end
%                         if ymax < max(accel)+1
%                             ymax = max(accel)+1;
%                         end
%                         if min(accel) < 0 && ymin > min(accel)-1
%                             ymin = min(accel)-1;
%                         end
%                         ylim([ymin, ymax]);
%                         savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_VARIABLES' filesep VRU_type filesep 'accel' filesep 'fig' filesep short_title(1:end-1) '_speedInf2kmh.fig'])
%                         saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\VRU_TYPES_AND_VARIABLES' filesep VRU_type filesep 'accel' filesep short_title(1:end-1) '_speedInf2kmh.png']);
%                         hold on
%                         pause(1)
%                     end
                    
                end
                clear var
                delete(trip)
            end
%             csvwrite([speeds_file_name '.csv'], speeds_around0_out_all);
% %             csvwrite([accels_file_name '.csv'], accels_around0_out_all);
%             clear speeds_around0_out_all accels_around0_out_all
%         end
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
            % general case
            if strcmp(variables(i_var,1), usefull_variable) && or(strcmp(variables(i_var,2), characteristic), and(isempty(variables{i_var,2}), isempty(characteristic{:})))
                states(i_usefull_var) = true;
                break
%             % case if we want to group by comment other than "..."
%             elseif strcmp(variables(i_var,1), usefull_variable) && or(~strcmp(variables(i_var,2), {['not ' cell2mat(characteristic)]}), and(isempty(variables{i_var,2}), isempty(characteristic{:})))
%                 states(i_usefull_var) = true;
%                 break
            end
        end
    end
    if mean(states) == true
        state = true;
    end
end

function title = build_title(charact)
    title = [];
    for i_charact = 1:size(charact,1)
        title = [title, '_' charact{i_charact,1} '=' charact{i_charact,2} '_'];
    end
end