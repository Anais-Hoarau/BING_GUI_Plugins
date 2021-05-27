% calculate fixations quantities and durations
function Pupil_fixations(trip, startTime, endTime, cas_situation)
    record = trip.getDataOccurencesInTimeInterval('PUPIL_GLASSES_gazes', startTime, endTime);
    DMO = cell2mat(record.getVariableValues('DMO')); % distance mouvement occulaire
    
    fix = 0;
    i_fix = 0;
    duree_fix_tot = 0;
    norm_deg_in_px = 0.01875;
    for i = 1:length(DMO)-2
        cond_fix = (DMO(i+2) - DMO(i)) < norm_deg_in_px;
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