% calcul du nombre de pas de temps
function numberOfSamples(trip, startTime, endTime, cas_situation)

variables_simulateur = trip.getDataOccurencesInTimeInterval('variables_simulateur', startTime, endTime);
pas_de_temps = cell2mat(variables_simulateur.getVariableValues('pas'));

NbPasDeTemps = pas_de_temps(end) - pas_de_temps(1);
trip.setSituationVariableAtTime(cas_situation, 'nb_ech', startTime, endTime, NbPasDeTemps);

end