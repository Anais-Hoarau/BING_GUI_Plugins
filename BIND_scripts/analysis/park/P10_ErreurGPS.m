% select the directory containing the data
directory = uigetdir('C:\Documents and Settings\huang\Bureau\Data');
[pathstr, name, ext] =  fileparts(directory);

folders = ls(directory);
folderadr = directory;

for n = 5:18 % The numbers must correspond to the first folder and the last folder
    % find the correct file for the trip database
    directory = [folderadr '\' folders(n,:)];
    pattern = '*.trip';
    tripFile =  fullfile(directory, pattern);
    listing = dir(tripFile);
    for i=1:length(listing)
        tripFile = fullfile(directory, listing(i).name);
        tripName = listing(i).name;
    end
    % create a BIND trip object from the database
    theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);
    
    % The ideal POIs
    % find the correct file containing information on points of interest (POI)
    pattern = 'P*.xls';
    poiFile =  fullfile(directory, pattern);
    listing = dir(poiFile);
    poiFile = ...
    fullfile(directory, listing.name);
    fileID = fopen(poiFile);
    % read the file that describes POI
    [num,txt] = xlsread(poiFile);
    fclose('all');
    POI11latitude = num(11,1);
    POI11longitude = num(11,2);
    POI12latitude = num(12,1);
    POI12longitude = num(12,2);
    
    % The POIs we find
    % Use BIND to read data in matlab workspace
    dataPOI = theTrip.getAllEventOccurences('POI');
    latitudePOI = cell2mat(dataPOI.getVariableValues('Latitude'));
    longitudePOI = cell2mat(dataPOI.getVariableValues('Longitude'));
    latitudePOI11 = latitudePOI(11);
    longitudePOI11 = longitudePOI(11);
    latitudePOI12 = latitudePOI(12);
    longitudePOI12 = longitudePOI(12);
    
    % The POIs defined manually
    % Here, Point3 == POI11 and Point6 == POI12
    situationZones = theTrip.getAllSituationOccurences('ZonesPoudrette');
    endTimecode = cell2mat(situationZones.getVariableValues('endTimecode'));
    timecodePOI11 = endTimecode(3);
    timecodePOI12 = endTimecode(6);
    dataGPS = theTrip.getAllDataOccurences('GPS5Hz');
    timecode = cell2mat(dataGPS.getVariableValues('timecode'));
    latitude = cell2mat(dataGPS.getVariableValues('Latitude_5Hz'));
    longitude = cell2mat(dataGPS.getVariableValues('Longitude_5Hz'));
    index = find(timecode <= timecodePOI11);
    indice = index(length(index));
    latPOI11 = latitude(indice);
    longPOI11 = longitude(indice);
    index = find(timecode <= timecodePOI12);
    indice = index(length(index));
    latPOI12 = latitude(indice);
    longPOI12 = longitude(indice);
    
    % Difference between ideal POI and POI found
    a = pi / 180;
    lat1 = POI11latitude * a;
    long1 = POI11longitude * a;
    lat2 = latitudePOI11/1000000 * a;
    long2 = longitudePOI11/1000000 * a;
    t = sin((lat1-lat2)/2)*sin((lat1-lat2)/2) + cos(lat1)*cos(lat2)*sin((long1-long2)/2)*sin((long1-long2)/2);
    diff1POI11 = 2 * 6371000 * atan2(sqrt(t),sqrt(1-t));
    
    lat1 = POI12latitude * a;
    long1 = POI12longitude * a;
    lat2 = latitudePOI12/1000000 * a;
    long2 = longitudePOI12/1000000 * a;
    t = sin((lat1-lat2)/2)*sin((lat1-lat2)/2) + cos(lat1)*cos(lat2)*sin((long1-long2)/2)*sin((long1-long2)/2);
    diff1POI12 = 2 * 6371000 * atan2(sqrt(t),sqrt(1-t));
        
    % Difference between ideal POI and POI defined manuelly
    lat1 = POI11latitude * a;
    long1 = POI11longitude * a;
    lat2 = latPOI11/1000000 * a;
    long2 = longPOI11/1000000 * a;
    t = sin((lat1-lat2)/2)*sin((lat1-lat2)/2) + cos(lat1)*cos(lat2)*sin((long1-long2)/2)*sin((long1-long2)/2);
    diff2POI11 = 2 * 6371000 * atan2(sqrt(t),sqrt(1-t));
    
    lat1 = POI12latitude * a;
    long1 = POI12longitude * a;
    lat2 = latPOI12/1000000 * a;
    long2 = longPOI12/1000000 * a;
    t = sin((lat1-lat2)/2)*sin((lat1-lat2)/2) + cos(lat1)*cos(lat2)*sin((long1-long2)/2)*sin((long1-long2)/2);
    diff2POI12 = 2 * 6371000 * atan2(sqrt(t),sqrt(1-t));
    
    % Display
    disp('---------------------------------------------------------');
    disp(tripName);
   
    disp('   ');
    
    disp('About POI11 (Point3)');
    message = ['Ideal Point Location:   ' num2str(POI11latitude) ' ' num2str(POI11longitude)];
    disp(message);
    message = ['Point Location Found:   ' num2str(latitudePOI11/1000000) ' ' num2str(longitudePOI11/1000000)];
    disp(message);
    message = ['Distance between ideal POI and POI found: ' num2str(diff1POI11) 'm'];
    disp(message);
    message = ['Point Location Defined: ' num2str(latPOI11/1000000) ' ' num2str(longPOI11/1000000)];
    disp(message);
    message = ['Distance between ideal POI and POI defined: ' num2str(diff2POI11) 'm'];
    disp(message);
    
    disp('   ');
    
    disp('About POI12 (Point6)');
    message = ['Ideal Point Location:   ' num2str(POI12latitude) ' ' num2str(POI12longitude)];
    disp(message);
    message = ['Point Location Found:   ' num2str(latitudePOI12/1000000) ' ' num2str(longitudePOI12/1000000)];
    disp(message);
    message = ['Distance between ideal POI and POI found: ' num2str(diff1POI12) 'm'];
    disp(message);
    message = ['Point Location Defined: ' num2str(latPOI12/1000000) ' ' num2str(longPOI12/1000000)];
    disp(message);
    message = ['Distance between ideal POI and POI defined: ' num2str(diff2POI12) 'm'];
    disp(message);
    disp('---------------------------------------------------------');
end

