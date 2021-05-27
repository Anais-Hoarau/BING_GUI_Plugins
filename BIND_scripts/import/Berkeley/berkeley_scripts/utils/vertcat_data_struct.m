% vertcat_data_struct.m (2-Level Data Structures)
%
% Written by Christopher Nowakowski
% v.1 11/03/08
%
% This function vertically concatinates two or more data (2-level) structures 
% of like type (i.e., all of the data sources and parameters are the same), 
% since the built-in vercat does not work on structures.
%
% This routine only works if the input data structures have two levels.  This 
% script was developed originally for CACC data structures.  Typically it should
% be used in load_data routines, before adding the data.meta fields. The data 
% structures to be vertically concatinated should look like the following:
%
% value = data.source.parameter(row#)
%
%
% Usage: [newstruct] = vertcat_data_struct(struct1, struct2, ...)
%

function [newstruct] = vertcat_data_struct(varargin)

% ------------------------------------------------------------------------------
% Check Input Arguments
% ------------------------------------------------------------------------------
newstruct = [];
usage_msg = 'Usage: [newstruct] = vertcat_data_struct(struct1, struct2, ...)';
if nargin == 1 && strcmpi(varargin{1},'?'),
    disp(usage_msg);
    return;
elseif nargin < 1,
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% Input Argument Loop - Cycles Through the varargin List
% ------------------------------------------------------------------------------
for argin = 1:size(varargin,2);
    
    % Check to see if the current input argument is empty
    if isempty(varargin{argin}),
        continue;
    end;
    
    % Check to see if the current input is of type struct
    if not(isstruct(varargin{argin})),
       error('%s\n%s',usage_msg, ['Error: Input argument ' num2str(argin)...
           ' is not a data structure.']);
    end; 
    
    % Check to see if this is the first non-empty input
    if isempty(newstruct),
        newstruct = varargin{argin};
        continue;
    end;
    
    
    % --------------------------------------------------------------------------
    % Data Source Loop - loops through the first structure level
    %
    % s = fieldnames(data) returns a list of fieldnames
    % data.(s(1)) is a working dynamic alias
    % --------------------------------------------------------------------------
    data_sources = fieldnames(newstruct);
    for source = 1:length(data_sources),
        
        % Test to make sure that this structure (data.source) level exists
        if not(isfield(varargin{argin}, data_sources{source})),
            error('%s\n%s\n%s%d%s%s',usage_msg,...
              'Error: Data sources were not consistent between input arguments.',...
              'Input Argument ', (argin), ' did not contain struct.', data_sources{source});
        end;
        
        % ----------------------------------------------------------------------
        % Data Parameters Loop - loops through the second structure level
        % ----------------------------------------------------------------------
        data_parameters = fieldnames(newstruct.(data_sources{source}));
        for parameter = 1:length(data_parameters),
            
            % Test to make sure that a this structure (data.source.parameter) level exists
            if not(isfield(varargin{argin}.(data_sources{source}),data_parameters{parameter})),
                error('%s\n%s\n%s%d%s%s%s%s',usage_msg,...
                    'Error: Data parameters were not consistent between input arguments.',...
                    'Input Argument ', (argin), ' did not contain struct.', data_sources{source},...
                    '.', data_parameters{parameter});
            end;
            
            % Perform the actual vercat
            newstruct.(data_sources{source}).(data_parameters{parameter}) = vertcat(...
                newstruct.(data_sources{source}).(data_parameters{parameter}),...
                varargin{argin}.(data_sources{source}).(data_parameters{parameter})...
                );
            
        end; % for parameter
        
    end; % for source
    
end; % for argin

end
