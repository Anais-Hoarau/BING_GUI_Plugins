% calculate pupil fixation
function MadisonPupilFixation(trip, inputDataName, inputVariablesNames, outputDataName, ouputVariablesNames, forceProcess)
    
    if or(~check_trip_meta(trip,['calcul_' mfilename],'OK'), forceProcess == 1) && trip.getMetaInformations.existData(inputDataName) && ~trip.getAllDataOccurences(inputDataName).isEmpty
        
        disp(['Calculating ' mfilename ' for trip : ' trip.getTripPath]);

        %% get values
        record = trip.getAllDataOccurences(inputDataName);
        timecode = cell2mat(record.getVariableValues('timecode'));
        for i_var = 1:length(inputVariablesNames)
            var.(inputVariablesNames{i_var}) = cell2mat(record.getVariableValues(inputVariablesNames{i_var}));
        end

        %% intrinsec parameters and check timesteps coherence
        delta_timecodes = diff(timecode);
        period_mean = mean(delta_timecodes);
        period_std = std(delta_timecodes);
        frequency = 1/period_mean; % ~120Hz
        threshold_fixation_duration = 0.075; % 75ms
        norm_deg_threshold = 0.005; %threshold_velocity * threshold_fixation_duration / norm_deg_in_px;
        threshold_period = round(threshold_fixation_duration / period_mean); % for 0.075 : 9 periods at 120Hz | 5 periods at 60Hz | 2 periods at 30Hz
        disp(['Fréquence = ' num2str(frequency)]);
        disp(['Seuil de période = ' num2str(threshold_period)]);
        disp(['Moyenne des pas de temps = ' num2str(period_mean)]);
        disp(['Ecart-type des pas de temps = ' num2str(period_std)]);

        %% calculate fixations according to parameters
        var.fixation = zeros(length(timecode),1)';
        DGP_out_threshold_OnPeriod = 0; % no gaze point out of the corner cone
        empty_lines_threshold = 0; % no empty line
        DGP_byLine_OnPeriod = NaN(length(threshold_period),1);
        for i = 1:length(timecode)-threshold_period
            empty_lines = 0;
            % Test if data exists on each time step and create DGP_byLine_OnPeriod (delta gaze point)
            for j = 1:threshold_period
                if all([~isempty(var.norm_pos_X(i)), ~isempty(var.norm_pos_X(i+1)), ~isempty(var.norm_pos_Y(i)), ~isempty(var.norm_pos_Y(i+1))])
                    DGP_byLine_OnPeriod(j) = sqrt((var.norm_pos_X(i+j)-var.norm_pos_X(i))^2+(var.norm_pos_Y(i+j)-var.norm_pos_Y(i))^2);
                else
                    DGP_byLine_OnPeriod(j) = NaN;
                    empty_lines = empty_lines + 1;
                end
            end
            if all([empty_lines <= empty_lines_threshold, ...
                    sum(DGP_byLine_OnPeriod(:) > norm_deg_threshold) <= DGP_out_threshold_OnPeriod, ...
                    all(var.confidence(i:i+threshold_period)>0.9)])
                var.fixation(i+1:i+threshold_period) = 1;
            end
        end
        
        %% check fixations
        nb_fix_steps = sum(var.fixation);
        nb_sac_steps = length(var.fixation) - nb_fix_steps;
        disp(['Nombre de pas de fixations = ' num2str(nb_fix_steps)]);
        disp(['Nombre de pas de saccades = ' num2str(nb_sac_steps)]);
        
        %% Create fixation column if necessary and write data in the trip
        for i_var = 1:length(ouputVariablesNames)
            addDataVariable2Trip(trip, outputDataName, ouputVariablesNames{i_var}, 'REAL')
            trip.setBatchOfTimeDataVariablePairs(outputDataName, ouputVariablesNames{i_var}, [num2cell(timecode(:)), num2cell(var.(ouputVariablesNames{i_var})(:))]')
        end
        
    elseif check_trip_meta(trip,['calcul_' mfilename],'OK') && forceProcess == 0
        disp(['Process "' mfilename '" already calculated for trip : ' trip.getTripPath]);
    elseif trip.getMetaInformations.existData(inputDataName) || trip.getAllDataOccurences(inputDataName).isEmpty
        disp([inputDataName ' is empty or missing from trip : ' trip.getTripPath]);
    end
    trip.setAttribute(['calcul_' mfilename], 'OK');
end

% threshold_velocity = 6.666; % 6.666°/sec | 35°/sec
% norm_deg = 0.005; % PupilLabsHeadset : 0.046875°/px | TobiiGlasses : 0.01875°/px => To check