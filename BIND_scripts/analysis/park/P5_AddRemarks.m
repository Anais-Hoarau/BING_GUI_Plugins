function P5_AddRemarks(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

% find the correct file containing information on points of interest (POI)
pattern = 'c*.xls';
poiFile =  fullfile(directory, pattern);
listing = dir(poiFile);
poiFile = fullfile(directory, listing.name);

% read the file that describes POI
[num,txt] = xlsread(poiFile);

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = ...
    fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

% Use BIND to collect the data to be updated with the remarks
situIntersection = theTrip.getAllSituationOccurences('Intersection');
label1 = situIntersection.getVariableValues('Label');
number = situIntersection.getVariableValues('Number');
timebegin = cell2mat(situIntersection.getVariableValues('startTimecode'));
timeend = cell2mat(situIntersection.getVariableValues('endTimecode'));
situBetween = theTrip.getAllSituationOccurences('BetweenTheIntersections');
label2 = situBetween.getVariableValues('Label');
begintime = cell2mat(situBetween.getVariableValues('startTimecode'));
endtime = cell2mat(situBetween.getVariableValues('endTimecode'));

% Combine the name completed of the data Intersection
newLabel = cell(length(number));
for i = 1:length(number)
    newLabel{i} = strcat(label1{i},num2str(number{i}));
end


for i = 1:length(txt)
    alarme = 0; % This alarme is used to avoid to many repetitions
    for j = 1:length(number)
        if strcmp(txt{i,1},newLabel{j})
            theTrip.setSituationVariableAtTime('Intersection','Remark',timebegin(j),timeend(j),txt{i,2});
            alarme = 1;
            break;
        end
    end
    if alarme == 0
        for j = 1:length(label2)
            
            if strcmp(txt{i,1},label2{j})
                theTrip.setSituationVariableAtTime('BetweenTheIntersections','Remark',begintime(j),endtime(j),txt{i,2});
                break;
            end
        end
    end
end
delete(theTrip);
close('all');
delete(timerfindall);
clear all;
end