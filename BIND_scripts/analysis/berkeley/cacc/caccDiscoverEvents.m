% eventsToSave = caccDiscoverEvents(discoverer,variableData,parameters,discoveredEventName)
% Facilitates the process of discovering events. Call the eventDiscoverer
% with the good set of data. The result is a cell array of timecodes and of
% the string containing the name of the discovered events (ready to save on
% the trip).
% discoverer:   an eventDiscoverer
% variableData: the first input of the eventDiscoverer.extract() method: 
%               A 2*n cell array of numerical values.
% parameters:   the second input of the eventDiscoverer.extract() method:
%               A cell array of strings containing the values of the parameters
% discoveredEventName:  a string containing the name of the discovered
%               event.
% eventsToSave: the discovered events (timecode,discoveredEventName)
function eventsToSave = caccDiscoverEvents(discoverer,variableData,parameters,discoveredEventName)

discoveredEvents = discoverer.extract(variableData,parameters);

eventsToSave = {};

% create triplets of timecode, Labels for backups
for i=1:length(discoveredEvents)
    eventsToSave{1,i} = discoveredEvents{1,i};
    eventsToSave{2,i} = discoveredEventName;
end

end