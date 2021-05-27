% calcul de la moyenne du pourcentage d'enfoncement de la pédale de frein
function meanBreakPedalPercentage(trip, startTime, endTime, cas_situation)
    
    %get data
    vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    breakValues = vitesseOccurences.getVariableValues('frein');
    
    %calculate indicator
    meanBreakPercentage = (mean(cell2mat(breakValues)) / 255) * 100;
    
    % display indicator
    disp(['[' num2str(startTime) ';' num2str(endTime) '] meanBreakPercentage : ' num2str(meanBreakPercentage) '%']);
    
    % save indicator
    trip.setSituationVariableAtTime(cas_situation, 'frein_moy', startTime, endTime, meanBreakPercentage);
    
end