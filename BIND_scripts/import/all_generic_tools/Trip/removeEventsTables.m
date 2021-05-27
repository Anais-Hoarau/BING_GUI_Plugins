% remove events tables from trip file
function isBaseTable = removeEventsTables(trip, eventsList, forceIsBase)
    meta = trip.getMetaInformations;
    for i = 1:length(eventsList)
        event = eventsList{i};
        if meta.existEvent(event)
            disp(['Removing event ' event ' from trip ' trip.getTripPath]);
            isBaseTable = isBase(meta.getMetaEvent(event));
            if isBaseTable && forceIsBase, trip.setIsBaseEvent(event, 0); end
            if ~isBaseTable
                trip.removeEvent(event);
            else
                disp([event ' event is locked by "isBase" protocole']);
            end
            if isBaseTable && forceIsBase, trip.setIsBaseEvent(event, 1); end
        else
            disp([event ' event doesn''t exist']);
        end
    end
end