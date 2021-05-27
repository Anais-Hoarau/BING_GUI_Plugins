% calcul de la valeur maximale de pourcentage d'enfoncement de la pédale de frein
function maxBreakPercentage(trip, startTime, endTime, cas_situation)
    
    %get data
    vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    breakValues = vitesseOccurences.getVariableValues('frein');
    
    %calculate indicator
    maxBreakPercentage = (max(cell2mat(breakValues)) / 255) * 100;
    
    % display indicator
    disp(['[' num2str(startTime) ';' num2str(endTime) '] maxBreakPercentage : ' num2str(maxBreakPercentage) '%']);
    
    % save indicator
    trip.setSituationVariableAtTime(cas_situation, 'frein_max', startTime, endTime, maxBreakPercentage);
    
end