% This algorithm is used to find the situations of each intersection which are divided into three parts: 
% Entry Intersection, Intersection, Exit Intersection.
% The creation of the situations is according to the property of the PointOfInterest 
function P2_FindIntersection(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);
tripMetaInformations = theTrip.getMetaInformations();

% Use BIND to read data in matlab workspace
dataPOI = theTrip.getAllEventOccurences('POI');
time = cell2mat(dataPOI.getVariableValues('TimeCode'));
name = dataPOI.getVariableValues('Name');
beforePOI = cell2mat(dataPOI.getVariableValues('BeforePOI'));
afterPOI = cell2mat(dataPOI.getVariableValues('AfterPOI'));
dataRoute = theTrip.getAllDataOccurences('SensorsMeasures');
timecode = cell2mat(dataRoute.getVariableValues('timecode'));
distancedriven = cell2mat(dataRoute.getVariableValues('DistanceDriven'));
POITypes = dataPOI.getVariableValues('Type');

% Check in meta datas if output events and outpus variables are
% available
if (~tripMetaInformations().existSituation('Intersection'))
    disp('The output event doesnt exist!');
    disp('And it will be created!')
    situationPOI = fr.lescot.bind.data.MetaSituation();
    label = fr.lescot.bind.data.MetaSituationVariable();
    id = fr.lescot.bind.data.MetaSituationVariable();
    type = fr.lescot.bind.data.MetaSituationVariable();
    entryspeed = fr.lescot.bind.data.MetaSituationVariable();
    exitspeed = fr.lescot.bind.data.MetaSituationVariable();
    averagespeed = fr.lescot.bind.data.MetaSituationVariable();
    stdevspeed = fr.lescot.bind.data.MetaSituationVariable();
    averagevolant = fr.lescot.bind.data.MetaSituationVariable();
    stdevvolant = fr.lescot.bind.data.MetaSituationVariable();
    averageacc = fr.lescot.bind.data.MetaSituationVariable();
    stdevacc = fr.lescot.bind.data.MetaSituationVariable();
    averagebrake = fr.lescot.bind.data.MetaSituationVariable();
    stdevbrake = fr.lescot.bind.data.MetaSituationVariable();
    averageclutch = fr.lescot.bind.data.MetaSituationVariable();
    stdevclutch = fr.lescot.bind.data.MetaSituationVariable();
    remark = fr.lescot.bind.data.MetaSituationVariable();
    
    situationPOI.setName('Intersection');
    label.setName('Label');
    id.setName('Number');
    type.setName('Type');
    entryspeed.setName('EntrySpeed');
    exitspeed.setName('ExitSpeed');
    averagespeed.setName('AverageSpeed');
    stdevspeed.setName('StdevSpeed');
    averagevolant.setName('AverageAngle');
    stdevvolant.setName('StdevAngle');
    averageacc.setName('AverageAccelerator');
    stdevacc.setName('StdevAccelerator');
    averagebrake.setName('AverageBrake');
    stdevbrake.setName('StdevBrake');
    averageclutch.setName('AverageClutch');
    stdevclutch.setName('StdevClutch');
    remark.setName('Remark');
    
    label.setType('TEXT');
    type.setType('TEXT');
    remark.setType('TEXT');
    
    situationPOI.setVariables({label,id,type,entryspeed,exitspeed,averagespeed,stdevspeed,averagevolant,stdevvolant,averageacc,stdevacc,averagebrake,stdevbrake,averageclutch,stdevclutch,remark});
    theTrip.addSituation(situationPOI);
else
    disp('The output event and output event variables already exist!');
    disp('Please delete them all to create or update!')
    disp('--- The end ---');
    return;
end

indice = 1; % Accumulator for the quantity of the intersections
ind = 1; % Accumulator for the number of the intersection
tablestart = zeros(1,length(time)); % We store the "starttime" of each intersection in it
tableend = zeros(1,length(time)); % We store the "endtime" of each intersection in it
labelcellarray = cell(length(time)); % We store the "Label"(Here,as "entryInt" "int" "exitInt", they can be defined by the user)
tableid = zeros(1,length(time)); % We store the "Number" of each intersection in it
types = cell(1, length(time));

% Loop to define the beginning and the end of a situation
i = 1;
while i <= length(time)
    disp([num2str(i) '/' num2str(length(time))]);
    % First case : the intersection with only "Entry Intersection"
    if name{i}(1) == 'B' && name{i+1}(1) ~= 'A'
        disp('On a qu''une entrée')
        % before
        index = find(timecode < time(i));
        newtimecode = timecode(index);
        newdistancedriven = distancedriven(index);
        nowdistance = distancedriven(index(length(index))+1);
        for j = length(newdistancedriven):-1:1
            if nowdistance - newdistancedriven(j) > beforePOI(i)
                tablestart(indice) =  newtimecode(j);
                tableend(indice) = time(i);
                labelcellarray{indice} = 'entryInt';
                tableid(indice) = ind;
                types{indice} = POITypes{i};
                break;
            end
        end
        indice = indice + 1;
        ind = ind + 1;
        i = i + 1;
    
    % Second case :  the intersection completed with three phases: "Entry Intersection" "Intersection" "Exit Intersection"    
    elseif name{i}(1) == 'B' && name{i+1}(1) == 'A'
        % before
        disp('On a entrée et sortie')
        index = find(timecode < time(i));
        newtimecode = timecode(index);
        newdistancedriven = distancedriven(index);
        nowdistance = distancedriven(index(length(index))+1);
        for j = length(newdistancedriven):-1:1
            if nowdistance - newdistancedriven(j) > beforePOI(i)
                tablestart(indice) =  newtimecode(j);
                tableend(indice) = time(i);
                labelcellarray{indice} = 'entryInt';
                tableid(indice) = ind;
                types{indice} = POITypes{i};
                break;
            end
        end
        indice = indice + 1;

        % middle
        tablestart(indice) = time(i);
        tableend(indice) = time(i+1);
        labelcellarray{indice} = 'int';
        types{indice} = POITypes{i};
        tableid(indice) = ind;
        indice = indice + 1;

        % after
        index = find(timecode > time(i+1));
        newtimecode = timecode(index);
        newdistancedriven = distancedriven(index);
        nowdistance = distancedriven(index(1)-1);
        for j = 1:length(newdistancedriven)
            if newdistancedriven(j)- nowdistance > afterPOI(i+1)
                tablestart(indice) =  time(i+1);
                tableend(indice) = newtimecode(j);
                types{indice} = POITypes{i};
                labelcellarray{indice} = 'exitInt';
                tableid(indice) = ind;
                break;
            end
        end
        indice = indice + 1;
        ind = ind + 1;
        i = i + 2;
    else
        disp('On est baisé !')
%     % Third case :  the special intersection with no zones to display, which, in fact, is an Eventment    
%     elseif name{i}(1) == 'P'
%         index = find(timecode < time(i));
%         p = index(length(index));
%         tablestart(indice) =  timecode(p);
%         tableend(indice) = timecode(p);
%         labelcellarray{indice} = 'Point Feu';
%         tableid(indice) = ind;
%         types{indice} = '';
%         indice = indice + 1;
%         ind = ind + 1;
%         i = i + 1;
    end
end

 % calculate & save the averages and the standard deviations
 for i = 1 : indice-1
     record = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',tablestart(i), tableend(i));
     result = record.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle'});
     speedline = result(2,:);
     inspeed = speedline{1};
     type = types{i};
     outspeed = speedline{size(result,2)};
     theTrip.setSituationVariableAtTime('Intersection', 'Label', tablestart(i), tableend(i),labelcellarray{i});
     theTrip.setSituationVariableAtTime('Intersection', 'Number', tablestart(i), tableend(i),tableid(i));
     theTrip.setSituationVariableAtTime('Intersection', 'EntrySpeed', tablestart(i), tableend(i),inspeed);
     theTrip.setSituationVariableAtTime('Intersection', 'ExitSpeed', tablestart(i), tableend(i),outspeed);
     theTrip.setSituationVariableAtTime('Intersection', 'Type', tablestart(i), tableend(i), type);
     message = [labelcellarray{i} num2str(tableid(i)) ' insert '];
     disp(message);
 end
delete(theTrip);
close('all');
delete(timerfindall);
clear all;
end