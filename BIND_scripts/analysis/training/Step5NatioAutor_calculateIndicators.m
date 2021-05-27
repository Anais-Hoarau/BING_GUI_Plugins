function Step5NatioAutor_calculateIndicators(tripFile)
    tic;
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile, 0.04, false);

    varList = trip.getMetaInformations().getSituationVariablesNamesList('motos');
    if ~any(strcmpi(varList, 'car_speed_at_detection_kmh'))
        disp('Adding variables to the situation table');
        car_speed_at_detection  = fr.lescot.bind.data.MetaSituationVariable();
        car_speed_at_detection.setName('car_speed_at_detection_kmh');
        car_speed_at_detection.setType('REAL');
        trip.addSituationVariable('motos', car_speed_at_detection);
        moto_speed_at_detection  = fr.lescot.bind.data.MetaSituationVariable();
        moto_speed_at_detection.setName('moto_speed_at_detection_kmh');
        moto_speed_at_detection.setType('REAL');
        trip.addSituationVariable('motos', moto_speed_at_detection);
        detection_distance = fr.lescot.bind.data.MetaSituationVariable();
        detection_distance.setName('detection_distance_m');
        detection_distance.setType('REAL');
        trip.addSituationVariable('motos', detection_distance);
        car_speed_3sec_before_detection = fr.lescot.bind.data.MetaSituationVariable();
        car_speed_3sec_before_detection.setName('car_speed_3sec_before_detection_kmh');
        car_speed_3sec_before_detection.setType('REAL');
        trip.addSituationVariable('motos', car_speed_3sec_before_detection);
        car_speed_3sec_after_detection = fr.lescot.bind.data.MetaSituationVariable();
        car_speed_3sec_after_detection.setName('car_speed_3sec_after_detection_kmh');
        car_speed_3sec_after_detection.setType('REAL');
        trip.addSituationVariable('motos', car_speed_3sec_after_detection);
        car_lane_position_3sec_before_detection = fr.lescot.bind.data.MetaSituationVariable();
        car_lane_position_3sec_before_detection.setName('car_lane_position_3sec_before_detection');
        car_lane_position_3sec_before_detection.setType('REAL');
        trip.addSituationVariable('motos', car_lane_position_3sec_before_detection);
        car_lane_position_3sec_after_detection = fr.lescot.bind.data.MetaSituationVariable();
        car_lane_position_3sec_after_detection.setName('car_lane_position_3sec_after_detection');
        car_lane_position_3sec_after_detection.setType('REAL');
        trip.addSituationVariable('motos', car_lane_position_3sec_after_detection);
        is_break_used_within_3sec_of_detection = fr.lescot.bind.data.MetaSituationVariable();
        is_break_used_within_3sec_of_detection.setName('is_break_used_within_3sec_of_detection');
        is_break_used_within_3sec_of_detection.setType('REAL');
        trip.addSituationVariable('motos', is_break_used_within_3sec_of_detection);
    end
    disp('Calculating detection time for each motorcycle');

    situationRecord = trip.getAllSituationOccurences('motos');
    motos = situationRecord.getVariableValues('vehicle');
    startTimes = situationRecord.getVariableValues('startTimecode');
    endTimes = situationRecord.getVariableValues('endTimecode');

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

        dDetections = [];
        tDetections = [];
        disp('--> Calculating distances (in meters)...');
        for j = 1:1:length(xMoto)
           distances{j} = sqrt((xMoto{j} - xCar{j})^2 + (yMoto{j} - yCar{j})^2 + ( zMoto{j} - zCar{j})^2 )/1000;
        end

        %Adding a sign to distance
        signedDistancesAsMat = sign_distance(cell2mat(distances));

        for j = 1:1:length(indics)
            if isHeadlights(indics{j})
                tDetections(end + 1) = timecodes{j};
                dDetections(end + 1) = signedDistancesAsMat(j);
                disp(['--> Detection detected at ' num2str(tDetections(end)) 's / ' sprintf('%.1f', dDetections(end)) 'm']);
            end
        end

        %Finding the closest detection
        isDetectionFound = false;
        if ~isempty(dDetections)
            [~, indiceDistanceMin] = min(abs(dDetections));
            tDetection = tDetections(indiceDistanceMin);
            dDetection = dDetections(indiceDistanceMin);
            disp(['--> Detection kept at ' num2str(tDetection) 's / ' sprintf('%.1f', dDetection) 'm']);
            isDetectionFound = true;
        else
            disp('--> No detections found !!!');
        end

        if isDetectionFound
            value = trip.getDataOccurenceNearTime('vehicule' , tDetection).getVariableValues('vitesse');
            value = value{1} * 3.6;
            trip.setSituationVariableAtTime('motos', 'car_speed_at_detection_kmh', startTime,	endTime, value);

            value = trip.getDataOccurenceNearTime(moto , tDetection).getVariableValues('vitesse');
            value = value{1} * 3.6;
            trip.setSituationVariableAtTime('motos', 'moto_speed_at_detection_kmh', startTime,	endTime, value);

            trip.setSituationVariableAtTime('motos', 'detection_distance_m', startTime,	endTime, dDetection);

            value = trip.getDataOccurenceNearTime('vehicule' , tDetection - 3).getVariableValues('vitesse');
            value = value{1} * 3.6;
            trip.setSituationVariableAtTime('motos', 'car_speed_3sec_before_detection_kmh', startTime,	endTime, value);

            value = trip.getDataOccurenceNearTime('vehicule' , tDetection + 3).getVariableValues('vitesse');
            value = value{1} * 3.6;
            trip.setSituationVariableAtTime('motos', 'car_speed_3sec_after_detection_kmh', startTime,	endTime, value);

            value = trip.getDataOccurenceNearTime('trajectoire' , tDetection - 3).getVariableValues('voie');
            value = value{1};
            trip.setSituationVariableAtTime('motos', 'car_lane_position_3sec_before_detection', startTime,	endTime, value);

            value = trip.getDataOccurenceNearTime('trajectoire' , tDetection + 3).getVariableValues('voie');
            value = value{1};
            trip.setSituationVariableAtTime('motos', 'car_lane_position_3sec_after_detection', startTime,	endTime, value);

            indics = trip.getDataVariableOccurencesInTimeInterval('vehicule', 'indics', tDetection, tDetection + 3).getVariableValues('indics');
            brake_used = false;
            for j = 1:1:length(indics)
                if isStoplights(indics{j})
                    brake_used = true;
                end
            end
        else
            trip.setSituationVariableAtTime('motos', 'car_speed_at_detection_kmh', startTime,	endTime, NaN);
            trip.setSituationVariableAtTime('motos', 'moto_speed_at_detection_kmh', startTime,	endTime, NaN);
            trip.setSituationVariableAtTime('motos', 'detection_distance_m', startTime,	endTime, NaN);
            trip.setSituationVariableAtTime('motos', 'car_speed_3sec_before_detection_kmh', startTime,	endTime, NaN);
            trip.setSituationVariableAtTime('motos', 'car_speed_3sec_after_detection_kmh', startTime,	endTime, NaN);
            trip.setSituationVariableAtTime('motos', 'car_lane_position_3sec_before_detection', startTime,	endTime, NaN);
            trip.setSituationVariableAtTime('motos', 'car_lane_position_3sec_after_detection', startTime,	endTime, NaN);
            trip.setSituationVariableAtTime('motos', 'is_break_used_within_3sec_of_detection', startTime, endTime, NaN);
        end
    end

    %Closing the trip
    disp('Closing trip...');
    delete(trip);
    %Display execution time
    elapsedTime = toc;
    disp(['Detection times found in ' num2str(toc) ' seconds']);
end