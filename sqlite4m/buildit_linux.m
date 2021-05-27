%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANT NOTE %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This scrit builds the sqlite4m mex for the linux arch on which the script
% is run. It will require gcc to be installed, and cpp support also (g++).
function buildit_linux

fprintf('Building sqlite4m...\n');
mex -output sqlite4m -ldl sqlite4m.cpp sqlite3.c;
fprintf('Done.\n');

end