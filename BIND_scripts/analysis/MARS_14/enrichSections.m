

function enrichSections(tripFullFile )

    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFullFile, 0.04, false);
    
    
    import fr.lescot.bind.processing.situationAggregators.*
    import fr.lescot.bind.processing.signalProcessors.*
    
    situationName = 'Sections';
    % on charge les situations
    situation = trip.getAllSituationOccurences(situationName);
    situationTime = situation.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
    
    % on charge la vitesse en metre par seconde et on la converti en
    % kilometre / heure
    data = trip.getAllDataOccurences('vitesse');
    speedInMS = data.buildCellArrayWithVariables({'timecode' 'Vit'});    
    speedInKmH = Scaler.process(speedInMS,{'3.6'});
    
    
    meanValues = Average.process(situationTime, speedInKmH,{'0'});
    trip.setBatchOfTimeSituationVariableTriplets(situationName,'meanSpeed',meanValues);
    
    situations = situation.buildCellArrayWithVariables({'startTimecode' 'endTimecode' 'type' 'speedLimit'});
    for i=1:length(situations)
        situationCourante = situations(:,i);
        if any(strcmp(situationCourante{3},{'Conduite' 'TD'}))
            speedLimit = situationCourante{4};
            record = trip.getDataVariableOccurencesInTimeInterval('vitesse','Vit',situationCourante{1},situationCourante{2});
            vitesse = record.buildCellArrayWithVariables({'timecode' 'Vit'});    
            vitesseInKmH = Scaler.process(vitesse,{'3.6'});
            v = cell2mat(vitesseInKmH(2,:));
            deviationToSpeedLimit = mean(v - speedLimit);
            trip.setSituationVariableAtTime(situationName,'deviationToSpeedLimit',situationCourante{1},situationCourante{2},deviationToSpeedLimit);
        end
    end   
    
    for i=1:length(situations)
        situationCourante = situations(:,i);
        if any(strcmp(situationCourante{3},{'Conduite' 'TAD' 'TAG' 'TD' 'Rond-point' 'Démarrage'}))
            record = trip.getDataOccurencesInTimeInterval('trajectoire',situationCourante{1},situationCourante{2});
            positionVoie = record.buildCellArrayWithVariables({'timecode' 'Voie' 'Sens'});    
            centreVoie = 1750;
            position = cell2mat(positionVoie(2,:));
            sens = positionVoie(3,:);
            decallageAuCentre = [];
            for k=1:length(sens)
                leSens = sens{k};
                switch leSens
                    case 'Direct'
                        decallageAuCentre(k) = position(k) - centreVoie;
                    case 'Inverse'
                        decallageAuCentre(k) = position(k) + centreVoie;
                end
            end
            % TODO :  
            % nettoyer le signal lors des changement de voie / trouver
            % comment gérer la 
            %
            % trouver l'operateur d'aggrégation le plus approprié au
            % contexte
            plot(decallageAuCentre);
            
            trip.setSituationVariableAtTime(situationName,'deviationToSpeedLimit',situationCourante{1},situationCourante{2},deviationToSpeedLimit);
        end
    end  
    
    

    sdValues = Stdev.process(situationTime, speedInKmH,{'0'});
    trip.setBatchOfTimeSituationVariableTriplets(situationName,'sdSpeed',sdValues);

    entropyValues = SteeringEntropy.process(situationTime, speedInKmH,{'0'});
    trip.setBatchOfTimeSituationVariableTriplets(situationName,'speedEntropy', entropyValues);
end

