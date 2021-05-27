% This application is used to find the points of interest with their exact positions according to the data GPS, their timecode and the distances before or after them which will be studied.
function P1_FindPOI(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

% find the correct file containing information on points of interest (POI)
pattern = 'P*.xls';
poiFile =  fullfile(directory, pattern);
listing = dir(poiFile);
poiFile = ...
    fullfile(directory, listing.name);

% read the file that describes POI
[~, ~, xlsContent] = xlsread(poiFile);
%Stripping the first line of the xls content (header)
xlsContent(1, :) = [];

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

% Help the user to enter the data name and the data variable names needed
% so it can be applied to any database however they are named
% Check in meta datas if input data and inputs variables are available
% Especially for the choices made as default, we verify if they exist.
disp('-----------------------------------------');
disp('Please entre some necessary information :');
disp('If you do not know exactly, please presse ENTER and we will set them as default');
disp('Attention : we are not sure the exitence of what we choose!')
disp('Here is the list of the existing datas :');
tripMetaInformations = theTrip.getMetaInformations();
disp(tripMetaInformations.getDatasNamesList());
data = input('Your GPS Data Name is ','s');
% if isempty(data)
%     data = 'GPS5Hz';
%     disp('We chose "GPS5Hz"');
% end
if isempty(data)
    data = 'GPS1Hz';
    disp('We chose "GPS1Hz"');
end

if(~tripMetaInformations.existData(data))
    disp('The input data is not available!');
    disp('--- The end ---');
    return;
end

disp('Here is the list of the existing data variables :')
disp(tripMetaInformations.getDataVariablesNamesList(data));
datav1 = input('Data variable for the timecode is ','s');
if isempty(datav1)
    datav1 = 'timecode';
    disp('We chose "timecode"');
end
datav2 = input('Data variable for the latitude is ','s') ;
% if isempty(datav2)
%     datav2 = 'Latitude_5Hz';
%     disp('We chose "Latitude_5Hz"');
% end
% datav3 = input('Data variable for the longitude is ','s') ;
% if isempty(datav3)
%     datav3 = 'Longitude_5Hz';
%     disp('We chose "Longitude_5Hz"');
% end
if isempty(datav2)
    datav2 = 'Latitude_1Hz';
    disp('We chose "Latitude_1Hz"');
end
datav3 = input('Data variable for the longitude is ','s') ;
if isempty(datav3)
    datav3 = 'Longitude_1Hz';
    disp('We chose "Longitude_1Hz"');
end
if(~tripMetaInformations.existDataVariable(data,datav1) || ~tripMetaInformations.existDataVariable(data,datav2) || ~tripMetaInformations.existDataVariable(data,datav3))
    disp('The input variables are not available!');
    disp('--- The end ---');
    return;
end

% Use BIND to read data in matlab workspace
dataRecord = theTrip.getAllDataOccurences(data);
timecode = cell2mat(dataRecord.getVariableValues(datav1));
latitude  = cell2mat(dataRecord.getVariableValues(datav2));
longitude  = cell2mat(dataRecord.getVariableValues(datav3));

%Find and remove the zeros in the datas
index = intersect(find(latitude ~= 0),find(longitude ~= 0));
latitude = latitude(index);
longitude = longitude(index);
timecode = timecode(index);

% for each POI, compute distance between GPS car positions and reference.
% Then, find the GPS car positions that is the closest to the POI
% point
distances = zeros(1,length(index));
tempsLastPOI = 0;

% Check in meta datas if output events and outpus variables are available,
% if not, create them
if (~tripMetaInformations.existEvent('POI'))
    disp('The output event doesnt exist!');
    disp('And it will be created!')
    poi = fr.lescot.bind.data.MetaEvent();
    id = fr.lescot.bind.data.MetaEventVariable();
    name = fr.lescot.bind.data.MetaEventVariable();
    latPOI = fr.lescot.bind.data.MetaEventVariable();
    longPOI = fr.lescot.bind.data.MetaEventVariable();
    before = fr.lescot.bind.data.MetaEventVariable();
    after = fr.lescot.bind.data.MetaEventVariable();
    speedPOI = fr.lescot.bind.data.MetaEventVariable();
    labelType = fr.lescot.bind.data.MetaEventVariable();
    type = fr.lescot.bind.data.MetaEventVariable();
    
    poi.setName('POI');
    id.setName('Id');
    name.setName('Name');
    latPOI.setName('Latitude');
    longPOI.setName('Longitude');
    before.setName('BeforePOI');
    after.setName('AfterPOI');
    speedPOI.setName('SpeedPOI');
    labelType.setName('LabelType');
    type.setName('Type');
    
    id.setType('TEXT');
    name.setType('TEXT');
    latPOI.setType('REAL');
    longPOI.setType('REAL');
    before.setType('REAL');
    after.setType('REAL');
    speedPOI.setType('REAL');
    labelType.setType('TEXT');
    type.setType('TEXT');
    
    poi.setComments('Points of interest');
    
    poi.setVariables({id,name,latPOI,longPOI,before,after,speedPOI,labelType, type});
    theTrip.addEvent(poi);
else
    if(~tripMetaInformations.existEventVariable('POI','Name')&&~tripMetaInformations.existEventVariable('POI','Id')&& ~tripMetaInformations.existEventVariable('POI','TimeCode')&&~tripMetaInformations.existEventVariable('POI','Latitude')&&~tripMetaInformations.existEventVariable('POI','Longitude'))
        disp('The output event variable do not exist!');
        disp('Please delete the table POI and the MetaData POI to store the data!');
        % Because if there is no variable for POI, the table POI could not
        % exist, but it does not exist, we could not write the data in it.
        % So it is better to delete all to create a new one
        return;
    else
        disp('The output event and output event variables already exist!')
        disp('--- The end ---');
        return;
    end
end

[xlsRows, ~] = size(xlsContent);
%For each POI
for i=1:xlsRows
    POIname = char(xlsContent{i,1});
    POIid = char(xlsContent{i,2});
    POIlatitude = xlsContent{i,3};
    POIlongitude = xlsContent{i,4};
    POIbefore = xlsContent{i,5};
    POIafter = xlsContent{i,6};
    POIType = char(xlsContent{i,7});
    POILabelType = char(xlsContent{i,8});
    for k = 1:length(longitude);
        % calcul de la distance entre 2 points GPS en radian
        a = pi / 180;
        lat1 = POIlatitude * a;
        long1 = POIlongitude * a;
        lat2 = latitude(k)/1000000 * a;
        long2 = longitude(k)/1000000 * a;
        t = sin((lat1-lat2)/2)*sin((lat1-lat2)/2) + cos(lat1)*cos(lat2)*sin((long1-long2)/2)*sin((long1-long2)/2);
        distances(k) = 2 * 6371000 * atan2(sqrt(t),sqrt(1-t));
    end
    
    % find the point that is the closest to the POI. As GPS position may be
    % equal during the trip going back and forth on the same road, it is
    % necessary to focus only on remaining position : the selection of the
    % nearest point takes into account time
    
    indicesTimeCodesAfterLastPOI = find(timecode > tempsLastPOI);
    timecodesFiltered = timecode(indicesTimeCodesAfterLastPOI);
    latitudeFiltered = latitude(indicesTimeCodesAfterLastPOI);
    longitudeFiltered = longitude(indicesTimeCodesAfterLastPOI);
    
    [~, indicesDistanceMin] = min(distances(indicesTimeCodesAfterLastPOI));
    newPOIIndex = indicesDistanceMin(1);
    %Now that we've found the index of the POI, lets fill the vars
    tempsLastPOI = timecodesFiltered(newPOIIndex);
    latitudePOI = latitudeFiltered(newPOIIndex);
    longitudePOI = longitudeFiltered(newPOIIndex);
    % Find the speed at this point
    record = theTrip.getDataOccurenceNearTime('SensorsMeasures', tempsLastPOI);
    speeds = record.getVariableValues('Speed');
    POIspeed = speeds{1};
    
    message = [ POIid ' / ' POIname ' trouvé au temps ' num2str(tempsLastPOI)];
    disp(message);
    
    % save the event in the trip
    theTrip.setEventVariableAtTime('POI','Id',tempsLastPOI,POIid);
    theTrip.setEventVariableAtTime('POI','Name',tempsLastPOI,POIname);
    theTrip.setEventVariableAtTime('POI','Latitude',tempsLastPOI,latitudePOI);
    theTrip.setEventVariableAtTime('POI','Longitude',tempsLastPOI,longitudePOI);
    theTrip.setEventVariableAtTime('POI','BeforePOI',tempsLastPOI,POIbefore);
    theTrip.setEventVariableAtTime('POI','AfterPOI',tempsLastPOI,POIafter);
    theTrip.setEventVariableAtTime('POI','SpeedPOI',tempsLastPOI,POIspeed);
    theTrip.setEventVariableAtTime('POI','LabelType',tempsLastPOI,POILabelType);
    theTrip.setEventVariableAtTime('POI','Type',tempsLastPOI,POIType);
end
delete(theTrip);
close('all');
delete(timerfindall);
clear all;
end

