function Toyota_VAR2BIND(xmlPath, pathToVAR, pathToTrip, trip_file)
%% Manage arguments
switch nargin
    %We don't have arguments, so we graphically prompt for them.
    case 0
        [xmlFile, xmlPath] = uigetfile('*.xml', 'Choisissez le fichier .xml');
        [varFile, pathToVAR] = uigetfile('*.var', 'Choisissez le fichier .var');
        pathToTrip = uigetdir(pwd, 'Choisissez le dossier de destination pour le nouveau trip');
    
    %We have the arguments, so we don't prompt for them.
    case 4
        [xmlPath, xmlFile, xmlExtension] = fileparts(xmlPath);
        xmlFile = [xmlFile xmlExtension];
        [pathToVAR, varFile, varExtension] = fileparts(pathToVAR);
        varFile = [varFile varExtension];
    otherwise
        error('Incorrect number of arguments. Must be either 0 or 4');
end

%% GenerateSQLiteFile
parsedXMLMappingFile = xmlread([xmlPath filesep xmlFile]);
generateSQLiteFile_simu(parsedXMLMappingFile, [pathToVAR filesep varFile], pathToTrip);