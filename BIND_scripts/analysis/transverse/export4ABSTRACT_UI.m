

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Selection of the events and situations to export %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[FileName,PathName] = uigetfile('*.trip','Select the trip file');

% find the correct directory and file
tripFile = fullfile(PathName, FileName);

theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

metaInformations = theTrip.getMetaInformations();

disp('For data enrichment, some information are required:');
disp('If you do not know exactly, please presse ENTER and we will set them as default');
disp('******');
disp('Here is the list of the existing datas :');
disp(theTrip.getMetaInformations().getDatasNamesList());
disp('******');
data = input('Give the name of the GPS Data','s');
if isempty(data)
    data = 'GPS5Hz';
    disp('We chose "GPS5Hz"');
end
if(~theTrip.getMetaInformations().existData(data))
    disp('The input data is not available!');
    disp('--- The end ---');
    return;
end

disp('Here is the list of the existing data variables for GPS:')
disp('******');
disp(theTrip.getMetaInformations().getDataVariablesNamesList(data));
disp('******');
datav2 = input('In this data, what is the variable name for the latitude ?','s') ;
if isempty(datav2)
    datav2 = 'Latitude_5Hz';
    disp('We chose "Latitude_5Hz"');
end
datav3 = input('In this data, what is the variable name for the longitude ?','s') ;
if isempty(datav3)
    datav3 = 'Longitude_5Hz';
    disp('We chose "Longitude_5Hz"');
end
if(~theTrip.getMetaInformations().existDataVariable(data,datav2)||~theTrip.getMetaInformations().existDataVariable(data,datav3))
    disp('The input variables are not available!');
    disp('--- The end ---');
    return;
end
% modify tables data names and variables names according to trip data
GPStableName = data;
GPSLatitudeName = datav2;
GPSLongitudeName = datav3;


disp('******');
disp('Here is the list of the existing datas :');
disp(theTrip.getMetaInformations().getDatasNamesList());
disp('******');
data = input('Give the name of the measures Data for distance Driven','s');
if isempty(data)
    data = 'SensorsMeasures';
    disp('We chose "SensorsMeasures"');
end
if(~theTrip.getMetaInformations().existData(data))
    disp('The input data is not available!');
    disp('--- The end ---');
    return;
end

disp('Here is the list of the existing data variables :')
disp('******');
disp(theTrip.getMetaInformations().getDataVariablesNamesList(data));
disp('******');
datav1 = input('In this data, what is the variable name for the distanceDriven ?','s') ;
if isempty(datav1)
    datav1 = 'DistanceDriven';
    disp('We chose "DistanceDriven"');
end

datav2 = input('In this data, what is the variable name for the Speed ?','s') ;
if isempty(datav2)
    datav2 = 'Speed';
    disp('We chose "Speed"');
end

datav3 = input('In this data, what is the variable name for the SteeringWheelAngle ?','s') ;
if isempty(datav3)
    datav3 = 'SteeringwheelAngle';
    disp('We chose "SteeringwheelAngle"');
end
if(~theTrip.getMetaInformations().existDataVariable(data,datav1)||~theTrip.getMetaInformations().existDataVariable(data,datav2)||~theTrip.getMetaInformations().existDataVariable(data,datav3))
    disp('The input variables are not available!');
    disp('--- The end ---');
    return;
end

vehicleDataTableName = data;
vehicleDataDistanceName = datav1;
vehicleDataSpeedName = datav2;
vehicleDataSteeringWheelName = datav3;

DataVariableNameForEnrichment = { {[GPStableName '.' GPSLatitudeName] 'latitude'}, ...
                                  {[GPStableName '.' GPSLongitudeName] 'longitude'}, ...
                                  {[vehicleDataTableName '.' vehicleDataDistanceName] 'distance'}, ...
                                  {[vehicleDataTableName '.' vehicleDataSpeedName] 'speed'}, ...
                                  {[vehicleDataTableName '.' vehicleDataSteeringWheelName] 'steeringWheel'}, ...
                                 };

%%%%%%%%%%%%%%%%%%%%%%%
% Select the markers %
%%%%%%%%%%%%%%%%%%%%%%%
cellArrayOfMarkersToExport = {};
for markerType = {'event' 'situation'}
    
    marker = char(markerType);
    
    switch marker
        case 'situation'
            markersName = metaInformations.getSituationsNamesList();
        case 'event'
            markersName = metaInformations.getEventsNamesList();
    end
    
    [Selection,ok] = listdlg('ListString',markersName,'PromptString',['Selectionnez les tables de ' marker ' à exporter']);
    
    for x = Selection
        cellArrayOfMarkersToExport = { cellArrayOfMarkersToExport{:} {marker, markersName{x}, ''} };
    end
end
                             
%%%%%%%%%%%%%%%%%%%%%%%
% Create the CSV file %
%%%%%%%%%%%%%%%%%%%%%%%

csvFile = [ tripFile '4ABSTRACT.csv'];

exportSituationsAndEvents2CSV( theTrip, csvFile, ';', DataVariableNameForEnrichment, cellArrayOfMarkersToExport);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Upload the CSV file in Abstract %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tripMeta = theTrip.getMetaInformations();
attributeList = tripMeta.getTripAttributesList();

description = 'Trace';
for i=1:length(attributeList)
    description = [description '_' theTrip.getAttribute(attributeList{i})];
end

% Define an ID from the date
date = datestr(now,31);
date = strrep(date, ' ', '');
date = strrep(date, '-', '');
date = strrep(date, ':', '');

uniqueID = date;

% Load Abstract to upload the CSV file
width = 800;
height = 500;
baseUrl = '137.121.169.186/abstract/modules/sequence/s10-importBIND/php/';
page = 'importCSVForm.php';
params = [ 'CSVFile=' csvFile];
params = [ params '&id=' uniqueID];
params = [ params '&shortDescription=' description];
f = figure('Position', [0 0 width height],'MenuBar','none','Resize','off');
ie = actxcontrol('Shell.Explorer.2',[0 0 width height],f);
url = [ baseUrl page '?' params ];
ie.Navigate(url);

