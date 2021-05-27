% calculate variations of DIV VP
function varDIV(trip, startTime, endTime, cas_situation)
    vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    DIVs = cell2mat(vitesseVPOccurences.getVariableValues('DIVv2'));
    varDIV = std(DIVs);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] variations DIV = ' num2str(varDIV) ' m']);
    trip.setSituationVariableAtTime(cas_situation, 'DIV_var', startTime, endTime, varDIV)
end