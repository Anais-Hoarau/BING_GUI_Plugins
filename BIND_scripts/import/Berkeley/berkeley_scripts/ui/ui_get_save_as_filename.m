% ui_get_save_as_filename.m
% 
% Written by Christopher Nowakowski
% v.1 11/20/08
% 
% This is a UI function that displays a 'Save As...' dialog box to the user.
% 
function [FileName] = ui_get_save_as_filename(datatype)

% Set Defaults
usage_msg = 'Usage: [SaveAsFileName] = ui_get_save_as_filename([opt ''-data'',''-figure'',''-kml''])';

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------
if (nargin == 0),
    datatype = 'data';
elseif (nargin == 1 && ischar(datatype)),
    if (strcmpi(datatype,'?')),
        disp(usage_msg);
        return;
    end;
else
    error(usage_msg);
end;

if (strcmpi(datatype,'data') || strcmpi(datatype,'-data') || strcmpi(datatype,'-d')),
    filter = '';
    prompt = 'Save Data As...';

elseif (strcmpi(datatype,'figure') || strcmpi(datatype,'-figure') || strcmpi(datatype,'-f')...
        || strcmpi(datatype,'-fig')),
    filter = {'*.jpg'; '*.png'; '*.pdf'; '*.eps'; '*.ai'; '*.*'};
    prompt = 'Save Figure As...';

elseif (strcmpi(datatype,'kml') || strcmpi(datatype,'-kml')),
    filter = {'*.kml'; '*.kmz'; '*.*'};
    prompt = 'Save KML File As...';

else,
    filter = '';
    prompt = 'Save Data As...';
end;
    

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------

FileNameSelected = 0;
while FileNameSelected == 0,
    [FileName PathName] = uiputfile(filter,prompt);
    % disp([PathName FileName]);
    if PathName == 0,
        FileName = [];
        return;
    end;
    if exist([PathName FileName],'file') == 0,
        FileNameSelected = 1;
    elseif exist([PathName FileName],'file') == 2,
        % Do you want to overwrite?
        error_msg = {[PathName FileName ' already exists.'];'Do you want to replace it?'};
        result = questdlg(error_msg);
        if strcmpi(result,'Yes'),
            % Overwrite
            FileNameSelected = 1;
        elseif strcmpi(result,'No'),
            % Select a New File
            FileNameSelected = 0;
        else,
            % Cancel 
            FileName = [];
            return;
        end; 
    else,
        % Invalid filename
        disp(['Result of exist: ' exist([PathName FileName],'file')]);
        error('Could not determine if selected filename was valid.');
    end;
end;

FileName = [PathName FileName];

end