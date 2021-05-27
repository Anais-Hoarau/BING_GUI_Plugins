% set_project.m
% 
% Written by Christopher Nowakowski
% v.1 12/01/08
% 
% This function sets the working directory to the project directory & provides 
% a character array as a return representing your previous working directory.
% 

function [previous_dir] = set_project(ProjectName)

% ------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [previous_dir] = set_project(ProjectName)';
valid_projects = 'Valid Project Names: CACC, RFSWarning';

% Only looking for one input argument
if nargin ~= 1,
    error('%s\n%s',usage_msg,valid_projects);
end;

% Only looking for a text input argument
if ~ischar(ProjectName),
    error('%s\n%s',usage_msg,'ProjectName must be a character array.');
end;

% Check for help request
if strcmpi(ProjectName, '?'),
    disp(usage_msg);
    disp('Usage: Changes the MatLab working directory to the script directory for the specified project.');
    disp(valid_projects);
    return;
end;


% ------------------------------------------------------------------------------
% Record Current Directory for Return
% ------------------------------------------------------------------------------
previous_dir = cd;


% ------------------------------------------------------------------------------
% Determine Trunk Directory
% ------------------------------------------------------------------------------
trunk = which('set_project');
trunk = trunk(1:length(trunk)-19);


% ------------------------------------------------------------------------------
% Set the Correct Project Directory
% ------------------------------------------------------------------------------

% CACC
if strcmpi(ProjectName,'CACC'),
    project_dir = [trunk 'cacc'];

% RFS Warning
elseif strcmpi(ProjectName,'RFSWarning'),
    if exist('G:\IDS\RFSWarning\bin','dir') == 7,
        project_dir = 'G:\IDS\RFSWarning\bin';
    elseif exist('/Volumes/IDS/RFSWarning/bin','dir') == 7,
        project_dir = '/Volumes/IDS/RFSWarning/bin';
    elseif exist('/Users/huckie/Documents/PATH/IDS/HF RFSWarning/bin','dir') == 7,
        project_dir = '/Users/huckie/Documents/PATH/IDS/HF RFSWarning/bin';
    else,
        error('%s\n%s\n%s','Error: Could not find a valid .../RFSWarning/bin directory.', usage_msg, valid_projects);
    end;
    
% Invalid Project Error    
else
    error('%s\n%s\n%s',['Error: ' ProjectName ' is not a valid project.'], usage_msg, valid_projects);
end;


% ------------------------------------------------------------------------------
% Change to the Project Directory
% ------------------------------------------------------------------------------
if exist(project_dir,'dir') == 7,
    cd(project_dir);
else,
    error('%s\n%s\n%s',['Error: ' project_dir ' could not be found.'], usage_msg, valid_projects);
end;

end