% calculate fixations quantities and durations in AOIs
function Tobii_fixationsAOI(trip, startTime, endTime, cas_situation, i)
    tobiiOccurences = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime);
    dist_mouv_ocu = cell2mat(tobiiOccurences.getVariableValues('DMO'));
    etat_visite_AOI = cell2mat(tobiiOccurences.getVariableValues(['pieton_' num2str(i)]));
    
    fix = 0;
    i_fix = 0;
    duree_fix_tot = 0;
    i_fix_AOI = 0;
    duree_fix_AOI_tot = 0;
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
        if fix == 1 && etat_visite_AOI(i) == 1
            duree_fix_AOI_tot = duree_fix_AOI_tot + 0.0333;
        else
            fix_AOI = 0;
        end
        if fix == 1 && etat_visite_AOI(i) == 1 && fix_AOI == 0
            i_fix_AOI = i_fix_AOI + 1;
            fix_AOI = 1;
        end
    end
    
    if i_fix_AOI > 0
        duree_fix_AOI_moy = duree_fix_AOI_tot/i_fix_AOI;
    else
        duree_fix_AOI_moy = 0;
    end
    
    disp(['[' num2str(startTime) ';' num2str(endTime) '] nb_fix_AOI = ' num2str(i_fix_AOI)]);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_AOI_tot = ' num2str(duree_fix_AOI_tot) 's']);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_AOI_moy = ' num2str(duree_fix_AOI_moy) 's']);
    
    trip.setSituationVariableAtTime(cas_situation, 'nb_fix_AOI', startTime, endTime, i_fix_AOI)
    trip.setSituationVariableAtTime(cas_situation, 'duree_fix_AOI_tot', startTime, endTime, duree_fix_AOI_tot)
    trip.setSituationVariableAtTime(cas_situation, 'duree_fix_AOI_moy', startTime, endTime, duree_fix_AOI_moy)
    
end