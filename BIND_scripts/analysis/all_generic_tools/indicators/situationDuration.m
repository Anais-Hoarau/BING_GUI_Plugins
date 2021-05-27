% calcul de la durée de la situation
function situationDuration(trip, startTime, endTime, cas_situation)

situationDuration = endTime - startTime;
trip.setSituationVariableAtTime(cas_situation, 'duree', startTime, endTime, situationDuration);

end