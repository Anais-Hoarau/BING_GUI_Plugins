% autoincrement.m
%
% Written by Christopher Nowakowski
% v.1   3/11/09
%
% This function basically creates a column that increments each row by the 
% increment argument supplied to the function.  Row 1 will start at 0 and 
% the successive rows will increment until reaching the last row.
%
% The column of incremented values then gets horizontally concatinated to the
% input matrix according to the column input.  Column 0 adds the new column to 
% the left side of the matrix, -1 adds the new column to the right side of the
% matrix, and specifying an exact column number writes or overwrites to that 
% specific column.
%

function [newdata] = autoincrement(data,increment,column)

% ------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [new_matrix] = autoincrement(matrix,increment,column)';

if (nargin == 1 && ischar(data) && strcmpi(data,'?')),
    disp(usage_msg);
    disp('Note: Set column to 0 to shift all of the matrix columns to the right by one (default)');
    disp('Note: Set column to -1 to add the new column to the right side of the matrix');
    disp('Note: Setting column to an existing column number will overwrite that column');
    return;
    
elseif (nargin == 2 && isnumeric(data) && isnumeric(increment)),
    % No Column Input Arguement Provided
    column = 0;
    
elseif (nargin == 3 && isnumeric(data) && isnumeric(increment)),
    % Input OK
    column = int32(column);
else,
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% Create a Column Where Each Row Increments
% ------------------------------------------------------------------------------
for i=1:length(data(:,1)),
    newdata(i,1) = (i-1)*increment;
end;


% ------------------------------------------------------------------------------
% Add the AutoIncremented Column to the Original Data
% ------------------------------------------------------------------------------
if (column == 0),
    newdata = [newdata data];

elseif (column < 0),
    newdata = [data newdata];

else,
    data(:,column) = newdata(:,1);
    newdata = data;
    
end;

end