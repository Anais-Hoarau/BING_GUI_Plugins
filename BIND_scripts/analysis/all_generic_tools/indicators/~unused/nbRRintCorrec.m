% calcul du nombre de RRintervals ajoutés par correction
function nbRRintCorrec(trip, startTime, endTime, cas_situation)

MP150_dataOccurences = trip.getDataOccurencesInTimeInterval('MP150_data', startTime, endTime);
RRintCorrec = cell2mat(MP150_dataOccurences.getVariableValues('RRintCorrec'));

nbRRintCorrec = sum(RRintCorrec);
disp(['[' num2str(startTime) ';' num2str(endTime) '] nombre des intervals RR ajoutés par correction = ' num2str(nbRRintCorrec)]);
trip.setSituationVariableAtTime(cas_situation, 'nbRRintCorrec', startTime, endTime, nbRRintCorrec);

end