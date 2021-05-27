record = trip.getDataVariableOccurencesInTimeInterval('vitesse','Vit',12.5673,71.0881)

cell = record.buildCellArrayWithVariables({'timecode' 'Vit'})

v = cell2mat(cell(2,:))

smoothedCell = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process(cell,{'6'})

sv = cell2mat(smoothedCell(2,:))

dVit = fr.lescot.bind.processing.signalProcessors.QADDerivative.process(smoothedCell,{'30'})

dv = cell2mat(dVit(2,:))

smoothedDVit = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process(dVit,{'6'})

sdv = cell2mat(smoothedDVit(2,:))


ddVit = fr.lescot.bind.processing.signalProcessors.QADDerivative.process(smoothedDVit,{'30'})

ddv = cell2mat(ddVit(2,:))

seuil = '3';
petitPicDDVitPositif = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(ddVit,{seuil})
petitPicDDVitNegatif = fr.lescot.bind.processing.situationDiscoverers.BelowThreshold.extract(ddVit,{['-' seuil ]})

seuil = '4';
grandPicDDVitPositif = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(ddVit,{seuil})
grandPicDDVitNegatif = fr.lescot.bind.processing.situationDiscoverers.BelowThreshold.extract(ddVit,{['-' seuil ]})

temps = cell2mat(ddVit(1,:))

plot(temps,v)
hold
plot(temps,dv,'red')
plot(temps,ddv,'green')
