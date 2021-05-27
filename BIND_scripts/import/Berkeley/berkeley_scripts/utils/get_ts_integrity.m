% get_ts_integrity.m
% 
% Written by Christopher Nowakowski
% v 1.0 written 1/22/2009
%
% This is a function that checks the timestamp column's integrity, looking for 
% cases where the difference between successive time stamps exceeds either the 
% upper or lower tolerance.
%
% Inputs
% 1. A data struct that contains data.ts.ssm or a column of timestamps in SSM
% 2. Upper and Lower Tolerances in (s)
%
% Outputs
% 1. ts_integrity matrix which is a column identical in size to the input with 
%    0/1 used to mark the rows where the sequential time stamps are within or
%    outside of the specified tolerances.
%
% 2. ts_errors is a simple data structure detailing the timestamp errors.  It
%    will contain either 3 or 6 fields depending on whether or a not a data
%    structure was passed that contains a data.gps.utc_time field.
%
%    Fields: row, clock, clock_diff, [utc, utc_pacific, utc_diff]
%
% 3. error_count is the number of discrete timestamp errors that were found.
%

function [ts_integrity tserr error_count] = get_ts_integrity(data,upper,lower)

% ------------------------------------------------------------------------------
% Check Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [ts_integrity ts_errors error_count] = get_ts_integrity([data.struct or ssm], upper_tolerance, lower_tolerance);';

if ( nargin == 0 || (nargin == 1 && ischar(data) && strcmpi(data,'?')) ),
    disp(usage_msg);
    return;

elseif ( nargin == 3 && isstruct(data) && isfield(data,'ts') && isfield(data.ts,'ssm')...
        && length(data.ts.ssm) > 2 && isnumeric(upper) && isnumeric(lower) ),
    
    % Input is a data structure
    ssm = data.ts.ssm;

elseif ( nargin == 3 && isnumeric(data) && length(data) > 2 && isnumeric(upper)...
        && isnumeric(lower) ),
    
    % Input is a column of timestamps in ssm
    ssm = data;
    data = [];

else,
    error(usage_msg);
end;

% Check for valid tolerance inputs
if (upper < 0 || lower < 0),
    error('%s\n%s','Upper and Lower Tolerances must be > 0.',usage_msg);
end;


% ------------------------------------------------------------------------------
% Create ts_integrity Matrix
% ------------------------------------------------------------------------------

% Initialize matrices used to create ts_integrity
ts_warning_start = zeros(length(ssm),1);
ts_warning_end = ts_warning_start;

% Subtraction of Successive Timestamps
ts_warning_start(1:length(ssm)-1) = -ssm(1:length(ssm)-1) + ssm(2:length(ssm));
ts_warning_end(2:length(ssm)) = ssm(2:length(ssm)) - ssm(1:length(ssm)-1);

% Reset first and last timestamp differences from 0 to within the tolerences
ts_warning_start(length(ssm)) = upper;
ts_warning_end(1) = lower;

% Be sure to catch the event start by setting anything out of bounds to -1
index = find( abs(ts_warning_start) < lower | abs(ts_warning_start) > upper );
ts_warning_start(index) = -1;
index = find( abs(ts_warning_end) < lower | abs(ts_warning_start) > upper );
ts_waring_end(index) = -1;

% Set anything within tolerances to 0
index = find( abs(ts_warning_start) >= lower & abs(ts_warning_start) <= upper );
ts_warning_start(index) = 0;
index = find( abs(ts_warning_end) >= lower & abs(ts_warning_end) <= upper );
ts_warning_end(index) = 0;

% Set anything that is still not 0 to 1
index = find( abs(ts_warning_start) ~= 0 );
ts_warning_start(index) = 1;
index = find( abs(ts_warning_end) ~= 0 );
ts_warning_end(index) = 1;

% Add ts_warning_start and ts_warning_end matrices which results in...
% 1 for the start of an event
% 2 for during an event
% 1 for the end of an event
ts_integrity = ts_warning_start + ts_warning_end;

% Reset anything not 0 to 1
index = find( ts_integrity ~= 0 );
ts_integrity(index) = 1;


% ------------------------------------------------------------------------------
% Create Error Summary and Count
% ------------------------------------------------------------------------------

% Create Minimal Simple tserr Data Struct For Return
tserr.row = [];
tserr.timestamp = [];
tserr.clock = [];
tserr.clock_diff = [];

% Create Extended Data Struct
if (~isempty(data)),
    tserr.utc = [];
    tserr.utc_pacific = [];    
    tserr.utc_diff = [];
end;

% Initialize error_count For Return
error_count = [];

% Find Data Rows With Jumps
tserr.row = find(ts_integrity ~= 0);

% Check for No Errors Condition
if (isempty(tserr.row)),
    % No Timestamp Errors
    tserr = [];
    error_count = 0;
    return;
else,
    tserr.row = cast(tserr.row,'int32');
end;

% Count the Number of Discrete (Nonsequential) Timestamp Errors
diff_index(2:(length(tserr.row))) =...
    tserr.row(2:(length(tserr.row))) - tserr.row(1:(length(tserr.row)-1));
discrete_errors = [1 find(diff_index > 1)];
error_count = length(discrete_errors);

% Store Clock Readings for Error Rows & Subtract Successive Clock Differences 
tserr.clock = ssm(tserr.row);
tserr.timestamp = convert_text_ts(tserr.clock);
tserr.clock_diff(2:length(tserr.row),1) =...
    tserr.clock(2:length(tserr.row)) - tserr.clock(1:(length(tserr.row)-1));
tserr.clock_diff(discrete_errors) = NaN;

% Store Additional Info If a Data Struct Was Passed In
if ( ~isempty(data) && isfield(data,'gps') && isfield(data.gps,'utc_time') ),

    % Store Raw GPS Readings for Error Rows
    tserr.utc = data.gps.utc_time(tserr.row);
    
    % Convert Raw GPS to Pacific Time SSM & Store It
    if (~isfield(data,'meta') || ~isfield(data.meta,'gmt_offset') || isempty(data.meta.gmt_offset)),
        data.meta.gmt_offset = 0;
    end;
    tserr.utc_pacific = convert_utc_2_ssm(tserr.utc,data.meta.gmt_offset);
    
    % Subtract Successive Clock Differences
    tserr.utc_diff(2:length(tserr.row),1) = tserr.utc_pacific(2:length(tserr.row)) - tserr.utc_pacific(1:(length(tserr.row)-1));
    tserr.utc_diff(discrete_errors) = NaN;
end;

end