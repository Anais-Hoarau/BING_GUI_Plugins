function S2EcalculateDistractionIndicators(tripFile)
    import fr.lescot.bind.*;

    theTrip = kernel.implementation.SQLiteTrip(tripFile, 0.01, false);
    
    %A. Do all the distraction zone stuff
    %A.1. Get all the occurences
    allDistractionRecord = theTrip.getAllSituationOccurences('Distraction');
    allDistractionTimecodes = allDistractionRecord.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
    if size(allDistractionTimecodes, 2) > 0
        allDynamicRecord = theTrip.getAllDataOccurences('dynamique_vehicule');
        allPositionRecord = theTrip.getAllDataOccurences('position_vehicule');

        %A.2. Add the destination variables
        speedStdDev = data.MetaSituationVariable();
        speedStdDev.setName('speed_stdDev');
        speedStdDev.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Distraction', speedStdDev);

        speedAverage = data.MetaSituationVariable();
        speedAverage.setName('speed_average');
        speedAverage.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Distraction', speedAverage);

        lanePositionStdDev = data.MetaSituationVariable();
        lanePositionStdDev.setName('lane_position_stdDev');
        lanePositionStdDev.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Distraction', lanePositionStdDev);

        lanePositionAverage = data.MetaSituationVariable();
        lanePositionAverage.setName('lane_position_average');
        lanePositionAverage.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Distraction', lanePositionAverage);
        
        totalExcursionTimeVariable = data.MetaSituationVariable();
        totalExcursionTimeVariable.setName('total_lane_excursion_time');
        totalExcursionTimeVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Distraction', totalExcursionTimeVariable);
        
        %Calculate the indicators

        %Calculate the standard deviation of the lane position
        laneSignal = allPositionRecord.buildCellArrayWithVariables({'timecode' 'voie'});
        laneStdDev = processing.situationAggregators.StandardDeviation.process(allDistractionTimecodes, laneSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Distraction', 'lane_position_stdDev', laneStdDev)
        laneAverage = processing.situationAggregators.Average.process(allDistractionTimecodes, laneSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Distraction', 'lane_position_average', laneAverage)


        %Mean and stdDev of speed (m/s)
        speedSignal = allDynamicRecord.buildCellArrayWithVariables({'timecode' 'vitesse'});
        speedStdDev = processing.situationAggregators.StandardDeviation.process(allDistractionTimecodes, speedSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Distraction', 'speed_stdDev', speedStdDev)
        speedAverage = processing.situationAggregators.Average.process(allDistractionTimecodes, speedSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Distraction', 'speed_average', speedAverage)

        %Lane excursion time
        laneExcursionTotalTimes = cell(1, size(allDistractionTimecodes, 2));
        for i = 1:1:size(allDistractionTimecodes, 2)
            startTime = allDistractionTimecodes{1, i};
            endTime = allDistractionTimecodes{2, i};
            positionRecord = theTrip.getDataOccurencesInTimeInterval('position_vehicule', startTime, endTime);
            positionValues = positionRecord.buildCellArrayWithVariables({'timecode' 'voie' 'cap degres' 'Sens'});
            laneExcursion = findLaneExcursions(positionValues);
            laneExcursionTotalTimes{i} = (sum(cell2mat(laneExcursion)) * 0.02);
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Distraction', 'total_lane_excursion_time',  {allDistractionTimecodes{1,:}; allDistractionTimecodes{2,:}; laneExcursionTotalTimes{:}})
    end
    delete(theTrip);
end