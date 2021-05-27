%% magic_process function
% The magic_process function calls a function that processes a trip file.
% In addition to calling that function with the right argument, extra
% features are provided: check if the function has already been called on
% that trip (check the trip meta attributes), if not, process the function.
% This function also handle exceptions and write the resulting exception (TODO) if
% any occurs.
% The output of the information deliver information about the called
% process: its status ('ok' or 'failed') and the time ellapsed.
%
% out = magic_process(function_name,trip,arguments)
%
% Arguments:
% function_name:    a String corresponding to the function to call
% trip:             the Trip object to be processed
% arguments:        arguments that will be givent to the function
% 
% Output:
% process_status:   a String ('ok' or 'failed') describing the status of
%                   the process
% ellapsed_time:    the time ellapsed (in seconds) 
%
% REMARKS:
% Note that the function to be called needs to follow the following
% constraints:
% - the function needs to be declared in Matlab. If it is a file, the file
% needs to be in the PATH (see Matlab str2func documentation for advanced
% documentation).
% - the first argument of the function HAS TO BE the trip object.
% - the output of the function should be a string (giving some extra
% information that one may want to log).
% 

function [process_status,ellapsed_time,result] = magic_process(function_name,trip,varargin)
    tic;
    result = '';
    try
        % define the name that is used in the trip meta attributes to
        % represent this script
        meta_attr_id = sprintf('__%s__',function_name);
        % if the meta attribute is set to 'ok', then the script has already
        % been processed
        if strcmp_trip_meta_attribute(trip,meta_attr_id,'ok')
            process_status = 'ok';
        % if the meta attribute does not exist or is not set to 'ok', then
        % the function needs to be called again.
        else
            % creates a function handler from the name of the function
            function_handler = str2func(function_name);
            % Call the function
            result = function_handler(trip,varargin{:});
            % If we are here, no exception has been triggered... the
            % processing is considered to be successful!
            trip.setAttribute(meta_attr_id,'ok');
            process_status = 'ok';
        end
    catch ME
        % Log error and keep going...
        disp(['Error caught, logging in ''' function_name '.log'' and skipping to next process']);
        ME.getReport
        Errorlog = fopen([ function_name '.log'], 'a+');
        fprintf(Errorlog, '%s\n', [datestr(now) ' : Error with this trip : ' trip.getTripPath ]);
        fprintf(Errorlog, '%s\n', ME.getReport('extended', 'hyperlinks', 'off'));
        fprintf(Errorlog, '%s\n', '---------------------------------------------------------------------------------');
        fclose(Errorlog);
        % write the message in a log file
        process_status = 'failed';
    end
    ellapsed_time = toc;
end