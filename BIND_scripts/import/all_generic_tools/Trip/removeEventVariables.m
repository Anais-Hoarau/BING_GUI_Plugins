% remove situation variables from trip file
function isBaseTable = removeEventVariables(trip, event, variablesList, forceIsBase)
    meta = trip.getMetaInformations;
    if meta.existEvent(event)
        isBaseTable = isBase(meta.getMetaEvent(event));
        if isBaseTable && forceIsBase, trip.setIsBaseEvent(event, 0); end
        for i = 1:length(variablesList)
            variable = variablesList{i};
            disp(['Removing variable ' variable ' from event table ' event ' in trip ' trip.getTripPath]);
            if ~isBaseTable && meta.existEventVariable(event, variable)
                trip.removeEventVariable(event, variable);
            else
                disp([event ' event is locked by "isBase" protocole']);
            end
        end
        if isBaseTable && forceIsBase, trip.setIsBaseEvent(event, 1); end
    else
        disp([event ' event doesn''t exist']);
    end
end