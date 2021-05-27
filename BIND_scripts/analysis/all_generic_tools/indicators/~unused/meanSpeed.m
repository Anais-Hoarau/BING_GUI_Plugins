% calculate mean speed VP
function meanSpeed(trip, startTime, endTime, cas_situation)

vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
Vvp = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));

meanVvp = mean(Vvp)*3.6;
disp(['[' num2str(startTime) ';' num2str(endTime) '] vitesse moyenne = ' num2str(meanVvp) ' km/h']);
trip.setSituationVariableAtTime(cas_situation, 'vit_moy', startTime, endTime, meanVvp);

end