% save_trip_index.m
%
% Written by Christopher Nowakowski
% v.1 12/05/08
% v.2 02/09/09
%
% This function saves three files in each trip directory.
% tripindex.dat
% clockskew.dat
% timestamp_errors.txt
%
% The tripindex.dat file is basically a timestamp index for each sequence 
% directory.  It is intended to be able to be quickly loaded to determine which 
% sequence files need to be loaded based on knowing the beginning and ending 
% timestamps for an event.  The file is not self-documented
%
% tripindex.dat file format
% Col 1 = Sequence Directory Number
% Col 2 = Beginning System-Clock TimeStamp (data.ts.ssm)
% Col 3 = Ending System-Clock TimeStamp (data.ts.ssm)
% Col 4 = Begininng System-Clock Synched to UTC Timestamp (data.ts.utc_ssm)
% Col 5 = Ending System-Clock Synched to UTC Timestamp (data.ts.utc_ssm)
%
% tripindex.dat can be reloaded into MatLab using the following command:
% variable = load('tripindex.dat');
%
% The clocksynch.dat file is the best guess at a clock synch between the system 
% clock and the UTC time.  This file is called by the load_trip() and contains
% either 4 or 6 columns depending on whether or not timestamp errors were found.
%
% clockskew.dat file format
% Col 1 = Suggested Clock Skew
% Col 2 = GMT Offset
% Col 3 = Min Recorded Clock Skew
% Col 4 = Maximum Recorded Clock Skew
% Col 5 = System Clock Timestamp (ssm) of A Clock Reset Event
% Col 6 = Suggested Clock Skew for Pre-Clock Reset Data
% 
% The timestamp_errors.txt file is a self-documented file detailing any
% system clock anomalies that were found.
%

function [error_msg] = save_trip_index(data,load_index)

% ------------------------------------------------------------------------------
% Check & Parse Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = '[error_msg] = save_trip_index(data,load_index); {saved files: clockskew.dat tripindex.dat} ';
error_msg = [];

if (nargin == 1 && ischar(data) && strcmpi(data,'?')),
    disp(usage_msg);
    return;
elseif (nargin == 2 && isstruct(data) && isnumeric(load_index)),
    % Inputs are of the correct type
else,
    error(usage_msg);
end;

% Check That Data Represents a Full Trip
if (isfield(data,'meta') && isfield(data.meta,'dataset')),
    if (~strcmpi(data.meta.dataset,'Full Trip')),
        error_msg = 'Error: save_trip_index() was only passed a partial trip.';
        disp(error_msg);
        disp('save_trip_index() operation cancelled.');
        return;
    end;
else,
    error_msg = 'Error: The trip data that was passed does not contain the data.meta.dataset field.';
    disp(error_msg);
    disp('save_trip_index() operation cancelled.');
    return;
end;

if (isempty(data.meta.pathname)),
    error_msg = 'Error: The trip pathname is missing from data.meta.pathname.';
    disp('save_trip_index() operation cancelled.');
    disp(error_msg);
    return;
end;


% ------------------------------------------------------------------------------
% Check For Timestamp Anomalies & Save dXX_[Vehicle][TripID]_timestamp_errors.txt
% ------------------------------------------------------------------------------
% Assumtption of 50 ms data interval with tolerances of 85 and 15 ms
disp(['Indexing ' data.meta.pathname]);
[ts_integrity error_summary error_count] = get_ts_integrity(data,0.085,0.015);

% Record Timestamp Error Summary File
if (error_count > 0),
    disp(['  Note: ' num2str(error_count) ' timestamp errors encountered.']);
    filename = [data.meta.pathname 'd' data.meta.driver '_' data.meta.vehicle data.meta.tripid...
        '_timestamp_errors.txt'];
    save_simple_struct(error_summary,filename);
    
    % Look for a Clock Reset (Assuming a 5 Hz GPS Update Rate)
    error_summary.timejump = error_summary.clock_diff - error_summary.utc_diff;
    timejump = find( abs(error_summary.timejump) > .405 );  % Roughly 2x GPS Update Interval
    
    if (isempty(timejump)),    
        % No Clock Resets Found
        clockreset = -1;
    
    else,
        % Found a Clock Reset
        clockreset = error_summary.clock(timejump);
        
        % Error On Multiple Clock Resets
        if ( length(clockreset) > 1 ),
            error('%s\n%s\n%s','Multiple clockreset events were found. Unable to proceed.',...
                'Please examine the following file:', filename);
        end;
        
        % Find the Magnitude of the Clock Reset
        clockreset(2) = error_summary.clock(timejump) - error_summary.clock(timejump-1) - .050;
        
    end;

else,
    % No Timestamp Errors Found So Set clockreset flag to -1
    clockreset = -1;
end;


% ------------------------------------------------------------------------------
% Synch System Clock to UTC time
% ------------------------------------------------------------------------------
disp('Synchronizing system clock to UTC time...')
tripdate = [data.meta.date(5:6) data.meta.date(3:4) data.meta.date(1:2)];
gmt_offset = get_gmt_offset(tripdate);
disp(['  GMT Time Zone Offset = ' num2str(gmt_offset,'%d')]);
[clockskew minskew maxskew] = get_clockskew(data.ts.ssm, data.gps.utc_time, gmt_offset, clockreset(1));
disp(['  Suggested Clockskew = ' num2str(clockskew)]);


% ------------------------------------------------------------------------------
% Save clockskew.dat file
% ------------------------------------------------------------------------------
filename = [data.meta.pathname 'clockskew.dat'];
if (exist(filename,'file') == 0),
    disp(['Saving ' filename '...']);
elseif exist(filename,'file') == 2,
    disp(['Overwriting ' filename '...']);
else,
    error_msg = '  Error: Cannot save clockskew.dat.  Specified filename is invalid.';
    disp(error_msg);
    disp('save_trip_index() operation aborted at line 147.');
    return;
end;
[fid message] = fopen(filename,'w');
if ~isempty(message),
    error_msg = '  Error: Could not save clockskew.dat.';
    disp(error_msg);
    disp('  Encountered the following errors on save:');
    disp(['    ' message]);
    disp('save_trip_index() operation aborted at line 156.');
    fclose(fid);
    return;
end;
if (clockreset(1) == -1)
    format_string = '%9.3f\t%d\t%9.3f\t%9.3f\n';
    fprintf(fid, format_string, clockskew, gmt_offset, minskew, maxskew);
else,
    format_string = '%9.3f\t%d\t%9.3f\t%9.3f\t%9.3f\t%9.3f\n';
    fprintf(fid, format_string, clockskew, gmt_offset, minskew, maxskew, clockreset(1), clockreset(2));
end;
fclose(fid);


% ------------------------------------------------------------------------------
% Save tripindex.dat file
% ------------------------------------------------------------------------------

% Add Best Guess UTC Times to Load Index File
load_index(:,4) = load_index(:,2) - clockskew;
load_index(:,5) = load_index(:,3) - clockskew;

% Correct UTC Times in Load Index for Clockreset Event
if (clockreset(1) ~= -1),
    timejumprow = find(load_index(:,2) == clockreset(1));
    if (~isempty(timejumprow) && timejumprow > 1),
        load_index(1:timejumprow-1,4) = load_index(1:timejumprow-1,4) + clockreset(2);
        load_index(1:timejumprow-1,5) = load_index(1:timejumprow-1,5) + clockreset(2);
    end;
end;

% Set Filename
filename = [data.meta.pathname 'tripindex.dat'];
if (exist(filename,'file') == 0),
    disp(['Saving ' filename '...']);
elseif exist(filename,'file') == 2,
    disp(['Overwriting ' filename '...']);
else,
    error_msg = '  Error: Cannot save tripindex.dat.  Specified filename is invalid.';
    disp(error_msg);
    disp('save_trip_index() operation aborted at line 196.');
    return;
end;
[fid message] = fopen(filename,'w');
if ~isempty(message),
    error_msg = '  Error: Could not save tripindex.dat.';
    disp(error_msg);
    disp('  Encountered the following errors on save:');
    disp(['    ' message]);
    disp('save_trip_index() operation aborted at line 205.');
    fclose(fid);
    return;
end;

% Write tripindex.dat file line by line
format_string = '%03d\t%13.3f\t%13.3f\t%13.3f\t%13.3f\n';
for i=1:length(load_index(:,1)),
    fprintf(fid, format_string, load_index(i,:));
end; % i=

% Close open file
fclose(fid);

end