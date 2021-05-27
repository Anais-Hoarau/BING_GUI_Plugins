% load_txt_datafile.m
%
% Written by Christopher Nowakowski
% v.1 12/14/09
%
% This function loads a text data file created using either save_simple_struct.m 
% or save_data_struct.m).  However, it works just fine to import any delimited
% text file so long as the first column is a header line, and the headers are
% all single words (no spaces).
%
% This function was written because the MatLab importdata command is very
% limited in dealing with text.  Although the importdata function would be
% more efficient, if you have any columns of text in the data, all columns
% to the left of the text columns will also be treated as text.  This function
% lets you specify how each column should be treated during import at the
% expense of speed.
%
% Inputs
%
% The inputs to this function include a format string and a filename to import.
% The input file should be a tab delimited (or other white space delimited) or 
% a comma seperated CSV file.
%
% If no filename is provided, the UI will prompt the user to select an input 
% file manually.
%
% Typical Input Format String Options: %d (int), %u (unint), %n (double), %s (string)
%
% DO NOT INCLUDE \t's or \n's in your format string.  Excel and other programs
% appear to be very bad at formatting ends of lines.  It's better to leave off
% explicit white space and end of line formatting and let MatLab deal with it.
% Otherwise, textscan will choke at the end of the line and return only the
% the first data line of your input file.
% 
% Search on Matlab "textscan" to read about input format string options.
%
% Outputs
% 
% The output of this function is currently a simple data structure (1-Level)
% containing the data from the text file imported into the format you specified
% in your format string.  
%
% Usage: [data_struct] = load_txt_file(format_string,[opt FullFilePath&Name])
%

function [data] = load_txt_datafile(format_string,filename)


% ------------------------------------------------------------------------------
% Check & Parse Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [data_struct] = load_txt_file(format_string,[opt FullFilePath&Name])';
if (nargin == 0 || (nargin == 1 && ischar(format_string) && strcmpi(format_string,'?')))
    % Help Request
    disp(usage_msg);
    disp('Note: Providing no input argument for the filename will bring up a GUI to select a file.');
    disp('Note: Format String Options Include %d (int), %u (unsigned int), %n (double), %s (string)');
    disp('Note: Do not include explicit \t''s or \n''s in your format string.');
    return;
    
elseif (nargin == 1 && ischar(format_string))
    % No filename provided
    askforfilename = 1;
    
elseif (nargin == 2 && ischar(format_string) && ischar(filename))
    % Filename provided
    if ((exist(filename,'file')) ~= 2)
        % Filename does not exist
        askforfilename = 1;
        filename = [];
    else
        askforfilename = 0;
    end;
else
    % Invalid input arguments provided
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% UI to Select Input File if None was Provided
% ------------------------------------------------------------------------------
data = [];
if (askforfilename == 1)
    [file path] = uigetfile('*','Select a Text File To Import...');
    if ischar(file)
        filename = [path file];
        clear path file;
    else
        return;
    end;
end;


% ------------------------------------------------------------------------------
% Import Data From File
% ------------------------------------------------------------------------------
fid = fopen(filename,'r');
header = fgets(fid);
rawdata = textscan(fid,format_string);
fclose(fid);


% ------------------------------------------------------------------------------
% Turn header row into a data structure
% ------------------------------------------------------------------------------

% Set default delimiter list
%            Tab     Space            CR       LF/NL
delimiter = [char(9) char(32) ',' ';' char(13) char(10)];

% Check for periods in the header values and replace with underscore
if ~isempty(findstr(header,'.'))
    header = strrep(header,'.','_');
end;

% Parse header into a structure
remain = header;
while length(remain > 0)
    [token remain] = strtok(remain,delimiter);                                  %#ok<STTOK>
    if length(token) > 0
        data.(token) = [];
    end;
end;


% ------------------------------------------------------------------------------
% Verify that the number of rawdata columns match header columns 
% ------------------------------------------------------------------------------
fields = fieldnames(data);
if (length(rawdata(1,:)) ~= length(fields))
    error('%s%d%s%d%s\n%s\n%s','Error: ',length(fields),...
        ' header columns detected, and ', length(rawdata(1,:)),...
        ' columns of imported data detected.',...
        'Note: This may indicate a problem with either the format_string or the datafile.',usage_msg);
end;


% ------------------------------------------------------------------------------
% Move rawdata to data structure
% ------------------------------------------------------------------------------
for i=1:length(fields)
    data.(fields{i}) = rawdata{i};
end;

end