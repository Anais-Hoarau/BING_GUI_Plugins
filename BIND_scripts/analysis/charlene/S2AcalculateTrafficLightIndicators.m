function S2AcalculateTrafficLightIndicators(tripFile)
    import fr.lescot.bind.*;

    theTrip = kernel.implementation.SQLiteTrip(tripFile, 0.01, false);
    
    %A. Do all the traffic light stuff
    %A.1. Get all the occurences
    allTrafficLightsRecord = theTrip.getAllSituationOccurences('Traffic_light');
    allTrafficLightsTimecodes = allTrafficLightsRecord.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
    if size(allTrafficLightsTimecodes, 2) > 0
        allDynamicRecord = theTrip.getAllDataOccurences('dynamique_vehicule');
        allPositionRecord = theTrip.getAllDataOccurences('position_vehicule');

        %A.2. Add the destination variables
        speedStdDev = data.MetaSituationVariable();
        speedStdDev.setName('speed_stdDev');
        speedStdDev.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Traffic_light', speedStdDev);

        speedAverage = data.MetaSituationVariable();
        speedAverage.setName('speed_average');
        speedAverage.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Traffic_light', speedAverage);

        distanceFromTLAtEvent = data.MetaSituationVariable();
        distanceFromTLAtEvent.setName('distance_from_TL_at_event');
        distanceFromTLAtEvent.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Traffic_light', distanceFromTLAtEvent);

        entrySpeedVariable = data.MetaSituationVariable();
        entrySpeedVariable.setName('speed_at_decision_zone_entry');
        entrySpeedVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Traffic_light', entrySpeedVariable);

        stopped = data.MetaSituationVariable();
        stopped.setName('stopped');
        stopped.setType(data.MetaSituationVariable.TYPE_TEXT);
        theTrip.addSituationVariable('Traffic_light', stopped);

        ranTrafficLight = data.MetaSituationVariable();
        ranTrafficLight.setName('ran_traffic_light');
        ranTrafficLight.setType(data.MetaSituationVariable.TYPE_TEXT);
        theTrip.addSituationVariable('Traffic_light', ranTrafficLight);

        maximumOfDeceleration = data.MetaSituationVariable();
        maximumOfDeceleration.setName('maximum_deceleration');
        maximumOfDeceleration.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Traffic_light', maximumOfDeceleration);

        reactionTimeVariable = data.MetaSituationVariable();
        reactionTimeVariable.setName('reaction_time');
        reactionTimeVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Traffic_light', reactionTimeVariable);

        lanePositionStdDev = data.MetaSituationVariable();
        lanePositionStdDev.setName('lane_position_stdDev');
        lanePositionStdDev.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Traffic_light', lanePositionStdDev);

        lanePositionAverage = data.MetaSituationVariable();
        lanePositionAverage.setName('lane_position_average');
        lanePositionAverage.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Traffic_light', lanePositionAverage);
        %A.3. Calculate the indicators

        %A.3.1 Calculate the standard deviation of the lane position
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
        laneStdDev = processing.situationAggregators.StandardDeviation.process(allTrafficLightsTimecodes, laneSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'lane_position_stdDev', laneStdDev)
        laneAverage = processing.situationAggregators.Average.process(allTrafficLightsTimecodes, laneSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'lane_position_average', laneAverage)


        %A.3.2 Mean and stdDev of speed (m/s)
        speedSignal = allDynamicRecord.buildCellArrayWithVariables({'timecode' 'vitesse'});
        speedStdDev = processing.situationAggregators.StandardDeviation.process(allTrafficLightsTimecodes, speedSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'speed_stdDev', speedStdDev)
        speedAverage = processing.situationAggregators.Average.process(allTrafficLightsTimecodes, speedSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'speed_average', speedAverage)

        %A.3.3 Distance from the traffic light when the even happenend (the
        %light changed color)
        trafficLightsEvents  = allTrafficLightsRecord.buildCellArrayWithVariables({'startTimecode' 'endTimecode' 'TL_pk' 'zone' 'event'});
        indicesDecisionZones = strcmpi('decision_zone',  trafficLightsEvents(4,:));
        decisionZones = trafficLightsEvents(:, indicesDecisionZones);
        distanceFromTL = cell(1, size(decisionZones, 2));
        for i = 1:1:size(decisionZones, 2)
            TL_pk = decisionZones{3, i};
            vpPKRecord = theTrip.getDataOccurenceNearTime('position_vehicule', decisionZones{1, i});
            vp_PK = vpPKRecord.getVariableValues('pk');
            vp_PK = vp_PK{1};
            distanceFromTL{i} = abs(TL_pk - vp_PK);
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'distance_from_TL_at_event',  {decisionZones{1,:}; decisionZones{2,:}; distanceFromTL{:}});

        %A.3.4 Speed at entry of decision zone
        entrySpeed = cell(1, size(decisionZones, 2));
        for i = 1:1:size(decisionZones, 2)
            vpSpeedRecord = theTrip.getDataOccurenceNearTime('dynamique_vehicule', decisionZones{1, i});
            vp_speed = vpSpeedRecord.getVariableValues('vitesse');
            vp_speed = vp_speed{1};
            entrySpeed{i} = vp_speed;
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'speed_at_decision_zone_entry',  {decisionZones{1,:}; decisionZones{2,:}; entrySpeed{:}});

        %A.3.5 Did the vehicle stopped in the zone ? Was the fire ran ?
        indicesIntermediateZones = strcmpi('intermediate_zone',  trafficLightsEvents(4,:));
        decisionAndIntermediateZoneIndices = indicesDecisionZones | indicesIntermediateZones;
        decisionAndIntermediateZones = trafficLightsEvents(:, decisionAndIntermediateZoneIndices);
        stoppedDuringZone = cell(1, size(decisionAndIntermediateZones, 2));
        ranTrafficLight = cell(1, size(decisionAndIntermediateZones, 2));
        for i = 1:1:size(decisionAndIntermediateZones, 2)
            % OLD CALCULATION BASED ON A SPEED MINIMUM... NOT CONVINCING!
            speedOnZoneRecord = theTrip.getDataVariableOccurencesInTimeInterval('dynamique_vehicule', 'vitesse', decisionAndIntermediateZones{1, i}, decisionAndIntermediateZones{2, i});
            speedOnZone = speedOnZoneRecord.getVariableValues('vitesse');
            if(min(cell2mat(speedOnZone)) <= 5)
               stoppedDuringZone{i} = 'true';
            else
                stoppedDuringZone{i} = 'false';
            end
            if strcmpi('decision_zone', decisionAndIntermediateZones{4, i})
               % driver stayed at least 7 sec in the decision zone,
               % knowing that the color of the TL in the decision zone
               % should be:
               % R: Red for 7 seconds
               % E: Amber for 3 seconds and Red for 7 seconds
               % H: Amber for 3 seconds and Red for 7 seconds
               if strcmpi('R', decisionAndIntermediateZones{5, i}) %Red light
                   if decisionAndIntermediateZones{2, i} - decisionAndIntermediateZones{1, i} < 7
                   % red = 7s
                       ranTrafficLight{i} = 'R';
                   else
                       ranTrafficLight{i} = 'G';
                   end
               elseif any(strcmpi({'E' 'H'}, decisionAndIntermediateZones{5, i})) %Amber easy or Amber Hard
                   if decisionAndIntermediateZones{2, i} - decisionAndIntermediateZones{1, i} < 3
                   % Amber = 3s
                       ranTrafficLight{i} = 'Y';
                   elseif decisionAndIntermediateZones{2, i} - decisionAndIntermediateZones{1, i} < 10
                   % Amber + Red = 10s
                       if decisionAndIntermediateZones{2, i} - decisionAndIntermediateZones{1, i} < 6
                       % Therefore, the test should be 3, not 6. However, in
                       % most TL E or H zone, a delay of was introduiced in the
                       % simulator scenario between the start of the decision
                       % zone and the end of the decision zone. Therefore, the
                       % end of the decision zone can't be know precisely if
                       % the driver cross the end of the decision zone before
                       % that delay. This delay varies accross the scenarios.
                       % Values vary from 3, 4 to 5.5 seconds for the amber
                       % easy condition and from 4 to 5 seconds for the amber
                       % hard condition. Therefore, a global estimate of 6
                       % seconds was defined
                           ranTrafficLight{i} = 'Y or R';
                       else
                           ranTrafficLight{i} = 'R';
                       end
                   else
                       ranTrafficLight{i} = 'G';
                   end
               else % Green
                   ranTrafficLight{i} = 'G';
               end
            else
                ranTrafficLight{i} = '0';
            end
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'stopped',  {decisionAndIntermediateZones{1,:}; decisionAndIntermediateZones{2,:}; stoppedDuringZone{:}});
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'ran_traffic_light',  {decisionAndIntermediateZones{1,:}; decisionAndIntermediateZones{2,:}; ranTrafficLight{:}});

        %A.3.6 Maximum of deceleration
        maxDecelerations = cell(1, size(decisionZones, 2));
        for i = 1:1:size(decisionZones, 2)
            speedRecordOnSituation = theTrip.getDataVariableOccurencesInTimeInterval('dynamique_vehicule', 'vitesse', decisionZones{1, i}, decisionZones{2, i});
            speedSignal = speedRecordOnSituation.buildCellArrayWithVariables({'timecode', 'vitesse'});
            smoothedSpeedSignal = processing.signalProcessors.MovingAverage.process(speedSignal, 5);
            derivatedSignal =  processing.signalProcessors.Derivator.process(smoothedSpeedSignal, processing.signalProcessors.Derivator.MIDDLE);
            maxDecelerations{i} = min(cell2mat(derivatedSignal(2, :)));
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'maximum_deceleration',  {decisionZones{1,:}; decisionZones{2,:}; maxDecelerations{:}});

        %A.3.7 Reaction time : shortest time between pressing break pedal and
        %clutch pedal
        reactionTimes = cell(1, size(decisionAndIntermediateZones, 2));
        for i = 1:1:size(decisionAndIntermediateZones, 2)
            breakPedalRecordOnSituation = theTrip.getDataVariableOccurencesInTimeInterval('commandes_vehicule', 'frein', decisionAndIntermediateZones{1, i}, decisionAndIntermediateZones{2, i});
            breakPedal = breakPedalRecordOnSituation.buildCellArrayWithVariables({'timecode' 'frein'});
            clutchPedalRecordOnSituation = theTrip.getDataVariableOccurencesInTimeInterval('commandes_vehicule', 'embrayage', decisionAndIntermediateZones{1, i}, decisionAndIntermediateZones{2, i});
            clutchPedal = clutchPedalRecordOnSituation.buildCellArrayWithVariables({'timecode' 'embrayage'});

            %If we are in the case of a decision_zone, we check that the
            %previous value was différent of -1. If the previous value is not
            %-1, then we already had a reaction and we don't waste time to
            %calculate anything here...
            if strcmpi('decision_zone', decisionAndIntermediateZones{4, i}) && i > 1 && reactionTimes{i - 1} ~= -1
                 reactionTimes{i} = -1;
            else
                if strcmpi('G', decisionAndIntermediateZones{5, i})%Green light case
                    reactionTimes{i} = -1;
                else
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
                        if strcmpi('decision_zone', decisionAndIntermediateZones{4, i})
                            reactionTimes{i} = reactionTimecode - decisionAndIntermediateZones{1, i - 1};%To measure from the start of the intermediate zone
                        else
                            reactionTimes{i} = reactionTimecode - decisionAndIntermediateZones{1, i};
                        end
                    end
                end
            end
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Traffic_light', 'reaction_time',  {decisionAndIntermediateZones{1,:}; decisionAndIntermediateZones{2,:}; reactionTimes{:}});
        delete(theTrip);
    end