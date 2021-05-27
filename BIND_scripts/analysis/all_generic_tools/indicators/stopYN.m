%% define if the car stoped during the situation
function stopYN(trip, startTime, endTime, cas_situation)
    PK_cibleOccurences = trip.getDataOccurencesInTimeInterval('cible', startTime, endTime);
    PK_cible = cell2mat(PK_cibleOccurences.getVariableValues('pkCible'));
    PK_cibleArret = PK_cible(find(diff(PK_cible)==0, 1));
    PK_VPOccurences = trip.getDataOccurencesInTimeInterval('localisation', startTime, endTime);
    PK_VP = cell2mat(PK_VPOccurences.getVariableValues('pk'));
    vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    vitesseVP = cell2mat(vitesseOccurences.getVariableValues('vitesse'));
    arret = 0;
    i=1;
    while PK_VP(i) < PK_cibleArret
        if min(vitesseVP(i)) < 1
            arret = 1;
        end
        i=i+1;
    end
    disp(['[' num2str(startTime) ';' num2str(endTime) '] arret = ' num2str(arret)]);
    trip.setSituationVariableAtTime(cas_situation, 'arret', startTime, endTime, arret)
end