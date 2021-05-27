function S2CcalculateGapAcceptanceIndicators(tripFile, version)
    import fr.lescot.bind.*;
    
    %Conversion tables from gap ordinality to gap size. Do not delete, they
    %are used via an eval call, and that's why they are marked as unused.
    AGA01 = {1 3 5 2 4 2 3 5 4 1 3 5 1 2 4}; %#ok<*NASGU>
    AGA02 = {3 2 1 5 4 1 3 5 2 4 5 2 1 3 4};
    AGA03 = {5 1 4 2 3 4 2 1 5 3 4 2 5 3 1};
    AGA04 = {2 5 3 1 4 5 2 1 3 4 1 2 4 5 3};
    AGA05 = {4 1 2 5 3 4 3 1 2 5 4 3 1 2 5};
    AGA06 = {3 5 4 2 1 5 1 4 3 2 4 1 3 5 2};
    AGA07 = {4 3 1 2 5 3 5 4 2 1 4 5 1 2 3};
    AGA08 = {5 1 4 3 2 4 1 2 5 3 1 4 5 3 2};
    AGA09 = {2 3 5 4 1 2 5 3 1 4 3 2 4 1 5};
    AGA10 = {4 2 1 5 3 5 1 4 2 3 4 2 5 3 1};

    BGA01 = {2 3 5 4 1 3 5 1 2 4 1 3 5 2 4};
    BGA02 = {1 3 5 2 4 5 2 1 3 4 3 2 1 5 4};
    BGA03 = {4 2 1 5 3 4 2 5 3 1 5 1 4 2 3};
    BGA04 = {5 2 1 3 4 1 2 4 5 3 2 5 3 1 4};
    BGA05 = {4 3 1 2 5 4 3 1 2 5 4 1 2 5 3};
    BGA06 = {5 1 4 3 2 4 1 3 5 2 3 5 4 2 1};
    BGA07 = {3 5 4 2 1 4 5 1 2 3 4 3 1 2 5};
    BGA08 = {4 1 2 5 3 1 4 5 3 2 5 1 4 3 2};
    BGA09 = {2 5 3 1 4 3 2 4 1 5 2 3 5 4 1};
    BGA10 = {5 1 4 2 3 4 2 5 3 1 4 2 1 5 3};

    CGA01 = {3 5 1 2 4 1 3 5 2 4 2 3 5 4 1};
    CGA02 = {5 2 1 3 4 3 2 1 5 4 1 3 5 2 4};
    CGA03 = {4 2 5 3 1 5 1 4 2 3 4 2 1 5 3};
    CGA04 = {1 2 4 5 3 2 5 3 1 4 5 2 1 3 4};
    CGA05 = {4 3 1 2 5 4 1 2 5 3 4 3 1 2 5};
    CGA06 = {4 1 3 5 2 3 5 4 2 1 5 1 4 3 2};
    CGA07 = {4 5 1 2 3 4 3 1 2 5 3 5 4 2 1};
    CGA08 = {1 4 5 3 2 5 1 4 3 2 4 1 2 5 3};
    CGA09 = {3 2 4 1 5 2 3 5 4 1 2 5 3 1 4};
    CGA10 = {4 2 5 3 1 4 2 1 5 3 5 1 4 2 3};


    %Creating the ordinality to gap size conversion arrays
    
    %C. Do all the gap acceptance stuff
    theTrip = kernel.implementation.SQLiteTrip(tripFile, 0.01, false);
    %C.1. Get all the occurences
    allGapAcceptanceRecord = theTrip.getAllSituationOccurences('Gap_acceptance');
    allGapAcceptanceTimecodes = allGapAcceptanceRecord.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
    if size(allGapAcceptanceTimecodes, 2) > 0
        allDynamicRecord = theTrip.getAllDataOccurences('dynamique_vehicule');
        allPositionRecord = theTrip.getAllDataOccurences('position_vehicule');

        gapAcceptanceEvents  = allGapAcceptanceRecord.buildCellArrayWithVariables({'startTimecode' 'endTimecode' 'zone' 'event' 'scenarioID'});
        indicesDecisionZones = strcmpi('decision_zone',  gapAcceptanceEvents(3,:));
        decisionZones = gapAcceptanceEvents(:, indicesDecisionZones);

        speedStdDev = data.MetaSituationVariable();
        speedStdDev.setName('speed_stdDev');
        speedStdDev.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Gap_acceptance', speedStdDev);

        speedAverage = data.MetaSituationVariable();
        speedAverage.setName('speed_average');
        speedAverage.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Gap_acceptance', speedAverage);

        stoppedVariable = data.MetaSituationVariable();
        stoppedVariable.setName('stopped');
        stoppedVariable.setType(data.MetaSituationVariable.TYPE_TEXT);
        theTrip.addSituationVariable('Gap_acceptance', stoppedVariable);

        stopPKVariable = data.MetaSituationVariable();
        stopPKVariable.setName('stop_pk');
        stopPKVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Gap_acceptance', stopPKVariable);

        chosenGapVariable = data.MetaSituationVariable();
        chosenGapVariable.setName('chosen_gap_size');
        chosenGapVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Gap_acceptance', chosenGapVariable);

        rejectedGapsVariable = data.MetaSituationVariable();
        rejectedGapsVariable.setName('rejected_gaps');
        rejectedGapsVariable.setType(data.MetaSituationVariable.TYPE_TEXT);
        theTrip.addSituationVariable('Gap_acceptance', rejectedGapsVariable);
        
        maxProposedGapsVariable = data.MetaSituationVariable();
        maxProposedGapsVariable.setName('max_proposed_gap');
        maxProposedGapsVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Gap_acceptance', maxProposedGapsVariable);
        
        gapBigVariable = data.MetaSituationVariable();
        gapBigVariable.setName('GapBig');
        gapBigVariable.setType(data.MetaSituationVariable.TYPE_TEXT);
        theTrip.addSituationVariable('Gap_acceptance', gapBigVariable);

        numberOfDiscardedCarsVariable = data.MetaSituationVariable();
        numberOfDiscardedCarsVariable.setName('number_of_discarded_cars');
        numberOfDiscardedCarsVariable.setType(data.MetaSituationVariable.TYPE_REAL);
        theTrip.addSituationVariable('Gap_acceptance', numberOfDiscardedCarsVariable);

        %C.3.2 Mean and stdDev of speed (m/s)
        speedSignal = allDynamicRecord.buildCellArrayWithVariables({'timecode' 'vitesse'});
        speedStdDev = processing.situationAggregators.StandardDeviation.process(allGapAcceptanceTimecodes, speedSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'speed_stdDev', speedStdDev)
        speedAverage = processing.situationAggregators.Average.process(allGapAcceptanceTimecodes, speedSignal);
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'speed_average', speedAverage)

        %C.3.3 Did the vehicle stop during the event ? And if yes, at which pk
        stopped = cell(1, size(decisionZones, 2));
        stopPKs = cell(1, size(decisionZones, 2));
        for i = 1:1:size(decisionZones, 2)
            speedRecordOnZone = theTrip.getDataVariableOccurencesInTimeInterval('dynamique_vehicule', 'vitesse', decisionZones{1, i}, decisionZones{2, i});
            speedOnZone = speedRecordOnZone.buildCellArrayWithVariables({'timecode' 'vitesse'});
            [minSpeed, minSpeedIndice] = min(cell2mat(speedOnZone(2, :)));
            if minSpeed == 0
                stopped{i} = 'true';
                stopPKRecord = theTrip.getDataOccurenceNearTime('position_vehicule', speedOnZone{1, minSpeedIndice});
                stopPK = stopPKRecord.getVariableValues('pk');
                stopPK = stopPK{1};
                stopPKs{i} = stopPK;
            else
                stopped{i} = 'false';
                stopPKs{i} = 0;
            end
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'stopped', {decisionZones{1,:}; decisionZones{2,:}; stopped{:}})
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'stop_pk', {decisionZones{1,:}; decisionZones{2,:}; stopPKs{:}})

        %C.3.4 Ok, let's try to determine those gaps...
        chosenGaps = cell(1, size(decisionZones, 2));
        numbersOfDiscardedCars = cell(1, size(decisionZones, 2));
        sequencesOfRejectedGaps = cell(1, size(decisionZones, 2));
        maxProposedGap = cell(1, size(decisionZones, 2));
        gapBig = cell(1, size(decisionZones, 2));
        for i = 1:1:size(decisionZones, 2)
            %First step, we find the pk on the zone at which vp changed of
            %road.
            positionRecord = theTrip.getDataOccurencesInTimeInterval('position_vehicule', decisionZones{1, i}, decisionZones{2, i});
            routes = positionRecord.buildCellArrayWithVariables({'route'});
            positions = positionRecord.buildCellArrayWithVariables({'pk'});
            timecodes = positionRecord.buildCellArrayWithVariables({'timecode'});
            sensArray = positionRecord.buildCellArrayWithVariables({'sens'});
            indexChange = -1;
            for j = 2:1:length(routes)
                if str2double(routes{j}) ~= str2double(routes{j - 1})
                   indexChange = j-1;%Vraiment pas compris pourquoi le -1, mais ca à l'air de marcher...
                   % BM: C'est parce que tu te sers du pk plus tard... Et tu
                   % veux que le pk soit celui de la route initiale (d'où les voitures viennent),
                   % pas celui de la route sur laquelle tu tournes.
                   break;
                end
            end
            timeCodeChange = timecodes{indexChange};
            pkChange = positions{indexChange};
            routeChange = routes{indexChange}; % BM: nécessaire pour savoir si les autres véhicules sont encore sur la même route.

            if strcmp('Direct', sensArray{1})%Un peu comme pour le -1 au dessus. y'a l'air d'avoir un pb dans la synchro de certaines lignes dans les données simu, qui fait que tout change pas d'étât au même moment.
                sens = -1; % BM: bizarre, j'aurais mis 1 si c'est direct et -1 sinon...
            else
                sens = 1;
            end

            % Now we're going to calculate the distance between the VP and all
            % the vehicles of the gaps (and the first dummy vehicle)
            scenarioID = decisionZones{5, i};
            scenarioNumber = str2double(scenarioID(end-1:end));
            vehiclesList = {'-1003' '-120' '-121' '-122' '-123' '-124' '-125' '-126' '-127' '-128' '-129' '-130' '-131' '-132' '-133' '-134'};
            distances = cell(1, length(vehiclesList));
            %disp('New gap acceptance');
            for j = 1:1:length(vehiclesList)
                 % BM: Hypothèse 1: tous les véhicules proviennent de la
                 % même route => on peut se baser sur le pk pour calculer
                 % la distance
                 % BM: Hypothèse 2: les véhicules qui ont quitté la route
                 % ont déjà franchi l'intersection => on peut leur
                 % attribuer une distance négative
                 gapVehiclesPositionRecord = theTrip.getDataOccurenceNearTime(vehiclesList{j}, timeCodeChange);
                 gapVehiclesRoutes = gapVehiclesPositionRecord.buildCellArrayWithVariables({'route'});
                 gapVehiclesPKs = gapVehiclesPositionRecord.buildCellArrayWithVariables({'pk'});
                 if gapVehiclesRoutes{1} == str2num(routeChange) % BM: Véhicule toujours sur la même route
                     distances{j} =  sens * (pkChange - gapVehiclesPKs{1}); % BM: On calcule la distance réelle
                     %disp(['Vehicule at ' num2str(distances{j})]);
                 else % BM: Le véhicule a déjà franchi l'intersection et a changé de route => on ne peut plus se baser sur le PK pour calculer la distance.
                     %disp('Vehicule in another route');
                     distances{j} = -99999; % BM: Distance négative arbitraire pour dire que le véhicule est déjà passé
                 end
            end

            %Review the distances. Where distance
            %goes from negative to positive, here we have our gap. The value
            %returned is the ordinality of the gap.
            gapOrdinality = -1000;
            if all(cell2mat(distances) > 0)
                gapOrdinality = -1;%The driver passed before everybody
            elseif all(cell2mat(distances) < 0)
                gapOrdinality = -999;%The driver passed after everybody    
            else
                for j = 2:1:length(distances)
                    if distances{j} > 0 && distances{j - 1} <= 0 % BM: bogue dans le cas où distances{end} == 0.
                       gapOrdinality = j - 1;
                       break;
                    end
                end
            end

            if gapOrdinality == -1
                gapChosen = -1;
            elseif gapOrdinality == -999
                gapChosen = -999;
            else 
                gapChosen = eval([num2str(version) scenarioID '{' num2str(gapOrdinality) '};']);
            end
            disp(['ordinality : ' num2str(gapOrdinality) ' --> ' num2str(gapChosen)]);
            chosenGaps{i} = gapChosen;
            if gapOrdinality == -1
                sequencesOfRejectedGaps{i} = -1;
                numbersOfDiscardedCars{i} = 0;
            elseif gapOrdinality == -999
                sequencesOfRejectedGaps{i} = eval(['num2str(cell2mat(' num2str(version) scenarioID '(1:end)));']);
                numbersOfDiscardedCars{i} = length(eval([num2str(version) scenarioID]));
            else
                sequencesOfRejectedGaps{i} = eval(['num2str(cell2mat(' num2str(version) scenarioID '(1:' num2str(gapOrdinality - 1) ')));']);
                numbersOfDiscardedCars{i} = gapOrdinality;
            end
   
            if gapOrdinality ~= -1
                maxProposedGap{i} = max([gapChosen eval([ '[' sequencesOfRejectedGaps{i} ']' ]) ]);
                if gapChosen == maxProposedGap{i}
                    gapBig{i} = 'equal';
                elseif gapChosen < maxProposedGap{i}
                    gapBig{i} = 'true';
                end
            else
                gapBig{i} = 'undef';
            end
        end
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'chosen_gap_size', {decisionZones{1,:}; decisionZones{2,:}; chosenGaps{:}});
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'rejected_gaps', {decisionZones{1,:}; decisionZones{2,:}; sequencesOfRejectedGaps{:}});
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'max_proposed_gap', {decisionZones{1,:}; decisionZones{2,:}; maxProposedGap{:}});
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'number_of_discarded_cars', {decisionZones{1,:}; decisionZones{2,:}; numbersOfDiscardedCars{:}});
        theTrip.setBatchOfTimeSituationVariableTriplets('Gap_acceptance', 'GapBig', {decisionZones{1,:}; decisionZones{2,:}; gapBig{:}});
    end
    delete(theTrip);
end