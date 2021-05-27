% get_clockskew.m
%
% Written by Christopher Nowakowski
% v.1   01/15/09
%
% This function returns the offset between the wrtfiles system clock and
% the recorded UTC timestamp.  Typically, wrtfiles records at 20 Hz (50 ms)
% while the GPS records at 5 Hz (200 ms).
%
% Although the system clocks are typically set to UTC time, they tend to be off
% by anywhere up to 1 second.
%

function [clockskew minskew maxskew] = get_clockskew(system, utc, gmt_offset, clockreset)

% ------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = '[ClockSkew MinSkew MaxSkew] = get_clockskew(data.ts.ssm, data.gps.utc_time, gmt_offset, [opt clockreset (ssm)]);';

if ( nargin == 1 && strcmpi(system,'?') ),
    disp(usage_msg);
    return;

elseif (nargin == 3),
    clockreset = -1;
    
elseif (nargin == 4),
    % Input OK
    
else,
    error(usage_msg);
end;

% Set default return value to 0
clockskew = 0;
minskew = 0;
maxskew = 0;

% Locate the first non-zero value in data.ts.ssm
for i = 1:length(system),
    if system(i) ~= 0,
        break;
    end;
end;
if i == length(system),
    disp('Warning: Input provided for System Clock Time was all 0''s. Clock skew set to 0.');
    return;
end;

% Locate the first non-zero value in data.gps.utc_time
for i = 1:length(utc),
    if utc(i) ~= 0,
        break;
    end;
end;
if i == length(utc),
    disp('Warning: Input provided for UTC Time was all 0''s. Clock skew set to 0.');
    return;
end;

if length(system) ~= length(utc),
    disp('Warning: Length of System Clock Input does not equal Length of UTC input.  Clock skew set to 0.');
    return;
end;


% ------------------------------------------------------------------------------
% Convert UTC to Pacific Time in SSM
% ------------------------------------------------------------------------------
utc_ssm = convert_utc_2_ssm(utc,gmt_offset);


% ------------------------------------------------------------------------------
% Deal With clockreset Events
% ------------------------------------------------------------------------------
% 
% Based on CACC Data, Driver 98, Copper, Date080804, Trip0220, there is a 
% possibility that the first few data files could have very large clock skews.  
%
% It looks like the copper car may start recording data before the clock gets 
% synched to UTC.  Seq 0 is blank, Seq 1 had 2 minutes of data, Seq 2 has one
% line of data which is approximately 2 minutes later.  Seq 3 then picks up correctly.  

% If A clockreset Timestamp Was Provided
if (clockreset > 0),
    timejump = find(system == clockreset);
    if (~isempty(timejump)),
        system = system(timejump:length(system));
        utc_ssm = utc_ssm(timejump:length(utc_ssm));
    end;
else,
    timejump = [];
end;
    
% If No clockreset Timestamp Provided: Filter Out The First 3 Minutes Anyways
if ( isempty(timejump) && length(system) > 4000 ),
    system = system(3601:length(system));
    utc_ssm = utc_ssm(3601:length(utc_ssm));
end;


% -------------------------------------------------------------------------------------------------
% Calculate Clock Skew
% -------------------------------------------------------------------------------------------------
utc_changed = zeros(length(utc_ssm),1);
utc_changed(2:length(utc_changed)) = utc_ssm(2:length(utc_ssm)) - utc_ssm(1:length(utc_ssm)-1);
index = find(utc_changed ~= 0);
time_diff = system(index) - utc_ssm(index);
minskew = min(time_diff);
maxskew = max(time_diff);
clockskew = mean(time_diff);
clockskew = round(clockskew*100)/100;

end