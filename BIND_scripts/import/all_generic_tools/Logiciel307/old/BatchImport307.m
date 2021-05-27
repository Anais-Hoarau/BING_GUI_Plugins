
% root directory, with trailing backslash!!
rootDirectoryOfExperiment = 'Z:\307\DEXTRE\ROUTE_donnees_vehicule\';

% directory names, WITHOUT trailing backslash
directoryNamesToConvert = {...
     'dextre_2303_101110_14h58'
    };

numberOfTripsToConvert = length(directoryNamesToConvert);

for i=1:numberOfTripsToConvert
    fullDirectory = [rootDirectoryOfExperiment directoryNamesToConvert{i}];
    
    [pathstr, name, ext] =  fileparts(fullDirectory);

    s2 = regexp(name, '_', 'split');
    nomSujet = s2{1};
    targetTripFileName = fullfile(fullDirectory, ['trip_' nomSujet '.trip']);
    
    % convert only if output file does not already exist
    if ~exist(targetTripFileName,'file')
        convertMOPAD2BIND(fullDirectory,targetTripFileName,'batch');
    else
        disp(['BIND file ' targetTripFileName ' already exist']);
    end
end
