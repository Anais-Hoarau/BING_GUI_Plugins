function LEPSIS2BIND_DRT(xmlfilename, pathToVAR, varFile, pathToTrip)

%Manage arguments
switch nargin
    %We don't have arguments, so we graphically prompt for them.
    case 0
        [xmlFile, xmlPath] = uigetfile('*.xml', 'Choisissez le fichier .xml');
        xmlfilename = [xmlPath xmlFile];
        cdold = pwd;
        cd('D:\Ldumont\DRT_MATLAB\datavar');
        [varFile pathToVAR] = uigetfile('*.var', 'Choisissez le fichier .var');
%        pathToTrip = uigetdir(pwd, 'Choisissez le dossier de destination pour le nouveau trip');
        debugMode = false; 
        cd(cdold);
    %We have the arguments, so we don't prompt for them.
    case 4
        %Be lazy and do nothing.
    otherwise
        error('Incorrect number of arguments. Must be either 0 or 3');
end
parsedXMLMappingFile = xmlread(xmlfilename);
generateSQLiteFile_DRT(parsedXMLMappingFile, [pathToVAR '\' varFile], pathToTrip);