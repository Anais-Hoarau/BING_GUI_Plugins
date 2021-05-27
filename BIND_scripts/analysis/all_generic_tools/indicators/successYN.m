%% define if the driver succeed the situation
function successYN(trip, startTime, endTime, cas_situation)
    piloteAutoOccurences = trip.getSituationOccurencesInTimeInterval(cas_situation, startTime, endTime);
    arret = cell2mat(piloteAutoOccurences.getVariableValues('arret'));
    franchissementOccurences = trip.getSituationOccurencesInTimeInterval('franchissement', startTime, endTime);
    franchissements = cell2mat(franchissementOccurences.getVariableValues('startTimecode'));
    if arret == 0 && (isempty(franchissements) || franchissements(1) > startTime+12)
        reussite = 0;
    else
        reussite = 1;
    end
    disp(['[' num2str(startTime) ';' num2str(endTime) '] reussite = ' num2str(reussite)]);
    trip.setSituationVariableAtTime(cas_situation, 'reussite', startTime, endTime, reussite)
end