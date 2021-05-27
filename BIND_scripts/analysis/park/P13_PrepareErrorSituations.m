function P13_PrepareErrorSituations(directory)
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

situationsIntersection = theTrip.getAllSituationOccurences('Intersection');
starttimeIntersection = cell2mat(situationsIntersection.getVariableValues('startTimecode'));
endtimeIntersection = cell2mat(situationsIntersection.getVariableValues('endTimecode'));
labelIntersection = situationsIntersection.getVariableValues('Label');
numberIntersection = cell2mat(situationsIntersection.getVariableValues('Number'));
typeIntersection = situationsIntersection.getVariableValues('Type');

situationsBetweenIntersection = theTrip.getAllSituationOccurences('BetweenTheIntersections');

situationsBetweenIntersection = theTrip.getAllSituationOccurences('BetweenTheIntersections');
starttimeBetweenIntersection = cell2mat(situationsBetweenIntersection.getVariableValues('startTimecode'));
endtimeBetweenIntersection = cell2mat(situationsBetweenIntersection.getVariableValues('endTimecode'));
labelsBetweenIntersection = situationsBetweenIntersection.getVariableValues('Label');

% Create the event database and the eventVariables
if (~theTrip.getMetaInformations().existSituation('errorSituations'))
     disp('The output event doesnt exist!');
    disp('And it will be created!');
    situationErrM = fr.lescot.bind.data.MetaSituation();
    situationErrM.setName('errorSituationsByMaud');

    situationErrL = fr.lescot.bind.data.MetaSituation();
    situationErrL.setName('errorSituationsByLaurence');

    label = fr.lescot.bind.data.MetaSituationVariable();
    label.setName('Label');
    label.setType('TEXT');
    
    type = fr.lescot.bind.data.MetaSituationVariable();
    type.setName('Type');
    type.setType('TEXT');
    
    variablesToSet = {label,type};
 
    
    variablesNameToCode = {'PAD',...
                'FO',...
                'FR',...
                'CLD',...
                'Stop',...
                'AbsCli',...
                'CliTardif',...
                'PbBV',...
                'PbPedales',...
                'FreinBrusque',...
                'FreinTardif',...
                'RegardFixe',...
                'AngleMort',...
                'AbsRetro',...
                'MvsChoixVoie',...
                'ChgmtVoieTardif',...
                'TrajCoupee',...
                'TrajLarge',...
                'PosG++',...
                'PosD++',...
                'FranchiLigne',...
                'ArretTardif',...
                'ArretVoie',...
                'TropVite',...
                'TropLent',...
                'DIVCourte',...
                'GAPCourt',...
                'NDPietons',...
                'Klaxon',...
                'IntervFrein',...
                'IntervVolant',...
                'IntervBoite de Vitesse',...
                'IntervOrale',...
                };
    
    
    for i=1:length(variablesNameToCode)
        variableName = variablesNameToCode{i};
        uneVariable = fr.lescot.bind.data.MetaSituationVariable();
        uneVariable.setName(variableName);
        uneVariable.setType('REAL');
        variablesToSet = {variablesToSet{:} uneVariable};
    end
    
    situationErrL.setVariables(variablesToSet);
    situationErrM.setVariables(variablesToSet);
    theTrip.addSituation(situationErrL);
    theTrip.addSituation(situationErrM);
else
    disp('The output event and output event variables already exist!')
    disp('--- The end ---');
    return;
end

% take all intersection situation and add to new table

for i=1:length(starttimeIntersection)
    
    startTime = starttimeIntersection(i);
    endTime = endtimeIntersection(i);
    
    idSituation = [labelIntersection{i} num2str(numberIntersection(i))];
    theTrip.setSituationVariableAtTime('errorSituationsByMaud', 'Label', startTime, endTime,idSituation);
    theTrip.setSituationVariableAtTime('errorSituationsByLaurence', 'Label', startTime, endTime,idSituation);
    typeSituation = typeIntersection{i};
    theTrip.setSituationVariableAtTime('errorSituationsByMaud', 'Type', startTime, endTime,typeSituation); 
    theTrip.setSituationVariableAtTime('errorSituationsByLaurence', 'Type', startTime, endTime,typeSituation); 
end

for i=1:length(starttimeBetweenIntersection)
    
    startTime = starttimeBetweenIntersection(i);
    endTime = endtimeBetweenIntersection(i);
    
    idSituation = labelsBetweenIntersection{i};
    theTrip.setSituationVariableAtTime('errorSituationsByMaud', 'Label', startTime, endTime,idSituation);
    theTrip.setSituationVariableAtTime('errorSituationsByLaurence', 'Label', startTime, endTime,idSituation);
    typeSituation = 'Z';
    theTrip.setSituationVariableAtTime('errorSituationsByMaud', 'Type', startTime, endTime,typeSituation); 
    theTrip.setSituationVariableAtTime('errorSituationsByLaurence', 'Type', startTime, endTime,typeSituation); 
end


end

