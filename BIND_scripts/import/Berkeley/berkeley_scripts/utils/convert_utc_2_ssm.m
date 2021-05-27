% convert_utc_2_ssm.m
%
% Written by Christopher Nowakowski
% v.1   1/20/09
%
% This function converts a column of UTC formatted time (hhmmss.ss)
% to SSM (Seconds Since Midnight).  It takes an offset parameter which is
% the number of hours offset from GMT to your desired time zone.
%

function [utc_ssm] = convert_utc_2_ssm(utc,gmt_offset)

% -------------------------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% -------------------------------------------------------------------------------------------------
usage_msg = '[utc_in_ssm] = convert_utc_2_ssm(utc,gmt_offset);';

if nargin == 1 && strcmpi(utc,'?'),
    disp(usage_msg);
    return;

elseif nargin == 1 && isnumeric(utc),
    gmt_offset = 0;

elseif nargin == 2 && isnumeric(utc) && isnumeric(gmt_offset),
    % Fall through
    
else
    error(usage_msg);
end;

% -------------------------------------------------------------------------------------------------
% Convert UTC to Specified Time Zone in SSM
% -------------------------------------------------------------------------------------------------

utc_hours = floor(utc/10000);
utc_mins = floor( (utc - utc_hours*10000)/100 );
utc_secs = utc - utc_hours*10000 - utc_mins*100;
utc_hours = utc_hours + gmt_offset;

% Correct negative hours
index = find(utc_hours < 0);
if ~isempty(index),
    utc_hours(index) = utc_hours(index) + 24;
end;
utc_ssm = utc_hours*3600 + utc_mins*60 + utc_secs;

% Correct for crossing midnight
index = find(utc_ssm < utc_ssm(1));
if ~isempty(index),
    utc_ssm(index) = utc_ssm(index) + 86400;
end;

end