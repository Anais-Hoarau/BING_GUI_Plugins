% calculate Min DIV VP
function minDIV(trip, startTime, endTime, cas_situation)
    vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    DIVs = cell2mat(vitesseVPOccurences.getVariableValues('DIVv2'));
    minDIV = min(DIVs);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] DIV minimum = ' num2str(minDIV) ' m']);
    trip.setSituationVariableAtTime(cas_situation, 'DIV_min', startTime, endTime, minDIV)
end