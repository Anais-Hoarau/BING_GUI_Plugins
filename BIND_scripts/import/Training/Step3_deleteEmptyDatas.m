function Step3_deleteEmptyDatas(tripFullPath)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFullPath, 0.04, false);
    metaInfo = trip.getMetaInformations();
    dataList = metaInfo.getDatasNamesList();
    disp('Removing empty datas...');
    for i = 1:1:length(dataList)
        data = dataList{i};
        dataContent = trip.getAllDataOccurences(data);
        if dataContent.isEmpty()
           disp(['--> Removing ' data '...']);
           trip.setIsBaseData(data, false);
           trip.removeData(data);
        end
    end
    %Closing the trip
    disp('Closing trip...');
    delete(trip);
    %Display execution time
    elapsedTime = toc;
    disp(['Datas cleaned in ' num2str(toc) ' seconds']);
end