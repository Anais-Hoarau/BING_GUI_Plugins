% calcul des variations des TIV du VP
function TIVVariations(trip, startTime, endTime, cas_situation)

%Calculé par rapport au véhicule cible (-10)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));

varTIV = std(TIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations de TIV = ' num2str(varTIV) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'TIV_var', startTime, endTime, varTIV);

end