% calculate pupil indicators : nb_fix, duree_fix_tot, duree_fix_moy, nb_sac, duree_sac_tot, ampli_sac_tot, ampli_sac_moy
function MadisonIndicatorsPupil(trip, inputDataName, inputVariablesNames, startTime, endTime, outputSituationName, outputIndicators, forceProcess)

    if or(~check_trip_meta(trip,['calcul_' mfilename '_' outputSituationName],'OK'), forceProcess == 1) && trip.getMetaInformations.existData(inputDataName) && ~trip.getAllDataOccurences(inputDataName).isEmpty
        
        disp(['Calculating ' mfilename  ' on situation ' outputSituationName ' for trip : ' trip.getTripPath]);

        %% get data
        record = trip.getDataOccurencesInTimeInterval(inputDataName, startTime, endTime);
        timecode = cell2mat(record.getVariableValues('timecode'));
        for i_var = 1:length(inputVariablesNames)
            var.(inputVariablesNames{i_var}) = cell2mat(record.getVariableValues(inputVariablesNames{i_var}));
        end
        
        %% calculate indicators
        
        % find start/end indexes for fixations/saccades 
        if var.fixation(1) == 1
            idx_fixStarts = [1, find(diff(var.fixation) == 1)+1];
            idx_sacStarts = find(diff(var.fixation) == -1)+1;
        elseif var.fixation(1) == 0
            idx_fixStarts = find(diff(var.fixation) == 1)+1;
            idx_sacStarts = [1, find(diff(var.fixation) == -1)+1];
        end
        if var.fixation(end) == 1
            idx_fixEnds = [find(diff(var.fixation) == -1)+1, length(var.fixation)];
            idx_sacEnds = find(diff(var.fixation) == 1)+1;
        elseif var.fixation(end) == 0
            idx_fixEnds = find(diff(var.fixation) == -1)+1;
            idx_sacEnds = [find(diff(var.fixation) == 1)+1, length(var.fixation)];
        end
        
        % calculate fixation indicators
        tc_fixStarts = timecode(idx_fixStarts)';
        tc_fixEnds = timecode(idx_fixEnds)';
        durees_fix = tc_fixEnds-tc_fixStarts;
        
        indicators.nb_fix = length(idx_fixStarts);
        indicators.duree_fix_tot = sum(durees_fix);
        indicators.duree_fix_moy = mean(durees_fix);
        indicators.duree_fix_std = std(durees_fix);
        
        % calculate saccades indicators
        tc_sacStarts = timecode(idx_sacStarts);
        tc_sacEnds = timecode(idx_sacEnds);
        durees_sac = tc_sacEnds-tc_sacStarts;
        normPosX_sacStarts = var.norm_pos_X(idx_sacStarts);
        normPosY_sacStarts = var.norm_pos_Y(idx_sacStarts);
        normPosX_sacEnds = var.norm_pos_X(idx_sacEnds);
        normPosY_sacEnds = var.norm_pos_Y(idx_sacEnds);
        amplitudes_sac = ((normPosX_sacEnds-normPosX_sacStarts).^2+(normPosY_sacEnds-normPosY_sacStarts).^2).^0.5.*100;

        indicators.nb_sac = length(tc_sacStarts);
        indicators.duree_sac_tot = sum(durees_sac);
        indicators.duree_sac_moy = mean(durees_sac);
        indicators.duree_sac_std = std(durees_sac);
        indicators.ampli_sac_tot = sum(amplitudes_sac);
        indicators.ampli_sac_moy = mean(amplitudes_sac);
        indicators.ampli_sac_std = std(amplitudes_sac);
        
        %% display and add indicators to the trip
        for i = 1:length(outputIndicators)
            disp(['[' num2str(startTime) ';' num2str(endTime) '] ' outputIndicators{i} ' = ' num2str(indicators.(outputIndicators{i}))]);
            addSituationVariable2Trip(trip, outputSituationName, outputIndicators{i}, 'REAL');
            trip.setSituationVariableAtTime(outputSituationName, outputIndicators{i}, startTime, endTime, indicators.(outputIndicators{i}));
        end
        
    elseif check_trip_meta(trip,['calcul_' mfilename '_' outputSituationName],'OK') && forceProcess == 0
        disp(['Process "' mfilename '" already calculated for trip : ' trip.getTripPath]);
    elseif trip.getMetaInformations.existData(inputDataName) || trip.getAllDataOccurences(inputDataName).isEmpty
        disp([inputDataName ' is empty or missing from trip : ' trip.getTripPath]);
    end
    trip.setAttribute(['calcul_' mfilename '_' outputSituationName], 'OK');
end