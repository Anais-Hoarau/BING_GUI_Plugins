function S2DcalculateAllTripIndicators(tripFile)
    import fr.lescot.bind.*;

    disp('Calculating global indicators...');
    
    theTrip = kernel.implementation.SQLiteTrip(tripFile, 0.01, false);
    
    speedStdDev = data.MetaSituationVariable();
    speedStdDev.setName('speed_stdDev');
    speedStdDev.setType(data.MetaSituationVariable.TYPE_REAL);
    theTrip.addSituationVariable('Full_trip', speedStdDev);

    speedAverage = data.MetaSituationVariable();
    speedAverage.setName('speed_average');
    speedAverage.setType(data.MetaSituationVariable.TYPE_REAL);
    theTrip.addSituationVariable('Full_trip', speedAverage);

    totalExcursionTimeVariable = data.MetaSituationVariable();
    totalExcursionTimeVariable.setName('total_lane_excursion_time');
    totalExcursionTimeVariable.setType(data.MetaSituationVariable.TYPE_REAL);
    theTrip.addSituationVariable('Full_trip', totalExcursionTimeVariable);
    

    allTripRecord = theTrip.getAllSituationOccurences('Full_trip');
    allTripTimecodes = allTripRecord.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
    if size(allTripTimecodes, 2) > 0
        %Speed indicators
        speedRecord = theTrip.getAllDataOccurences('dynamique_vehicule');
        speedSignal = speedRecord.buildCellArrayWithVariables({'timecode' 'vitesse'});
        averageSpeeds = processing.situationAggregators.Average.process(allTripTimecodes, speedSignal);
        averageSpeed = averageSpeeds{3,1};
        stdDevSpeeds = processing.situationAggregators.StandardDeviation.process(allTripTimecodes, speedSignal);
        stdDevSpeed = stdDevSpeeds{3,1};
        %Lane excursion time
        positionRecord = theTrip.getAllDataOccurences('position_vehicule');
        positionValues = positionRecord.buildCellArrayWithVariables({'timecode' 'voie' 'cap degres' 'Sens'});
        laneExcursion = findLaneExcursions(positionValues);
        laneExcursionTotalTime = (sum(cell2mat(laneExcursion)) * 0.02);
    end
    startTime = allTripTimecodes{1, 1};
    endTime = allTripTimecodes{2, 1};
    theTrip.setSituationVariableAtTime('Full_trip', 'speed_stdDev',	startTime, endTime,	stdDevSpeed);
    theTrip.setSituationVariableAtTime('Full_trip', 'speed_average',	startTime, endTime,	averageSpeed);
    theTrip.setSituationVariableAtTime('Full_trip', 'total_lane_excursion_time',	startTime, endTime,	laneExcursionTotalTime);
    
    delete(theTrip);
end