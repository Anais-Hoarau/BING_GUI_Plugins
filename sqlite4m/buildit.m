%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANT NOTE %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% To use this script that build both mexw32 and mex64, you must have
% Microsoft Visual Studio 8 (2005) installed, and its cross compiler.
%
% This script only works on a win32 platform.
%
% If you have a newer version, you have to specify it in both mexopts_32
% and mexopts_64, at lines 22 and 23 (and maybe elsewhere, depending on
% what's new).

function buildit

matlabdir = [matlabroot '\'];
extern = 'extern\lib\';
bin = 'bin\';

%Copy extern\lib\win64 if necessary
dirEx = dir([matlabdir extern 'win64']);
dirExSz = size(dirEx);

if (dirExSz(1) == 0)
    fprintf('Copying extern\\lib\\win64 ...\n');
    copyfile([extern], [matlabdir extern]);
end

%Copy bin\win64 if necessary
dirEx = dir([matlabdir bin 'win64']);
dirExSz = size(dirEx);

if (dirExSz(1) == 0)
    fprintf('Copying bin\\win64 (287MB - Do not interupt) ...\n');
    copyfile([bin], [matlabdir bin]);
end

%Build mex for 64 bits
fprintf('Building sqlite4m (x64) ...\n');
mex -output sqlite4m -f mexopts_64.bat sqlite4m.cpp sqlite3.c;
movefile('sqlite4m.mexw32', 'sqlite4m.mexw64');

%Build mex for 32 bits
fprintf('Building sqlite4m (x86) ...\n');
mex -output sqlite4m -f mexopts_32.bat sqlite4m.cpp sqlite3.c;

fprintf('Done.\n');

end