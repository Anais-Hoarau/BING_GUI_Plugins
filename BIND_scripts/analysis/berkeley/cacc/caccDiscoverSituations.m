% situationsToSave = caccDiscoverSituations(discoverer,variableData,parameters,discoveredSituationName)
% Facilitates the process of discovering situations. Call the situationDiscoverer
% with the good set of data. The result is a cell array of start and end timecodes and of
% the string containing the name of the discovered situtation (ready to save on
% the trip).
% discoverer:   a situationDiscoverer
% variableData: the first input of the situationDiscoverer.extract() method: 
%               A 2*n cell array of numerical values.
% parameters:   the second input of the situationDiscoverer.extract() method:
%               A cell array of strings containing the values of the parameters
% discoveredSituationName:  a string containing the name of the discovered
%               situation.
% situationsToSave: the discovered situations (timecode_bein,timecode_end,discoveredSituationName)
function situationsToSave = caccDiscoverSituations(discoverer,variableData,parameters,discoveredSituationName)

discoveredSituations = discoverer.extract(variableData,parameters);

situationsToSave = {};

[~,numSituations] = size(discoveredSituations);
% create triplets of timecode, Labels for backups
for i=1:numSituations
    situationsToSave{1,i} = discoveredSituations{1,i};
    situationsToSave{2,i} = discoveredSituations{2,i};
    situationsToSave{3,i} = discoveredSituationName;
end

end