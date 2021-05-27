% calcul des franchissements de voie du VP par situation
function crossingLaneBySituation(trip, startTime, endTime, cas_situation)
    
    franchissementVPOccurences = trip.getSituationOccurencesInTimeInterval('franchissement', startTime, endTime);
    dureeFranchissement = cell2mat(franchissementVPOccurences.getVariableValues('duree_franchissement'));
    dureeFranchissementMoy = mean(dureeFranchissement);
    
    trip.setSituationVariableAtTime(cas_situation, 'nb_SV', startTime, endTime, length(dureeFranchissement));
    trip.setSituationVariableAtTime(cas_situation, 'dureeSV_moy', startTime, endTime, dureeFranchissementMoy);
    
end