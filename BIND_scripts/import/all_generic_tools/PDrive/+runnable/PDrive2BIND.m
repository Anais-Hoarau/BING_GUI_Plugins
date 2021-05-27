function PDrive2BIND()

    [xmlFile, xmlPath] = uigetfile('*.xml', 'Choisissez le fichier .xml');
    [matFile pathToMAT] = uigetfile('*.mat', 'Choisissez le fichier .mat');
    additionnalMats = {};
    wantMoreTrips = true;
    while(wantMoreTrips)
        button = questdlg('Voulez-vous ajouter plus de .mat pour ce trip ?','.mat additionnel','Oui','Non', 'Oui');
        if strcmp('Oui', button)
            [additonalMatFile pathToMAT] = uigetfile([pathToMAT filesep '*.mat'], 'Choisissez le fichier .mat');
            additionnalMats{end + 1} = [pathToMAT filesep additonalMatFile];
        else
            wantMoreTrips = false;
        end
    end
    pathToTrip = uigetdir(pwd, 'Choisissez le dossier de destination pour le nouveau trip');
    parsedXMLMappingFile = xmlread([xmlPath filesep xmlFile]);
    generateSQLiteFile(parsedXMLMappingFile, [pathToMAT filesep matFile], additionnalMats, pathToTrip);
end