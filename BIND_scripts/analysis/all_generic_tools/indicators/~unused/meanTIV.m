% calcul de la moyenne des TIV du VP
function meanTIV(trip, startTime, endTime, cas_situation)

%Calcul� par rapport au v�hicule cible (-10)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));

meanTIV = mean(TIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] TIV moyen = ' num2str(meanTIV) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'TIV_moy', startTime, endTime, meanTIV);

end