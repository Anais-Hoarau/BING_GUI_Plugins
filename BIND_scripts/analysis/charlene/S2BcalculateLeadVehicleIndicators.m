function S2BcalculateLeadVehicleIndicators(tripFile)
    import fr.lescot.bind.*;
    
    %B Do all the lead vehicle stuff
    theTrip = kernel.implementation.SQLiteTrip(tripFile, 0.01, false);
    %B.1
    %B.1 Get all the occurences
    allLeadVehiclesRecord = theTrip.getAllSituationOccurences('Lead_vehicle');
    allLeadVehicleTimecodes = allLeadVehiclesRecord.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
    if size(allLeadVehicleTimecodes, 2) > 0
        leadVehicleEvent  = allLeadVehiclesRecord.buildCellArrayWithVariables({'startTimecode' 'endTimecode' 'zone' 'event' 'lead_vehicle_id'});
        indicesDecisionZones = strcmpi('decision_zone',  leadVehicleEvent(3,:));
        decisionZones = leadVehicleEvent(:, indicesDecisionZones);
        indicesApproachZones = strcmpi('approach_zone',  leadVehicleEvent(3,:));
        decisionAndApproachZoneIndices = indicesDecisionZones | indicesApproachZones;
        decisionAndApproachZones = leadVehicleEvent(:, decisionAndApproachZoneIndices);

        allDynamicRecord = theTrip.getAllDataOccurences('dynamique_vehicule');
        allPositionRecord = theTrip.getAllDataOccurences('position_vehicule');

        %B.2 Add the destination variables

        speedStdDev = data.MetaSituationVariable();
        speedStdDev.setName('speed_stdDev');
        speedStdDev.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', speedStdDev)

        speedAverage = data.MetaSituationVariable();
        speedAverage.setName('speed_average');
        speedAverage.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', speedAverage)

        startZoneSpeed = data.MetaSituationVariable();
        startZoneSpeed.setName('speed_at_start_of_zone');
        startZoneSpeed.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', startZoneSpeed)

        endZoneSpeed = data.MetaSituationVariable();
        endZoneSpeed.setName('speed_at_end_of_zone');
        endZoneSpeed.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', endZoneSpeed)

        distanceStartZone = data.MetaSituationVariable();
        distanceStartZone.setName('distance_at_start_of_zone');
        distanceStartZone.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', distanceStartZone)

        gearSequence = data.MetaSituationVariable();
        gearSequence.setName('gear_sequence');
        gearSequence.setType(data.MetaSituationVariable.TYPE_TEXT);
        theTrip.addSituationVariable('Lead_vehicle', gearSequence)

        gearChanged = data.MetaSituationVariable();
        gearChanged.setName('gear_changed');
        gearChanged.setType(data.MetaSituationVariable.TYPE_TEXT);
        theTrip.addSituationVariable('Lead_vehicle', gearChanged)
        
        lanePositionStdDev = data.MetaSituationVariable();
        lanePositionStdDev.setName('lane_position_stdDev');
        lanePositionStdDev.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', lanePositionStdDev)

        lanePositionAverage = data.MetaSituationVariable();
        lanePositionAverage.setName('lane_position_average');
        lanePositionAverage.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', lanePositionAverage)

        headwayMinVariable = data.MetaSituationVariable();
        headwayMinVariable.setName('headway_minimum');
        headwayMinVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', headwayMinVariable);
        
        headwayMaxVariable = data.MetaSituationVariable();
        headwayMaxVariable.setName('headway_maximum');
        headwayMaxVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', headwayMaxVariable);

        headwayMeanVariable = data.MetaSituationVariable();
        headwayMeanVariable.setName('headway_average');
        headwayMeanVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', headwayMeanVariable);

        headwayStdDevVariable = data.MetaSituationVariable();
        headwayStdDevVariable.setName('headway_stdDev');
        headwayStdDevVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', headwayStdDevVariable);
        
        % BM: added maximum deceleration for LV events
        maximumOfDeceleration = data.MetaSituationVariable();
        maximumOfDeceleration.setName('maximum_deceleration');
        maximumOfDeceleration.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', maximumOfDeceleration);
        
        ttcMinVariable = data.MetaSituationVariable();
        ttcMinVariable.setName('ttc_minimum');
        ttcMinVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', ttcMinVariable);

        ttcMaxVariable = data.MetaSituationVariable();
        ttcMaxVariable.setName('ttc_maximum');
        ttcMaxVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', ttcMaxVariable);
        
        ttcMeanVariable = data.MetaSituationVariable();
        ttcMeanVariable.setName('ttc_average');
        ttcMeanVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', ttcMeanVariable);

        ttcStdDevVariable = data.MetaSituationVariable();
        ttcStdDevVariable.setName('ttc_stdDev');
        ttcStdDevVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', ttcStdDevVariable);

        reactionTimeVariable = data.MetaSituationVariable();
        reactionTimeVariable.setName('reaction_time');
        reactionTimeVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Lead_vehicle', reactionTimeVariable)

        %B.3.1 Calculate the standard deviation of the lane position
        laneSignal = allPositionRecord.buildCellArrayWithVariables({'timecode' 'voie'});
        sensSignal = allPositionRecord.buildCellArrayWithVariables({'sens'});
        % At this point, the laneSignal is positive if you drive in the
        % direct way of the road and negative otherwise. Therefore, we need
        % to check which is the driven direction. If it is 'Inverse', the
        % lane position should be multiplied by -1.
        sensInverse = strcmp('Inverse',sensSignal); % 0 si sens direct -1 si sens inverse
        directLaneSignal = cell2mat(laneSignal(2,:)) * 2 .*(0.5 - sensInverse); % Toujours positif si sur sa voie, négatif si roule à contre-sens (voie du trafic opposé)
        laneSignal(2,:) = num2cell(directLaneSignal);
        % ^^^^^^^^^^^^^ Now, laneSignal is always positive when driving on
        % your lane. And negative if you drive in the opposite traffic
        % lane. (This happens if you overtake, but also when you turn left
        % as the simulator consider at one point that you drive on the
        % opposite trafic lane of the road you're turning into.
        laneStdDev = processing.situationAggregators.StandardDeviation.process(allLeadVehicleTimecodes, laneSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'lane_position_stdDev', laneStdDev)
        laneAverage = processing.situationAggregators.Average.process(allLeadVehicleTimecodes, laneSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'lane_position_average', laneAverage)
        

        %B.3.2 Mean and stdDev of speed (m/s)
        speedSignal = allDynamicRecord.buildCellArrayWithVariables({'timecode' 'vitesse'});
        speedStdDev = processing.situationAggregators.StandardDeviation.process(allLeadVehicleTimecodes, speedSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'speed_stdDev', speedStdDev)
        speedAverage = processing.situationAggregators.Average.process(allLeadVehicleTimecodes, speedSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'speed_average', speedAverage)

        %B.3.3 Speed at entry and end of event zone
        startZoneSpeeds = cell(1, size(decisionZones, 2));
        decisionZoneSpeeds = cell(1, size(decisionZones, 2));
        for i = 1:1:size(decisionZones, 2)
            speedOnZoneRecord = theTrip.getDataVariableOccurencesInTimeInterval('dynamique_vehicule', 'vitesse', decisionZones{1, i}, decisionZones{2, i});
            speed = speedOnZoneRecord.buildCellArrayWithVariables({'vitesse'});
            startZoneSpeeds{i} = speed{1};
            decisionZoneSpeeds{i} = speed{end};
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'speed_at_start_of_zone',  {decisionZones{1,:}; decisionZones{2,:}; startZoneSpeeds{:}});
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'speed_at_end_of_zone',  {decisionZones{1,:}; decisionZones{2,:}; decisionZoneSpeeds{:}});

        distancesFromLV = cell(1, size(decisionZones, 2));

        %B.3.4 Distance (base on pks) between vp and lead vehicle at event time
        for i = 1:1:size(decisionZones, 2)  
            idLeadVehicle = decisionZones{5, i};
            lvPKRecord = theTrip.getDataOccurenceNearTime(idLeadVehicle, decisionZones{1, i});
            lv_PK = lvPKRecord.getVariableValues('pk');
            lv_PK = str2double(lv_PK{1});
            vpPKRecord = theTrip.getDataOccurenceNearTime('position_vehicule', decisionZones{1, i});
            vp_PK = vpPKRecord.getVariableValues('pk');
            vp_PK = vp_PK{1};

            distancesFromLV{i} = abs(lv_PK - vp_PK); 
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'distance_at_start_of_zone',  {decisionZones{1,:}; decisionZones{2,:}; distancesFromLV{:}});

        %B.3.5 Gear box sequence 
        gearSequences = cell(1, size(decisionAndApproachZones, 2));
        gearChanged = cell(1, size(decisionAndApproachZones, 2));
        for i = 1:1:size(decisionAndApproachZones, 2)
            gearSequence = '';
            gearsOnZoneRecord = theTrip.getDataVariableOccurencesInTimeInterval('commandes_vehicule', 'boite de vitesse', decisionAndApproachZones{1, i}, decisionAndApproachZones{2, i});
            gears = gearsOnZoneRecord.buildCellArrayWithVariables({'boite de vitesse'});
            for j = 2:1:length(gears)
                if gears{j} ~= gears{j - 1}
                    gearSequence = [gearSequence int2str(gears{j-1})];
                    if j == length(gears)
                        gearSequence = [gearSequence int2str(gears{j})];
                    end
                end
            end
            %For the case where the gear didn't change
            if isempty(gearSequence)
               gearSequence =  gears{1};
            end
            gearSequences{i} = gearSequence;
            if length(gearSequence) > 1
                gearChanged{i} = 'true';
            else
                gearChanged{i} = 'false';
            end
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'gear_sequence',  {decisionAndApproachZones{1,:}; decisionAndApproachZones{2,:}; gearSequences{:}});
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'gear_changed',  {decisionAndApproachZones{1,:}; decisionAndApproachZones{2,:}; gearChanged{:}});

        %B.3.6 Average / Min / stdDev "TIV" on the situations
        TIVSignal = allDynamicRecord.buildCellArrayWithVariables({'timecode' 'tiv'});            
        doubleTIVSignal = str2double(TIVSignal(2,:));
        minusOneIndexes = doubleTIVSignal < 0;
        TIVSignal(:, minusOneIndexes) = [];
        TIVStdDev = processing.situationAggregators.StandardDeviation.process(allLeadVehicleTimecodes, TIVSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'headway_stdDev', TIVStdDev)   
        TIVAverage = processing.situationAggregators.Average.process(allLeadVehicleTimecodes, TIVSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'headway_average', TIVAverage)
        TIVMini = processing.situationAggregators.Min.process(allLeadVehicleTimecodes, TIVSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'headway_minimum', TIVMini);
        TIVMaxi = processing.situationAggregators.Max.process(allLeadVehicleTimecodes, TIVSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'headway_maximum', TIVMaxi);
        
        %B.3.6 Average / Min / Max / stdDev "TTC" on the situations
        TTCSignal = allDynamicRecord.buildCellArrayWithVariables({'timecode' 'ttc'});   
        infiniIndexes = strcmp('infini', TTCSignal(2,:));
        TTCSignal(2, infiniIndexes) = {'-1'};
        doubleTTCSignal = str2double(TTCSignal(2,:));
        TTCSignal(2,:) = num2cell(doubleTTCSignal);
        minusOneIndexes = doubleTTCSignal < 0;
        TTCSignal(:, minusOneIndexes) = [];
        TTCStdDev = processing.situationAggregators.StandardDeviation.process(allLeadVehicleTimecodes, TTCSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'ttc_stdDev', TTCStdDev)   
        TTCAverage = processing.situationAggregators.Average.process(allLeadVehicleTimecodes, TTCSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'ttc_average', TTCAverage)
        TTCMini = processing.situationAggregators.Min.process(allLeadVehicleTimecodes, TTCSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'ttc_minimum', TTCMini);
        TTCMaxi = processing.situationAggregators.Max.process(allLeadVehicleTimecodes, TTCSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'ttc_maximum', TTCMaxi);
        
        %B.3.6 Reaction time : shortest time between pressing break pedal and
        %clutch pedal
        reactionTimes = cell(1, size(decisionZones, 2));
        for i = 1:1:size(decisionZones, 2)
            breakPedalRecordOnSituation = theTrip.getDataVariableOccurencesInTimeInterval('commandes_vehicule', 'frein', decisionZones{1, i}, decisionZones{2, i});
            breakPedal = breakPedalRecordOnSituation.buildCellArrayWithVariables({'timecode' 'frein'});
            clutchPedalRecordOnSituation = theTrip.getDataVariableOccurencesInTimeInterval('commandes_vehicule', 'embrayage', decisionZones{1, i}, decisionZones{2, i});
            clutchPedal = clutchPedalRecordOnSituation.buildCellArrayWithVariables({'timecode' 'embrayage'});

            %If we are in the case of a decision_zone, we check that the
            %previous value was différent of -1. If the previous value is not
            %-1, then we already had a reaction and we don't waste time to
            %calculate anything here...
                % BM: CODE INUTILE... RESTE D'UN COPIER-COLLER DEPUIS TL
                % EVENT ? >>>>>
                if strcmpi('G', decisionZones{5, i})%Green light case
                    reactionTimes{i} = -1;
                else
                % BM: FIN DU CODE INUTILE ?
                    firstBreakIndice = find(cell2mat(breakPedal(2,:)) > 20, 1, 'first');
                    if isempty(firstBreakIndice)
                        firstBreakTimecode =  Inf;
                    else
                        firstBreakTimecode = breakPedal{1, firstBreakIndice};
                    end

                    firstClutchIndice = find(cell2mat(clutchPedal(2,:)) > 20, 1, 'first');
                    if isempty(firstClutchIndice)
                        firstClutchTimecode =  Inf;
                    else
                        firstClutchTimecode = clutchPedal{1, firstClutchIndice};
                    end

                    reactionTimecode = min(firstBreakTimecode, firstClutchTimecode);
                    if reactionTimecode == Inf
                        reactionTimes{i} = -1;
                    else
                        reactionTimes{i} = reactionTimecode - decisionZones{1, i};
                    end
                end
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'reaction_time',  {decisionZones{1,:}; decisionZones{2,:}; reactionTimes{:}});
        
        %B.3.7 Maximum of deceleration (added by BM)
        maxDecelerations = cell(1, size(decisionZones, 2));
        for i = 1:1:size(decisionZones, 2)
            speedRecordOnSituation = theTrip.getDataVariableOccurencesInTimeInterval('dynamique_vehicule', 'vitesse', decisionZones{1, i}, decisionZones{2, i});
            speedSignal = speedRecordOnSituation.buildCellArrayWithVariables({'timecode', 'vitesse'});
            smoothedSpeedSignal = processing.signalProcessors.MovingAverage.process(speedSignal, 5);
            derivatedSignal =  processing.signalProcessors.Derivator.process(smoothedSpeedSignal, processing.signalProcessors.Derivator.MIDDLE);
            maxDecelerations{i} = min(cell2mat(derivatedSignal(2, :)));
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Lead_vehicle', 'maximum_deceleration',  {decisionZones{1,:}; decisionZones{2,:}; maxDecelerations{:}});
        
    end
    delete(theTrip);
end