% save_sensor_calibration.m (CACC)
%
% Written by Christopher Nowakowski
% v.1 3/30/09
%
% This function saves a calibration.dat file for a given set of CACC data in the
% directory from which the data set was loaded.  The calibration.dat file is
% then read in by the CACC load_trip.m routine in order to calibrate the various
% sensors even when only a partial trip has been loaded.  
%
% calibration.dat file column definitions:
%
% (1,1) - mean x acceleration
% (1,2) - mean y acceleration 
%

function [error_msg] = save_sensor_calibration(data)

% ------------------------------------------------------------------------------
% Check & Parse Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = '[error_msg] = save_sensor_calibration(data);';

if (nargin == 1 && ischar(data) && strcmpi(data,'?')),
    disp(usage_msg);
    return;
elseif (nargin == 1 && isstruct(data)),
    % A data struct was provided, but verify that it is a full CACC trip
    if (~isfield(data,'meta'))
        error('%s\n%s','Error: data was not tagged as CACC study data.',usage_msg);
    elseif (~isfield(data.meta,'study')),
        error('%s\n%s','Error: data was not tagged as CACC study data.',usage_msg);
    elseif (~strcmpi(data.meta.study,'CACC')),
        error('%s\n%s','Error: data was not tagged as CACC study data.',usage_msg);
    elseif (~strcmpi(data.meta.dataset,'Full Trip'))
        error('%s\n%s','Error: sensor calibration can only be performed using a full set of data for the trip.',usage_msg);
    end;
    
    % If you made it this far, then the data set should be OK.
    
else,
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% Calculate Mean X-Y Accelerations
% ------------------------------------------------------------------------------
calibration(1,1) = mean(data.veh.accl_x);
calibration(1,2) = mean(data.veh.accl_y);


% ------------------------------------------------------------------------------
% Save calibration.dat
% ------------------------------------------------------------------------------
% Set up filename
filename = [data.meta.pathname 'calibration.dat'];
if (exist(filename,'file') == 0),
    error_msg = 'Saved ';
elseif (exist(filename,'file') == 2),
    error_msg = 'Overwrote ';
else,
    error_msg= ['Error: filename invalid.  Cannot save ' filename];
    disp(error_msg);
    return;
end;

% Open file write
[fid message] = fopen(filename,'w');
if ~isempty(message),
    error_msg = ['Error saving calibration.dat: ' message];
    disp(error_msg);
    fclose(fid);
    return;
end;

% Write calibration.dat
% Write Line 1: Mean X, Mean Y Accelerations
fprintf(fid, '%8.5f\t%8.5f\n',calibration(1,1), calibration(1,2));

% Close file write
fclose(fid);
error_msg = [error_msg filename];

end