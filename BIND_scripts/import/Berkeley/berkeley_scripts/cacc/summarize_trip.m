% summarize_trip.m
%
% Written by Christopher Nowakowski
% v.1   04/01/09
%
% This function generates all of the files that go in the trip directory that 
% usually get generated in the summarize_driver.m routine.
% 
% Typically you would use this routine to quickly look at a new trip of interest,
% when you don't want to go through the re-generation of all trips of a driver.
%

function [data] = summarize_trip(driver,vehicle,tripdate,tripid)

% ------------------------------------------------------------------------------
% Check & Parse Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [data] = summarize_trip(driver,vehicle,tripdate,tripid);';
trip_path = [];

if (nargin == 0),
    % No input arguments provided so select trip manually
    project_path = get_path();
    if isempty(project_path)
        project_path{1} = cd;
        project_path{2} = filesep;
        project_path{1} = [project_path{1} project_path{2}];
    end;
    slash = project_path{2};
    trip_path = uigetdir(project_path{1});
    if trip_path == 0,
        % User Cancelled Dialog Box
        return;
    else,
        trip_path = [trip_path slash];
    end;

elseif (nargin == 1 && ischar(driver) && strcmpi(driver,'?'))
    disp(usage_msg);
    disp('Usage: [data] = summarize_trip();');
    disp('Note: Providing no input arguments results in GUI to select a trip directory.');
    return;
    
elseif (nargin == 4)
    % Assume inputs are OK
    
else
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% Load The Trip
% ------------------------------------------------------------------------------
if (~isempty(trip_path))
    disp(['Loading ' trip_path]);
    [data load_index] = load_trip(trip_path);
else
    [data load_index] = load_trip(driver,vehicle,tripdate,tripid,'-v');
end;

% Save Timestamp Errors, tripindex.dat, and clockskew.dat
error_msg = save_trip_index(data, load_index);
if (~isempty(error_msg))
    disp(error_msg);
end;


% ------------------------------------------------------------------------------
% Re-Load The Trip
% ------------------------------------------------------------------------------
if (~isempty(trip_path))
    disp(['ReLoading ' trip_path]);
    [data] = load_trip(trip_path);
else
    [data] = load_trip(driver,vehicle,tripdate,tripid,'-v');
end;


% --------------------------------------------------------------------------
% Create dXX_vXXXX_route.kml file in the trip directory
% --------------------------------------------------------------------------
filename = [data.meta.pathname 'd' data.meta.driver '_' lower(data.meta.vehicle(1)) data.meta.tripid '_route.kml'];
save_kml(data,filename);


% --------------------------------------------------------------------------
% Save calibration.dat file
% --------------------------------------------------------------------------
[error_msg] = save_sensor_calibration(data);
if (~isempty(error_msg))
    disp(error_msg);
end;


% --------------------------------------------------------------------------
% Create ACC Overview Graphs in the trip directory
% --------------------------------------------------------------------------

% Save SI Sysclock Raw Graph
h = graph_acc_overview(data,'-si -sysclock -hms -raw');
resize_figure(h,1000,800);
filename = [data.meta.pathname 'd' data.meta.driver '_' lower(data.meta.vehicle(1)) data.meta.tripid '_overview1.jpg'];
save_figure(h,'-jpg',filename);


% Save MPH UTC Graph
h = graph_acc_overview(data,'-mph -utc -hms');
resize_figure(h,1000,800);
filename = [data.meta.pathname 'd' data.meta.driver '_' lower(data.meta.vehicle(1)) data.meta.tripid '_overview2.jpg'];
save_figure(h,'-jpg',filename);

end