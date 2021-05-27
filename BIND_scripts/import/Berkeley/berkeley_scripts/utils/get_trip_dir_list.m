% get_trip_dir_list.m
%
% Written by Christopher Nowakowski
% 02/19/09
%
% This function returns a list of TripID directory pathnames (in a cell array) 
% when given a vehicle directory pathname and the data directory structure 
% conforms to the following convention:
%
% / VehicleID Dir / Trip Date Dir / TripID Dir / Seq# Dirs / *.dat Files
%
% An empty set is returned if the vehicle directory does not exist or if no 
% TripID directories are found.
%
% Date Directories with more than 10 characters in the name will be skipped. 
% Trip Directories with more than 8 characters in the name will be skipped.
%
% Thus, if a trip or date directory contains bad data, you can mark it in the 
% directory name and that data will then always be skipped when using this 
% function to process all off the data for a given driver and vehicle.
%


function [trip_dir_list] = get_trip_dir_list(vehicle_dir)

% ------------------------------------------------------------------------------
% Check & Parse Function Input Arguments
% ------------------------------------------------------------------------------
trip_dir_list = [];
usage_msg = 'triplist{} = get_trip_dir_list(vehicle_directory);';

if (nargin == 1 && ischar(vehicle_dir) && strcmpi(vehicle_dir,'?')),
    disp(usage_msg);
elseif (nargin == 1 && ischar(vehicle_dir)),
    % Input OK
else,
    error(usage_msg);
end;

if (exist(vehicle_dir,'dir') ~= 7),
    return;
end;

% Figure out what the slash character is on the vehicle directory
if (~isempty(findstr(vehicle_dir,'\'))),
    slash = '\';
else
    slash = '/';
end;


% ------------------------------------------------------------------------------
% Loop to Create a List of "Date" Directories Within the Vehicle Directory
% ------------------------------------------------------------------------------
dir_list = dir(vehicle_dir);
n = 1;
for i = 1:length(dir_list),
    
    % if item is not a directory, skip it.
    if (~dir_list(i).isdir),
        continue;
    end;
    
    % if item is a directory that starts with "Date" add to list
    if (length(dir_list(i).name) == 10),
        if (findstr(dir_list(i).name,'Date') == 1),
            date_dir_list{n} = [vehicle_dir dir_list(i).name slash];
            n = n + 1;
        end;
    end;
    
end; % for i...


% ------------------------------------------------------------------------------
% Loop Through Date Directory List
% ------------------------------------------------------------------------------
n = 1;
for i = 1:length(date_dir_list),
    
    % Get a list of contents for each date directory
    dir_list = dir(date_dir_list{i});
    
    % --------------------------------------------------------------------------
    % Loop Through Each Date Directory's Contents Looking for Trip Directories
    % --------------------------------------------------------------------------
    for j=1:length(dir_list),
        
        % if item is not a directory, skip it.
        if (~dir_list(j).isdir),
            continue;
        end;

        % if item is a directory that starts with "Trip" add to list
        if (length(dir_list(j).name) == 8),
            if (findstr(dir_list(j).name,'Trip') == 1),
                trip_dir_list{n} = [date_dir_list{i} dir_list(j).name slash];
                n = n + 1;
            end;
        end;
    
    end; % for j...
    
end; % for i...

end