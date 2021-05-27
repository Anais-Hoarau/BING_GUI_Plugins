% get_path.m  (CACC)
%
% Written by Christopher Nowakowski
% v.1 10/21/08
% v.2 12/05/08  - Removed fatal error.  Replaced with a null return value.
% v.3 06/07/10  - Updated after upgrade of HF-Raid.
%
% This function checks for connections to the HF-RAID computer or for 
% project files on the local disk, and sets the data location accordingly.
% It also gets the appropriate file separater character depending on
% whether you are on windows or mac.
%
% Note: The return value "file_path" is a cell array.  This means that you access the 
%       individual values in it by using {} instead of ().
%
% Usage: file_path{} = get_path()
%
% file_path{1} = Remote or Local Data File Path
% file_path{2} = OS-Specific File Separator Character
% file_path{3} = User Readable Information Message

function [file_path] = get_path(varargin)

% If any input arguments are provided, display usage message
if nargin > 0,
    disp('Usage: file_path{} = get_path()');
    disp('file_path{1} = CACC Raw Data Directory (with trailing file separator)');
    disp('file_path{2} = File Separator Character');
    disp('file_path{3} = Verbose Message');
end;

% Check for Local HF-Raid Connection on Windows
if exist('F:\CACC\RawData\','dir') == 7
    file_path{1} = 'F:\CACC\RawData\';
    file_path{2} = '\';
    file_path{3} = 'Note: Running script locally on the HF-Raid computer (Windows).';

% Check for Remote HF-Raid Connection on Windows
elseif exist('\\128.32.234.237\CACC\RawData\','dir') == 7
    file_path{1} = '\\128.32.234.237\CACC\RawData\';
    file_path{2} = '\';
    file_path{3} = 'Note: Successfully connected to HF-Raid. Running scripts remotely (Windows).';

% Check for Remote HF-Raid Connection on Mac
elseif exist('/Volumes/CACC/RawData/','dir') == 7
    file_path{1} = '/Volumes/CACC/RawData/';
    file_path{2} = '/';
    file_path{3} = 'Note: Successfully connected to HF-Raid. Running scripts remotely (Mac).';

% Check for local CACC Data Directory on Mac {Christopher's Laptop}
elseif exist('/Users/huckie/Documents/PATH/CACC/RawData/','dir') == 7
    file_path{1} = '/Users/huckie/Documents/PATH/CACC/RawData/';
    file_path{2} = '/';
    file_path{3} = 'Note: HF-Raid could not be found. Running scripts locally on CSN''s Mac.';
else
    file_path = [];
    disp('Warning: Could not find a valid CACC Data Directory.');
end;

end