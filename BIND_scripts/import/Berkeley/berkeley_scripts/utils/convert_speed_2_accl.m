% convert_speed_2_accl.m
%
% Written by Christopher Nowakowski
% v.1   02/10/10
%
% This function converts a column of speed values (m/s) and a column of 
% correspoinding timestamps (in ssm) into acceleration values.
%
% Acceleration is computed by looking at speed data points both before and after
% the moment of interest. The number of data points looked at depends on the
% filter input parameters. Obviously, this script works best if the data point time
% intervals are consisent.
%
% Setting the min_filter input parameter to 1 results in the most instaneous 
% measure of acceleration.  Increasing the values for the min or max_filter 
% parameters means that more data points are used in calculating the acceleration.
% The computation is done iteratively from the minimum number of data points
% specified to the maximum number specified. The resulting acceleration that is 
% reported is the average of the estimates produced in each iteration.
%
% Note: The first and last x points (where x is the iteration filter value)
% are calculated using the assumption that acceleration remains constant at 
% the ends of the data, e.g., they are copies of the first or last value that 
% could be calculated for that sized filter.
%
% Inputs
%
% speed:   should be a column of speed values (suggest m/s)
% time:    should be a corresponding column of timestamped increments (suggest s)
% filters: values must be integers such that 1 <= lo_filter <= hi_filter
%          (suggest 4,8 for vehicle accelerations measured at 50 ms increments)
%
% Output
%
% accl:    A column of acceleration values in m/s/s (based on the suggestions)
%          If you need acceleration in g, divide by 9.812865328 m/s/s
%          
% Note:    At least max_filter*2+1 data points are needed to estimate acceleration
%          This function returns NaN if not enough data points are provided
%
%
% Usage: [accl] = convert_speed_2_accl(speed,time,min_filter,max_filter)
%

function [accl] = convert_speed_2_accl(speed,ssm,imin,imax)

% ------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [accl] = convert_speed_2_accl(speed,time,min_filter,max_filter);';

if (nargin == 1 && ischar(speed) && strcmpi(speed,'?')),
    disp(usage_msg);
    disp('Note: time should be in seconds and speed should be in m/s resulting is output of m/s/s');
    disp('Note: min_filter is the minimum half-width of data points to use when computing acceleration,');
    disp('      max_filter is the maximum half-width of data points to use when computing acceleration.');
    disp('Note: filter values must be integers such that 1 <= lo_filter <= hi_filter.');
    disp('Note: At least max_filter*2+1 data points are needed to estimate acceleration.');
    disp('      This function returns NaN if not enough data points are provided.');
elseif nargin ~= 4 || ~isnumeric(speed) || ~isnumeric(ssm) || ~isnumeric(imin) || ~isnumeric(imax),
    error(usage_msg);
end;

% Check Filter Value & Computer Max Number of Loop Iterations
imin = floor(imin);
imax = floor(imax);
if imin < 1 || imax < imin,
    error('%s\n%s','Error: filter values must be integers such that 1 <= lo_filter <= hi_filter.',usage_msg);
end;

% Check Input Data Column Lengths
n = length(speed);
if n ~= length(ssm),
    error('%s\n%s','Error: speed and time are arrays of different lenghts.',usage_msg);
end;

% Verify that Enough Data Samples Were Provided to Calculate At Least 1 Acceleration Estiamte
if n < (imax*2+1);
    disp('Warning: Sample size was too small to calculate acceleration using the specified filter.');
    disp(['         At least ' num2str(imax*2+1) ' data points are necessary, but only ' num2str(n) ' were provided.']);
    accl = NaN;
    return;
end;

% ------------------------------------------------------------------------------
% Calculate Acceleration Based on Speed
% ------------------------------------------------------------------------------

% Calculate dt matrix (delta time)
% dt(c) is the number of data points used to calculate acceleration in each estimate, e.g., 3, 5, 7, 9, etc.
for i=imin:imax,
    c = i-imin+1;                                                               % Column
    dt(c) = i*2+1;                                                              %#ok<AGROW>
end;

% Set size of accl_matrix (length of data by the number of estimates to average)
accl_matrix = zeros(n,imax-imin+1);

% Compute Acceleration Matrix
% Loop Iterates the Acceleration Calculation for Each dt based on the filter value
for i=imin:imax,
    c = i-imin+1;                                                               % Column
    accl_matrix(i+1:n-i,c) =...                                                 % v2-v1 / d2-d1
        ( speed(dt(c):n) - speed(1:n-(dt(c)-1)) ) ./ ...
        ( ssm(dt(c):n) - ssm(1:n-(dt(c)-1)) );
    
    % Backfill tails with the first and last acceleration values that could be computed
    for j=1:i,
        accl_matrix(j,c) = accl_matrix(i+1,c);
        accl_matrix(n+1-j,c) = accl_matrix(n-i,c);
    end;
end;

% Average All Iterations
accl = mean(accl_matrix,2);

end