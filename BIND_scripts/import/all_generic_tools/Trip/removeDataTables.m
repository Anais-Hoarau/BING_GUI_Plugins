% remove data tables from trip file
function isBaseTable = removeDataTables(trip, dataList, forceIsBase)
    meta = trip.getMetaInformations;
    for i = 1:length(dataList)
        data = dataList{i};
        if meta.existData(data)
            disp(['Removing data table ' data ' from trip ' trip.getTripPath]);
            isBaseTable = isBase(meta.getMetaData(data));
            if isBaseTable && forceIsBase, trip.setIsBaseData(data, 0); end
            if ~isBaseTable
                trip.removeData(data);
            else
                disp([data ' data is locked by "isBase" protocole']);
            end
            if isBaseTable && forceIsBase, trip.setIsBaseData(data, 1); end
        else
            disp([data ' data doesn''t exist']);
        end
    end
end