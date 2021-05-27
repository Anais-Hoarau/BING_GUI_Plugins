% save_simple_struct.m
% 
% Written by Christopher Nowakowski
% v.1 02/21/09
% 
% This function saves a text data file from a single-tiered structure of the
% format: data.column_name 
% 
% The output is a tab delimited text file where the top column is a text header 
% with colunm name as it appears in the data structure.
%
% If no output filename is given, the function will bring up a 'save as...' 
% dialog box.
%
% The optional precision input value is the number of decimel places to print.
% The default precision is 3.
% 

function [error] = save_simple_struct(data,precision,filename)

% ------------------------------------------------------------------------------
% Check Input Arguments
% ------------------------------------------------------------------------------

% Set Defaults
usage_msg = 'Usage: [error] = save_simple_struct(data_structure,[opt precision],[opt FullFilePath&Name]);';
error = [];
ask_user_for_filename = 1;

% Check for help request
if nargin == 1 && strcmpi(data,'?'),
    disp(usage_msg);
    return;

elseif (nargin == 1 && isstruct(data)),
    % Data Struct Only
    precision = 3;
    % ask_user_for_filename = 1;
    
elseif (nargin == 2 && isstruct(data) && isnumeric(precision)),
    % Data Struct & Precision
    % ask_user_for_filename = 1;
    
elseif (nargin == 2 && isstruct(data) && ischar(precision)),
    % Data Struct & Filename    
    filename = precision;
    precision = 3;
    ask_user_for_filename = 0;
    
elseif (nargin == 3 && isstruct(data) && isnumeric(precision) && ischar(filename))
    % All Parameters Provided
    ask_user_for_filename = 0;
    
else,
    error = 'Error: Invalid Input Parameters.';
    disp(error);
    disp(usage_msg);
    return;
end;

% Check Precision
if (precision >= 0),
    precision = ceil(precision);
else,
    precision = 3;
end;

% Check Filename If Provided
if (~ask_user_for_filename),
    if (exist(filename,'file') == 0);
        ask_user_for_filename = 0;
        disp(['Saving ' filename]);
    elseif (exist(filename,'file') ==  2);
        disp(['Overwriting ' filename]);
    else,
        error = ['Error: Could not save ' filename];
        disp(error);
        return;
    end;
end;



% ------------------------------------------------------------------------------
% Ask User Where to Save the New File
% ------------------------------------------------------------------------------
if ask_user_for_filename,
    filename = ui_get_save_as_filename();
    if isempty(filename),
        error = 'Operation Cancelled by User.';
        return;
    end;
end;


% ------------------------------------------------------------------------------
% Convert Data Structure To a Flat Matrix
% ------------------------------------------------------------------------------

% Initialize data_columns
data_columns = fieldnames(data);

% Initialize Progress Bar
progress = 0;
progress_bar = waitbar(progress,'Formatting data to be saved...');
total_progress = length(data_columns);

% Initialize Cell Array
data_cell_array = cell(0);
format_string = '';


% Cycle Through Each Parameter
for i = 1:length(data_columns),

    % Set Up Format String by Variable Type & Copy Data to temp_cell_array as Flat Cells
    if ischar(data.(data_columns{i})),
        format_string = [format_string '%s'];
        temp_cell_array = cellstr(data.(data_columns{i}));
        
    elseif iscell(data.(data_columns{i})),
        % This is likely just a character array in a cell
        format_string = [format_string '%s'];
        temp_cell_array = cellstr(data.(data_columns{i}));

    elseif strcmpi(class(data.(data_columns{i})),'double'),
        % Determine the number of digits before the decimel point
        maxvalue = max( max(data.(data_columns{i})) , abs(min(data.(data_columns{i}))) );
        if (mod(maxvalue,10) == 0 || maxvalue <= 1),
            % Fix cases where the log10 will result in less than 1
            maxvalue = maxvalue + 1;
        end;
        % Determine total number of digits
        digits = ceil(log10(maxvalue)) + 1 + precision;
        if (min(data.(data_columns{i})) < 0),
            % Add a digit for the negative sign
            digits = digits + 1;
        end;
        
        % Set the format string & put the data into the temporary cell array
        format_string = [format_string '%' num2str(digits) '.' num2str(precision) 'f'];
        temp_cell_array = num2cell(data.(data_columns{i}));
        
    elseif isnumeric(data.(data_columns{i})),
        format_string = [format_string '%d'];
        temp_cell_array = num2cell(data.(data_columns{i}));

    else,
        % Probably a Structure Fieldname
        progress = progress + 1;
        if (i < length(data_columns)),
            continue;
        end;
    end;

    % Set Tab or New Line in Format String
    if (i == length(data_columns)),
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


% ------------------------------------------------------------------------------
% Initialize Progress Bar to Start Saving the Data File
% ------------------------------------------------------------------------------
message = ['Saving ' filename];
message = strrep(message,'\','\\');
message = strrep(message,'_','\_');
waitbar(0,progress_bar,message);


% ------------------------------------------------------------------------------
% Write Data File
% ------------------------------------------------------------------------------
[fid message] = fopen(filename,'w');
if ~isempty(message),
    error = ['Error: Could not save ' filename];
    disp(error);
    fclose(fid);
    return;
end;

% Write Data Headers
for i = 1:length(data_columns),
    if (ischar(data.(data_columns{i})) || iscell(data.(data_columns{i})) || isnumeric(data.(data_columns{i}))),
        if (i == length(data_columns)),
            header_format_string = '%s\n';
        else,
            header_format_string = '%s\t';
        end;
        fprintf(fid,header_format_string,data_columns{i});
    end;
end;

% Write Data Line by Line
total_progress = length(data_cell_array(:,1));
for progress=1:total_progress,
    fprintf(fid, format_string, data_cell_array{progress,:});
    if (mod(i,100) == 0),
        waitbar(progress/total_progress,progress_bar);
    end;
end;
waitbar(1,progress_bar);

% ------------------------------------------------------------------------------
% Close Open File
% ------------------------------------------------------------------------------
fclose(fid);
close(progress_bar);
pause(0.1);

end