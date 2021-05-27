% createMetaEvent(trip,eventName,variables)
% Creates a metaEvent with associated variables and add it to the trip.
% If the metaEvent with this name already exists, it deletes it and
% recreate the proper metaEvent
% trip:      the Trip object you're working on
% eventName: a string, the name of the metaEvent to create
% variables: a cellArray containing information about the variables.
%            ie: {{'var1Name','var1Type'},{'var2Name','var2Type'},...}
function createMetaEvent(trip,eventName,variables)


if (trip.getMetaInformations().existEvent(eventName))
        trip.removeEvent(eventName);
end

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