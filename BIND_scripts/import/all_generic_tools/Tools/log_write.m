%% log_write function
% TODO
%
% log_write(log_file_handler,value1,value2,...)
%
% Arguments:
% log_file_handler: TODO
% values:           a string or a number that will be written in the log
%                   file

function log_write(log_file_handler,varargin)
    % TODO check the input arguments
    
    format_str = '';
    % build the scheme string
    for i = 1:length(varargin)
        if i ~= 1
            format_str = [format_str '\t'];
        end
        
        if ischar(varargin{i})
            format_str = [format_str '%s'];
        elseif isnumeric(varargin{i})
            format_str = [format_str '%f'];
        else
            err = MException('InputArg:WrongType', ...
            'Data to write must be either string or numeric');
            throw(err)
        end
    end
    format_str = [format_str '\n'];
    fprintf(log_file_handler,format_str,varargin{:});

end