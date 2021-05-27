function SpectrageTR()
    mainFolder = '\\vrlescot\SPECTRAGE\DATA\Simu';
    tripList = dirrec(mainFolder, '.trip');
    
    %% Loop on trips
    for i_trip = 1:length(tripList) %parfor
        disp(['_____________________________________' tripList{i_trip} '_____________________________________']);
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripList{i_trip}, 0.04, false);
        
        split_path = strfind(tripList{i_trip}, '_');
        trip.setAttribute('participant_id', tripList{i_trip}(split_path(1)+1:split_path(1)+3));
        if length(split_path) > 1
            trip.setAttribute('scenario', tripList{i_trip}(split_path(2)+1:split_path(2)+3));
        end
        addSituationVariable2Trip(trip, 'levees_pedales', 'TR', 'REAL');
        addSituationVariable2Trip(trip, 'levees_pedales', 'TR_filtered', 'REAL');
        addSituationVariable2Trip(trip, 'scenario_complet', 'TR_moy', 'REAL');
        addSituationVariable2Trip(trip, 'scenario_complet', 'TR_std', 'REAL');
        addSituationVariable2Trip(trip, 'scenario_complet', 'TR_filtered_moy', 'REAL');
        addSituationVariable2Trip(trip, 'scenario_complet', 'TR_filtered_std', 'REAL');
        addSituationVariable2Trip(trip, 'scenario_complet', 'nb_TRFiltered_Inf', 'REAL');
        addSituationVariable2Trip(trip, 'scenario_complet', 'nb_TRFiltered_Sup', 'REAL');
        
        record = trip.getAllSituationOccurences('levees_pedales');
        startTime = record.getVariableValues('startTimecode');
        endTime = record.getVariableValues('endTimecode');
        
        TR_filtered = {};
        nb_TRFiltered_Inf = 0;
        nb_TRFiltered_Sup = 0;
        for i = 1:length(startTime)
            
            table_vitesse{i} = trip.getDataOccurencesInTimeInterval('vitesse', startTime{i}, endTime{i});
            levee_pedale{i} = cell2mat(table_vitesse{i}.getVariableValues('accelerateur'));
            timecodes{i} = cell2mat(table_vitesse{i}.getVariableValues('timecode'));
            
            mask_pedAccel_zero{i} = (levee_pedale{i} == 0);
            mask_timecode{i} = timecodes{i}(mask_pedAccel_zero{i});
            try
                TR{i} = mask_timecode{i}(1) - startTime{i};
            catch
                TR{i} = NaN;
            end
            
            if TR{i} < 0.2
                mask_TR_filtered{i} = 0;
                TR_filtered{i} = NaN;
                nb_TRFiltered_Inf = nb_TRFiltered_Inf + 1;
            elseif TR{i} > 3
                mask_TR_filtered{i} = 0;
                TR_filtered{i} = NaN;
                nb_TRFiltered_Sup = nb_TRFiltered_Sup + 1;
            else
                mask_TR_filtered{i} = 1;
                TR_filtered{i} = TR{i};
            end
            
            %     plot(levee_pedale{i});
            plot(i, TR_filtered{i}, '*');
            hold on
            
            %% display and add indicators to the trip
            disp(['[' num2str(startTime{i}) ';' num2str(endTime{i}) '] ' 'TR' ' = ' num2str(TR{i})]);
            disp(['[' num2str(startTime{i}) ';' num2str(endTime{i}) '] ' 'TR_filtered' ' = ' num2str(TR_filtered{i})]);
            trip.setSituationVariableAtTime('levees_pedales', 'TR', startTime{i}, endTime{i}, TR{i});
            trip.setSituationVariableAtTime('levees_pedales', 'TR_filtered', startTime{i}, endTime{i}, TR_filtered{i});
            
        end
        
        TR_moy = mean(cell2mat(TR));
        TR_std = std(cell2mat(TR));
        TR_filtered_moy = mean(TR_filtered{mask_TR_filtered{:}});
        TR_filtered_std = std(TR_filtered{mask_TR_filtered{:}});
        
        disp(['TR_moy : ' num2str(TR_moy)]);
        disp(['TR_std : ' num2str(TR_std)]);
        disp(['TR_filtered_moy : ' num2str(TR_filtered_moy)]);
        disp(['TR_filtered_std : ' num2str(TR_filtered_std)]);

        record_scn = trip.getAllSituationOccurences('scenario_complet');
        startTime_scn = record_scn.getVariableValues('startTimecode');
        endTime_scn = record_scn.getVariableValues('endTimecode');
        
        trip.setSituationVariableAtTime('scenario_complet', 'TR_moy', startTime_scn{:}, endTime_scn{:}, TR_moy);
        trip.setSituationVariableAtTime('scenario_complet', 'TR_std', startTime_scn{:}, endTime_scn{:}, TR_std);
        trip.setSituationVariableAtTime('scenario_complet', 'TR_filtered_moy', startTime_scn{:}, endTime_scn{:}, TR_filtered_moy);
        trip.setSituationVariableAtTime('scenario_complet', 'TR_filtered_std', startTime_scn{:}, endTime_scn{:}, TR_filtered_std);
        trip.setSituationVariableAtTime('scenario_complet', 'nb_TRFiltered_Inf', startTime_scn{:}, endTime_scn{:}, nb_TRFiltered_Inf);
        trip.setSituationVariableAtTime('scenario_complet', 'nb_TRFiltered_Sup', startTime_scn{:}, endTime_scn{:}, nb_TRFiltered_Sup);
        
        delete(trip);
        % hold off
        % plot(timecodes{21}, levee_pedale{21})
    end
    
    disp(['nb_TRFiltered_Inf : ' num2str(nb_TRFiltered_Inf)]);
    disp(['nb_TRFiltered_Sup : ' num2str(nb_TRFiltered_Sup)]);
    
end