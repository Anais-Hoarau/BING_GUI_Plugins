function [temps,heureGMT,acc,frein,commentaires1,commentaires2,commentaires3] = import_var_ACT2(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [TEMPS,HEUREGMT,ACC,FREIN,COMMENTAIRES1,COMMENTAIRES2,COMMENTAIRES3] =
%   IMPORTFILE(FILENAME) Reads data from text file FILENAME for the default
%   selection.
%
%   [TEMPS,HEUREGMT,ACC,FREIN,COMMENTAIRES1,COMMENTAIRES2,COMMENTAIRES3] =
%   IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%
% Example:
%   [temps,heureGMT,acc,frein,commentaires1,commentaires2,commentaires3] =
%   importfile('17101417.var',2, 23391);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2013/10/23 17:00:38

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column2: text (%s)
%	column3: text (%s)
%   column14: double (%f)
%	column15: double (%f)
%   column17: text (%s)
%	column18: text (%s)
%   column19: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%s%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%f%f%*s%s%s%s%*s%*s%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
temps = dataArray{:, 1};
heureGMT = dataArray{:, 2};
acc = dataArray{:, 3};
frein = dataArray{:, 4};
commentaires1 = dataArray{:, 5};
commentaires2 = dataArray{:, 6};
commentaires3 = dataArray{:, 7};

