% vertcat_simple_struct.m (1-Level Data Structures)
%
% Written by Christopher Nowakowski
% v.1 06/04/09
%
% This function vertically concatinates two or more simple (single level) 
% structures of like type (i.e., all of the parameters are the same), since the
% built-in vercat does not work on structures.
% 
% This routine only works if the data structures have one level. The data 
% structures to be vertically concatinated should look like the following:
%
% value = data.parameter(row#)
%
%
% Usage: [newstruct] = vertcat_simple_struct(struct1, struct2, ...)
%

function [newstruct] = vertcat_simple_struct(varargin)

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------
newstruct = [];
usage_msg = 'Usage: [newstruct] = vertcat_simple_struct(struct1, struct2, ...)';
if nargin == 1 && strcmpi(varargin{1},'?'),
    disp(usage_msg);
    return;
elseif nargin < 1,
    error(usage_msg);
end;


% -------------------------------------------------------------------------------------------------
% Input Argument Loop - Cycles Through the varargin List
% -------------------------------------------------------------------------------------------------
for argin = 1:size(varargin,2);
    
    % Check to see if the current input argument is empty
    if isempty(varargin{argin}),
        continue;
    end;
    
    % Check to see if the current input is of type struct
    if not(isstruct(varargin{argin})),
       error('%s\n%s',usage_msg, 'Error: Encountered one or more input arguments that were not simple structures.');
    end; 
    
    % Check to see if this is the first non-empty input
    if isempty(newstruct),
        newstruct = varargin{argin};
        continue;
    end;
    

    % -------------------------------------------------------------------------------------------------
    % Data Parameters Loop
    % -------------------------------------------------------------------------------------------------
    data_parameters = fieldnames(newstruct);
    for parameter = 1:length(data_parameters),

        % Test to make sure that a this parameter exists
        if not(isfield(varargin{argin},data_parameters{parameter})),
            error('%s\n%s\n%s%d%s%s',usage_msg,...
                'Error: Data parameters were not consistent between input arguments.',...
                '       Input Argument ', argin, ' did not contain struct.', data_parameters{parameter});
        end;

        % Perform the actual vercat
        newstruct.(data_parameters{parameter}) = vertcat(...
            newstruct.(data_parameters{parameter}),...
            varargin{argin}.(data_parameters{parameter})...
            );

    end; % for parameter
    
end; % for argin

end
