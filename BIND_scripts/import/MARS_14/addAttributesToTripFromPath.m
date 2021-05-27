function addAttributesToTripFromPath(tripPath)

if nargin == 0
   [name path] = uigetfile('*.trip', 'Choisissez le fichier .trip'); 
   tripPath = [path name];
end
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripPath, 0.04, false);
[path, name, ext] = fileparts(tripPath);

%Parsing the file name to get informations
[idParcours, timestamp] = strtok(name);
timestamp = strtrim(timestamp);
day = timestamp(1:2);
month = timestamp(3:4);
hour = timestamp(5:6);
minutes = timestamp(7:8);
%Splitting the path into tokens
remainder = path;
pathToks = {};
while ~isempty(remainder)
    [pathToks{end + 1} remainder] = strtok(remainder, filesep);
end
%Parsing the subject folder to get its ID
subjectFolder = pathToks{end};
[~, subjectID] = strtok(subjectFolder);
%Parsing the category folder to get the category of the subject
categoryFolder = pathToks{end - 1};
age = 'undefined';
switch categoryFolder(1);
    case 'Y'
        age = 'jeune';
    case 'O'
        age = 'âgé';
end
sexe = 'undefined';
switch categoryFolder(4);
    case 'h'
        sexe = 'homme';
    case 'f'
        sexe = 'femme';
end
    
theTrip.setAttribute('idParcours', idParcours);
theTrip.setAttribute('date', [day '/' month '/2010 ' hour 'h' minutes]);
theTrip.setAttribute('numSujet', subjectID);
theTrip.setAttribute('age', age);
theTrip.setAttribute('sexe', sexe);
theTrip.setAttribute('nom', '');
delete(theTrip);