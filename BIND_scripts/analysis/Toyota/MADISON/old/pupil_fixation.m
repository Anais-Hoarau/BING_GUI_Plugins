% calculate pupil fixation data by Trip
function pupil_fixation(trip)
    
    bindDataName = 'PUPIL_GLASSES_processed';
    
    if trip.getMetaInformations.existData(bindDataName)
        
        
        % get values
        record = trip.getAllDataOccurences(bindDataName);
        timecode = cell2mat(record.getVariableValues('timecode'));
        confidence = cell2mat(record.getVariableValues('confidence'));
        norm_pos_X = cell2mat(record.getVariableValues('norm_pos_X'));
        norm_pos_Y = cell2mat(record.getVariableValues('norm_pos_Y'));
        delta_gaze_point = cell2mat(record.getVariableValues('delta_gaze_point'));

        % check timesteps coherence
        delta_timecodes = diff(timecode);
        mean_delta_timecodes = mean(delta_timecodes);
        std_delta_timecodes = std(delta_timecodes);
        disp(['Moyenne des pas de temps = ' num2str(mean_delta_timecodes)]);
        disp(['Ecart-type des pas de temps = ' num2str(std_delta_timecodes)]);

        % intrinsec parameters
        period = mean_delta_timecodes; % ~8.1ms
        frequency = 1/period; % ~120Hz
        
        % extrinsec parameters to detect fixations
        threshold_fixation_duration = 0.070; % 70ms
        threshold_velocity = 35; %35°/sec
        norm_deg_in_px = 0.01875; % 0.01875px/deg
        norm_deg_threshold = norm_deg_in_px * threshold_velocity * threshold_fixation_duration;
        threshold_period = round(threshold_fixation_duration / period); % 9 periods
        threshold_fixation_duration_corrected = threshold_period*period;
        
        % calculate fixations according to parameters
        fixation = NaN(length(timecode),1);
        DGP_out_threshold_OnPeriod = 0; % no gaze point out of the corner cone
        empty_lines_threshold = 0; % no empty line
        
        for i = 1:length(timecode)-threshold_period
            
            empty_lines = 0;
            
            % Test if data exists on each time step and create DGP_byLine_OnPeriod (delta gaze point)
            for j = 1:threshold_period
                DGP_byLine_OnPeriod(j,1) = timecode(i+j);
                if all([~isempty(norm_pos_X(i)), ~isempty(norm_pos_X(i+1)), ~isempty(norm_pos_Y(i)), ~isempty(norm_pos_Y(i+1))])
                    DGP_byLine_OnPeriod(j,2) = sqrt((norm_pos_X(i+j)-norm_pos_X(i))^2+(norm_pos_Y(i+j)-norm_pos_Y(i))^2);
                else
                    DGP_byLine_OnPeriod(j,2) = NaN;
                    empty_lines = empty_lines + 1;
                end
            end
            
            if all([empty_lines <= empty_lines_threshold, ...
                    sum(DGP_byLine_OnPeriod(:,2) > norm_deg_threshold) <= DGP_out_threshold_OnPeriod, ...
                    all(confidence(i:i+threshold_period-1)>0.9)])
                fixation(i:i+threshold_period-1,1) = timecode(i:i+threshold_period-1);
                fixation(i:i+threshold_period-1,2) = 1;
            else
                fixation(i:i+threshold_period-1,1) = timecode(i:i+threshold_period-1);
                fixation(i:i+threshold_period-1,2) = 0;
            end
            
        end
        
        % check fixations
        nb_fix_steps = sum(fixation(:,2));
        nb_sac_steps = length(fixation)-nb_fix_steps;
        disp(['Nombre de pas de fixations = ' num2str(nb_fix_steps)]);
        disp(['Nombre de pas de saccades = ' num2str(nb_sac_steps)]);
        
        % Create fixation column if necessary and write data in the trip
        addDataVariable2Trip(trip,'PUPIL_GLASSES_processed','fixation','REAL')
        trip.setBatchOfTimeDataVariablePairs(bindDataName, 'fixation', [num2cell(timecode(:)), num2cell(fixation(:,2))]')
        
    end
end