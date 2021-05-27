% convert_gps_2_deg.m
%
% Written by Tom Kuhn
% v.1   1/14/09
%
% This function converts the typical GPS output which is in the format of 
% dddmm.mmmmmm to straight degrees ddd.dddddd
%
% Usage: [gps_in_degrees] = convert_gps_2_deg(gps_in_dddmm.mmmmmm)
%


function [gps_degrees] = convert_gps_2_deg(dddmm)

% ------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [gps_in_degrees] = convert_gps_2_deg(gps_in_dddmm.mmmmmm);';

if (nargin == 1 && ischar(dddmm) && strcmpi(dddmm,'?')),
    disp(usage_msg);
elseif (nargin == 1 && isnumeric(dddmm)),
    % Input Assumed Good
else,
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% Convert Single Value or Array of Values
% ------------------------------------------------------------------------------
 degrees = fix(dddmm./100.0);
 sign_d = sign(degrees);
 minutes = sign_d .* (dddmm - (degrees .* 100.0));
 degrees = sign_d .* degrees;
 minutes = minutes ./ 60.0;
 gps_degrees = sign_d .* (degrees + minutes);

end