function P7_CreateKMLforSituations(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = fullfile(directory, listing.name);

theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

% fichier KML
coordonnees = '';
% change name for backup : save in trip directory PathName
fileID = fopen([ directory filesep 'situations.kml'],'w');
message = '<?xml version="1.0" encoding="UTF-8"?>';
fprintf(fileID, '%s', message);
message = '<kml xmlns="http://www.opengis.net/kml/2.2">';
fprintf(fileID, '%s', message);
message = '<Document>';
fprintf(fileID, '%s\n', message);

% recuperation des données et calculs
% connect on the good situation and get the correct variables
situationRecord = theTrip.getAllSituationOccurences('Intersection');
id = cell2mat(situationRecord.getVariableValues('Number'));
timecodeDebut = cell2mat(situationRecord.getVariableValues('startTimecode'));
timecodeFin = cell2mat(situationRecord.getVariableValues('endTimecode'));
entryspeed = cell2mat(situationRecord.getVariableValues('EntrySpeed'));
exitspeed = cell2mat(situationRecord.getVariableValues('ExitSpeed'));
meanSpeed = cell2mat(situationRecord.getVariableValues('AverageSpeed'));
meanAngle = cell2mat(situationRecord.getVariableValues('AverageAngle'));
stdevSpeed = cell2mat(situationRecord.getVariableValues('StdevSpeed'));
stdevAngle = cell2mat(situationRecord.getVariableValues('StdevAngle'));
eventRecord = theTrip.getAllEventOccurences('POI');
timeCodePOI = cell2mat(eventRecord.getVariableValues('TimeCode'));
idPOI = eventRecord.getVariableValues('Id');
latitudePOI = cell2mat(eventRecord.getVariableValues('Latitude'));
longitudePOI = cell2mat(eventRecord.getVariableValues('Longitude'));
speedPOI = cell2mat(eventRecord.getVariableValues('SpeedPOI'));

%Convert the PathName with the slash'/' for the need to display the curves
%of intersections
index = find(directory == '\');
for i = 1:length(index)
    directory(index(i)) = '/';
end

i = 1; % Accumulator to skim the table INTERSECTION
ind = 1; % Accumulator to note a whole intersection 
while i <= length(id)
    % Only "Before"
    if id(i) == 22 || id(i) == 40
        % pour chaque situation, get correct gps data
        %dataRecord = theTrip.getDataOccurencesInTimeInterval('GPS5Hz',timecodeDebut(i),timecodeFin(i));
        %latitude  = cell2mat(dataRecord.getVariableValues('Latitude_5Hz'));
        %longitude = cell2mat(dataRecord.getVariableValues('Longitude_5Hz'));
        dataRecord = theTrip.getDataOccurencesInTimeInterval('GPS1Hz',timecodeDebut(i),timecodeFin(i));
        latitude  = cell2mat(dataRecord.getVariableValues('Latitude_1Hz'));
        longitude = cell2mat(dataRecord.getVariableValues('Longitude_1Hz'));
        message = '<Placemark>';
        fprintf(fileID, '%s', message);
        message = '<name>';
        fprintf(fileID, '%s\n', message);
        monId = num2str(id(i));
        message = ['Entry Intersection ' monId ' - Z' num2str(i)];
        fprintf(fileID, '%s\n', message);
        message = '</name>';
        fprintf(fileID, '%s\n', message);
        message = '<description><![CDATA[';
        fprintf(fileID, '%s\n', message);
        message = ['Curves of the Intersection <a href="file:///' directory filesep 'Curves/Intersection' monId '.png">link</a>'];
        fprintf(fileID, '%s\n', message);
        message = [ 'Mean speed : ' num2str(meanSpeed(i))];
        fprintf(fileID, '<p>%s</p>\n', message);
        message = [ 'Standard deviation of speed : ' num2str(stdevSpeed(i))];
        fprintf(fileID, '<p>%s</p>\n', message);
        message = [ 'Mean angle : ' num2str(meanAngle(i)) ];
        fprintf(fileID, '<p>%s</p>\n', message);
        message = [ 'Standard deviation of angle : ' num2str(stdevAngle(i))];
        fprintf(fileID, '<p>%s</p>\n', message);
        message = ']]></description>';
        fprintf(fileID, '%s\n', message);
        
        message = '<Style>';
        fprintf(fileID, '%s\n', message);
        message = '<LineStyle>';
        fprintf(fileID, '%s\n', message);
        message = '<color>7fff0000</color>';
        fprintf(fileID, '%s\n', message);
        message = '<width>5</width>';
        fprintf(fileID, '%s\n', message);
        message = '</LineStyle>';
        fprintf(fileID, '%s\n', message);
        message = '</Style>';
        fprintf(fileID, '%s\n', message);
        
        message = '<LineString>';
        fprintf(fileID, '%s\n', message);
        message = '<extrude>1</extrude><tessellate>1</tessellate>';
        fprintf(fileID, '%s', message);
        message = '<coordinates>';
        fprintf(fileID, '%s\n', message);

        % on repete la partie avec les points
        for k=1:length(latitude)
            a = sprintf('%6f,%6f,400',longitude(k)/1000000,latitude(k)/1000000);
            fprintf(fileID, ' %s\n', char(a));
        end
        message = '</coordinates>';
        fprintf(fileID, '%s\n', message);
        message = '</LineString>';
        fprintf(fileID, '%s\n', message);
        message = '</Placemark>';
        fprintf(fileID, '%s', message);

        % Entry Point
        message = '<Placemark>';
        fprintf(fileID, '%s', message);
        message = '<name>';
        fprintf(fileID, '%s\n', message);
        message = ['Entry Point ' num2str(ind)];
        fprintf(fileID, '%s\n', message);
        message = '</name>';
        fprintf(fileID, '%s\n', message);
        message = '<description><![CDATA[';
        fprintf(fileID, '%s\n', message);
        message = [ 'Latitude : ' num2str(latitude(1))];
        fprintf(fileID, '<p>%s</p>\n', message);    
        message = [ 'Longitude : ' num2str(longitude(1))];
        fprintf(fileID, '<p>%s</p>\n', message);   
        message = [ 'EntrySpeed : ' num2str(entryspeed(i)) ];
        fprintf(fileID, '<p>%s</p>\n', message);
        message = ']]></description>';
        fprintf(fileID, '%s\n', message);
        message = '<Point>';
        fprintf(fileID, '%s\n', message);
        message = '<coordinates>';
        fprintf(fileID, '%s\n', message);
        a = sprintf('%6f,%6f,400',longitude(1)/1000000,latitude(1)/1000000);
        fprintf(fileID, ' %s\n', char(a));
        message = '</coordinates>';
        fprintf(fileID, '%s\n', message);   
        message = '</Point>';
        fprintf(fileID, '%s', message);
        message = '</Placemark>';
        fprintf(fileID, '%s', message); 
        
        i = i + 1;
        ind = ind + 1;
    
    elseif id(i) == 41
        i = i + 1;
        ind = ind + 1;
        
    else
        for j = 1:3
            % pour chaque situation, get correct gps data
%             dataRecord = theTrip.getDataOccurencesInTimeInterval('GPS5Hz',timecodeDebut(i),timecodeFin(i));
%             latitude  = cell2mat(dataRecord.getVariableValues('Latitude_5Hz'));
%             longitude = cell2mat(dataRecord.getVariableValues('Longitude_5Hz'));
            dataRecord = theTrip.getDataOccurencesInTimeInterval('GPS1Hz',timecodeDebut(i),timecodeFin(i));
            latitude  = cell2mat(dataRecord.getVariableValues('Latitude_1Hz'));
            longitude = cell2mat(dataRecord.getVariableValues('Longitude_1Hz'));
            
            if j == 1
                message = '<Placemark>';
                fprintf(fileID, '%s', message);
                message = '<name>';
                fprintf(fileID, '%s\n', message);
                monId = num2str(id(i));
                message = ['Entry Intersection ' monId ' - Z' num2str(i)];
                fprintf(fileID, '%s\n', message);
                message = '</name>';
                fprintf(fileID, '%s\n', message);
                message = '<description><![CDATA[';
                fprintf(fileID, '%s\n', message);
                message = ['Curves of the Intersection <a href="file:///' directory filesep 'Curves/Intersection' monId '/Entry.png">link</a>'];
                fprintf(fileID, '%s\n', message);
                message = [ 'Mean speed : ' num2str(meanSpeed(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Standard deviation of speed : ' num2str(stdevSpeed(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Mean angle : ' num2str(meanAngle(i)) ];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Standard deviation of speed : ' num2str(stdevAngle(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = ']]></description>';
                fprintf(fileID, '%s\n', message);
                
                message = '<Style>';
                fprintf(fileID, '%s\n', message);
                message = '<LineStyle>';
                fprintf(fileID, '%s\n', message);
                message = '<color>7fff0000</color>';
                fprintf(fileID, '%s\n', message);
                message = '<width>5</width>';
                fprintf(fileID, '%s\n', message);
                message = '</LineStyle>';
                fprintf(fileID, '%s\n', message);
                message = '</Style>';
                fprintf(fileID, '%s\n', message);
                
                message = '<LineString>';
                fprintf(fileID, '%s\n', message);
                message = '<extrude>1</extrude><tessellate>1</tessellate>';
                fprintf(fileID, '%s', message);
                message = '<coordinates>';
                fprintf(fileID, '%s\n', message);
                
                % on repete la partie avec les points
                for k=1:length(latitude)
                    a = sprintf('%6f,%6f,400',longitude(k)/1000000,latitude(k)/1000000);
                    fprintf(fileID, ' %s\n', char(a));
                end
                message = '</coordinates>';
                fprintf(fileID, '%s\n', message);
                message = '</LineString>';
                fprintf(fileID, '%s\n', message);
                message = '</Placemark>';
                fprintf(fileID, '%s', message);

                % Entry Point
                message = '<Placemark>';
                fprintf(fileID, '%s', message);
                message = '<name>';
                fprintf(fileID, '%s\n', message);
                message = ['Entry Point ' num2str(ind)];
                fprintf(fileID, '%s\n', message);
                message = '</name>';
                fprintf(fileID, '%s\n', message);
                message = '<description><![CDATA[';
                fprintf(fileID, '%s\n', message);
                message = [ 'Latitude : ' num2str(latitude(1))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Longitude : ' num2str(longitude(1))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'EntrySpeed : ' num2str(entryspeed(i)) ];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = ']]></description>';
                fprintf(fileID, '%s\n', message);
                
                message = '<Point>';
                fprintf(fileID, '%s\n', message);
                message = '<coordinates>';
                fprintf(fileID, '%s\n', message);
                a = sprintf('%6f,%6f,400',longitude(1)/1000000,latitude(1)/1000000);
                fprintf(fileID, ' %s\n', char(a));
                message = '</coordinates>';
                fprintf(fileID, '%s\n', message);
                message = '</Point>';
                fprintf(fileID, '%s', message);
                message = '</Placemark>';
                fprintf(fileID, '%s', message);
                                
            elseif j == 2
                message = '<Placemark>';
                fprintf(fileID, '%s', message);
                message = '<name>';
                fprintf(fileID, '%s\n', message);
                monId = num2str(id(i));
                message = ['Intersection ' monId ' - Z' num2str(i)];
                fprintf(fileID, '%s\n', message);
                message = '</name>';
                fprintf(fileID, '%s\n', message);
                message = '<description><![CDATA[';
                fprintf(fileID, '%s\n', message);
                message = ['Curves of the Intersection <a href="file:///' directory filesep 'Curves/Intersection' monId '/Middle.png">link</a>'];
                fprintf(fileID, '%s\n', message);
                message = [ 'Mean speed : ' num2str(meanSpeed(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Standard deviation of speed : ' num2str(stdevSpeed(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Mean angle : ' num2str(meanAngle(i)) ];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Standard deviation of speed : ' num2str(stdevAngle(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = ']]></description>';
                fprintf(fileID, '%s\n', message);
                
                message = '<Style>';
                fprintf(fileID, '%s\n', message);
                message = '<LineStyle>';
                fprintf(fileID, '%s\n', message);
                message = '<color>7fff0000</color>';
                fprintf(fileID, '%s\n', message);
                message = '<width>5</width>';
                fprintf(fileID, '%s\n', message);
                message = '</LineStyle>';
                fprintf(fileID, '%s\n', message);
                message = '</Style>';
                fprintf(fileID, '%s\n', message);
                
                message = '<LineString>';
                fprintf(fileID, '%s\n', message);
                message = '<extrude>1</extrude><tessellate>1</tessellate>';
                fprintf(fileID, '%s', message);
                message = '<coordinates>';
                fprintf(fileID, '%s\n', message);
                
                % on repete la partie avec les points
                for k=1:length(latitude)
                    a = sprintf('%6f,%6f,400',longitude(k)/1000000,latitude(k)/1000000);
                    fprintf(fileID, ' %s\n', char(a));
                end
                message = '</coordinates>';
                fprintf(fileID, '%s\n', message);
                message = '</LineString>';
                fprintf(fileID, '%s\n', message);
                message = '</Placemark>';
                fprintf(fileID, '%s', message);
                
            elseif j == 3
                message = '<Placemark>';
                fprintf(fileID, '%s', message);
                message = '<name>';
                fprintf(fileID, '%s\n', message);
                monId = num2str(id(i));
                message = ['Exit Intersection ' monId ' - Z' num2str(i)];
                fprintf(fileID, '%s\n', message);
                message = '</name>';
                fprintf(fileID, '%s\n', message);
                message = '<description><![CDATA[';
                fprintf(fileID, '%s\n', message);
                message = ['Curves of the Intersection <a href="file:///' directory filesep 'Curves/Intersection' monId '/Exit.png">link</a>'];
                fprintf(fileID, '%s\n', message);
                message = [ 'Mean speed : ' num2str(meanSpeed(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Standard deviation of speed : ' num2str(stdevSpeed(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Mean angle : ' num2str(meanAngle(i)) ];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = [ 'Standard deviation of speed : ' num2str(stdevAngle(i))];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = ']]></description>';
                fprintf(fileID, '%s\n', message);
                
                message = '<Style>';
                fprintf(fileID, '%s\n', message);
                message = '<LineStyle>';
                fprintf(fileID, '%s\n', message);
                message = '<color>7fff0000</color>';
                fprintf(fileID, '%s\n', message);
                message = '<width>5</width>';
                fprintf(fileID, '%s\n', message);
                message = '</LineStyle>';
                fprintf(fileID, '%s\n', message);
                message = '</Style>';
                fprintf(fileID, '%s\n', message);
                
                message = '<LineString>';
                fprintf(fileID, '%s\n', message);
                message = '<extrude>1</extrude><tessellate>1</tessellate>';
                fprintf(fileID, '%s', message);
                message = '<coordinates>';
                fprintf(fileID, '%s\n', message);
                
                % on repete la partie avec les points
                for k=1:length(latitude)
                    a = sprintf('%6f,%6f,400',longitude(k)/1000000,latitude(k)/1000000);
                    fprintf(fileID, ' %s\n', char(a));
                end
                message = '</coordinates>';
                fprintf(fileID, '%s\n', message);
                message = '</LineString>';
                fprintf(fileID, '%s\n', message);
                message = '</Placemark>';
                fprintf(fileID, '%s', message);
                
                % Exit Point
                message = '<Placemark>';
                fprintf(fileID, '%s', message);
                message = '<name>';
                fprintf(fileID, '%s\n', message);
                message = ['Exit Point ' num2str(ind)];
                fprintf(fileID, '%s\n', message);
                message = '</name>';
                fprintf(fileID, '%s\n', message);
                message = '<description><![CDATA[';
                fprintf(fileID, '%s\n', message);
                message = [ 'Latitude : ' num2str(latitude(length(latitude)))];
                fprintf(fileID, '<p>%s</p>\n', message);    
                message = [ 'Longitude : ' num2str(longitude(length(latitude)))];
                fprintf(fileID, '<p>%s</p>\n', message);   
                message = [ 'ExitSpeed : ' num2str(exitspeed(i)) ];
                fprintf(fileID, '<p>%s</p>\n', message);
                message = ']]></description>';
                fprintf(fileID, '%s\n', message);
                message = '<Point>';
                fprintf(fileID, '%s\n', message);
                message = '<coordinates>';
                fprintf(fileID, '%s\n', message);
                a = sprintf('%6f,%6f,400',longitude(length(latitude))/1000000,latitude(length(latitude))/1000000);
                fprintf(fileID, ' %s\n', char(a));
                message = '</coordinates>';
                fprintf(fileID, '%s\n', message);   
                message = '</Point>';
                fprintf(fileID, '%s', message);
                message = '</Placemark>';
                fprintf(fileID, '%s', message);  
            
            end
            i = i + 1;
        end
        ind = ind + 1;
    end
end

for i = 1:length(idPOI)
    message = '<Placemark>';
    fprintf(fileID, '%s', message);
    message = '<name>';
    fprintf(fileID, '%s\n', message);
    monId = idPOI{i};
    message = [ 'POI : ' monId];
    fprintf(fileID, '%s\n', message);
    message = '</name>';
    fprintf(fileID, '%s\n', message);
    
    message = '<description><![CDATA[';
    fprintf(fileID, '%s\n', message);
    message = [ 'TimeCode : ' num2str(timeCodePOI(i)) ];
    fprintf(fileID, '<p>%s</p>\n', message);
    message = [ 'Latitude : ' num2str(latitudePOI(i))];
    fprintf(fileID, '<p>%s</p>\n', message);    
    message = [ 'Longitude : ' num2str(longitudePOI(i))];
    fprintf(fileID, '<p>%s</p>\n', message); 
    message = [ 'Actuel Speed : ' num2str(speedPOI(i))];
    fprintf(fileID, '<p>%s</p>\n', message); 
    message = ']]></description>';
    fprintf(fileID, '%s\n', message); 
    
    message = '<Point>';
    fprintf(fileID, '%s\n', message);
    message = '<coordinates>';
    fprintf(fileID, '%s\n', message);
    a = sprintf('%6f,%6f,400',longitudePOI(i)/1000000,latitudePOI(i)/1000000);
    fprintf(fileID, ' %s\n', char(a));
    message = '</coordinates>';
    fprintf(fileID, '%s\n', message);   
    message = '</Point>';
    fprintf(fileID, '%s', message);
    
    message = '</Placemark>';
    fprintf(fileID, '%s', message); 
end


% KML to display the zones between two adjacent intersections
% connect on the good situation and get the correct variables
situationRecord = theTrip.getAllSituationOccurences('BetweenTheIntersections');
id = situationRecord.getVariableValues('Label');
timecodeDebut = cell2mat(situationRecord.getVariableValues('startTimecode'));
timecodeFin = cell2mat(situationRecord.getVariableValues('endTimecode'));
remark = situationRecord.getVariableValues('Remark');

for i = 1:length(id)
    % pour chaque situation, get correct gps data
    %dataRecord = theTrip.getDataOccurencesInTimeInterval('GPS5Hz',timecodeDebut(i),timecodeFin(i));
    %latitude  = cell2mat(dataRecord.getVariableValues('Latitude_5Hz'));
    %longitude = cell2mat(dataRecord.getVariableValues('Longitude_5Hz'));
    dataRecord = theTrip.getDataOccurencesInTimeInterval('GPS1Hz',timecodeDebut(i),timecodeFin(i));
    latitude  = cell2mat(dataRecord.getVariableValues('Latitude_1Hz'));
    longitude = cell2mat(dataRecord.getVariableValues('Longitude_1Hz'));
    message = '<Placemark>';
    fprintf(fileID, '%s', message);
    message = '<name>';
    fprintf(fileID, '%s\n', message);
    message = id{i};
    fprintf(fileID, '%s\n', message);
    message = '</name>';
    fprintf(fileID, '%s\n', message);
    message = '<description><![CDATA[';
    fprintf(fileID, '%s\n', message);
    message = [ 'Remark : ' remark{i}];
    fprintf(fileID, '<p>%s</p>\n', message);
    message = ']]></description>';
    fprintf(fileID, '%s\n', message);
    
    message = '<LineString>';
    fprintf(fileID, '%s\n', message);
    message = '<extrude>1</extrude><tessellate>1</tessellate>';
    fprintf(fileID, '%s', message);
    message = '<coordinates>';
    fprintf(fileID, '%s\n', message);
    
    % on repete la partie avec les points
    for k=1:length(latitude)
        a = sprintf('%6f,%6f,400',longitude(k)/1000000,latitude(k)/1000000);
        fprintf(fileID, ' %s\n', char(a));
    end
    message = '</coordinates>';
    fprintf(fileID, '%s\n', message);
    message = '</LineString>';
    fprintf(fileID, '%s\n', message);
    message = '</Placemark>';
    fprintf(fileID, '%s', message);
end

message = '</Document>';
fprintf(fileID, '%s', message);
message = '</kml>';
fprintf(fileID, '%s', message);

fclose(fileID);

delete(theTrip);
close('all');
delete(timerfindall);
clear all;
end



