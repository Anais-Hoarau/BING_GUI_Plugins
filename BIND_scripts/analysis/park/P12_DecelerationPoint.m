function P12_DecelerationPoint(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

import fr.lescot.bind.processing.*
import fr.lescot.bind.processing.situationAggregators.*

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

dataPOI = theTrip.getAllEventOccurences('POI');
poiWithTime = dataPOI.buildCellArrayWithVariables({'Latitude' 'Longitude' 'Name' 'Type'});
situation = theTrip.getAllSituationOccurences('Intersection');
dataInt = situation.buildCellArrayWithVariables({'startTimecode' 'endTimecode' 'Label' 'Type'});

% Create the event database and the eventVariables
if (~theTrip.getMetaInformations().existEvent('DecelerationPoint'))
    disp('The output event doesnt exist!');
    disp('And it will be created!')
    deAccPoint = fr.lescot.bind.data.MetaEvent();
    name = fr.lescot.bind.data.MetaEventVariable();
    type = fr.lescot.bind.data.MetaEventVariable();
    distance = fr.lescot.bind.data.MetaEventVariable();
    remark = fr.lescot.bind.data.MetaEventVariable();
    deAccPoint.setName('DecelerationPoint');
    name.setName('Name');
    name.setType(fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT);
    distance.setName('Distance2POI');
    type.setName('Type');
    type.setType(fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT);
    remark.setName('Remark');
    remark.setType(fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT);
    deAccPoint.setVariables({name,type,distance,remark});
    theTrip.addEvent(deAccPoint);
else
    disp('The output event and output event variables already exist!')
    disp('--- The end ---');
    return;
end

% Find all the index of "EntryInt" in the situation INTERSECTION
ind = zeros(1,length(dataInt));
for j = 1:length(dataInt)
    if regexp(dataInt{3,j},'entryInt') & isempty(regexp(dataInt{4,j},'CP'))
        ind(1,j) = j;
    end
end
ind = unique(ind);

% Find all the index of POI "before" entering the intersection
indPOI = zeros(1,length(poiWithTime));
for j = 1:length(poiWithTime)
    if regexp(poiWithTime{3,j},'B') & isempty(regexp(poiWithTime{4,j},'CP'))
        indPOI(1,j) = j;
    end
end
indPOI = unique(indPOI);

for j = 1:length(ind)
    if ind(j)~=0
        startTime = dataInt{1,ind(j)};
        endTime = dataInt{2,ind(j)};
        dataAcc = theTrip.getDataVariableOccurencesInTimeInterval('ProcessedData','%Accelerator',startTime,endTime);
        acc = cell2mat(dataAcc.getVariableValues('%Accelerator'));
        dataBrake = theTrip.getDataVariableOccurencesInTimeInterval('ProcessedData','%Brake',startTime,endTime);
        brake = cell2mat(dataBrake.getVariableValues('%Brake'));
        dataTime = theTrip.getDataVariableOccurencesInTimeInterval('ProcessedData','timecode',startTime,endTime);
        timecode = cell2mat(dataTime.getVariableValues('timecode'));
        
        brakesPositive = find(brake > 0);
        if ~isempty(brakesPositive)
            firstPositiveBrakePoint = timecode(brakesPositive(1));
            newDataAcc = theTrip.getDataVariableOccurencesInTimeInterval('ProcessedData','%Accelerator',startTime,firstPositiveBrakePoint);
            newAcc = cell2mat(newDataAcc.getVariableValues('%Accelerator'));
            accsNegative = find(newAcc <= 5);
            if ~isempty(accsNegative)
                newDataTime = theTrip.getDataVariableOccurencesInTimeInterval('ProcessedData','timecode',startTime,firstPositiveBrakePoint);
                newTimecode = cell2mat(newDataTime.getVariableValues('timecode'));
                pointDeceleration = newTimecode(accsNegative(length(accsNegative)));
            else
                pointDeceleration = firstPositiveBrakePoint;
            end
        else
            accsNegative = find(acc <= 5);
            if ~isempty(accsNegative)
                pointDeceleration = timecode(accsNegative(length(accsNegative)));
            else
                pointDeceleration = 'Not Found';
            end
        end
        
        if ~strcmp(pointDeceleration,'Not Found')
            dataGPS = theTrip.getDataOccurenceAtTime('GPS5Hz',pointDeceleration);
            latGPS = cell2mat(dataGPS.getVariableValues('Latitude_5Hz'));
            longGPS = cell2mat(dataGPS.getVariableValues('Longitude_5Hz'));
            
            dataLat = cell2mat(dataPOI.getVariableValues('Latitude'));
            dataLong = cell2mat(dataPOI.getVariableValues('Longitude'));
            latPOI = dataLat(indPOI(j));
            longPOI = dataLong(indPOI(j));
            
            % Calculate the distance of deceleration
            a = pi / 180;
            lat1 = latGPS/1000000 * a;
            long1 = longGPS/1000000 * a;
            lat2 = latPOI/1000000 * a;
            long2 = longPOI/1000000 * a;
            t = sin((lat1-lat2)/2)*sin((lat1-lat2)/2) + cos(lat1)*cos(lat2)*sin((long1-long2)/2)*sin((long1-long2)/2);
            distanceValue = 2 * 6371000 * atan2(sqrt(t),sqrt(1-t));
            
            theTrip.setEventVariableAtTime('DecelerationPoint','Name',pointDeceleration,dataInt{3,ind(j)});
            theTrip.setEventVariableAtTime('DecelerationPoint','Type',pointDeceleration,poiWithTime{4,indPOI(j)});
            theTrip.setEventVariableAtTime('DecelerationPoint','Distance2POI',pointDeceleration,distanceValue);
            
        else
            pointDeceleration = startTime;
            theTrip.setEventVariableAtTime('DecelerationPoint','Name',pointDeceleration,dataInt{3,ind(j)});
            theTrip.setEventVariableAtTime('DecelerationPoint','Type',pointDeceleration,poiWithTime{4,indPOI(j)});
            theTrip.setEventVariableAtTime('DecelerationPoint','Distance2POI',pointDeceleration,'NotFound');
        end
        
        message = [dataInt{3,ind(j)} ' at ' num2str(pointDeceleration) ' inserts!'];
        disp(message);
        
    end
end

