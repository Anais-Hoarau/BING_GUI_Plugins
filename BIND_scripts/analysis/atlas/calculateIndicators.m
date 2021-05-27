function calculateIndicators(tripPath)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripPath, 0.04, false);
    
    %On récupère la liste des situations
    situationOccurences = trip.getAllSituationOccurences('Sections');
    
    startTimes = situationOccurences.getVariableValues('startTimecode');
    endTimes = situationOccurences.getVariableValues('endTimecode');
    types = situationOccurences.getVariableValues('type');
    
    for i = 1:1:length(startTimes)
        startTime = startTimes{i};
        endTime = endTimes{i};
        type = types{i};
        switch(type)
            case 'demarrage'
                %rien
            case 'depassement'
                %rien
            case 'conduite monotone 130'
                addSpeedMeanDeviationToPrescription(trip, startTime, endTime, 130);
                addSpeedJerk(trip, startTime, endTime);
            case 'conduite monotone 110'
                addSpeedMeanDeviationToPrescription(trip, startTime, endTime, 110);
                addSpeedJerk(trip, startTime, endTime);
            case {'panneau bleu' 'panneau rouge'}
                addSpeedJerk(trip, startTime, endTime);
                addLanePositionStdDev(trip, startTime, endTime);
            case 'arret soudain'
                addLanePositionStdDev(trip, startTime, endTime);
                addMeanBreakPedalPercentage(trip, startTime, endTime);
                addMaxBreakPercentage(trip, startTime, endTime);
            case 'suivi de vehicule'
                addCoherence(trip, startTime, endTime);
                addPhaseShift(trip, startTime, endTime);
                addModulus(trip, startTime, endTime);
            case 'intrusion'
                addMeanTIV(trip, startTime, endTime);
            otherwise
                error(['Type de situation non reconnu ! : ' type]);
        end
    end
    delete(trip);
end

function addSpeedMeanDeviationToPrescription(trip, startTime, endTime, prescription)
    vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    speedValues = vitesseOccurences.getVariableValues('vitesse');
    speedValuesMat = cell2mat(speedValues);
    speedDeviations = abs(speedValuesMat * 3.6 - prescription);
    meanDeviationToPrescription = mean(speedDeviations);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] meanDeviationToPrescription : ' num2str(meanDeviationToPrescription)]);
    trip.setSituationVariableAtTime('Sections', 'mean_deviation_to_prescripted_speed', startTime, endTime, meanDeviationToPrescription)
end

function addSpeedJerk(trip, startTime, endTime)
    record = trip.getDataVariableOccurencesInTimeInterval('vitesse','vitesse',startTime,endTime);
    cell = record.buildCellArrayWithVariables({'timecode' 'vitesse'});
    smoothedCell = fr.lescot.bind.processing.signalProcessors.MovingAverage.process(cell,{'6'});
    dVit = fr.lescot.bind.processing.signalProcessors.Derivator.process(smoothedCell,{'30'});
    smoothedDVit = fr.lescot.bind.processing.signalProcessors.MovingAverage.process(dVit,{'6'});
    ddVit = fr.lescot.bind.processing.signalProcessors.Derivator.process(smoothedDVit,{'30'});
    
    seuil = '4'; %valeurs à essayer : 3, 4 ou ...
    grandPicDDVit = fr.lescot.bind.processing.situationDiscoverers.ThresholdComparator.extract(abs(ddVit), '>', {seuil});
    jerk = length(grandPicDDVit);
    
    disp(['[' num2str(startTime) ';' num2str(endTime) '] jerk (' seuil ') : ' num2str(jerk)]);
    trip.setSituationVariableAtTime('Sections', 'jerk', startTime, endTime, jerk);
end

function addLanePositionStdDev(trip, startTime, endTime)
    trajectoireOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
    laneValues = trajectoireOccurences.getVariableValues('voie');
    laneStdDev = std(cell2mat(laneValues));
    disp(['[' num2str(startTime) ';' num2str(endTime) '] laneStdDev : ' num2str(laneStdDev)]);
    trip.setSituationVariableAtTime('Sections', 'lane_deviation', startTime, endTime, laneStdDev);
end

function addMeanBreakPedalPercentage(trip, startTime, endTime)
    vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    breakValues = vitesseOccurences.getVariableValues('frein');
    meanBreakPercentage = (mean(cell2mat(breakValues)) / 255) * 100;
    disp(['[' num2str(startTime) ';' num2str(endTime) ' meanBreakPercentage : ' num2str(meanBreakPercentage) '%']);
    trip.setSituationVariableAtTime('Sections', 'mean_break_percentage', startTime, endTime, meanBreakPercentage);
end

function addMaxBreakPercentage(trip, startTime, endTime)
    vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    breakValues = vitesseOccurences.getVariableValues('frein');
    maxBreakPercentage = (max(cell2mat(breakValues)) / 255) * 100;
    disp(['[' num2str(startTime) ';' num2str(endTime) '] maxBreakPercentage : ' num2str(maxBreakPercentage) '%']);
    trip.setSituationVariableAtTime('Sections', 'max_break_percentage', startTime, endTime, maxBreakPercentage);
end

function addMeanTIV(trip, startTime, endTime)
    %Calculé par rapport au véhicule de la colonne -13
    vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
    vVP = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));
    XVP = cell2mat(trajectoireVPOccurences.getVariableValues('X'));
    YVP = cell2mat(trajectoireVPOccurences.getVariableValues('Y'));
    ZVP = cell2mat(trajectoireVPOccurences.getVariableValues('Z'));

    %%%%%%%%%%%%
    vehiculePotentiallyFollowed1 = trip.getDataOccurencesInTimeInterval('-13', startTime, endTime);
    vehiculePotentiallyFollowed2 = trip.getDataOccurencesInTimeInterval('-14', startTime, endTime);
    vpf1Speed = cell2mat(vehiculePotentiallyFollowed1.getVariableValues('vitesse'));
    vpf2Speed = cell2mat(vehiculePotentiallyFollowed2.getVariableValues('vitesse'));
    if (isempty(vpf2Speed) || all(vpf2Speed == 0)) && (isempty(vpf1Speed) || all(vpf1Speed == 0))
        disp('### Erreur, toutes les vitesses valent 0 !!!');
    else if isempty(vpf1Speed) || all(vpf1Speed == 0)
            vehicleFollowed = '-14';
        else
            vehicleFollowed = '-13';
        end
        %%%%%%%%%%%%
        busOccurences = trip.getDataOccurencesInTimeInterval(vehicleFollowed, startTime, endTime);
        vBus = cell2mat(busOccurences.getVariableValues('vitesse'));
        XBus = cell2mat(busOccurences.getVariableValues('X'));
        YBus = cell2mat(busOccurences.getVariableValues('Y'));
        ZBus = cell2mat(busOccurences.getVariableValues('Z'));
        %On calcule un vecteur avec toutes les distances entre VP et le
        %vehicule a suivre (le bus)
        distances = zeros(1, length(XBus));
        for i = 1:1:length(XBus)
            distances(i) = euclidian_distance(XVP(i), YVP(i), ZVP(i), XBus(i), YBus(i), ZBus(i));
        end
        tivs = (distances / 1000) ./ (abs(vVP - vBus));
        meanTIV = mean(tivs);
        disp(['[' num2str(startTime) ';' num2str(endTime) ' meanTIV : ' num2str(meanTIV) '%']);
        trip.setSituationVariableAtTime('Sections', 'mean_TIV', startTime, endTime, meanTIV);
    end
end

function addModulus(trip, startTime, endTime)
    %non implémenté pour le moment
end

function addPhaseShift(trip, startTime, endTime)
    %non implémenté pour le moment
end

function addCoherence(trip, startTime, endTime)
    %non implémenté pour le moment
end
