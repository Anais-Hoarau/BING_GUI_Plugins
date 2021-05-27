% calcul du nombre d'à-coups sur l'accélération (à partir de la dérivée de l'accélération)
function speedJerk(trip, startTime, endTime, cas_situation)
record = trip.getDataVariableOccurencesInTimeInterval('vitesse','vitesse',startTime,endTime);
cell = record.buildCellArrayWithVariables({'timecode' 'vitesse'});
smoothedCell = fr.lescot.bind.processing.signalProcessors.MovingAverage.process(cell, 7);
dVit = fr.lescot.bind.processing.signalProcessors.Derivator.process(smoothedCell, 0);
smoothedDVit = fr.lescot.bind.processing.signalProcessors.MovingAverage.process(dVit, 7);
ddVit = fr.lescot.bind.processing.signalProcessors.Derivator.process(smoothedDVit, 0);
ddVitAbs = num2cell(cellfun(@abs, ddVit));

seuil = 4; % Essayer avec 3, 4 ou ...
grandPicDDVit = fr.lescot.bind.processing.situationDiscoverers.ThresholdComparator.extract(ddVitAbs, '>', seuil);
jerk = length(grandPicDDVit);
disp(['[' num2str(startTime) ';' num2str(endTime) '] jerk (' num2str(seuil) ') : ' num2str(jerk)]);

trip.setSituationVariableAtTime(cas_situation, 'jerk', startTime, endTime, jerk);
end