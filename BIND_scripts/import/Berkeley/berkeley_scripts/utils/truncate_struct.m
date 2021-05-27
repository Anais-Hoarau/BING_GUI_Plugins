% truncate_struct.m
% 
% Written by Christopher Nowakowski
% v.1  3/09/09
% v.2 12/15/09 Major rewrite to accept truncation by -index method
% 
% Usage: [newdata] = truncate_struct(data,fieldname,minvalue,maxvalue)
%
% This function truncates the data contained in a 1-level (simple) or a 2-level 
% data structure.
% 
% The truncation can be based on one of three different criteria:
% 1.  It can be based on locating all the data between a provided min/max value
%     in a single specified data field.  
%
% 2.  It can be based on on providing an exact row number for the min/max
%     value input parameters, and specifing the fieldname to be '-row'; however,
%     the fieldname parameter must still indicate the depth of the structure. So
%     for a 2-level data structure, you would need to specify {'-row' '-row'}
%
% 3.  It can be based on providing a list of row numbers in the minvalue field,
%     and specifying the fieldname to be '-index' or {'-index' '-index'}.  The 
%     maxvalue field can be left blank.
%
% Note: I can't figure out how exactly to make this function univeral, so it 
% will only work for structures that are flat (1-level) or a 2-level data struct
% where you have data.source.parameter.
%
% Note: Any level-1 fieldname called 'meta' (data.meta) will simply be copied
% over "as is" and the data.meta.dataset parameter will be changed to read as 
% 'Partial Trip'
% 
% Usage: [newdata] = truncate_struct(data,fieldname,minvalue,maxvalue)
% Note: Fieldname should be a cell array indicating the depth of the structure.
%       E.g., A 2-level structure where you want to search on data.ts.ssm would have fieldname = {''ts'' ''ssm''}
% Note: You can also directly provide min and max row numbers by designating fieldname as {''-row'' ''-row''}
% Note: You can also directly provide a list of rows by designating fieldname as {''-index'' ''-index''}
%

function [newdata] = truncate_struct(data,field,minvalue,maxvalue)

% ------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [newdata] = truncate_struct(data_struct,fieldname,minvalue,maxvalue);';

if (nargin == 1 && ischar(data) && strcmpi(data,'?')),
    disp(usage_msg);
    disp('Note: Fieldname should be a cell array indicating the depth of the structure.');
    disp('      E.g., A 2-level structure where you want to search on data.ts.ssm would have fieldname = {''ts'' ''ssm''};');
    disp('Note: You can also directly provide min and max row numbers by designating fieldname as {''-row'' ''-row''}');
    disp('Note: You can also directly provide a list of rows by designating fieldname as {''-index'' ''-index''}');
    return;

elseif (nargin == 3 && isstruct(data) && (ischar(field) || iscell(field)) && isnumeric(minvalue)),
    % User is probably specifing truncation by -index method
    maxvalue = NaN;

elseif (nargin == 4 && isstruct(data) && (ischar(field) || iscell(field)) && isnumeric(minvalue) && isnumeric(maxvalue)),
    % Input OK
    
else,
    error('%s\n%s','Error: Input arguments provided were not of the correct type.',usage_msg);
end;

% Check that field parameter is a cell array & set structure depth
if (ischar(field))
    % User provided a single fieldname as a character array so convert it to a cell array
    field = {field};
end;
depth = length(field); 

% Set Default Return Value
newdata = [];


% ------------------------------------------------------------------------------
% Create an index of row numbers to keep
% ------------------------------------------------------------------------------
if (strcmpi(field{1},'-index')),
    % --------------------------------------------------------------------------
    % Method 3: Truncate by Index
    % --------------------------------------------------------------------------
    if (min(minvalue) < 1)
        error('%s\n%s','Error: Attempted to truncate by method -index, but all row numbers must be greater than 0.',...
            usage_msg);
    end;
    index = uint32(minvalue);    

    
elseif (strcmpi(field{1},'-row')),
    % --------------------------------------------------------------------------
    % Method 2: Truncate by Row Number
    % --------------------------------------------------------------------------
    
    % Check to see if the input parameters are row numbers
    startrow = uint32(minvalue);
    endrow = uint32(maxvalue);
    if (startrow == 0 || endrow == 0 ||(endrow - startrow < 1))
        error('%s\n%s','Error: Attempted to truncate by method -row, but 0 < minvalue < maxvalue.',usage_msg);
    end;
    
    % Convert start/end row numbers to an index
    index = zeros((endrow - startrow + 1),1);
    index = autoincrement(index,1,1);
    index = index + startrow;
    clear startrow endrow;

    
else,
    % --------------------------------------------------------------------------
    % Method 1: Truncate by FieldName & Min/Max Values
    % --------------------------------------------------------------------------
    
    % Find Start & End Rows Based on a Fieldname and Min/Max Values
    if (depth == 1),
        index = find(data.(field{1}) >= minvalue & data.(field{1}) <= maxvalue);

    elseif (depth == 2),
        index = find(data.(field{1}).(field{2}) >= minvalue & data.(field{1}).(field{2}) <= maxvalue);

    else,
        error('%s\n%s','Error: This function only works on 1- or 2-level structures.', usage_msg);
    end;
end;


% ------------------------------------------------------------------------------
% Check for null index
% ------------------------------------------------------------------------------
if (isempty(index) || (min(index) < 1)),
        disp('Error: No data was found to match the input parameters.');
        return;
end;


% ------------------------------------------------------------------------------
% Truncate A Simple Struct (1-Level)
% ------------------------------------------------------------------------------
if (depth == 1),
    parameter = fieldnames(data);
    for i=1:length(parameter),
        newdata.(parameter{i}) = data.(parameter{i})(index,:);
    end;
end;


% ------------------------------------------------------------------------------
% Truncate A 2-Level Data Structure
% ------------------------------------------------------------------------------
if (depth == 2),
    
    % Loop Through Data Sources
    source = fieldnames(data);
    for i=1:length(source),
        
        % Handle Meta Data If It Exists
        if strcmpi(source{i},'meta'),
            newdata.meta = data.meta;
            newdata.meta.dataset = 'Partial Trip';
            
        else,
            % Loop Through Data Parameters and Truncate
            parameter = fieldnames(data.(source{i}));
            for j=1:length(parameter);
                newdata.(source{i}).(parameter{j}) = data.(source{i}).(parameter{j})(index,:);
                
            end;    % for j...
        end;
    end;    % for i...
end;

end