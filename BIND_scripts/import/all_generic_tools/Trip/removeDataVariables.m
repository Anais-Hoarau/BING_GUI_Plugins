% remove data variables from trip file
function isBaseTable = removeDataVariables(trip, data, variablesList, forceIsBase)
    meta = trip.getMetaInformations;
    if meta.existData(data)
        isBaseTable = isBase(meta.getMetaData(data));
        if isBaseTable && forceIsBase, trip.setIsBaseData(data, 0); end
        for i = 1:length(variablesList)
            variable = variablesList{i};
            disp(['Removing variable ' variable ' from data table ' data ' in trip ' trip.getTripPath]);
            if ~isBaseTable && meta.existDataVariable(data, variable)
                trip.removeDataVariable(data, variable);
            else
                disp([data ' data is locked by "isBase" protocole']);
            end
        end
        if isBaseTable && forceIsBase, trip.setIsBaseData(data, 1); end
    else
        disp([data ' data doesn''t exist']);
    end
end