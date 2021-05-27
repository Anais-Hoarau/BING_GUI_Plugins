% get_file_input_format.m
%
% Written by Christopher Nowakowski
% v1  12/16/09
%
% This function documents the various file formats used in the CACC project that
% need to be loaded into MatLab.  The function returns a format_string which 
% which can be used with the load_txt_datafile.m script or the MatLab textscan 
% command.
%
% Usage: [format_string] = get_file_input_format(filetype)
% Valid Filetypes: afile, cfile, dfile, triplist
%

function [format_string] = get_file_input_format(filetype)

% Test command input parameters
usage_msg = 'Usage: [format_string] = get_file_input_format(filetype);';
if (nargin ~= 1 || ~ischar(filetype))
    error(usage_msg);
end;

% Help Request
if (strcmpi(filetype,'?'))
    disp(usage_msg);
    disp('Valid Filetypes: afile, cfile, dfile, triplist');

% ACC/CACC A-File
elseif (~isempty(findstr(filetype,'afile')))
    % Column         %1   %2 %3 %4 %5 %6  %7  %8 %9 %10 %11 %12 %13 %14 %15 %16
    format_string = '%12c %n %n %n %n %d8 %d8 %n %n %d8 %n  %n  %n  %d8 %n  %n';
    
% ACC/CACC C-File    
elseif (~isempty(findstr(filetype,'cfile')))
    % Column         %1   %2 %3 %4 %5 %6 %7  %8 %9 %10 %11 %12 %13 %14 %15 %16 %17 %18 %19 %20 %21 %22 %23 %24
    format_string = '%12c %n %n %n %n %n %u8 %n %n %n  %n  %n  %d8 %d8 %n  %d8 %d8 %d8 %n  %n  %n  %n  %n  %n';
    
% ACC/CACC D-File
elseif (~isempty(findstr(filetype,'dfile')))
    % Column         %1   %2 %3 %4 %5 %6 %7 %8 %9 %10 %11 %12 %13 %14 %15 %16 %17 %18 %19 %20 %21 %22 %23 %24 %25 %26 %27 %28 %29 %30 %31 %32 %33
    format_string = '%12c %n %n %n %n %n %n %n %n %d8 %d8 %d8 %d8 %d8 %d8 %d8 %n  %n  %n  %d8 %d8 %n  %n  %n  %n  %n  %n  %n  %d8 %d  %d8 %n  %n';
    
% TripList.dat    
elseif (~isempty(findstr(filetype,'triplist')))
    format_string = [];
    for i=1:13
        format_string = [format_string '%d'];                                   %#ok<AGROW>
    end;    
    
% Unrecognized Request    
else
    error('Error: Unrecognized filetype.');
end;



end