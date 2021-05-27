% calculate fixations quantities and durations
function Tobii_fixations(trip, startTime, endTime, cas_situation)
    tobiiOccurences = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime);
    dist_mouv_ocu = cell2mat(tobiiOccurences.getVariableValues('DMO'));
    
    fix = 0;
    i_fix = 0;
    duree_fix_tot = 0;
    for i = 1:length(dist_mouv_ocu)-2
        cond_fix = (dist_mouv_ocu(i+2) - dist_mouv_ocu(i)) < 6;
        if cond_fix
            duree_fix_tot = duree_fix_tot + 0.0333;
        else
            fix = 0;
        end
        if cond_fix && fix == 0
            i_fix = i_fix + 1;
            fix = 1;
        end
    end
    
    if i_fix > 0
        duree_fix_moy = duree_fix_tot/i_fix;
    else
        duree_fix_moy = 0;
    end
    
    disp(['[' num2str(startTime) ';' num2str(endTime) '] nb_fix = ' num2str(i_fix)]);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_tot = ' num2str(duree_fix_tot) 's']);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_moy = ' num2str(duree_fix_moy) 's']);
    
    trip.setSituationVariableAtTime(cas_situation, 'nb_fix', startTime, endTime, i_fix)
    trip.setSituationVariableAtTime(cas_situation, 'duree_fix_tot', startTime, endTime, duree_fix_tot)
    trip.setSituationVariableAtTime(cas_situation, 'duree_fix_moy', startTime, endTime, duree_fix_moy)
    
end