function TrajConvVideoToWorldProspect_test(trip_file, trip_num)
%% GET DATA
trip_file = '\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP2\34_20150922_164655_199A\20150922_164655_199A.trip';
exec_file = '\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\prospect_calib_leost.exe';
load('\\vrlescot\PROSPECT\CODAGE\trip_input_list_all.mat');
trip_num = 1;
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
        % removeDataTables(trip, {'CAR_trajectories2','VRU_trajectories2'})
    else
        return
    end
end

%% APPLY PROCESSES
for i_var = 1:7
    if strcmp(var_names{i_var}, 'timecode')
        data_in.(var_names{i_var}) = cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))';
    elseif strcmp(var_names{i_var}(1:end-2), var_names{i_var+1}(1:end-2))
        data_in.(var_names{i_var}(1:end-2)) = [cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))', 2160-cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var+1}))']; % (2160-Y) to reverse Yaxis
        
        %% TRANSFORM POINT TRAJECTORY IN VIDEO BASIS TO WORLD BASIS
        if mean(cell2mat(mark_traj_vid_ref.getVariableValues(var_names{i_var}))) ~= 0
            refPoint = var_names{i_var}(1:end-2);
            mask = find(data_in.(var_names{i_var}(1:end-2))(:,1) ~=0);
        end
    end
end
data2write = int16([data_in.car_front_left',data_in.car_front_right',data_in.car_back_left']');
filename = fullfile(full_directory, [trip_name '_' var_names{i_var}(1:end-2) '.csv.tmp']);
export_csv_temp_PROSPECT(filename, data2write)
command = buildCommandLine(exec_file, filename, [filename(1:end-3) '3d'], ' 0', xml_file); % height : 0
system(command)
data_use = [PROSPECT_import_CSV_file_4([filename(1:end-3) '3d'])/1000];
for i_row = 1:length(data_use)
    plot(data_use(i_row,1),data_use(i_row,2),'Marker','*','color','red')
    set(gca,'Ydir','reverse')
%     xlim([-10 60]);
%     ylim([-25 15]);
    hold on
end
saveas(gcf,[full_directory filesep 'background.png'])
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
