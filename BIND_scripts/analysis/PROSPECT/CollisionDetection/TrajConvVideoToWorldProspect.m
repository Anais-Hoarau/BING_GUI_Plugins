function [TTC_null, Intersect, trip_problem] = TrajConvVideoToWorldProspect(trip_file, trip_num)
    
    %% CHOOSE OPTIONS
    trajectory_expansion_time = 0; % default 0
    convert_traj_video2World = 0; % apply to update tracking
    trip_num_expand = 1:124; % default 0 (no one trip_num = 0)
    save_extrap_traj_plot = 0;
    save_others_figures = 0;
    remove_data_tables = 0;
    TTC_and_PET_needed = 0;
    break_time_plot = 0;
    save_data = 0;
    
    %% GET DATA
    exec_file = '\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\prospect_calib_leost.exe';
    load('\\vrlescot\PROSPECT\CODAGE\trip_input_list_all.mat');
    trip_problem = 0;
    Intersect = 0;
    TTC_null = 0;
    site = tripinputlistall{trip_num,6};
    if strcmp(site, 'Site 1')
        xml_file = '\\vrlescot.ifsttar.fr\PROSPECT\CODAGE\DATA_CALIBRATION\camera_site1.xml';
    elseif strcmp(site, 'Site 2')
        xml_file = '\\vrlescot.ifsttar.fr\PROSPECT\CODAGE\DATA_CALIBRATION\camera_site2.xml';
    end
    idx_sep = strfind(trip_file, '\');
    full_directory = trip_file(1:idx_sep(end)-1);
    trip_name = trip_file(idx_sep(end)+1:end-5);
    if exist(trip_file, 'file')
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        if trip.getMetaInformations().existData('markersTraj_videoRef')
            mark_traj_vid_ref = trip.getAllDataOccurences('markersTraj_videoRef');
            var_names = mark_traj_vid_ref.getVariableNames;
            if remove_data_tables
                removeDataTables(trip, {'CAR_trajectories2','VRU_trajectories2','TTC_PET'})
            end
        else
            delete(trip)
            return
        end
    end
    
    %% APPLY PROCESSES
    span = 25;
    cutoff = ceil(span/2);
    threshold_speed = 0.1;
    for i_var = 1:length(var_names)-1
        if strcmp(var_names{i_var}, 'timecode')
            data_in.(var_names{i_var}) = cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))';
        elseif strcmp(var_names{i_var}(1:end-2), var_names{i_var+1}(1:end-2))
            data_in.(var_names{i_var}(1:end-2)) = [cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))', 2160-cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var+1}))']; % (2160-Y) to reverse Yaxis
            
            %% TRANSFORM POINT TRAJECTORY IN VIDEO BASIS TO WORLD BASIS
            if mean(cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))) ~= 0
                refPoint = var_names{i_var}(1:end-2);
                mask = find(data_in.(var_names{i_var}(1:end-2))(:,1) ~=0);
                data2write = int16(data_in.(var_names{i_var}(1:end-2))(mask(1):mask(end),:));
                
                % interpolate if find missing tracking values
                idx_zeros = find(data2write(:,1) == 0);
                for i_zeros = 1:length(idx_zeros)
                    if or(data2write(idx_zeros(i_zeros)+1,:) ~= 0, data2write(idx_zeros(i_zeros)-1,:) ~= 0)
                        data2write(idx_zeros(i_zeros),:) = (data2write(idx_zeros(i_zeros)+1,:)+data2write(idx_zeros(i_zeros)-1,:))/2;
                    end
                end
                filename = fullfile(full_directory, [trip_name '_' var_names{i_var}(1:end-2) '.csv.tmp']);
                export_csv_temp_PROSPECT(filename, data2write)
                if convert_traj_video2World
                    command = buildCommandLine(exec_file, filename, [filename(1:end-3) '3d'], ' 0', xml_file); % height : 0
                    system(command)
                end
                
                %% CONVERT POINT TRAJECTORY TO SHAPE TRAJECTORY
                timecodes = data_in.timecode(mask(1):mask(end),:);
                traj_raw = [timecodes, PROSPECT_import_CSV_file_4([filename(1:end-3) '3d'])/1000];
                % traj_temp(:,1) = traj_raw(:,1);
                % traj_temp(:,i_var:i_var+1) = traj_raw(:,2:3);
                
                % smooth trajectories data
                traj_smooth(:,1) = traj_raw(:,1);
                traj_smooth(:,2) = smooth(smooth(traj_raw(:,2),span,'lowess'),span,'lowess');
                traj_smooth(:,3) = smooth(smooth(traj_raw(:,3),span,'lowess'),span,'lowess');
                
                % cuttoff and expand to correct false trajectories data due to smoothing
                % generating erronous data at begining and end of half span length
                traj_smooth_cutoff = traj_smooth(cutoff:end-cutoff,:);
                
                % expand to original traj time + X seconds depending "trajectory_expansion_time" parameter
                traj_smooth_cutoff_expanded(:,1) = [traj_smooth(1:end-1,1)',(traj_smooth(end,1):0.04:traj_smooth(end,1) + trajectory_expansion_time)]';
                traj_smooth_cutoff_expanded(:,2:3) = interp1(traj_smooth_cutoff(:,1),traj_smooth_cutoff(:,2:3),[traj_smooth(1:end-1,1)',(traj_smooth(end,1):0.04:traj_smooth(end,1) + trajectory_expansion_time)]','spline','extrap');
                
                % plot raw and smooth trajectories
                plot(traj_raw(:,2),traj_raw(:,3))
                hold on
                plot(traj_smooth_cutoff(:,2),traj_smooth_cutoff(:,3))
                plot(traj_smooth_cutoff_expanded(:,2),traj_smooth_cutoff_expanded(:,3))
                if strcmp(site, 'Site 1')
                    x_lim = [-10,60]; xlim(x_lim);
                    y_lim = [-30,20]; ylim(y_lim);
                elseif strcmp(site, 'Site 2')
                    x_lim = [-60,30]; xlim(x_lim);
                    y_lim = [-20,40]; ylim(y_lim);
                end
                set(gca,'Ydir','reverse')
                
                %% CHECK SPEED AND ANGLE SPEED
                %                 for i_row = 1:length(traj_smooth_cutoff)-2
                %                     %% GET COORDONATES DATAS
                %                     X1 = traj_smooth_cutoff(i_row,2);
                %                     Y1 = traj_smooth_cutoff(i_row,3);
                %                     X2 = traj_smooth_cutoff(i_row+1,2);
                %                     Y2 = traj_smooth_cutoff(i_row+1,3);
                %                     X3 = traj_smooth_cutoff(i_row+2,2);
                %                     Y3 = traj_smooth_cutoff(i_row+2,3);
                %
                %                     dt1 = traj_smooth_cutoff(i_row+1,1) - traj_smooth_cutoff(i_row,1);
                %                     dt2 = traj_smooth_cutoff(i_row+2,1) - traj_smooth_cutoff(i_row+1,1);
                %
                %                     v1 = [X2-X1,Y2-Y1]/dt1;
                %                     v2 = [X3-X2,Y3-Y2]/dt2;
                %
                %                     teta1 = atan(v1(2)/v1(1));
                %                     teta2 = atan(v2(2)/v2(1));
                %
                %                     Vteta = min(abs(teta2 - teta1),abs(teta2 - teta1 - pi))/dt2;
                %                     Vteta_array(i_row,:) = [traj_smooth_cutoff(i_row+2,1),norm(v2),Vteta];
                %                 end
                % %                 plot(Vteta_array(:,2),Vteta_array(:,3),'Marker','*');
                %                 plot(Vteta_array(:,1),Vteta_array(:,2),'Marker','*');
                %                 plot(Vteta_array(:,1),Vteta_array(:,3),'Marker','*');
                
                traj_shape = traj_smooth_cutoff(1:end-1,1);
                for i_row = 1:length(traj_smooth_cutoff)-1
                    X = traj_smooth_cutoff(i_row,2);
                    Y = traj_smooth_cutoff(i_row,3);
                    V = getLastValidOrientation(traj_smooth_cutoff,i_row,threshold_speed);
                    [A,B,C,D] = TrajConvPointToShapeProspect(X,Y,V,refPoint,trip_num);
                    traj_shape(i_row,2:3) = mean([A',B',C',D'],2)';
                end
                
                traj_shape_expanded = traj_smooth_cutoff_expanded(1:end-1,1);
                for i_row = 1:length(traj_smooth_cutoff_expanded)-1
                    X = traj_smooth_cutoff_expanded(i_row,2);
                    Y = traj_smooth_cutoff_expanded(i_row,3);
                    V = getLastValidOrientation(traj_smooth_cutoff_expanded,i_row,threshold_speed);
                    [A,B,C,D] = TrajConvPointToShapeProspect(X,Y,V,refPoint,trip_num);
                    traj_shape_expanded(i_row,2:3) = mean([A',B',C',D'],2)';
                end
                
                if ~isempty(strfind(var_names{i_var},'car'))
                    CAR_trajectories2 = traj_shape;
                    CAR_trajectories2_expanded = traj_shape_expanded;
                    traj_smooth_cutoff_car = traj_smooth_cutoff;
                    traj_smooth_cutoff_car_expanded = traj_smooth_cutoff_expanded;
                elseif ~isempty(strfind(var_names{i_var},'cyc')) || ~isempty(strfind(var_names{i_var},'ped'))
                    VRU_trajectories2 = traj_shape;
                    VRU_trajectories2_expanded = traj_shape_expanded;
                    traj_smooth_cutoff_vru = traj_smooth_cutoff;
                    traj_smooth_cutoff_vru_expanded = traj_smooth_cutoff_expanded;
                end
                %             delete(filename,[filename(1:end-3) '3d'])
                clear traj_smooth;
                clear traj_smooth_cutoff;
                clear traj_smooth_cutoff_expanded;
                clear traj_shape;
                clear traj_shape_expanded;
            end
        end
    end
    pause(break_time_plot)
    if save_others_figures
        savefig([full_directory filesep 'Figures' filesep trip_name '_trajectories.fig'])
        saveas(gcf,[full_directory filesep 'Figures' filesep trip_name '_trajectories.png'])
    end
    hold off
    
    %% PLOT BACKGROUND
    %     for i_row = 1:length(traj_temp)-1
    %         plot(traj_temp(i_row,2),traj_temp(i_row,3),'Marker','*')
    %         set(gca,'Ydir','reverse')
    %         hold on
    %         plot(traj_temp(i_row,4),traj_temp(i_row,5),'Marker','*')
    %         plot(traj_temp(i_row,6),traj_temp(i_row,7),'Marker','*')
    %         plot(traj_temp(i_row,8),traj_temp(i_row,9),'Marker','*')
    %     end
    
    tic;
    
    %% Reframe trajectories to be on the same timespan
    [timecodes,idx_1,idx_2] = intersect(traj_smooth_cutoff_car(:,1),traj_smooth_cutoff_vru(:,1));
    T0_codage = cell2mat(trip.getAllEventOccurences('interaction').getVariableValues('timecode'));
    T0 = cell2mat(trip.getDataOccurenceNearTime('timecode_data',T0_codage).getVariableValues('timecode'));
    
    if ~isempty(timecodes) && ~isempty(find(timecodes == T0,1)) && isempty(find(trip_num == trip_num_expand,1))
        data_out.CAR_trajectories2 = CAR_trajectories2;
        data_out.VRU_trajectories2 = VRU_trajectories2;
        traj_smooth_car_inter = traj_smooth_cutoff_car(idx_1,:);
        traj_smooth_vru_inter = traj_smooth_cutoff_vru(idx_2,:);
        data_out.TTC_PET = [timecodes, inf(length(timecodes),2)];
    elseif isempty(timecodes) || isempty(find(timecodes == T0,1)) || ~isempty(find(trip_num == trip_num_expand,1))
        data_out.CAR_trajectories2 = CAR_trajectories2_expanded;
        data_out.VRU_trajectories2 = VRU_trajectories2_expanded;
        [timecodes,idx_1,idx_2] = intersect(traj_smooth_cutoff_car_expanded(:,1),traj_smooth_cutoff_vru_expanded(:,1));
        traj_smooth_car_inter = traj_smooth_cutoff_car_expanded(idx_1,:);
        traj_smooth_vru_inter = traj_smooth_cutoff_vru_expanded(idx_2,:);
        data_out.TTC_PET = [timecodes, inf(length(timecodes),2)];
    end
    
    assert(length(traj_smooth_car_inter) == length(traj_smooth_vru_inter));
    try
        assert(isempty(find(diff(timecodes) > 0.05,1)));
    catch
        trip_problem = 1;
        delete(trip)
        return
    end
    
    %% Choose extrapolation methode
    % extrapolation_function = @ExtrTraj_RealTraj_RealSpeed;
    % extrapolation_function = @ExtrTraj_ExtrTraj_WithSpeed;
    % extrapolation_function = @ExtrTraj_ExtrTraj_WithSpeedAndAccel;
    extrapolation_function = @ExtrTraj_ExtrTraj_WithAccel;
    % extrapolation_function = @ExtrTraj_ExtrTraj_WithKalman;
    
    extr_func_struct = functions(extrapolation_function);
    function_name = strsplit(extr_func_struct.function,'_');
    
    for i_row = 1:length(traj_smooth_car_inter(:,1))-3
        
        %% EXTRAPOLATE TRAJECTORIES
        CAR_traj_extr = extrapolation_function(traj_smooth_car_inter,i_row,threshold_speed);
        VRU_traj_extr = extrapolation_function(traj_smooth_vru_inter,i_row,threshold_speed);
        
        if i_row == 1
            hold on
            plot(CAR_traj_extr(1,2),CAR_traj_extr(1,3),'Marker','*')
            plot(VRU_traj_extr(1,2),VRU_traj_extr(1,3),'Marker','*')
        else
            hold off
        end
        
        if i_row > 1
            CAR_traj_complete = [traj_smooth_car_inter(1:i_row-1,1:3)', CAR_traj_extr(:,1:3)']';
            VRU_traj_complete = [traj_smooth_vru_inter(1:i_row-1,1:3)', VRU_traj_extr(:,1:3)']';
        else
            CAR_traj_complete = CAR_traj_extr;
            VRU_traj_complete = VRU_traj_extr;
        end
        
        %% CONVERT POINT TRAJECTORY TO SHAPE TRAJECTORY
        CAR_shape_extr(:,1) = CAR_traj_extr(:,1);
        VRU_shape_extr(:,1) = VRU_traj_extr(:,1);
        for i_extr = 1:length(CAR_traj_extr)-1
            X = CAR_traj_extr(i_extr,2);
            Y = CAR_traj_extr(i_extr,3);
            V = getLastValidOrientation(CAR_traj_complete,i_row+i_extr-1,threshold_speed);
            [A,B,C,D] = TrajConvPointToShapeProspect(X,Y,V,'car',trip_num);
            CAR_shape_extr(i_extr,2:9) = [A,B,C,D];
        end
        CAR_shape_extr = CAR_shape_extr(1:end-1,:);
        
        for i_extr = 1:length(VRU_traj_extr)-1
            X = VRU_traj_extr(i_extr,2);
            Y = VRU_traj_extr(i_extr,3);
            V = getLastValidOrientation(VRU_traj_complete,i_row+i_extr-1,threshold_speed);
            [A,B,C,D] = TrajConvPointToShapeProspect(X,Y,V,'vru',trip_num);
            VRU_shape_extr(i_extr,2:9) = [A,B,C,D];
        end
        VRU_shape_extr = VRU_shape_extr(1:end-1,:);
        
        %% DETECTE COLLISION AND CALCULATE TTC/PET
        data_out.TTC_PET(i_row,1) = traj_smooth_car_inter(i_row,1);
        [data_out.TTC_PET(i_row,2),data_out.TTC_PET(i_row,3)] = CollisionDetection(CAR_shape_extr,VRU_shape_extr,x_lim,y_lim,TTC_and_PET_needed);
        
        %% SAVE TRAJECTORIES PLOTTED
        if save_extrap_traj_plot
            collision_tests_folder = [full_directory filesep 'Collision_tests'];
            if ~exist(collision_tests_folder,'dir')
                mkdir(collision_tests_folder);
            end
            pause(0.01)
            saveas(gcf,[collision_tests_folder filesep trip_name '_collision_test_' num2str(i_row) '_' cell2mat(function_name(2:end)) '.png'])
        end
        
        disp(['Au timecode ' num2str(traj_smooth_car_inter(i_row,1))]);
        disp(['le TTC est de : ' num2str(data_out.TTC_PET(i_row,2))])
        disp(['le PET est de : ' num2str(data_out.TTC_PET(i_row,3))])
    end
    toc;
    
    %% PLOT TTC/PET
    timecodes_video = cell2mat(trip.getAllDataOccurences('timecode_data').getVariableValues('timecode'));
    plot(data_out.TTC_PET(:,1),data_out.TTC_PET(:,2),'Marker','*');
    hold on;
    plot(data_out.TTC_PET(:,1),abs(data_out.TTC_PET(:,3)),'Marker','*');
    xlim([0,timecodes_video(end)]);
    ylim([0,10]);
    set(gca,'Ydir','normal')
    if save_others_figures
        savefig([full_directory filesep 'Figures' filesep trip_name '_TTC_PET.fig'])
        saveas(gcf,[full_directory filesep 'Figures' filesep trip_name '_TTC_PET.png'])
    end
    pause(break_time_plot);
    hold off;
    
    %% WRITE DATA IN TRIP
    if save_data
        struct_matlab = import_MatlabFiles(data_out);
        import_data_struct_in_bind_trip(struct_matlab, trip, '');
        trip.setAttribute('import_trajectories_data2','OK');
    end
    
    %% CHECK IF SITUATION INTERSECT OR NOT
    Intersect = find(~isnan(diff([data_out.TTC_PET(:,2)',data_out.TTC_PET(:,3)']')), 1);
    if ~isempty(Intersect)
        Intersect = 1;
    else
        Intersect = 0;
    end
    
    TTC_null = find(data_out.TTC_PET(:,2)' == 0, 1);
    if ~isempty(TTC_null)
        TTC_null = 1;
    else
        TTC_null = 0;
    end
    
    delete(trip)
end

%% EXPORT CSV TEMP FOR EACH OBJECT
function export_csv_temp_PROSPECT(filename, data2write)
    fid = fopen(filename, 'w');
    for rows=1:length(data2write)
        fprintf(fid, '%i;%i\n' , data2write(rows,:));
    end
    fclose(fid);
end

%% buildCommandLine
function commandLine = buildCommandLine(varargin)
    commandLine = '';
    for i=1:1:length(varargin)
        tmp = strtrim(varargin{i});
        commandLine = [commandLine tmp ' '];%#ok
    end
end
