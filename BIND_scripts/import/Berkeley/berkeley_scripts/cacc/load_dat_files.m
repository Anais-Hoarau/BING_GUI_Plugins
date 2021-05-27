% load_dat_files.m  (CACC)
%
% Written by Christopher Nowakowski
% v.1 10/24/08
% v.2 02/10/10  - Moved create_event_table() off to a function in utilities
%
% This function loads the a, c, and d engineering files for a specified directory.  
% All three file types are loaded into a single CACC data structure that contains 
% all of the data for each of the three file types.
%
% This function can be used on a single sequence directory, or on a 
% raw directory of vehicle data (pre-import with the RealBasic program). Thus, if  
% there are multiple a, c, and d files in the specified directory, they will all
% be imported in file system alphabetical order.
%
% The number of a, c, and d files must be the same across file type.  Missing 
% files will trigger an error.
%
% .dat files that do not start with sa, sc, sd or ca, cc, or cd, will be ignored.
%
% Post-processing is done at this stage to convert units, recode variables, and 
% generate new metrics.  However, there are some exceptions: 
%
% 1. Synchronization to GMT is not done with or during this script.
% 2. Meta data is not filled in by this script.
%

function [data, error_log] = load_dat_files(seq_dir)

% Set Default Return Value
data = [];

% ------------------------------------------------------------------------------
% Check Input Arguments
% ------------------------------------------------------------------------------
if nargin == 0,
    % If no arguments bring up a select folder dialog box
    seq_dir = get_path;
    if isempty(seq_dir),
        seq_dir = '';
    end;
    seq_dir = uigetdir(seq_dir{1},'Select a folder containing CACC *.dat files...');
    if seq_dir == 0,
        % User Cancelled Dialog Box
        return;
    end;
elseif nargin == 1,
    % Check to make sure that the input argument is text
    temp = whos('seq_dir');
    if ~strcmp(temp.class,'char'),
        error('Usage: [data, error_message] = load_dat_files(''full_sequence_directory_path'')');
    end;
    
    % Check for help request
    if strcmpi(seq_dir,'?'),
        disp('Usage: [data, error_message] = load_dat_files(''full_sequence_directory_path'')');
        return;
    end;
else,
    % If there were multiple input arguments, error
    error('Usage: [data, error_message] = load_dat_files(''full_sequence_directory_path'')');
end;

% Check to make sure that the input directory exists
if exist(seq_dir,'dir') ~= 7,
    error_message = [seq_dir ' directory does not exist!'];
    error(error_message);
else
    % Make sure that there is a trailing file separator
    if not(strcmpi(seq_dir(length(seq_dir)),filesep)),
        seq_dir = [seq_dir filesep];
    end;
end;

% Initialize Error Log Counter
error_count = 0;
error_log = [];

% Get a list of files in the directory
file_list = dir([seq_dir '*.dat']);

if isempty(file_list),
    error_log{error_count+1,1} = ['Error: load_dat_files found no CACC *.dat files in ' seq_dir];
    error_log{error_count+2,1} = 'load_dat_files() operation aborted at line 83.';
    return;
end;

% ------------------------------------------------------------------------------
% Main File Opening Loop
% ------------------------------------------------------------------------------

% Initialize Temporary Data Variables
afile = [];
cfile = [];
dfile = [];

% Initialize Activity Log & Trip ID
%
% Row 1 = a files       |  Col 1 = 1st seq # opened
% Row 2 = c files       |  Col 2 = last seq # opened
% Row 3 = d files       |  Col 3 = total seq #'s opened
%
activity_log = -1 * ones(3,3);
trip_id = -1;
vehicle_id = 0;        % 0 for Unknown, -1 for Copper, 3 for Silver

% Loop through the list of files in the directory
for i=1:length(file_list),
    
    % --------------------------------------------------------------------------
    % Determine .dat File Type
    % --------------------------------------------------------------------------
    if strcmp(file_list(i).name(1:2),'sa') || strcmp(file_list(i).name(1:2),'ca'),
        format_string = get_file_input_format('afile');
    elseif strcmp(file_list(i).name(1:2),'sc') || strcmp(file_list(i).name(1:2),'cc'),
        format_string = get_file_input_format('cfile');
    elseif strcmp(file_list(i).name(1:2),'sd') || strcmp(file_list(i).name(1:2),'cd'),
        format_string = get_file_input_format('dfile');    
    else
        % File Name Does Not Match Known CACC a, c, or d Files - Skip Over It
        error_count = error_count + 1;
        error_log{error_count,1} = ['Warning: Unknown ' file_list(i).name ' encountered and skipped.'];
        continue;
    end;
    
    % Make sure that all the files being opened are from the same trip & set vehicle color
    str_start = length(file_list(i).name) - 10;
    str_end = length(file_list(i).name) - 7;
    if trip_id == -1,
        trip_id = str2num(file_list(i).name(str_start:str_end));
        if strcmp(file_list(i).name(1), 's'),
            vehicle_id = 3; % Silver
        else,
            vehicle_id = -1; % Copper
        end;
    elseif trip_id ~= str2num(file_list(i).name(str_start:str_end)),
        error_log{error_count+1,1} = ['Error: Multiple trip IDs were detected in the .dat files in ' seq_dir];
        error_log{error_count+2,1} = 'load_dat_files() operation aborted at line 136.';
        return;
    end;
    
    % --------------------------------------------------------------------------
    % Open & Read .dat File
    % --------------------------------------------------------------------------
    fid = fopen([seq_dir file_list(i).name],'r');
    if fid == -1,
        error_count = error_count + 1;
        error_log{error_count,1} = ['Warning: ' seq_dir file_list(i).name 'could not be opened and was skipped.'];
        continue;
    end;
    temp_data = textscan(fid,format_string);
    fclose(fid);
    clear fid;
    
    % Get the Sequence Number of the File Just Opened
    str_start = length(file_list(i).name) - 6;
    str_end = length(file_list(i).name) - 4;
    seq_num = str2num(file_list(i).name(str_start:str_end));
    
    % Update the Activity Log and Put the Data into a Temp Variable
    if length(format_string) == 57,
        % Update A-File Activity Log
        if activity_log(1,1) == -1,
            activity_log(1,1) = seq_num;
            activity_log(1,2) = seq_num;
            activity_log(1,3) = 1;
        else
            if (seq_num - activity_log(1,2)) ~= 1,
                error_count = error_count + 1;
                error_log{error_count,1} = ['Warning: a-files skipped from sequence # ' num2str(activity_log(1,2)) ' to ' num2str(seq_num)];
            end;
            activity_log(1,2) = seq_num;
            activity_log(1,3) = activity_log(1,3) + 1;
        end;
        
        % Update Temporary A-File Cell Array
        afile = vertcat(afile, temp_data);
        
    elseif length(format_string) == 88,
        % Update C-File Activity Log
        if activity_log(2,1) == -1,
            activity_log(2,1) = seq_num;
            activity_log(2,2) = seq_num;
            activity_log(2,3) = 1;
        else
            if (seq_num - activity_log(2,2)) ~= 1,
                error_count = error_count + 1;
                error_log{error_count,1} = ['Warning: c-files skipped from sequence # ' num2str(activity_log(2,2)) ' to ' num2str(seq_num)];
            end;
            activity_log(2,2) = seq_num;
            activity_log(2,3) = activity_log(2,3) + 1;
        end;
        
        % Update Temporary C-File Cell Array
        cfile = vertcat(cfile, temp_data);
        
    elseif length(format_string) == 123,
        % Update D-File Activity Log
        if activity_log(3,1) == -1,
            activity_log(3,1) = seq_num;
            activity_log(3,2) = seq_num;
            activity_log(3,3) = 1;
        else
            if (seq_num - activity_log(3,2)) ~= 1,
                error_count = error_count + 1;
                error_log{error_count,1} = ['Warning: d-files skipped from sequence # ' num2str(activity_log(3,2)) ' to ' num2str(seq_num)];
            end;
            activity_log(3,2) = seq_num;
            activity_log(3,3) = activity_log(3,3) + 1;
        end;
        
        % Update Temporary D-File Cell Array
        dfile = vertcat(dfile, temp_data);
    end;

end;

% ------------------------------------------------------------------------------
% Check Activity Log For Errors
% ------------------------------------------------------------------------------
if activity_log(3,1) == -1,
    error_log{error_count + 1,1} = 'Error: No d.dat files were found.';
    error_log{error_count + 2,1} = 'load_dat_files() operation aborted at line 221.';
    return;
end;
if activity_log(1,1) ~= activity_log(2,1) || activity_log(1,1) ~= activity_log(3,1),
    error_log{error_count + 1,1} = ['Error: .dat files did not start at the same sequence number. A=' num2str(activity_log(1,1)) ' C=' num2str(activity_log(2,1)) ' D=' num2str(activity_log(3,1))];
    error_log{error_count + 2,1} = 'load_dat_files() operation aborted at line 226.';
    return;
end;
if activity_log(1,2) ~= activity_log(2,2) || activity_log(1,2) ~= activity_log(3,2),
    error_log{error_count + 1,1} = ['Warning: .dat files did not end at the same sequence number. A=' num2str(activity_log(1,2)) ' C=' num2str(activity_log(2,2)) ' D=' num2str(activity_log(3,2))];
    error_log{error_count + 2,1} = 'load_dat_files() operation aborted at line 231.';
    return;
end;
if activity_log(1,3) ~= activity_log(2,3) || activity_log(1,3) ~= activity_log(3,3),
    error_log{error_count + 1,1} = ['Error: The number of .dat files by file type was not consistent. A=' num2str(activity_log(1,3)) ' C=' num2str(activity_log(2,3)) ' D=' num2str(activity_log(3,3))];
    error_log{error_count + 2,1} = 'load_dat_files() operation aborted at line 235.';
    return;
end;

% ------------------------------------------------------------------------------
% Create Empty CACC Data Structure
% ------------------------------------------------------------------------------
data = create_empty_data_struct();

% ------------------------------------------------------------------------------
% Populate Final Data Structure with Temporary Data Files That Were Read In
% ------------------------------------------------------------------------------
for i=1:length(dfile(:,1)), % i corresponds to the number of .dat files that were vertcat'd together
    
    data.ts.text = vertcat(data.ts.text, dfile{i,1});
    data.ts.comm_sent = vertcat(data.ts.comm_sent, dfile{i,3});
    data.ts.comm_recv = vertcat(data.ts.comm_recv, dfile{i,4});
    data.ts.eng_sent = vertcat(data.ts.eng_sent, dfile{i,5});
    data.ts.eng_recv = vertcat(data.ts.eng_recv, dfile{i,6});
    data.veh.yaw_rate = vertcat(data.veh.yaw_rate, dfile{i,7});
    data.veh.accl_x = vertcat(data.veh.accl_x, dfile{i,8});
    data.veh.accl_y = vertcat(data.veh.accl_y, dfile{i,9});
    data.acc.active = vertcat(data.acc.active, dfile{i,10});
    data.acc.car_space = vertcat(data.acc.car_space, dfile{i,11});
    data.acc.appr_warn = vertcat(data.acc.appr_warn, dfile{i,12});
    data.acc.enabled = vertcat(data.acc.enabled, dfile{i,13});
    data.acc.buzzer = vertcat(data.acc.buzzer, dfile{i,14});
    data.acc.buzzer2 = vertcat(data.acc.buzzer2, dfile{i,15});
    data.acc.buzzer3 = vertcat(data.acc.buzzer3, dfile{i,16});
    data.acc.set_speed = vertcat(data.acc.set_speed, dfile{i,17});
    data.veh.throttle = vertcat(data.veh.throttle, dfile{i,18});
    data.veh.throttle_virtual = vertcat(data.veh.throttle_virtual, dfile{i,19});
    data.veh.brake = vertcat(data.veh.brake, dfile{i,20});
    % data.acc.main_sw = vertcat(data.acc.main_sw, dfile{i,21});
    data.veh.brake_pressure = vertcat(data.veh.brake_pressure, dfile{i,22});
    data.veh.speed = vertcat(data.veh.speed, dfile{i,23});
    data.gps.utc_time = vertcat(data.gps.utc_time, dfile{i,24});
    data.gps.long = vertcat(data.gps.long, dfile{i,25});
    data.gps.lat = vertcat(data.gps.lat, dfile{i,26});
    data.gps.alt = vertcat(data.gps.alt, dfile{i,27});
    data.gps.speed = vertcat(data.gps.speed, dfile{i,28});
    data.gps.sat = vertcat(data.gps.sat, dfile{i,29});
    data.gps.utc_date = vertcat(data.gps.utc_date, dfile{i,30});
    data.acc.lidar_target_id = vertcat(data.acc.lidar_target_id, dfile{i,31});
    data.acc.dist = vertcat(data.acc.dist, dfile{i,32});
    data.acc.rel_speed = vertcat(data.acc.rel_speed, dfile{i,33});
    data.veh.rpm = vertcat(data.veh.rpm, afile{i,4});
    data.veh.torque = vertcat(data.veh.torque, afile{i,5});
    data.veh.shift = vertcat(data.veh.shift, afile{i,6});
    data.veh.gear = vertcat(data.veh.gear, afile{i,7});
    data.veh.wheel_rpm = vertcat(data.veh.wheel_rpm, afile{i,8});
    data.veh.outputshaft_rpm = vertcat(data.veh.outputshaft_rpm, afile{i,11});
    data.veh.turbine_rpm = vertcat(data.veh.turbine_rpm, afile{i,12});
    data.veh.torque_target = vertcat(data.veh.torque_target, afile{i,13});
    data.acc.target_lock = vertcat(data.acc.target_lock, afile{i,14});
    data.acc.virtual_dist = vertcat(data.acc.virtual_dist, afile{i,15});
    data.acc.virtual_speed = vertcat(data.acc.virtual_speed, afile{i,16});
    data.comm.msg_count = vertcat(data.comm.msg_count, cfile{i,7});
    data.comm.throttle = vertcat(data.comm.throttle, cfile{i,9});
    data.comm.throttle_virtual = vertcat(data.comm.throttle_virtual, cfile{i,10});
    data.comm.rpm = vertcat(data.comm.rpm, cfile{i,11});
    data.comm.torque = vertcat(data.comm.torque, cfile{i,12});
    data.comm.shift = vertcat(data.comm.shift, cfile{i,13});
    data.comm.gear = vertcat(data.comm.gear, cfile{i,14});
    data.comm.wheel_rpm = vertcat(data.comm.wheel_rpm, cfile{i,15});
    data.comm.brake = vertcat(data.comm.brake, cfile{i,16});
    data.comm.target_lock = vertcat(data.comm.target_lock, cfile{i,17});
    data.comm.car_space = vertcat(data.comm.car_space, cfile{i,18});
    data.comm.set_speed = vertcat(data.comm.set_speed, cfile{i,19});
    data.comm.brake_pressure = vertcat(data.comm.brake_pressure, cfile{i,20});
    data.comm.dist = vertcat(data.comm.dist, cfile{i,21});
    data.comm.rel_speed = vertcat(data.comm.rel_speed, cfile{i,22});
    data.comm.yaw_rate = vertcat(data.comm.yaw_rate, cfile{i,23});
    data.comm.speed = vertcat(data.comm.speed, cfile{i,24});

end;

% ------------------------------------------------------------------------------
% Check for an empty data set
% ------------------------------------------------------------------------------
if isempty(data.ts.text),
    % Reset Default Return Value
    data = [];
    % Update Error Log
    error_log{error_count+1,1} = ['Warning: load_dat_files() skipped the following directory because it contained no data: ' seq_dir];
    return;
end;


% ------------------------------------------------------------------------------
% Post Processing - Conversions - Recoding - New Parameter Generation
% ------------------------------------------------------------------------------


% Convert Text TimeStamp to SSM
% data.ts.ssm = str2num(data.ts.text(:,1:2))*3600 + str2num(data.ts.text(:,4:5))*60 + str2num(data.ts.text(:,7:12));
data.ts.ssm = convert_text_ts(data.ts.text);


% Recode DriverBrake (originally 0 = on / 1 = off)
data.veh.brake = int8(~data.veh.brake);


% Convert all speeds to m/s
data.veh.speed = data.veh.speed/3.6; % km/h -> m/s
data.gps.speed = data.gps.speed/3.6; % km/h -> m/s
data.acc.set_speed = data.acc.set_speed*0.44704; % mph -> m/s
% data.acc.rel_speed - Arleady in m/s
% data.acc.virtual_speed - Already in m/s
data.comm.set_speed = data.comm.set_speed*0.44704; % mph -> m/s
% data.comm.rel_speed - Already in m/s
data.comm.speed = data.comm.speed/3.6; % km/h -> m/s


% Convert GPS Format from dddmm.mmmmmm -> ddd.dddddddd
data.gps.lat = convert_gps_2_deg(data.gps.lat);
data.gps.long = convert_gps_2_deg(data.gps.long);


% Filter acc.car_space to 0 when the acc system is turned off
index = find(data.acc.enabled == 0);
data.acc.car_space(index) = 0;


% Recode acc.car_space and comm.car_space
% Remapping to 1-6 from shortest to longest gap setting.  Setting 4 overlaps between copper and silver.
% vehicle_id: 0 for unknown, -1 for copper, 3 for silver
index = find(data.acc.car_space ~= 0);
data.acc.car_space(index) = data.acc.car_space(index) + vehicle_id;
if vehicle_id == -1,
    % Copper car_space is 2 though 5 where 2 is the longest gap
    % First remapping changes it to 1 through 4 where 1 is the longest gap
    % This remapping reverses it to 1 thorugh 4 where 1 is the shortest gap
    data.acc.car_space(index) = 5 - data.acc.car_space(index);
end;
% data.comm.car_space is always remapped to silver (+3)
index = find(data.comm.car_space ~= 0);
data.comm.car_space(index) = data.comm.car_space(index) + 3;


% Generate data.acc.gap_setting (in seconds)
data.acc.gap_setting = zeros(length(data.veh.speed),1);
index = find(data.acc.car_space == 1);
data.acc.gap_setting(index) = 0.6;
index = find(data.acc.car_space == 2);
data.acc.gap_setting(index) = 0.7;
index = find(data.acc.car_space == 3);
data.acc.gap_setting(index) = 0.9;
index = find(data.acc.car_space == 4);
data.acc.gap_setting(index) = 1.1;
index = find(data.acc.car_space == 5);
data.acc.gap_setting(index) = 1.6;
index = find(data.acc.car_space == 6);
data.acc.gap_setting(index) = 2.2;


% Filter out data.acc.set_speed blinking events (set_speed alternates to 0)
% Forward Pass (replace 0's with previous set_speed if available)
index = find(data.acc.active == 1 & data.acc.set_speed == 0);
if (~isempty(index)),
    for i=1:length(index),
        % Check for array out of bounds
        if ((index(i) - 1) < 1),
            continue;
        end;
        % Check to make sure that previous set_speed was not 0
        if (data.acc.set_speed(index(i)-1) == 0),
            continue;
        end;
        % Replace a 0 set_speed with previous set_speed
        data.acc.set_speed(index(i)) = data.acc.set_speed(index(i)-1);
    end;
end;
% Reverse Pass (replace 0's with next non-zero set_speed if needed
index = find(data.acc.active == 1 & data.acc.set_speed == 0);
if (~isempty(index)),
    for i=length(index):-1:1,
        % Check for array out of bounds
        if ((index(i) + 1) > length(data.acc.set_speed)),
            continue;
        end;
        % Check to make sure that previous set_speed was not 0
        if (data.acc.set_speed(index(i)+1) == 0),
            continue;
        end;
        % Replace a 0 set_speed with previous set_speed
        data.acc.set_speed(index(i)) = data.acc.set_speed(index(i)+1);
    end;
end;


% Recode data.acc warnings and buzzers to be 0 or 1 flags
index = find(data.acc.appr_warn > 0);
data.acc.appr_warn(index) = 1;
index = find(data.acc.buzzer > 0);
data.acc.buzzer(index) = 1;
index = find(data.acc.buzzer2 > 0);
data.acc.buzzer2(index) = 1;
index = find(data.acc.buzzer3 > 0);
data.acc.buzzer3(index) = 1;


% Generate data.acc.low_speed_warn
data.acc.low_speed_warn = data.acc.buzzer;


% Recode all Relative Speeds (Originally + if closing gap / - if opening gap)
data.acc.rel_speed = -data.acc.rel_speed;
data.acc.virtual_speed = -data.acc.virtual_speed;
data.comm.rel_speed = -data.comm.rel_speed;


% Recode Longitudinal Acceleration (Originally + if slowing / - if speeding up)
data.veh.accl_x = -data.veh.accl_x;


% Generate Lead Vehicle Speed (rel_speed is - if closing gap / + if opening gap)
data.acc.lead_veh_speed = data.veh.speed + data.acc.rel_speed;
% Set lead vehicle speed to -1 if there is no lead vehicle registered by the lidar
index = find(data.acc.dist == 0);
data.acc.lead_veh_speed(index) = -1;


% Generate Comm Lead Vehicle Speed (rel_speed is - if closing gap / + if opening gap)
data.comm.lead_veh_speed = data.comm.speed + data.comm.rel_speed;
% Set lead vehicle speed to -1 if there is no lead vehicle registered by the lidar
index = find(data.comm.dist == 0);
data.comm.lead_veh_speed(index) = -1;


% Generate data.acc.time_gap (Following Time Gap)
% Initialize
data.acc.time_gap = zeros(length(data.veh.speed),1);
data.acc.time_gap(:) = -1;
% Generate Time Gap When Self Speed > 0 And Target is Present
index = find(data.veh.speed > 0 & data.acc.dist > 0);
data.acc.time_gap(index) = data.acc.dist(index) ./ data.veh.speed(index);


% Generate data.acc.mode (Speed Regulation vs. Gap Regulation)
data.acc.mode = zeros(length(data.veh.speed),1);
% Set default when acc is active to speed regulation mode
index = find(data.acc.active == 1);
data.acc.mode(index) = 1;                                                       %#ok<*FNDSB>
% Find cases where...
%    1.  lead vehicle is present and below current gap setting + low threshold
index = find(data.acc.active == 1 & data.acc.time_gap > 0 & data.acc.time_gap < data.acc.gap_setting + .2);
data.acc.mode(index) = 2;
% Find cases where...
%    1. vehicle speed is lower than set speed - threshold
%    2. lead vehicle is present and below current gap setting + high threshold
index = find(data.acc.active == 1 & (data.acc.set_speed - data.veh.speed) > 1.4 & data.acc.time_gap > 0 & (data.acc.gap_setting + 0.4 - data.acc.time_gap) > 0);
data.acc.mode(index) = 2;
% Filter Gap Regulation Events (drop/merge events)
index = find(data.acc.mode == 2);
if ~isempty(index),
    gr_et = create_event_table(index);
    if length(gr_et(:,1)) > 1,
        result = filter_gapreg_event_table(data,gr_et);
        data.acc.mode(1:length(data.acc.mode)) = result;
        clear result;
    end;
    clear gr_et;
end;    
    
    
% Generate data.acc.ttc (Time to Collision)
% Initialize
data.acc.ttc = zeros(length(data.acc.rel_speed),1);
data.acc.ttc(:) = -1;
% Filter out cases where TTC is undefined: i.e., where gap is steady or opening
index = find(data.acc.rel_speed < 0);
% Calculate TTC (and flip the sign so that it is positive)
data.acc.ttc(index) = data.acc.dist(index) ./ -data.acc.rel_speed(index);

end


% ------------------------------------------------------------------------------
% Function to Filter the Gap Regulation Event Table
% ------------------------------------------------------------------------------
function [result] = filter_gapreg_event_table(data,event_table)


% ------------------------------------------------------------------------------
% 0.  Initialize New Result
% ------------------------------------------------------------------------------

% Generate system off as the default result mode
result = zeros(length(data.acc.mode),1);

% Set the default result mode when acc is active to speed regulation mode
index = find(data.acc.active == 1);
result(index) = 1; 

% ------------------------------------------------------------------------------
% 1.  Merge Events that Appear Separated Due to Target Drop-outs
% ------------------------------------------------------------------------------

% Initialize Filtered Event Table (fet)
n = 1;
fet(n,1) = n;
fet(n,2) = event_table(n,2);
fet(n,3) = event_table(n,3);

% Loop Through Event_Table Rows (Starting from Row 2)
for i=2:length(event_table(:,1)),
    
    % Set Loop Default
    start_new_event = 1;
    
    % Check if current event is within 4 second (80 samples) of last event
    if (event_table(i,2) - fet(n,3)) < 80,
        
        % Check if lead vehicle time gap at end of last event is near the lead vehicle time gap at the current event
        if abs(data.acc.time_gap(event_table(i,2)) - data.acc.time_gap(fet(n,3))) <= .4,
        
            % Merge Events
            fet(n,3) = event_table(i,3);
            start_new_event = 0;
        end;
    end;
        
    % Start a new row in the filtered event table
    if start_new_event == 1,
        n = n + 1;
        fet(n,1) = n;
        fet(n,2) = event_table(i,2);
        fet(n,3) = event_table(i,3);
    end;
end;
event_table = fet;
clear n fet i start_new_event;

% ------------------------------------------------------------------------------
% 2.  Eliminate Short Events Probably Due to Spurious Target Acquisitions
% ------------------------------------------------------------------------------

% Loop Through Event_Table Rows (Starting from Row 1)
n = 0;
for i=1:length(event_table(:,1)),
    
    % Check if current event is shorter than 1 second (20 samples)
    if (event_table(i,3) - event_table(i,2)) > 20,
        n = n + 1;
        fet(n,1) = n;
        fet(n,2:3) = event_table(i,2:3);
    end;
end;

% Test to see if all events were eliminated
if exist('fet','var'),
    event_table = fet;
end;
clear n i fet;


% ------------------------------------------------------------------------------
% 3.  Use Event Table to Generate New Result
% ------------------------------------------------------------------------------
for i=1:length(event_table(:,1)),
    result(event_table(i,2):event_table(i,3)) = 2;
end;

end