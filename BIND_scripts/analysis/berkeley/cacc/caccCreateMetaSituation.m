% caccCreateMetaSituation(trip,situationName,variables)
% Creates a metaSituation with associated variables and add it to the trip.
% If the metaSituation with this name already exists, it deletes it and
% recreate the proper metaSituation (TODO: change this behavior for something
% more sensible).
% trip:      the Trip object you're working on
% metaSituation: a string, the name of the metaSituation to create
% variables: a cellArray containing information about the variables.
%            ie: {{'var1Name','var1Type'},{'var2Name','var2Type'},...}
function caccCreateMetaSituation(trip,situationName,variables)


% metaSituationExists = true;
% % first check metadata
if (trip.getMetaInformations().existSituation(situationName))
%     %if it is there, check if  the variables are correct
%     if (trip.getMetaInformations().existSituationVariable(situationName, 'startTimecode') ...
%      && trip.getMetaInformations().existSituationVariable(situationName, 'endTimecode') && trip.getMetaInformations().existSituationVariable(situationName, 'endTimecode') )
%         % table can store data : empty it for regeneration
%         trip.removeAllSituationOccurences(situationName);
%     else
%         % table exist but cannot store data : delete and recreate with good
%         % strucuture
        trip.removeSituation(situationName);
        metaSituationExists = false;
%     end
else
    % table does not exist
    metaSituationExists = false;
end

% create the metaSituation if it does not already exist
if not(metaSituationExists)
    % create a metaSituation
    newMetaSituation = fr.lescot.bind.data.MetaSituation;
    newMetaSituation.setName(situationName);
    % create metaSituationVariables
    metaSituationVariableArray = cell(size(variables));
    for i=1:length(variables)
        metaSituationVariableArray{i} = fr.lescot.bind.data.MetaSituationVariable();
        metaSituationVariableArray{i}.setName(variables{i}{1});
        metaSituationVariableArray{i}.setType(variables{i}{2});
    end
    % set the metaSituationVariables in the metaSituation
    newMetaSituation.setVariables(metaSituationVariableArray);
    % add the metaSituation to the trip
    trip.addSituation(newMetaSituation);
end

end