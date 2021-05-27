% get_gmt_offset.m
%
% Written by Christopher Nowakowski
% v.1   01/15/09
%
% This function returns the offset between GMT and PST or PDT
% depending on the date that is passed to the function.
%
% The DST starting and ending dates need to be updated yearly in the
% daylight_savings_time.txt file stored in the same directory
% as this function.
%
% daylight_savings_time.txt file format:
%
% Column 1 = Year Entry
% Column 2 = DST Start Month
% Column 3 = DST Start Day
% Column 4 = DST End Month
% Column 5 = DST End Date
%

function [offset] = get_gmt_offset(tripdate)

% -------------------------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% -------------------------------------------------------------------------------------------------
usage_msg = 'Usage: [hours] = get_gmt_offset(TripDate{DDMMYY})';

if nargin ~= 1,    
    error(usage_msg);
    return;
end;

if strcmpi(tripdate,'?'),
    disp(usage_msg);
    return;
end;

if ischar(tripdate),
    if length(tripdate) == 6,
        year = 2000 + str2num(tripdate(5:6));
    elseif length(tripdate) == 8,
        year = str2num(tripdate(5:8));
    else,
        error('%s%s\n%s',tripdate,' is not in the correct date format.',usage_msg);
    end;
    day = str2num(tripdate(1:2));
    month = str2num(tripdate(3:4));

elseif isa(tripdate,'numeric'),
    if tripdate < 320000,
        day = floor(tripdate/10000);
        month = floor((tripdate - day*10000)/100); 
        year = 2000 + tripdate - day*10000 - month*100;
    elseif tripdate < 32000000,
        day = floor(tripdate/1000000);
        month = floor((tripdate - day*1000000)/10000); 
        year = tripdate - day*1000000 - month*10000;
    else,
        error('%8.0f%s\n%s',tripdate,' is not in the correct date format.',usage_msg);
    end;
else,
    error(usage_msg);
end;

if day < 1 || day > 31,
    error('%s%2.0f%s\n%s','Incorrect date format. ',day,' is not a valid day of the month.',usage_msg);
end;
if month < 1 || month > 12,
    error('%s%2.0f%s\n%s','Incorrect date format. ',month,' is not a valid month.',usage_msg);
end;


% -------------------------------------------------------------------------------------------------
% Load DST Table & Get DST Offset
% -------------------------------------------------------------------------------------------------
if exist('daylight_savings_time.txt','file') ~= 2,
    error('Could not find the file daylight_savings_time.txt.  Make sure this file is stored in the PATH alias directory.');
end;
dst_table = load('daylight_savings_time.txt');

% Find year & determine if DST was active
row = find(dst_table(:,1) == year);
if isempty(row),
    error('%s%4.0f%s','The file daylight_savings_time.txt contains no entry for ',year,'. Please update the file.');
end;

if month < dst_table(row,2) || month > dst_table(row,4),
    % ST
    dst_offset = 0;

elseif month == dst_table(row,2),
    % In month where DST starts so check day
    if day < dst_table(row,3),
        % ST
        dst_offset = 0;
    else,
        % DST
        dst_offset = 1;
    end;

elseif month == dst_table(row,4),
    % In month where DST ends so check day
    if day < dst_table(row,5),
        % DST
        dst_offset = 1;
    else,
        % ST
        dst_offset = 0;
    end;

else,
    dst_offset = 1;
end;

% -------------------------------------------------------------------------------------------------
% Return Pacific Time Zone Offset
% -------------------------------------------------------------------------------------------------
offset = -8 + dst_offset;

end