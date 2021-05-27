function  S0cleanSpeed(tripFile)
    import fr.lescot.bind.*;

    theTrip = kernel.implementation.SQLiteTrip(tripFile, 0.01, false);
    
    theTrip.setIsBaseData('dynamique_vehicule', false);
    
    positionRecord = theTrip.getAllDataOccurences('position_vehicule');
    routes = positionRecord.buildCellArrayWithVariables({'timecode' 'route'});
    
    for i = 2:1:size(routes, 2)
        if routes{2, i} ~= routes{2, i - 1}%Change of lane ==> null speed to correct       
            previousSpeedRecord = theTrip.getDataOccurenceNearTime('dynamique_vehicule', routes{1, i - 1});
            previousSpeed = previousSpeedRecord.getVariableValues('vitesse');
            previousSpeed = previousSpeed{1};
            followingSpeedRecord = theTrip.getDataOccurenceNearTime('dynamique_vehicule', routes{1, i + 1});
            followingSpeed = followingSpeedRecord.getVariableValues('vitesse');
            followingSpeed = followingSpeed{1};
            newSpeed = (previousSpeed + followingSpeed) / 2;
            theTrip.setDataVariableAtTime('dynamique_vehicule', 'vitesse', routes{1, i}, newSpeed);
        end
    end
    
    theTrip.setIsBaseData('dynamique_vehicule', true);
    delete(theTrip);
end