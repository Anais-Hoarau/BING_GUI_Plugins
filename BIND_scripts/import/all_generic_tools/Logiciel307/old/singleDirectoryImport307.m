function singleDirectoryImport307()
% get a directory name, WITHOUT trailing backslash
directory = uigetdir('C:\');
if directory == 0
    disp('Abandon car aucune selection');
    return;
end

[pathstr, name, ext] =  fileparts(directory);
s2 = regexp(name, '_', 'split');
nomSujet = s2{1};
targetTripFile =  fullfile(directory, ['trip_' nomSujet '.trip']);

% start conversion.
convertMOPAD2BIND(directory,targetTripFile,'single');

end