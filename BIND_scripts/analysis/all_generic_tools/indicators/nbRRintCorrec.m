% calcul du nombre de RRintervals ajoutés par correction
function nbRRintCorrec(trip, startTime, endTime, cas_situation)

M150_dataOccurences = trip.getDataOccurencesInTimeInterval('M150_data', startTime, endTime);
RRintCorrec = cell2mat(variables_simulateur.getVariableValues('RRintCorrec'));

nbRRintCorrec = sum(RRintCorrec);
trip.setSituationVariableAtTime(cas_situation, 'nbRRintCorrec', startTime, endTime, nbRRintCorrec);

end