% convert_text_ts.m
%
% Written by Christopher Nowakowski
% v.1 11/18/08
%
% This function converts timestamps between two formats:
%
% 1.  If the input is a character array of the format HH:MM:SS.xxx, then it is converted to
%     a float representing SSM (Seconds Since Midnight).
%
% 2.  If a float is provided, then it is converted from SSM to a character array of the format
%     HH:MM:SS.xxx where HH is on a 24 hour clock.  If the float is greater than 24 hours, it
%     will return a value greater than 24, thus, 48 would represent 2 days.  If HH exceeds 96
%     hours, it will return an error.
% 
% Usage: [new format] = convert_text_ts(ssm or ''HH:MM:SS.xxx'')
%


function [new_ts] = convert_text_ts(old_ts)

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------
usage_msg = 'Usage: [new format] = convert_text_ts(ssm or ''HH:MM:SS.xxx'');';
if nargin ~= 1,
    error(usage_msg);
end;


if ischar(old_ts),
    % -------------------------------------------------------------------------------------------------
    % Input Argument is Text - Convert to SSM
    % -------------------------------------------------------------------------------------------------
    
    % Check for help request
    if length(old_ts) == 1 && strcmpi(old_ts,'?'),
        disp(usage_msg);
        return;
    end;

    % Verify That Input is a Timestamp
    if length(old_ts(1,:)) < 8,
        error('%s\n%s','Text timestamp must be at least 8 characters long.',...
        'Usage: [new_format] = convert_text_ts(ssm or ''HH:MM:SS.xxx'')');
    elseif ~strcmpi(old_ts(1,3),':') || ~strcmpi(old_ts(1,6),':'),
        error('%s\n%s','Text timestamp must of the format HH:MM:SS.xxx',...
        'Usage: [new_format] = convert_text_ts(ssm or ''HH:MM:SS.xxx'')');
    else,
        % Convert Text TS to SSM
        new_ts = str2num(old_ts(:,1:2)).*3600 + str2num(old_ts(:,4:5)).*60 + str2num(old_ts(:,7:length(old_ts(1,:))));
    end;

else,
    % -------------------------------------------------------------------------------------------------
    % Input Argument is Numeric - Convert to HH:MM:SS.xxx
    % -------------------------------------------------------------------------------------------------
    
    % Verify that valid input range
    if min(old_ts) < 0,
        error('%s\n%s','SSM (Seconds Since Midnight) cannot be a negative value.',...
            usage_msg);
    end;
    if max(old_ts./3600) >= 100,
        error('%s\n%s','SSM (Seconds Since Midnight) cannot exceed 4 days.',...
            usage_msg);
    end;
    
    % Convert SSM to TS
    h = floor(old_ts./3600);
    m = floor((old_ts - h.*3600)./60);
    s = old_ts - h.*3600 - m.*60;
    colons(1:length(h),1) = ':';
    new_ts = [num2str(h,'%02d') colons num2str(m,'%02d') colons num2str(s,'%06.3f')];
end;

end