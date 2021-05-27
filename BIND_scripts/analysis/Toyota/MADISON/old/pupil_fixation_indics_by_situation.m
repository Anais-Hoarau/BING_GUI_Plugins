% calculate fixations quantities and durations and saccades amplitudes
function pupil_fixation_indics_by_situation(trip)
    
    bindDataName = 'PUPIL_GLASSES_processed';
    situationNames = {'fin_situations2Process_0-30', 'fin_situations2Process_0-60', 'fin_situations2Process_0-90', 'fin_situations2Process_0-120'};
    
    if trip.getMetaInformations.existData(bindDataName)
        
        %% Loop on situations tables
        for i = 1:length(situationNames)
            
            record_situation = trip.getAllSituationOccurences(situationNames{i});
            startTimecodes = cell2mat(record_situation.getVariableValues('startTimecode'));
            endTimecodes = cell2mat(record_situation.getVariableValues('endTimecode'));
            
            %% Loop on lines in situations tables
            for j = 1:length(startTimecodes)
                
                startTime = startTimecodes(j);
                endTime = endTimecodes(j);
                
                record_data = trip.getDataOccurencesInTimeInterval(bindDataName, startTime, endTime);
                timecode = cell2mat(record_data.getVariableValues('timecode'));
                delta_gaze_point = cell2mat(record_data.getVariableValues('delta_gaze_point'));
                fixation = cell2mat(record_data.getVariableValues('fixation'));
                
                period = mean(diff(timecode));
                diff_fix = diff(fixation)';
                nb_fix = sum(diff_fix == -1);
                duree_fix_tot = sum(fixation)*period;
                duree_fix_moy = duree_fix_tot/nb_fix;
                nb_sac = sum(diff_fix == 1);
                duree_sac_tot = sum(fixation == 0)*period;
                ampli_sac_tot = sum(delta_gaze_point(fixation == 0));
                ampli_sac_moy = ampli_sac_tot/nb_sac;
                
%                 variables = {'nb_fix', 'duree_fix_tot', 'duree_fix_moy', 'nb_sac', 'duree_sac_tot', 'ampli_sac_tot', 'ampli_sac_moy'};
%                 for k = 1:length(variables)
%                 end

                % Display data
                disp(['[' num2str(startTime) ';' num2str(endTime) '] nb_fix = ' num2str(nb_fix)]);
                disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_tot = ' num2str(duree_fix_tot) 's']);
                disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_moy = ' num2str(duree_fix_moy) 's']);
                disp(['[' num2str(startTime) ';' num2str(endTime) '] nb_sac = ' num2str(nb_sac)]);
                disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_sac_tot = ' num2str(duree_sac_tot) 's']);
                disp(['[' num2str(startTime) ';' num2str(endTime) '] ampli_sac_tot = ' num2str(ampli_sac_tot) '']);
                disp(['[' num2str(startTime) ';' num2str(endTime) '] ampli_sac_moy = ' num2str(ampli_sac_moy) '']);
                
                % Write data in trip
                addSituationVariable2Trip(trip,situationNames{i},'nb_fix','REAL');
                addSituationVariable2Trip(trip,situationNames{i},'duree_fix_tot','REAL');
                addSituationVariable2Trip(trip,situationNames{i},'duree_fix_moy','REAL');
                addSituationVariable2Trip(trip,situationNames{i},'nb_sac','REAL');
                addSituationVariable2Trip(trip,situationNames{i},'duree_sac_tot','REAL');
                addSituationVariable2Trip(trip,situationNames{i},'ampli_sac_tot','REAL');
                addSituationVariable2Trip(trip,situationNames{i},'ampli_sac_moy','REAL');

                trip.setSituationVariableAtTime(situationNames{i}, 'nb_fix', startTime, endTime, nb_fix);
                trip.setSituationVariableAtTime(situationNames{i}, 'duree_fix_tot', startTime, endTime, duree_fix_tot);
                trip.setSituationVariableAtTime(situationNames{i}, 'duree_fix_moy', startTime, endTime, duree_fix_moy);
                trip.setSituationVariableAtTime(situationNames{i}, 'nb_sac', startTime, endTime, nb_sac);
                trip.setSituationVariableAtTime(situationNames{i}, 'duree_sac_tot', startTime, endTime, duree_sac_tot);
                trip.setSituationVariableAtTime(situationNames{i}, 'ampli_sac_tot', startTime, endTime, ampli_sac_tot);
                trip.setSituationVariableAtTime(situationNames{i}, 'ampli_sac_moy', startTime, endTime, ampli_sac_moy);

            end
        end
    end
end