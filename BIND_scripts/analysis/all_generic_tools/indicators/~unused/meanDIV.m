% calculate Mean DIV VP
function meanDIV(trip, startTime, endTime, cas_situation)

vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
DIVs = cell2mat(vitesseVPOccurences.getVariableValues('DIV'));

meanDIV = mean(DIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] DIV moyen = ' num2str(meanDIV) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'DIV_moy', startTime, endTime, meanDIV)

end