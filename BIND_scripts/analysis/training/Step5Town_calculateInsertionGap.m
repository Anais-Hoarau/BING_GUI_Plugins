function Step5Town_calculateInsertionGap(tripFile)
    tic;
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile, 0.04, false);

    disp('Adding variables to the situation table');
    first_moto_gap_acceptance_m  = fr.lescot.bind.data.MetaSituationVariable();
    first_moto_gap_acceptance_m.setName('first_moto_gap_acceptance_m');
    first_moto_gap_acceptance_m.setType('REAL');
    trip.addSituationVariable('motos', first_moto_gap_acceptance_m);

    second_moto_insertion_gap_m = fr.lescot.bind.data.MetaSituationVariable();
    second_moto_insertion_gap_m.setName('second_moto_insertion_gap_m');
    second_moto_insertion_gap_m.setType('REAL');
    trip.addSituationVariable('motos', second_moto_insertion_gap_m);

    second_moto_min_distance_m = fr.lescot.bind.data.MetaSituationVariable();
    second_moto_min_distance_m.setName('second_moto_min_distance_m');
    second_moto_min_distance_m.setType('REAL');
    trip.addSituationVariable('motos', second_moto_min_distance_m);

    disp('Calculating distance to shortest accepted insertion before first moto');

    situationRecord = trip.getAllSituationOccurences('motos');
    motos = situationRecord.getVariableValues('vehicle');
    startTimes = situationRecord.getVariableValues('startTimecode');
    endTimes = situationRecord.getVariableValues('endTimecode');

    %filtering motos to get only the first one of each situation
    indicesToRemove = [];
    for i = 1:1:length(motos) 
        regexp(motos{i}, '^Moto\d{1}\.1$', 'match');
        if isempty(regexp(motos{i}, '^Moto\d{1}\.1$', 'match'))
            indicesToRemove(end + 1) = i;
        end
    end
    motos(indicesToRemove) = [];
    startTimes(indicesToRemove) = [];
    endTimes(indicesToRemove) = [];

    for i = 1:1:length(motos)
        moto = motos{i};
        startTime = startTimes{i};
        endTime = endTimes{i};

        disp(['Calculating for vehicle ' moto '[ ' num2str(startTime) ' ; ' num2str(endTime) ' ]']);

        xMoto = trip.getDataVariableOccurencesInTimeInterval(moto, 'X', startTime, endTime).getVariableValues('X');
        yMoto = trip.getDataVariableOccurencesInTimeInterval(moto, 'Y', startTime, endTime).getVariableValues('Y');
        zMoto = trip.getDataVariableOccurencesInTimeInterval(moto, 'Z', startTime, endTime).getVariableValues('Z');

        xCar = trip.getDataVariableOccurencesInTimeInterval('localisation', 'X', startTime, endTime).getVariableValues('X');
        yCar = trip.getDataVariableOccurencesInTimeInterval('localisation', 'Y', startTime, endTime).getVariableValues('Y');
        zCar = trip.getDataVariableOccurencesInTimeInterval('localisation', 'Z', startTime, endTime).getVariableValues('Z');

        timecodes = trip.getDataVariableOccurencesInTimeInterval(moto, 'timecode', startTime, endTime).getVariableValues('timecode');

        indics = trip.getDataVariableOccurencesInTimeInterval('vehicule', 'indics', startTime, endTime).getVariableValues('indics');

        distances = cell(1, length(xMoto));

        dHeadlights = [];
        tHeadlights = [];
        disp('--> Calculating distances (in meters)...');
        for j = 1:1:length(xMoto)
           distances{j} = euclidian_distance(xMoto{j}, yMoto{j}, zMoto{j}, xCar{j},  yCar{j}, zCar{j}) / 1000;
        end

        %Adding a sign to distance
        signedDistancesAsMat = sign_distance(cell2mat(distances));

        for j = 1:1:length(indics)
            if isHeadlights(indics{j}) &&  signedDistancesAsMat(j) >= 0
                tHeadlights(end + 1) = timecodes{j};
                dHeadlights(end + 1) = signedDistancesAsMat(j);
                disp(['--> Headlights detected at ' num2str(tHeadlights(end)) 's / ' sprintf('%.1f', dHeadlights(end)) 'm']);
            end
        end

        %Finding the closest detection
        isDetectionFound = false;
        if ~isempty(dHeadlights)
            [~, indiceDistanceMin] = min(dHeadlights);
            tHeadlight = tHeadlights(indiceDistanceMin);
            dHeadlight = dHeadlights(indiceDistanceMin);
            disp(['--> Headlights kept at ' num2str(tHeadlight) 's / ' sprintf('%.1f', dHeadlight) 'm']);
            isDetectionFound = true;
        else
            disp('--> No headlights found !!!');
        end

        if isDetectionFound
            trip.setSituationVariableAtTime('motos', 'first_moto_gap_acceptance_m', startTime,	endTime, dHeadlight);
        else
            trip.setSituationVariableAtTime('motos', 'first_moto_gap_acceptance_m', startTime,	endTime, NaN);
        end
    %     figure('Name', moto);
    %     plotHandler = plot(cell2mat(timecodes), signedDistancesAsMat);
    %     if ~isempty(dHeadlights)
    %         hold on;
    %         yLims = get(gca, 'YLim');
    %         yMax = yLims(2);
    %         stem(tHeadlight, yMax, 'color', 'r', 'marker', 'v', 'MarkerFaceColor', 'r');
    %     end
    %     hold off;
    end
    %##########################################################################
    disp('Calculating distance to insertion before the second moto (excepted for moto 5.2');
    situationRecord = trip.getAllSituationOccurences('motos');
    motos = situationRecord.getVariableValues('vehicle');
    startTimes = situationRecord.getVariableValues('startTimecode');
    endTimes = situationRecord.getVariableValues('endTimecode');

    %filtering motos to get only the second one of each situation, excepted
    %5.2
    indicesToRemove = [];
    for i = 1:1:length(motos)
        if isempty(regexp(motos{i}, '^Moto\d{1}\.2$', 'match')) || strcmp('Moto5.2', motos{i})
            indicesToRemove(end + 1) = i;
        end
    end
    motos(indicesToRemove) = [];
    startTimes(indicesToRemove) = [];
    endTimes(indicesToRemove) = [];

    for i = 1:1:length(motos)
        moto = motos{i};
        startTime = startTimes{i};
        endTime = endTimes{i};

        disp(['Calculating for vehicle ' moto '[ ' num2str(startTime) ' ; ' num2str(endTime) ' ]']);

        vehicleData = trip.getDataOccurencesInTimeInterval('vehicule', startTime, endTime);
        timecodes  = cell2mat(vehicleData.getVariableValues('timecode'));
        vitesseMS = vehicleData.getVariableValues('vitesse');
        vitesseKMH = cell2mat(vitesseMS).*3.6;

        aberrantPointsIndices = find(vitesseKMH == 0);
        vitesseKMH(aberrantPointsIndices) = [];
        timecodes(aberrantPointsIndices) = [];

        smoothedSignal = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process(num2cell([timecodes; vitesseKMH]), {'7'});%{'31'});

        smoothedSpeed = smoothedSignal(2, :);

        %crazy classifier of doom !
        for j = 1:1:length(smoothedSpeed)
            speed = smoothedSpeed{j};
            classSize = 5;
            smoothedSpeed{j} = round(speed/classSize)*classSize + classSize/2;
        end
        smoothedTimecodes = smoothedSignal(1, :);

        %Dectecting restart :
        %speed @ t < threshold
        %speed @t+1 >= threshold
        threshold = 5;
        indexRestarts = [];
        isRestartFound = false;
        for j = 1:1:length(smoothedSpeed)-1
            if smoothedSpeed{j} < threshold && smoothedSpeed {j+1} >= threshold
                indexRestarts(end + 1) = j;
                disp(['--> Restart detected at ' num2str(smoothedTimecodes{indexRestarts(end)})]);
                isRestartFound = true;
            end
        end


        if ~isempty(indexRestarts)
            if length(indexRestarts) > 1
                disp('Warning, several restarts detected, we''ll keep only the first one !');
            end
            indexRestart = indexRestarts(1);
            timecodeRestart = smoothedTimecodes{indexRestart};
            indexRestart = indexRestarts(1);
            motoOccurence = trip.getDataOccurenceAtTime(moto,timecodeRestart);
            xMoto = motoOccurence.getVariableValues('X');
            xMoto = xMoto{1};
            yMoto = motoOccurence.getVariableValues('Y');
            yMoto = yMoto{1};
            zMoto = motoOccurence.getVariableValues('Z');
            zMoto = zMoto{1};

            carOccurence = trip.getDataOccurenceAtTime('localisation',timecodeRestart);
            xCar = carOccurence.getVariableValues('X');
            xCar = xCar{1};
            yCar = carOccurence.getVariableValues('Y');
            yCar = yCar{1};
            zCar = carOccurence.getVariableValues('Z');
            zCar = zCar{1};
            distanceAtRestart = euclidian_distance(xMoto, yMoto, zMoto, xCar,  yCar, zCar) / 1000;
            disp(['Distance at restart : ' num2str(distanceAtRestart) 'm']);
        end

        timecodeRestart = smoothedTimecodes{indexRestart};

        if isRestartFound
            trip.setSituationVariableAtTime('motos', 'second_moto_insertion_gap_m', startTime,	endTime, distanceAtRestart);
        else
            trip.setSituationVariableAtTime('motos', 'second_moto_insertion_gap_m', startTime,	endTime, NaN);
        end

        %Now, we will calculate the minimum of distance between the vp and the
        %moto 2. Please don't ask why...
        xMoto = trip.getDataVariableOccurencesInTimeInterval(moto, 'X', startTime, endTime).getVariableValues('X');
        yMoto = trip.getDataVariableOccurencesInTimeInterval(moto, 'Y', startTime, endTime).getVariableValues('Y');
        zMoto = trip.getDataVariableOccurencesInTimeInterval(moto, 'Z', startTime, endTime).getVariableValues('Z');

        xCar = trip.getDataVariableOccurencesInTimeInterval('localisation', 'X', startTime, endTime).getVariableValues('X');
        yCar = trip.getDataVariableOccurencesInTimeInterval('localisation', 'Y', startTime, endTime).getVariableValues('Y');
        zCar = trip.getDataVariableOccurencesInTimeInterval('localisation', 'Z', startTime, endTime).getVariableValues('Z');

        timecodes = trip.getDataVariableOccurencesInTimeInterval(moto, 'timecode', startTime, endTime).getVariableValues('timecode');

        indics = trip.getDataVariableOccurencesInTimeInterval('vehicule', 'indics', startTime, endTime).getVariableValues('indics');

        distances = cell(1, length(xMoto));

        dDetections = [];
        tDetections = [];
        disp('--> Calculating all distances (in meters)...');
        for j = 1:1:length(xMoto)
           distances{j} = sqrt((xMoto{j} - xCar{j})^2 + (yMoto{j} - yCar{j})^2 + ( zMoto{j} - zCar{j})^2 )/1000;
        end
        minDistance = num2str(min(cell2mat(distances)));
        disp(['--> Min of distances is : ' minDistance 'm']);
        trip.setSituationVariableAtTime('motos', 'second_moto_min_distance_m', startTime,	endTime, minDistance);
    %##########################################################################

    end
    %Closing the trip
    disp('Closing trip...');
    delete(trip);
    %Display execution time
    elapsedTime = toc;
    disp(['Detection times found in ' num2str(toc) ' seconds']);
end
