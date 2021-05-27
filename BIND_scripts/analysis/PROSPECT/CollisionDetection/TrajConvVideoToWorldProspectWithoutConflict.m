function [TTC_null, Intersect, trip_problem] = TrajConvVideoToWorldProspectWithoutConflict(trip_file, trip_num)
    
    %% CHOOSE OPTIONS
    convert_traj_video2World = 0; % apply to update tracking
    remove_data_tables = 0;
    save_figures = 0;
    save_data = 0;
    
    %% GET DATA
    exec_file = '\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\prospect_calib_leost.exe';
    load('\\vrlescot\PROSPECT\CODAGE\trip_input_list_all.mat');
    trip_problem = 0;
    Intersect = 0;
    TTC_null = 0;
    site = 'Site 1';
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
%                 removeDataTables(trip, {'VRU_trajectories2'})
            end
        else
            delete(trip)
            return
        end
    end
    
    %% APPLY PROCESSES
    span = 25;
    cutoff = ceil(span/2);
%     threshold_speed = 0.1;
    for i_var = 1:length(var_names)-1
        if strcmp(var_names{i_var}, 'timecode')
            data_in.(var_names{i_var}) = cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))';
        elseif strcmp(var_names{i_var}(1:end-2), var_names{i_var+1}(1:end-2))
            data_in.(var_names{i_var}(1:end-2)) = [cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))', 2160-cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var+1}))']; % (2160-Y) to reverse Yaxis
            
            %% TRANSFORM POINT TRAJECTORY IN VIDEO BASIS TO WORLD BASIS
            if mean(cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))) ~= 0
%                 refPoint = var_names{i_var}(1:end-2);
                mask = find(data_in.(var_names{i_var}(1:end-2))(:,1) ~=0);
                data2write = int16(data_in.(var_names{i_var}(1:end-2))(mask(1):mask(end),:));
                
                % interpolate if find missing tracking values
                idx_zeros = find(data2write(:,1) == 0);
                for i_zeros = 1:length(idx_zeros)
                    if and(data2write(idx_zeros(i_zeros)+1,:) ~= 0, data2write(idx_zeros(i_zeros)-1,:) ~= 0)
                        data2write(idx_zeros(i_zeros),:) = (data2write(idx_zeros(i_zeros)+1,:)+data2write(idx_zeros(i_zeros)-1,:))/2;
                    elseif and(data2write(idx_zeros(i_zeros)+2,:) ~= 0, data2write(idx_zeros(i_zeros)-2,:) ~= 0)
                        data2write(idx_zeros(i_zeros),:) = (data2write(idx_zeros(i_zeros)+2,:)+data2write(idx_zeros(i_zeros)-2,:))/2;
                    end
                end
                
                idx_zeros = find(data2write(:,1) == 0);
                for i_zeros = 1:length(idx_zeros)
                    if and(data2write(idx_zeros(i_zeros)+1,:) ~= 0, data2write(idx_zeros(i_zeros)-1,:) ~= 0)
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
                traj_smooth_cutoff_expanded(:,1) = [traj_smooth(1:end-1,1)',(traj_smooth(end,1):0.04:traj_smooth(end,1))]';
                traj_smooth_cutoff_expanded(:,2:3) = interp1(traj_smooth_cutoff(:,1),traj_smooth_cutoff(:,2:3),[traj_smooth(1:end-1,1)',(traj_smooth(end,1):0.04:traj_smooth(end,1))]','spline','extrap');
                
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
                               
%                 traj_shape = traj_smooth_cutoff(1:end-1,1);
%                 for i_row = 1:length(traj_smooth_cutoff)-1
%                     X = traj_smooth_cutoff(i_row,2);
%                     Y = traj_smooth_cutoff(i_row,3);
%                     traj_shape(i_row,2:3) = [X,Y];
%                 end
                
                traj_shape_expanded = traj_smooth_cutoff_expanded(1:end-1,1);
                for i_row = 1:length(traj_smooth_cutoff_expanded)-1
                    X = traj_smooth_cutoff_expanded(i_row,2);
                    Y = traj_smooth_cutoff_expanded(i_row,3);
                    traj_shape_expanded(i_row,2:3) = [X,Y];
                end
                
                if ~isempty(strfind(var_names{i_var},'cyc')) || ~isempty(strfind(var_names{i_var},'ped'))
                    VRU_trajectories2_expanded = traj_shape_expanded;
                    data_out.VRU_trajectories2 = VRU_trajectories2_expanded;
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
    if save_figures
        savefig([full_directory filesep 'Figures' filesep trip_name '_trajectories.fig'])
        saveas(gcf,[full_directory filesep 'Figures' filesep trip_name '_trajectories.png'])
    end
    hold off
    
    %% WRITE DATA IN TRIP
    if save_data
        struct_matlab = import_MatlabFiles(data_out);
        import_data_struct_in_bind_trip(struct_matlab, trip, '');
        trip.setAttribute('import_trajectories_data2','OK');
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
