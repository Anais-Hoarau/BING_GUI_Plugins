% calcul de la fréquence de la situation
function frequency(trip, startTime, endTime, cas_situation)

suiviOccurences = trip.getSituationOccurencesInTimeInterval(cas_situation, startTime, endTime);
duree = cell2mat(suiviOccurences.getVariableValues('duree'));
nb_ech = cell2mat(suiviOccurences.getVariableValues('nb_ech'));
fs = nb_ech / duree ;

trip.setSituationVariableAtTime(cas_situation, 'freq', startTime, endTime, fs);

end