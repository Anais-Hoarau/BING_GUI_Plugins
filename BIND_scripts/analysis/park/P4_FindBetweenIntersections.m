function P4_FindBetweenIntersections(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end
% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = ...
fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

% Use BIND to read data in matlab workspace
dataSituation = theTrip.getAllSituationOccurences('Intersection');
idzones = cell2mat(dataSituation.getVariableValues('Number'));
starttime = cell2mat(dataSituation.getVariableValues('startTimecode'));
endtime = cell2mat(dataSituation.getVariableValues('endTimecode'));

% Check in meta datas if output events and outpus variables are
% available
if (~theTrip.getMetaInformations().existSituation('BetweenTheIntersections'))
    disp('The output event doesnt exist!');
    disp('And it will be created!');
    situationB = fr.lescot.bind.data.MetaSituation();
    label = fr.lescot.bind.data.MetaSituationVariable();
    remark = fr.lescot.bind.data.MetaSituationVariable();
    
    situationB.setName('BetweenTheIntersections');
    label.setName('Label');
    remark.setName('Remark');
    
    label.setType('TEXT');
    remark.setType('TEXT');
    
    situationB.setVariables({label,remark});
    theTrip.addSituation(situationB);
else
    disp('The output event and output event variables already exist!');
    disp('Please delete them all to create or update!')
    disp('--- The end ---');
    return;
end

indice = 1; % Accumulator to test whether it is in the same intersection
index = 1; % Accumulator to collect the data
for i = 1:length(idzones)
    if idzones(i) ~= indice
        beginpoint= endtime(index-1);
        endpoint = starttime(index);
        idsituation = strcat('betweenInt',num2str(indice),'and',num2str(indice+1));
        if beginpoint < endpoint
            disp(['Going to insert ' idsituation]);
            theTrip.setSituationVariableAtTime('BetweenTheIntersections', 'Label', beginpoint, endpoint,idsituation);
        else
           disp('Situation skipped because start > end') 
        end
        indice = indice + 1;
    end
    index = index + 1;
end
delete(theTrip);
close('all');
delete(timerfindall);
clear all;
end