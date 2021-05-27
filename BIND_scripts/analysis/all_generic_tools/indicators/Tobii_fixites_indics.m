% calculate fixations quantities and durations
function Tobii_fixites(trip, startTime, endTime, cas_situation)
    tobiiOccurences = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime);
    fixite_regard = cell2mat(tobiiOccurences.getVariableValues('fixite_regard_60'));
    
    nb_pas_fixites_regard = sum(fixite_regard);
    duree_fixites_tot = nb_pas_fixites_regard*0.033;
    
    disp(['[' num2str(startTime) ';' num2str(endTime) '] nb_pas_fixites = ' num2str(nb_pas_fixites_regard)]);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fixites_tot = ' num2str(duree_fixites_tot) 's']);
    
    trip.setSituationVariableAtTime(cas_situation, 'nbPas_fixit', startTime, endTime, nb_pas_fixites_regard)
    trip.setSituationVariableAtTime(cas_situation, 'duree_fixit_tot', startTime, endTime, duree_fixites_tot)
    
end