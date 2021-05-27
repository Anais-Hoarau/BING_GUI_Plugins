% caccCreateMetaEvent(trip,eventName,variables)
% Creates a metaEvent with associated variables and add it to the trip.
% If the metaEvent with this name already exists, it deletes it and
% recreate the proper metaEvent (TODO: change this behavior for something
% more sensible).
% trip:      the Trip object you're working on
% eventName: a string, the name of the metaEvent to create
% variables: a cellArray containing information about the variables.
%            ie: {{'var1Name','var1Type'},{'var2Name','var2Type'},...}
function caccCreateMetaEvent(trip,eventName,variables)


% metaEventExists = true;
% % first check metadata
if (trip.getMetaInformations().existEvent(eventName))
%     %if it is there, check if  the variables are correct
%     if (trip.getMetaInformations().existSituationVariable(eventName, 'startTimecode') ...
%      && trip.getMetaInformations().existSituationVariable(eventName, 'endTimecode') && trip.getMetaInformations().existSituationVariable(eventName, 'endTimecode') )
%         % table can store data : empty it for regeneration
%         trip.removeAllSituationOccurences(eventName);
%     else
%         % table exist but cannot store data : delete and recreate with good
%         % strucuture
        trip.removeEvent(eventName);
        metaEventExists = false;
%     end
else
    % table does not exist
    metaEventExists = false;
end

% create the metaEvent if it does not already exist
if not(metaEventExists)
    % create a metaEvent
    newMetaEvent = fr.lescot.bind.data.MetaEvent;
    newMetaEvent.setName(eventName);
    % create metaEventVariables
    metaEventVariableArray = cell(size(variables));
    for i=1:length(variables)
        metaEventVariableArray{i} = fr.lescot.bind.data.MetaEventVariable();
        metaEventVariableArray{i}.setName(variables{i}{1});
        metaEventVariableArray{i}.setType(variables{i}{2});
    end
    % set the metaEventVariables in the metaEvent
    newMetaEvent.setVariables(metaEventVariableArray);
    % add the metaEvent to the trip
    trip.addEvent(newMetaEvent);
end

end