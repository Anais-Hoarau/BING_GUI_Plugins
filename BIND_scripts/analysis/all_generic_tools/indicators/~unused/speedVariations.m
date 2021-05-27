% calculate speed VP variations
function speedVariations(trip, startTime, endTime, cas_situation)

vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
Vvp = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));

varVvp = std(Vvp)*3.6;
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations de vitesse = ' num2str(varVvp) ' km/h']);
trip.setSituationVariableAtTime(cas_situation, 'vit_var', startTime, endTime, varVvp);

end