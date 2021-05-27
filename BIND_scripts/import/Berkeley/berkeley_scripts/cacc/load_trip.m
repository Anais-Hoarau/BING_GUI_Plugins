% load_trip.m  (CACC)
%
% Written by Christopher Nowakowski
% v.1 11/04/08
%
% Inputs
%
% This function loads the engineering files for a CACC trip.  The minimum 
% definition of a CACC trip includes Driver Number, Vehicle Name, Trip Date, 
% and TripID.
%
% Optionally, sequence start and end numbers can be provided if you only want to 
% load part of the data set.
% 
% If no input parameters are provided, the UI will prompt the user to select
% a trip directory manually.
%
% The function may be called with a single text input string corresponding to 
% the full pathname of the trip directory to be loaded.
%
% Outputs
% 
% There are two function outputs.  The first is a data structure containing the
% data that was loaded from the *.dat files.  The second is an index of the 
% sequence directories that were loaded which contains three columns:
%
% Sequence Directory Number | Starting Timestamp | Ending Timestamp
%

function [data load_index] = load_trip(driver,vehicle,tripdate,tripid,varargin)

% ------------------------------------------------------------------------------
% Setup Defaults
% ------------------------------------------------------------------------------

% Set Default Return Value
data = create_empty_data_struct;
load_index = [];

% Set Default Input Parameters
verbose = 0;        % False
seq_start = 0;      % Start from First Sequence
seq_end = 1000;       % Continue to Last Sequence

% Set Project Path
project_path = get_path();
if isempty(project_path)
    project_path{1} = cd;
    project_path{2} = filesep;
    project_path{1} = [project_path{1} project_path{2}];
else
    if verbose,
        disp(project_path{3});
    end;
end;
slash = project_path{2};

% Set Default Trip Path
trip_path = [];


% ------------------------------------------------------------------------------
% Check & Parse Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [data seq_dir_index] = load_trip(Driver,Vehicle,TripDate{YYMMDD},TripID,[Opt Starting Seq #],[Opt Ending Seq #],[Opt ''verbose'']);';

if (nargin == 0),
    % If no input arguments were provided, bring up a select folder dialog box
    verbose = 1;
    trip_path = uigetdir(project_path{1},'Select a CACC trip directory...');
    if trip_path == 0,
        % User Cancelled Dialog Box
        return;
    else
        trip_path = [trip_path slash];
    end;
    
elseif (nargin == 1 && strcmpi(driver,'?')),
    % Help Request
    data = [];
    disp(usage_msg);
    disp('Usage: [data seq_dir_index] = load_trip(''TripDirectoryPathName'');');
    disp('Usage: [data seq_dir_index] = load_trip();');
    disp('Note: Providing no input arguments results in GUI to select a trip directory.');
    return;

elseif (nargin == 1 && ischar(driver)),
    % Input Provided a Trip Directory PathName
    trip_path = driver;
    % Set Driver to -1 as a flag for how to handle meta data
    driver = -1;
    
elseif (nargin == 4),
    % Minimum Number of Inputs Provided
    
elseif (nargin >= 5 && nargin <= 7),
    % Parse Optional Arguments
    
    % At least one argument was provided so it is either "verbose" or a sequence start number.
    if size(varargin,2) > 0,
        
        if strcmpi('verbose',varargin{1}) || strcmpi('v',varargin{1}) || strcmpi('-v',varargin{1}),
            verbose = 1;
        else
            seq_start = varargin{1};
        end;
    end;
   
    % At least two arguments were provided so argument 2 is either "verbose", seq start, or seq end.
    if size(varargin,2) > 1,
        if strcmpi('verbose',varargin{2}) || strcmpi('v',varargin{2}) || strcmpi('-v',varargin{2}),
            verbose = 1;
        elseif verbose == 1,             % Arg 1 must have been "verbose"
            seq_start = varargin{2};
        else                             % Arg 1 must have been seq start
            seq_end = varargin{2};
        end;
    end;
    
    % Three arguments were provided so argument 3 is either "verbose" or seq_end.
    if size(varargin,2) > 2,
        if strcmpi('verbose',varargin{3}) || strcmpi('v',varargin{3}) || strcmpi('-v',varargin{3}),
            verbose = 1;
        else
            seq_end = varargin{3};
        end;
    end;

else
    % Invalid input arguments provided
    clear data;
    error(usage_msg);    
    
end;


% ------------------------------------------------------------------------------
% Create trip path from function input parameters
% ------------------------------------------------------------------------------
if isempty(trip_path),
    
    % Set Vehicle Directory
    if isnumeric(vehicle) && vehicle == 1,
        vehicle = 'Silver';
    elseif isnumeric(vehicle) && vehicle == 2,
        vehicle = 'Copper';
    elseif ischar(vehicle) && (strcmpi(vehicle,'s') || strcmpi(vehicle,'-s') || strcmpi(vehicle,'silver')),
        vehicle = 'Silver';
    elseif ischar(vehicle) && (strcmpi(vehicle,'c') || strcmpi(vehicle,'-c') || strcmpi(vehicle,'copper')),
        vehicle = 'Copper';
    else
        error('%s\n%s','Usage: [trip_data] = load_trip(Driver,Vehicle,TripDate{YYMMDD},TripID,[Opt Starting Seq #],[Opt Ending Seq #],[Opt ''verbose'')',...
            'Error: Unknown Vehicle Specified.  Vehicle input should be ''Silver'' (1) or ''Copper'' (2).');
    end;

    % Convert Trip Date to string
    if isnumeric(tripdate)
        tripdate = num2str(tripdate,'%06d');
    end;

    % Convert TripID to string
    if isnumeric(tripid)
        tripid = num2str(tripid,'%04d');
    end;

    % Assemble Trip Path
    trip_path = [project_path{1} 'Driver' num2str(driver,'%02d') slash vehicle slash 'Date' tripdate slash 'Trip' tripid slash];
else
    % Set Flag to Generate Meta Data from the trip path manually selected by a user
    driver = -1;
end;

% ------------------------------------------------------------------------------
% Verifty that the trip path exists
% ------------------------------------------------------------------------------
if (verbose),
    disp(['load_trip() - loading .dat files from ' trip_path]);
end;
if (exist(trip_path,'dir')) ~= 7,
    if verbose,
        disp(['  Error: ' trip_path ' does not exist!']);
    else
        disp(['Error: load_trip() cancelled. ' trip_path ' does not exist!']);
        data = [];
        return;
    end;
end;


% -------------------------------------------------------------------------------------------------
% Main Loop - Cycle Through Files & Directories in the Trip Path to Find Sequence Directories
% -------------------------------------------------------------------------------------------------

% Initialize # of Directories Imported Counter
dir_imported_count = 0;

% Get a list of sequence directories in the trip directory
trip_dir_file_list = dir(trip_path);
for i=1:length(trip_dir_file_list),
    
    % If item is not a directory, skip it.
    if not(trip_dir_file_list(i).isdir),
        continue;
    end;
    
    % If item is a directory named "copper" (which is a reserved word in MatLab)
    if strcmpi(trip_dir_file_list(i).name,'copper'),
        continue;
    end;
    
    % If item is a dir, but not a sequence directory, skip it.
    if isempty(str2num(trip_dir_file_list(i).name)),
        continue;
    end;
    
    % If the sequence directory is less than the optional sequence start number, skip it.
    if str2num(trip_dir_file_list(i).name) < seq_start,
        continue;
    end;
    
    % If the sequence directory is greater than the optional sequence end number, finished.
    if str2num(trip_dir_file_list(i).name) > seq_end,
        break;
    end;
    
    % If you've made it this far, load the .dat files from the sequence directory.
    seq_dir = [trip_path trip_dir_file_list(i).name slash];
    if verbose,
        disp(['Loading Sequence Directory ' trip_dir_file_list(i).name]);
    end;
    [seq_dir_data error_log] = load_dat_files(seq_dir);
    
    
    % Check for errors on .dat file load
    if isempty(seq_dir_data),
        if (~verbose),
            disp(['Attempted to Load Sequence Directory ' trip_dir_file_list(i).name]);
        end;
        for entry=1:length(error_log),
            disp(['  ' error_log{entry}]);
        end;
        continue;
    end;
    
    % Update the counter for the number of directories successfully imported
    dir_imported_count = dir_imported_count + 1;
    
    % Update the load_index with the new seq_dir_data
    load_index(dir_imported_count,:) = ...
        [str2num(trip_dir_file_list(i).name) seq_dir_data.ts.ssm(1) seq_dir_data.ts.ssm(length(seq_dir_data.ts.ssm))];
    
    % Add Current Seq Dir Data to Overall Import Data Set
    data = vertcat_data_struct(data,seq_dir_data);
    
end;  % for i

% Final check to make sure that something happened
if isempty(data.ts.text),
    data = [];
    load_index = [];
    disp(['Error: load_trip() found no data to import from ' trip_path]);
    return;
end;


% ------------------------------------------------------------------------------
% Generate Meta Data
% ------------------------------------------------------------------------------

% Generate Meta Data from the trip path if it was manually selected by a user
if driver == -1;
    str_start = findstr('Driver',trip_path) + 6;
    str_end = str_start + 1;
    driver = str2num(trip_path(str_start:str_end));
    
    str_start = str_start + 3;
    str_end = str_start + 5;
    vehicle = trip_path(str_start:str_end);
    
    str_start = findstr('Date',trip_path) + 4;
    str_end = str_start + 5;
    tripdate = trip_path(str_start:str_end);
    
    str_start = findstr('Trip',trip_path) + 4;
    str_end = str_start + 3;
    tripid = trip_path(str_start:str_end);
end;

% Record Meta Data
data.meta.study = 'CACC';
data.meta.driver = num2str(driver,'%02d');
data.meta.vehicle = vehicle;
data.meta.date = tripdate;
data.meta.tripid = tripid;
if (seq_start == 0 && seq_end == 1000),
    data.meta.dataset = 'Full Trip';
else
    data.meta.dataset = 'Partial Trip';
end;
data.meta.seq_start = load_index(1,1);
data.meta.seq_end = load_index(length(load_index(:,1)),1);
data.meta.pathname = trip_path;


% ------------------------------------------------------------------------------
% Synch timestamp to UTC time - Calculate data.ts.utc_ssm
% ------------------------------------------------------------------------------

% Correct data.ts.ssm for crossing midnight
index = find(data.ts.ssm < data.ts.ssm(1));
if ~isempty(index),
    data.ts.ssm(index) = data.ts.ssm(index) + 86400;
end;

% Correct load_index for crossing midnight
for i=2:length(load_index(:,1)),
    if load_index(i,2) < load_index(i-1,2),
        load_index(i,2) = load_index(i,2) + 86400;
    end;
    if load_index(i,3) < load_index(i-1,3),
        load_index(i,3) = load_index(i,3) + 86400;
    end;
end;

% Check for an existing clockskew.dat file which already contains the synch info
if (exist([trip_path 'clockskew.dat'],'file') == 2),
    clockskew = load([trip_path 'clockskew.dat']);
    if (verbose && ~isempty(clockskew)),
        disp('A clockskew.dat file was found.  Synching to to UTC time...');
        disp(['GMT Time Zone Offset = ' num2str(clockskew(2),'%d')]);
        disp(['Clockskew = ' num2str(clockskew(1))]);
    end;
else
    clockskew = [];
end;

% If there is no clockskew.dat file and a full trip has been loaded...
% Attempt to calculate a best estimate for the clockskew
if (isempty(clockskew) && strcmpi(data.meta.dataset,'Full Trip')),
    clockskew(2) = get_gmt_offset(tripdate(3:4),tripdate(5:6),tripdate(1:2));
    [clockskew(1) clockskew(3) clockskew(4)] = get_clockskew(data.ts.ssm, data.gps.utc_time, clockskew(2));
    if verbose,
        disp('No clockskew.dat file found.  Attempting synch to to UTC time...');
        disp(['GMT Time Zone Offset = ' num2str(clockskew(2),'%d')]);
        disp(['Clockskew = ' num2str(clockskew(1))]);
        disp('Note: Did not check for system clock reset events.');
    end;
    
elseif (isempty(clockskew)),
    % If there is no clockskew.dat file and a partial trip has been loaded...
    % Punt and set the clockskew to 0.
    if verbose,
        disp('No clockskew.dat file found.  Cannot synch to UTC time.');
        disp('Clockskew = 0.0');
    end;
    clockskew(1) = 0.0;
    clockskew(2) = 0;
end;

% Apply the clockskew and record what was done to the meta data
data.ts.utc_ssm = data.ts.ssm - clockskew(1);
data.meta.gmt_offset = clockskew(2);
data.meta.clockskew = clockskew(1);

% Attempt to correct for System Clock Reset Events
if (length(clockskew) == 6);
    timejumprow = find(data.ts.ssm == clockskew(5));
    if (~isempty(timejumprow) && timejumprow > 1),
        % Correct the data.ts.utc_ssm values before the system clock was reset
        data.ts.utc_ssm(1:timejumprow-1) = data.ts.utc_ssm(1:timejumprow-1) + clockskew(6);
        if (verbose),
            disp(['Note: The sych to UTC time included correcting for a system clock reset event at ' convert_text_ts(clockskew(5))]);
        end;
        
    elseif (isempty(timejumprow && strcmpi(data.meta.dataset,'Full Trip'))),
        % This warning would indicate that an exact match for the event could not be found
        if (verbose),
            disp(['Warning: clockskew.dat indicates the existence of a clock reset event at ' convert_text_ts(clockskew(5)) ' that could not be found.']);
        end;
    end;
end;


% ------------------------------------------------------------------------------
% Post Processing - Conversions - Recoding - New Parameter Generation
% ------------------------------------------------------------------------------
%
% Note: Most post processing is done in load_dat_file.m
% 
% Generate subject vehicle acceleration estimates based on speed (g)
data.veh.accl = convert_speed_2_accl(data.veh.speed,data.ts.utc_ssm,4,8);
data.veh.accl = data.veh.accl/9.812865328;

% Generate comm vehicle acceleration estiamtes based on comm vehicle speed (g)
data.comm.accl = convert_speed_2_accl(data.comm.speed,data.ts.utc_ssm,4,8);
data.comm.accl = data.comm.accl/9.812865328;

% Generate lead vehicle acceleration estimates based on lead vehicle speed (g)
data.acc.lead_veh_accl = get_lead_veh_accl(data);

% Generate required deceleration when closing in on a lead vehicle (g)
data.acc.areq = zeros(length(data.acc.rel_speed),1);
index = find(data.acc.rel_speed < 0);
if ~isempty(index),
    data.acc.areq(index) = (data.acc.rel_speed(index) .* data.acc.rel_speed(index)) ./ (2 .* data.acc.dist(index));
    data.acc.areq(index) = data.acc.areq(index)/9.812865328 - data.acc.lead_veh_accl(index);
    index = find(data.acc.areq < 0);
    data.acc.areq(index) = 0;
end;


% ------------------------------------------------------------------------------
% Operation Completed
% ------------------------------------------------------------------------------
if verbose,
    disp(['Operation completed. Number of sequence directories imported = ' num2str(dir_imported_count)]);
end;

end



% ------------------------------------------------------------------------------
% Generate lead vehicle acceleration estimates based on lead vehicle speed
% ------------------------------------------------------------------------------
function [lvaccl] = get_lead_veh_accl(data)

% Initialize output acceleration to zero & set filter parameters 
lvaccl = zeros(length(data.acc.lead_veh_speed),1);
lo_filter = 8;
hi_filter = 12;

% Find all following events and cycle through each event
index = find(data.acc.time_gap > -1);
fet = create_event_table(index);
for i=1:length(fet(:,1)),
    fs = fet(i,2);                                                              % following start
    fe = fet(i,3);                                                              % following end
    
    % Only continue if the following event is long enough
    if fe-fs+1 >= hi_filter*2+1,
        
        % Cycle through lead vehicle target switches within the following event
        for j=min(data.acc.lidar_target_id(fs:fe)):max(data.acc.lidar_target_id(fs:fe))
            index = find(data.acc.lidar_target_id(fs:fe) == j);
            if length(index) >= hi_filter*2+1,
                
                % Create a vehicle following event table
                % (Just in case the same target id was used multiple times in a single following event)
                vfet = create_event_table(index);
                vfet(:,2) = vfet(:,2)+fs-1;                                     % Correct to original data row
                vfet(:,3) = vfet(:,3)+fs-1;                                     % Correct to original data row
                
                % Cylce through single vehilce following events
                for k=1:length(vfet(:,1))
                    vfs = vfet(k,2);                                            % vehicle following start
                    vfe = vfet(k,3);                                            % vehicle following end
                    
                    % Only continue if the following event is long enough
                    if vfe-vfs >= hi_filter*2+1,
                        
                        % Estimate Acceleration
                        lvaccl(vfs:vfe,1) = convert_speed_2_accl(data.acc.lead_veh_speed(vfs:vfe),data.ts.utc_ssm(vfs:vfe),lo_filter,hi_filter);
                    
                    end;
                end; % for k...
            end; % if length...
        end; % for j...
    end; % if fe...
end;  % for i...

% Convert to (g)
lvaccl = lvaccl/9.812865328;

end