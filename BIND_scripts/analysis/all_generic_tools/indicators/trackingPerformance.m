% calcul des performances de suivi de Brookhuis (cohérence, phase, gain)
function trackingPerformance(trip, startTime, endTime, cas_situation)

% Variables
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
vVP = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));
vitesseCibleOccurences = trip.getDataOccurencesInTimeInterval('cible', startTime, endTime);
vCible = cell2mat(vitesseCibleOccurences.getVariableValues('vitesseCible'));

suiviOccurences = trip.getSituationOccurencesInTimeInterval(cas_situation, startTime, endTime);
fs = cell2mat(suiviOccurences.getVariableValues('freq'));

% Calculate performance
[mCoh, mPha, mGain] = following(vCible, vVP, fs);
trip.setSituationVariableAtTime(cas_situation, 'perf_coherence', startTime, endTime, mCoh);
trip.setSituationVariableAtTime(cas_situation, 'perf_phase', startTime, endTime, mPha);
trip.setSituationVariableAtTime(cas_situation, 'perf_gain', startTime, endTime, mGain);

end