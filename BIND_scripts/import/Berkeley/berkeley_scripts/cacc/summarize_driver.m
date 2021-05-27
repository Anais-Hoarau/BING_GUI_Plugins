% summarize_driver.m
%
% Written by Christopher Nowakowski
% v.1 12/08/08
% v.2  2/11/09
%
% This function cycles through all of the trips in a driver directory and 
% creates the following:
%
% 1. It creates a tripindex.dat file in each of the trip directories.  These 
%    can be subsequently used to figure out which sequence directory contains a 
%    particular timestamp.
%
% 2. It creates a clockskew.dat file in each trip directory which saves the 
%    the average clockskew caclculated based on the entire trip's data.
%
% 3. It creates a dXX_tripXXXX_route.kml file in each trip directory which 
%    contains the gps points in a format that can be read and plotted by 
%    google earth.
%
% 4. It creates 2 ACC overview graphs (one in raw mode and one in absolute mode)
%    which plot key parameters from the trip.
%
% 5. It creates a dXX_trips_summary.txt file in the driver directory.  This file 
%    contains a summary of the trips contained in the driver directory to 
%    include date, time, and a summary of selected parameters.
%

function summarize_driver(drivers,copypath)

% Set Defaults
usage_msg = 'Usage: [] = summarize_driver([driver numbers],[opt full pathname for copies]);';

% ------------------------------------------------------------------------------
% Check & Parse Function Input Arguments
% ------------------------------------------------------------------------------

if (nargin == 1 && ischar(drivers) && strcmpi(drivers,'?')),
    % Help Request
    disp(usage_msg);
    disp('Driver Dir Files Saved: dXX_trips_summary.txt & -DriverXX_Summary_Log.txt');
    disp('Trip Dir Files Saved: tripindex.dat, clockskew.dat, and dXX_tripXXXX_route.kml');
    disp('Trip Dir Graphs Saved: dXX_tripXXXX_overview1.jpg & dXX_tripXXXX_overview2.jpg');
    return;

elseif (nargin == 1 && (isnumeric(drivers) || ischar(drivers))),
    copypath = [];
    
elseif (nargin == 2 && (isnumeric(drivers) || ischar(drivers))),
    % Verification that copypath exists occurs later

else,
    error(usage_msg);
end;

% Convert driver string to numeric
if (ischar(drivers)),
    drivers = str2num(drivers);
end;

% Verify that copypath exists
project_path = get_path;
slash = project_path{2};
if (~isempty(copypath)),
    % If the given directory was not valid, allow the user to select or create a valid directory
    if (exist(copypath,'dir') ~= 7)
        message = 'Select a directory to save copies of the text, kml, and graphs...';
        disp(message);
        copypath = uigetdir(project_path{1},message);
        if (copypath == 0),
            copypath = [];
        end;
    end;
    % Add a trailing slash if one does not already exist
    if (~isempty(copypath)),
        if (~strcmpi(copypath(length(copypath)),slash)),
            copypath = [copypath slash];
        end;
    end;
end;


% ------------------------------------------------------------------------------
% Main Loop For Processing Multiple Drivers
% ------------------------------------------------------------------------------
for d=1:length(drivers),
    
    driver = drivers(d);
    
    % --------------------------------------------------------------------------
    % Driver Preprocessing Setup
    % --------------------------------------------------------------------------

    % Start Log File
    c = clock;
    log = [];
    log{1} = ['CACC Summarize Driver Script Started Processing Driver '...
        num2str(driver) ' on ' date ' at ' num2str(c(4)) ':'...
        num2str(c(5),'%02d') ':' num2str(floor(c(6)),'%02d')];
    disp(' ');
    disp(log{length(log)});
    
    % Test for driver number out of bounds error.
    if (driver <= 0 || driver > 99),
        log{length(log)+1} = '  Error: Driver number must be between 1 and 99.';
        disp(log{length(log)});
        log{length(log)+1} = ['  Skipped Processing Driver ' num2str(driver)];
        disp(log{length(log)});
        continue;
    end;
    
    % Assemble driver path and verify that it exists
    driver_path = [project_path{1} 'Driver' num2str(driver,'%02d') slash];
    if (exist(driver_path,'dir') ~= 7),
        log{length(log)+1} = ['  Error: ' driver_path ' does not exist!'];
        disp(log{length(log)});
        log{length(log)+1} = ['  Skipped Processing Driver ' num2str(driver)];
        disp(log{length(log)});
        continue;
    end;
    
    % Get a List of Silver Trip Directories
    vehicle_path = [driver_path 'Silver' slash];
    triplist = get_trip_dir_list(vehicle_path);
    if (isempty(triplist)),
        log{length(log)+1} = ['  Error: ' vehicle_path ' was empty or did not exist!'];
        disp(log{length(log)});
    end;
    
    % Get a List of Copper Trip Directories
    vehicle_path = [driver_path 'Copper' slash];
    triplist2 = get_trip_dir_list(vehicle_path);
    if (isempty(triplist2)),
        log{length(log)+1} = ['  Error: ' vehicle_path ' was empty or did not exist!'];
        disp(log{length(log)});
    end;
    
    % Merge Trip Lists
    triplist = [triplist triplist2];                                            %#ok<AGROW>
    clear triplist2;
    
    
    % --------------------------------------------------------------------------
    % Process Each Trip For the Current Driver
    % --------------------------------------------------------------------------
    [driver_summary timestamp_summary log] = process_trip_directories(driver,triplist,log,copypath);
    
    
    % --------------------------------------------------------------------------
    % Save Summary & Log Files in the Current Driver Directory
    % --------------------------------------------------------------------------
    
    % Save dXX_trips_summary.txt
    filename = [driver_path 'd' num2str(driver,'%02d') '_trip_summary.txt'];
    save_simple_struct(driver_summary,filename);
    log{length(log)+1} = ['Saving/Overwriting ' filename];
    if (~isempty(copypath)),
        filename = [copypath 'd' num2str(driver,'%02d') '_trip_summary.txt'];
        save_simple_struct(driver_summary,filename);
    end;
    
    % Save dXX_timestamps_summary.txt
    filename = [driver_path 'd' num2str(driver,'%02d') '_timestamp_summary.txt'];
    save_simple_struct(timestamp_summary,filename);
    log{length(log)+1} = ['Saving/Overwriting ' filename];
    if (~isempty(copypath)),
        filename = [copypath 'd' num2str(driver,'%02d') '_timestamp_summary.txt'];
        save_simple_struct(driver_summary,filename);
    end;
    
    % Save -DriverXX_Summary_Log.txt
    filename = [driver_path '-Driver' num2str(driver,'%02d') '_Summary_Log.txt'];
    log{length(log)+1} = ['Appending ' filename];
    c = clock;
    log{length(log)+1} = ['CACC Summarize Driver Script Completed Processing Driver '...
        num2str(driver,'%02d') ' on ' date ' at ' num2str(c(4)) ':'...
        num2str(c(5),'%02d') ':' num2str(floor(c(6)),'%02d')];
    disp(log{length(log)});
    disp(' ');
    [fid message] = fopen(filename,'a');
    if ~isempty(message),
        disp(['Warning: Attempted to save driver log file ' filename]);
        disp('Encountered the following error:');
        disp(['  ' message]);
        disp('summarize_driver() aborted saving the log file.');
        fclose(fid);
        continue;
    end;
    for i=1:length(log),
        if (i < length(log)),
            fprintf(fid,'%s\n',log{i});
        else,
            fprintf(fid,'%s\n\n',log{i});
        end;
    end;
    fclose(fid);
    clear fid message;
    
end; % for d...

end


% ------------------------------------------------------------------------------
% Function to Loop Through & Process Each Trip Directory Of a Single Driver
% ------------------------------------------------------------------------------
function [ds ts log] = process_trip_directories(driver,triplist,log,copypath)

% ds/ts are the driver_summary and timestamp_summary files
[ds ts] = create_empty_summary_structs();

for i=1:length(triplist),
    
    % --------------------------------------------------------------------------
    % Create Driver Summary File Minimal Trip Entry
    % --------------------------------------------------------------------------
    
    % Figure out TripID from Directory Name
    str_start = findstr('Trip',triplist{i}) + 4;
    str_end = str_start + 3;
    tripid = triplist{i}(str_start:str_end);
    clear str_start str_end;
    
    % Record a Driver# and TripID Line Entry Even If Trip Load Fails
    ds.driver(i,1) = driver;
    ts.driver(i,1) = driver;
    ds.tripid(i,:) = str2num(tripid);
    ts.tripid(i,:) = str2num(tripid);
    
    % --------------------------------------------------------------------------
    % Load Trip Data (First Pass)
    % --------------------------------------------------------------------------
    disp(' ');
    log{length(log)+1} = ['Processing Trip ' tripid];
    disp(log{length(log)});
    log{length(log)+1} = ['First Pass: Loading ' triplist{i}];
    disp(log{length(log)});
    [data load_index] = load_trip(triplist{i});
    if (isempty(data)),
        log{length(log)+1} = '  Error: summarize_driver() found no trip data.  Additional trip processing was skipped.';
        disp(log{length(log)});
        continue;
    end;
    
    
    % --------------------------------------------------------------------------
    % Record Trip Info For This Trip in the Driver Summary File
    % --------------------------------------------------------------------------
    ds.vehicle(i,1:6) = data.meta.vehicle(1:6);
    ds.year(i,1) = str2num(['20' data.meta.date(1:2)]);
    ds.month(i,1) = str2num(data.meta.date(3:4));
    ds.day(i,1) = str2num(data.meta.date(5:6));
    ds.clock_start(i,1:12) = data.ts.text(1,1:12);
    ds.clock_end(i,1:12) = data.ts.text(length(data.ts.ssm),1:12);
    
    ts.vehicle(i,1:6) = data.meta.vehicle(1:6);
    ts.year(i,1) = str2num(['20' data.meta.date(1:2)]);
    ts.month(i,1) = str2num(data.meta.date(3:4));
    ts.day(i,1) = str2num(data.meta.date(5:6));
    ts.clock_start(i,1) = data.ts.ssm(1);
    ts.clock_end(i,1) = data.ts.ssm(length(data.ts.ssm));
    ts.utc_start(i,1) = convert_utc_2_ssm(data.gps.utc_time(1),0);
    ts.utc_end(i,1) = convert_utc_2_ssm(data.gps.utc_time(length(data.gps.utc_time)),0);
    
    
    % --------------------------------------------------------------------------
    % Save timestamp_errors.txt & clockskew.dat & tripindex.dat files
    % --------------------------------------------------------------------------
    [error_msg] = save_trip_index(data,load_index);
    if (~isempty(error_msg)),
        log{length(log)+1} = 'Indexing trip with save_trip_index() routine';
        log{length(log)+1} = ['  ' strtrim(error_msg)];
        log{length(log)+1} = 'summarize_driver() has skipped additional trip processing.';
        continue;
    end;
    log{length(log)+1} = ['Saving/Overwriting ' triplist{i} 'tripindex.dat'];
    log{length(log)+1} = ['Saving/Overwriting ' triplist{i} 'clockskew.dat'];
    
    
    % --------------------------------------------------------------------------
    % Load Trip Data (Second Pass) - using corrections from clockskew.dat
    % --------------------------------------------------------------------------
    log{length(log)+1} = ['Second Pass: Reloading ' triplist{i}];
    disp(log{length(log)});
    [data] = load_trip(triplist{i});
    if (isempty(data)),
        log{length(log)+1} = '  Error: summarize_driver() found no trip data.  Additional trip processing skipped.';
        disp(log{length(log)});
        continue;
    end;
    
    
    % --------------------------------------------------------------------------
    % Save calibration.dat file
    % --------------------------------------------------------------------------
    [error_msg] = save_sensor_calibration(data);
    if (~isempty(error_msg)),
        log{length(log)+1} = 'Saving sensor calibrations with save_sensor_calibration() routine';
        log{length(log)+1} = ['  ' strtrim(error_msg)];
        log{length(log)+1} = 'calibration.dat may not have been saved.';
    else
        log{length(log)+1} = ['Saving/Overwriting ' triplist{i} 'calibration.dat'];
    end;
        
    
    % --------------------------------------------------------------------------
    % Timestamp Summary Operations
    % --------------------------------------------------------------------------
    filename = [triplist{i} 'clockskew.dat'];
    clockskew = load(filename);
    if length(clockskew >= 4),
        ts.gmt_offset(i,1) = clockskew(2);
        ts.clockskew(i,1) = clockskew(1);
        ts.minskew(i,1) = clockskew(3);
        ts.maxskew(i,1) = clockskew(4);
    end;
    if (length(clockskew) == 6),
        ts.clock_reset(i,1) = clockskew(6);
    else,
        ts.clock_reset(i,1) = 0;
    end;
    
    % Check Timestamp Inegrity
    [tsi es error_count] = get_ts_integrity(data,0.085,0.015);
    ts.ts_errors(i,1) = error_count;
    clear tsi es error_count clockskew;
    
    % Store Best Corrected UTC Start & End Times
    ts.utcp_start(i,1) = data.ts.utc_ssm(1);
    ds.utcp_start(i,1:12) = convert_text_ts(data.ts.utc_ssm(1));
    ts.utcp_end(i,1) = data.ts.utc_ssm(length(data.ts.utc_ssm));
    ds.utcp_end(i,1:12) = convert_text_ts(data.ts.utc_ssm(length(data.ts.utc_ssm)));
    
    
    % --------------------------------------------------------------------------
    % Create dXX_vXXXX_route.kml file in the trip directory
    % --------------------------------------------------------------------------
    filename = [triplist{i} 'd' num2str(driver,'%02d') '_' lower(data.meta.vehicle(1)) tripid '_route.kml'];
    log{length(log)+1} = ['Saving/Overwriting ' filename];
    disp(log{length(log)});
    save_kml(data,filename);
    if (~isempty(copypath)),
        filename = [copypath 'd' num2str(driver,'%02d') '_' lower(data.meta.vehicle(1)) tripid '_route.kml'];
        save_kml(data,filename);
    end;
    
    
    % --------------------------------------------------------------------------
    % Create ACC Overview Graphs in the trip directory
    % --------------------------------------------------------------------------
    
    % Save SI Sysclock Raw Graph
    h = graph_acc_overview(data,'-si -sysclock -hms -raw');
    resize_figure(h,1000,800);
    filename = [triplist{i} 'd' num2str(driver,'%02d') '_' lower(data.meta.vehicle(1)) tripid '_overview1.jpg'];
    log{length(log)+1} = ['Saving/Overwriting ' filename];
    save_figure(h,'-jpg',filename);
    if (~isempty(copypath)),
        filename = [copypath 'd' num2str(driver,'%02d') '_' lower(data.meta.vehicle(1)) tripid '_overview1.jpg'];
        save_figure(h,'-jpg',filename);
    end;
    close(h);
    pause(0.1);
    
    % Save MPH UTC Graph
    h = graph_acc_overview(data,'-mph -utc -hms');
    resize_figure(h,1000,800);
    filename = [triplist{i} 'd' num2str(driver,'%02d') '_' lower(data.meta.vehicle(1)) tripid '_overview2.jpg'];
    log{length(log)+1} = ['Saving/Overwriting ' filename];
    save_figure(h,'-jpg',filename);
    if (~isempty(copypath)),
        filename = [copypath 'd' num2str(driver,'%02d') '_' lower(data.meta.vehicle(1)) tripid '_overview2.jpg'];
        save_figure(h,'-jpg',filename);
    end;
    close(h);
    pause(0.1);
    
    
    % --------------------------------------------------------------------------
    % Driver Summary Operations
    % --------------------------------------------------------------------------
    ds.trip_time(i,1) = floor( (data.ts.ssm(length(data.ts.utc_ssm)) - data.ts.utc_ssm(1))/60 );
    f1 = {'acc_on';'acc_active';'gap_6';'gap_7';'gap_9';'gap_11';'gap_16';'gap_22'};
    f2 = {'_events';'_time';'_set_speed';'_mean_speed'};
    gap = [0 0 1 2 3 4 5 6];
    for j=1:length(f1);
        if (j == 1);
            index = find(data.acc.enabled == 1);
        elseif (j == 2),
            index = find(data.acc.enabled == 1 & data.acc.active == 1);
        else,
            index = find(data.acc.enabled == 1 & data.acc.active == 1 &...
                data.acc.car_space == gap(j));
        end;
        
        [acc_summary] = get_acc_summary(data,index);
        
        for k=1:length(f2),
            field = [f1{j,:} f2{k,:}];
            ds.(field)(i,1) = acc_summary(k);
        end;
    end; % for j...
    
end; % for i...


% ------------------------------------------------------------------------------
% Reformat Integer Return Data Types
% ------------------------------------------------------------------------------
ds.driver = int8(ds.driver);
ds.tripid = int16(ds.tripid);
ds.day = int8(ds.day);
ds.month = int8(ds.month);
ds.year = int16(ds.year);
ds.trip_time = int16(ds.trip_time);
field = fieldnames(ds);
for j=1:length(field);
    if (~isempty(findstr(field{j},'events'))),
        ds.(field{j}) = int32(ds.(field{j}));
    end;
end;
    
ts.driver = int8(ts.driver);
ts.tripid = int16(ts.tripid);
ts.day = int8(ts.day);
ts.month = int8(ts.month);
ts.year = int16(ts.year);
ts.gmt_offset = int8(ts.gmt_offset);
ts.ts_errors = int8(ts.ts_errors);

end


% ------------------------------------------------------------------------------
% Function to Create an Empty Summary Structures
% ------------------------------------------------------------------------------
function [ds ts] = create_empty_summary_structs()

% This is just a convenience function to pre-allocate the summary structure
% and preserve the desired variable order even though the data will be acquired
% in a random order.  Also, for some reason, text fields need to be pre-created,
% otherwise the fields get converted to doubles.  I don't understand this bug, 
% as it only happens within a function.

% Driver Summary
ds.driver = [];             % int8
ds.vehicle = 'text';        % char
ds.tripid = [];             % int16
ds.day = [];                % int8
ds.month = [];              % int8
ds.year = [];               % int16
ds.clock_start = 'text';    % Text Rounded to Nearest Second
ds.clock_end = 'text';      % Text Rounded to Nearest Second
ds.utcp_start = 'text';     % Text Rounded to Nearest Second
ds.utcp_end = 'text';       % Text Rounded to Nearest Second
ds.trip_time = [];          % Rounded to Nearest Minute (int16)

% Timestamp Summary
ts.driver = [];             % int8
ts.vehicle = 'text';        % char
ts.tripid = [];             % int16
ts.day = [];                % int8
ts.month = [];              % int8
ts.year = [];               % int16
ts.clock_start = [];        % SSM
ts.clock_end = [];          % SSM
ts.utc_start = [];          % Raw UTC SSM
ts.utc_end = [];            % Raw UTC SSM
ts.utcp_start = [];         % SSM
ts.utcp_end = [];           % SSM

ts.gmt_offset = [];         % int8
ts.clockskew = [];          % Mean clockskew
ts.minskew = [];            % Min clockskew
ts.maxskew = [];            % Max clockskew
ts.ts_errors = [];          % Number of timestamp errors encountered (int8)
ts.clock_reset = [];        % Magnitude of time jump in (s)

end


% ------------------------------------------------------------------------------
% Function to Return A Summary of the Data
% ------------------------------------------------------------------------------
function [acc_summary] = get_acc_summary(data,index)

if length(index) < 2,
    acc_summary(1) = 0;
    acc_summary(2) = 0;
    acc_summary(3) = 0;
    acc_summary(4) = 0;
    return;
end;

% acc_summary(1) = # of discrete events
diff_index(2:length(index)) = index(2:length(index)) - index(1:length(index)-1);
event_start = [1 find(diff_index > 1)];
acc_summary(1) = length(event_start);

% acc_summary(2) = total time in (s)
diff_index(1:(length(index)-1)) = index(2:length(index)) - index(1:length(index)-1);
event_end = [find(diff_index > 1) length(index)];
acc_summary(2) = 0;
for i=1:length(event_start),
    acc_summary(2) = acc_summary(2) + data.ts.utc_ssm(index(event_end(i))) -...
        data.ts.utc_ssm(index(event_start(i)));
end;

% acc_summary(3) = mean set speed (m/s)
acc_summary(3) = mean(data.acc.set_speed(index));

% acc_summary(4) = mean speed (m/s)
acc_summary(4) = mean(data.veh.speed(index));

end
