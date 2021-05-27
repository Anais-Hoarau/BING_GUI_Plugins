function generateSituationForIAVehicules(tripPath)

    if nargin == 0
       [name path] = uigetfile('*.trip', 'Choisissez le fichier .trip'); 
       tripPath = [path name];
    end

    theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripPath, 0.04, false);
    metaInfos = theTrip.getMetaInformations();
    metaDatas = metaInfos.getDatasNamesList();
    for i = 1:1:length(metaDatas)
        metaDataName = metaDatas{i};
        convertedDataName = str2double(metaDataName);
        if convertedDataName < 0
            dataMinTime = theTrip.getDataVariableMinimum(metaDataName, 'timecode');
            dataMaxTime = theTrip.getDataVariableMaximum(metaDataName, 'timecode');
            %Adding the situation occurence
            existingSituation = theTrip.getSituationOccurenceAtTime('VehiclePresence', dataMinTime, dataMaxTime);
            if existingSituation.isEmpty()
                theTrip.setSituationVariableAtTime( 'VehiclePresence', 'idVehicles', dataMinTime, dataMaxTime, metaDataName);
            else
                currentValue = existingSituation.getVariableValues('idVehicles');
                currentValue = currentValue{1};
                theTrip.setSituationVariableAtTime( 'VehiclePresence', 'idVehicles', dataMinTime, dataMaxTime, [currentValue ';' metaDataName]);
            end
        end
    end
    delete(theTrip);
end