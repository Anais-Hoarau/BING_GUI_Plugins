function collecteSync = resyncCollecteUnPoint(data_mopad,data_kvaser,offset_mopad,offset_kvaser)

    collecteSync.Mopad = data_mopad;
    names = fieldnames(data_mopad);
    for i = 1:length(names)
        record = getfield(collecteSync.Mopad,names{i});
        % remove possible timecode = 0
        ind_tcNotEq0 = record.tc~=0;
        subnames = fieldnames(record);
        for j = 1:length(subnames)
            data = getfield(record,subnames{j});
            record = setfield(record,subnames{j},data(ind_tcNotEq0));
        end
        record.tc_sync = (record.tc - offset_mopad)/1000 ;
        collecteSync.Mopad = setfield(collecteSync.Mopad,names{i},record);
    end

    collecteSync.Kvaser = data_kvaser;
    names = fieldnames(data_kvaser);
    for i = 1:length(names)
        record = getfield(collecteSync.Kvaser,names{i});
        subnames = fieldnames(record);
        for j = 1:length(subnames)
            data = getfield(record,subnames{j});
            data.tc_sync = data.tc - offset_kvaser;
            record = setfield(record,subnames{j},data);
        end
        collecteSync.Kvaser = setfield(collecteSync.Kvaser,names{i},record);
    end
    
end