[fileName,pathName] = uigetfile('*.trip','Select the trip file');

linebreak = char(10);
% find the correct directory and file
tripFile = fullfile(pathName, fileName);

theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);


fichierID = '1';
coordinatesDataName = ['GPS' fichierID 'Hz'];
latVarName = ['Latitude_' fichierID 'Hz'];
longVarName = ['Longitude_' fichierID 'Hz'];
% recuperation des données et calculs
dataRecord = theTrip.getAllDataOccurences(coordinatesDataName);

latitude = dataRecord.getVariableValues(latVarName);
longitude = dataRecord.getVariableValues(longVarName);

coordonnees = '';
fileID = fopen([pathName filesep 'parcours' fichierID 'Hz.kml'],'w');
fprintf(fileID, '%s\n', '<?xml version="1.0" encoding="UTF-8"?> ');
fprintf(fileID, '%s\n', '<kml xmlns="http://www.opengis.net/kml/2.2">');
fprintf(fileID, '%s\n', '<Document>');


% on va faire une ligne par morceau de 20000 points
N = length(latitude);
longueurLigne = 20000;
nbLineString = floor(N/longueurLigne);

for k=1:nbLineString + 1
    
    fprintf(fileID, '%s\n', '<Placemark>'); 
    fprintf(fileID, '%s\n', '<LineString>');
    fprintf(fileID, '%s\n', '<extrude>1</extrude><tessellate>1</tessellate>');

    fprintf(fileID, '%s\n', '<coordinates>');
    
    indexPointDebut = (k-1)*longueurLigne + 1;
    indexPointCible = min(N,(k)*longueurLigne);
    % on repete la partie avec les points
    for i=indexPointDebut:indexPointCible
        fprintf(fileID, '%6f,%6f,400\n', longitude{i}/1000000,latitude{i}/1000000);
    end
    fprintf(fileID, '%s\n', '</coordinates>');
    fprintf(fileID, '%s\n', '</LineString>');
    fprintf(fileID, '%s\n', '</Placemark>');
    
end


%On ajoute tout les events en tant que pins
metaInfos = theTrip.getMetaInformations();
eventsList = metaInfos.getEventsList();
for i = 1:1:length(eventsList)
    event = eventsList{i};
    occurences = theTrip.getAllEventOccurences(event.getName());
    variablesList = occurences.getVariableNames();
    timecodes = occurences.getVariableValues('timecode');
    fprintf(fileID, '%s\n', '<Folder>');
    for j = 1:1:length(timecodes)
        fprintf(fileID, '%s\n', ['<name>' event.getName() '</name>']);
        %calcul de la latitude et la longitude au temps de l'occurence de
        %l'event
        occurenceTimecode = timecodes{j};
        GPSData = theTrip.getDataOccurenceNearTime(coordinatesDataName, occurenceTimecode);
        latitude = GPSData.getVariableValues(latVarName);
        latitude = latitude{1}/1000000;
        longitude = GPSData.getVariableValues(longVarName);
        longitude = longitude{1}/1000000;
        %Génération du kml correspondant à l'occurence
        fprintf(fileID, '%s\n', '<Placemark>');
        fprintf(fileID, '%s\n', '<description>');
        fprintf(fileID, '%s\n', '<ul>');
        %Génération de l'infobulle avec les valeurs des variables
        for k = 1:1:length(variablesList)
           variableName = variablesList{k};
           variableValues = occurences.getVariableValues(variableName);
           variableValue = variableValues{j};
           fprintf(fileID, '%s\n', ['<li>' variableName ' = ' num2str(variableValue) '</li>']);
        end
        %%%
        fprintf(fileID, '%s\n', '</ul>');
        fprintf(fileID, '%s\n', '</description>');
        fprintf(fileID, '%s\n', ['<name>' event.getName() ' - ' num2str(j) '</name>']);
        fprintf(fileID, '%s\n', ['<Point><coordinates>' num2str(longitude) ',' num2str(latitude) '</coordinates></Point>']);
        fprintf(fileID, '%s\n', '</Placemark>');
    end
    message = fprintf(fileID, '%s\n', '</Folder>');
end

fprintf(fileID, '%s\n', '</Document>');
fprintf(fileID, '%s\n', '</kml>');

fclose(fileID);

delete(theTrip);
