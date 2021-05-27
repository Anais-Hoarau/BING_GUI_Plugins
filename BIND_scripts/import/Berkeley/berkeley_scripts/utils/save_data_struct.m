% save_data_struct.m
% 
% Written by Christopher Nowakowski
% v.1 11/20/08
% 
% This function saves a data file that was loaded with a load_dat_files command where the data
% has been put into a 2-tiered structure such that it can be accessed by data.source.parameter.
% 
% The output is a tab delimited text file where the top column is a text header with the parameter
% name.  If no output filename is given, the function will bring up a 'save as...' dialog box.
% Warnings are also provided if the resulting file will be too large to be loaded by excel.
% 

function [FileName] = save_data_struct(data,FileName)

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------

% Set Defaults
usage_msg = 'Usage: [SavedFileName] = save_data_struct(data_structure,[opt FullFilePath&Name]);';
ask_user_for_filename = 1;

% Check for invalid number of arguments
if nargin == 0 || nargin > 2,
    error(usage_msg);
end;

% Check for help request
if nargin == 1 && strcmpi(data,'?'),
    disp(usage_msg);
    return;
end;

% Check input argument to see if it's of type struct
if not(isstruct(data)),
    error('%s\n%s',usage_msg,'Error: Input argument was not a structure.');
end;

if not(isfield(data,'ts')),
    error('%s\n%s',usage_msg,'Error: Input argument did not contain timestamp data source.');
end;

if not(isfield(data.ts,'text')),
    error('%s\n%s',usage_msg,'Error: Input argument did not contain timestamp data field.');
end;

if nargin == 2,
    if ~ischar(FileName),
        ask_user_for_filename = 1;
    else,
        if exist(FileName,'file');
            message = ['Warning: ' FileName ' already exists.  Save Data Operation Aborted.'];
            disp(message);
            FileName = [];
            return;
        else,
            ask_user_for_filename = 0;
        end;
    end;
end;

% Check Data Length vs. Excel Line Limit
if (length(data.ts.text) + 1) > 65536,
    disp('Warning: Data set will exceed Excel''s 65,536 line limit.');
    if ask_user_for_filename,
        warndlg('Data set will exceed Excel''s 65,536 line limit.');
    end;
end;


% -------------------------------------------------------------------------------------------------
% Ask User Where to Save the New File
% -------------------------------------------------------------------------------------------------
if ask_user_for_filename,
    FileName = ui_get_save_as_filename();
    if isempty(FileName),
        return;
    end;
end;

% -------------------------------------------------------------------------------------------------
% Initialize Progress Bar For Data Reformatting
% -------------------------------------------------------------------------------------------------
progress_bar = waitbar(0,'Formatting data to be saved...');

% Initialize data_sources, ignoring the meta data field
% Warning: data_sources is is used multiple times - Do Not Overwrite
data_sources = fieldnames(data);
index = find(strcmpi('meta',data_sources));
if (~isempty(index)),
    data_sources(index) = [];
end;

% Loop through the data sources and parameters to get a total number of fields in the structure
total_progress = 0;
for source = 1:length(data_sources),
    data_parameters = fieldnames(data.(data_sources{source}));
    for parameter = 1:length(data_parameters),
        total_progress = total_progress + 1;
    end; % for parameter
end; % for source


% -------------------------------------------------------------------------------------------------
% Convert Data Structure To a Flat Matrix
% -------------------------------------------------------------------------------------------------

% Initialize
data_cell_array = cell(0);
format_string = '';
progress = 0;

% Cycle Through Each Data Source
for source = 1:length(data_sources),

    % Get Current Parameter List
    data_parameters = fieldnames(data.(data_sources{source}));

    % Cycle Through Each Parameter
    for parameter = 1:length(data_parameters),

        % Set Up Format String by Variable Type & Copy Data to temp_cell_array as Flat Cells
        if ischar(data.(data_sources{source}).(data_parameters{parameter})),
            format_string = [format_string '%s'];
            temp_cell_array = cellstr(data.(data_sources{source}).(data_parameters{parameter}));
            
        else,
            if strcmpi(class(data.(data_sources{source}).(data_parameters{parameter})),'double'),
                format_string = [format_string '%13.6f'];
            
            elseif strcmpi(class(data.(data_sources{source}).(data_parameters{parameter})),'int8'),
                format_string = [format_string '%d'];
            
            elseif strcmpi(class(data.(data_sources{source}).(data_parameters{parameter})),'int32'),
                format_string = [format_string '%d'];
            
            elseif strcmpi(class(data.(data_sources{source}).(data_parameters{parameter})),'uint8'),
                format_string = [format_string '%d'];
            end;
            temp_cell_array = num2cell(data.(data_sources{source}).(data_parameters{parameter}));
        end;
        
        % Set Tab or New Line in Format String
        if source == length(data_sources) && parameter == length(data_parameters),
            format_string = [format_string '\n'];
        else
            format_string = [format_string '\t'];
        end;
        
        % Horizontally Concatinate temp_cell_array to data_cell_array
        if isempty(data_cell_array),
            data_cell_array = temp_cell_array;
        else,
            data_cell_array = [data_cell_array temp_cell_array];
        end;
        
        % Update Progressbar
        progress = progress + 1;
        waitbar(progress/total_progress,progress_bar);
        
    end; % for parameter

end; % for source


% -------------------------------------------------------------------------------------------------
% Initialize Progress Bar to Start Saving the Data File
% -------------------------------------------------------------------------------------------------
message = ['Saving ' FileName];
message = strrep(message,'\','\\');
message = strrep(message,'_','\_');
waitbar(0,progress_bar,message);


% -------------------------------------------------------------------------------------------------
% Write Data File
% -------------------------------------------------------------------------------------------------
[fid message] = fopen(FileName,'w');
if ~isempty(message),
    disp(['Warning: Attempted to save ' FileName]);
    disp('Encountered the following error:');
    disp(message);
    disp('Save Data Operation Aborted!');
    FileName = [];
    fclose(fid);
    return;
end;

% Write Data Headers
for source = 1:length(data_sources),
    data_parameters = fieldnames(data.(data_sources{source}));
    for parameter = 1:length(data_parameters),
        if source == length(data_sources) && parameter == length(data_parameters),
            header_format_string = '%s\n';
        else,
            header_format_string = '%s\t';
        end;
        header = [data_sources{source} '.' data_parameters{parameter}];
        fprintf(fid, header_format_string, header); 
    end; % for parameter
end; % for source

% Write Data Line by Line
total_progress = length(data.ts.text);
for progress=1:total_progress,
    fprintf(fid, format_string, data_cell_array{progress,:});
    waitbar(progress/total_progress,progress_bar);
end; % for progress

% -------------------------------------------------------------------------------------------------
% Close Open File
% -------------------------------------------------------------------------------------------------
fclose(fid);
close(progress_bar);
end