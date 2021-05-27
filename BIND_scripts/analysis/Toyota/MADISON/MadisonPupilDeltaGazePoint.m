% Calculate delta gaze points : distance between 2 consecutive gaze point
function MadisonPupilDeltaGazePoint(trip, inputDataName, inputVariablesNames, outputDataName, ouputVariablesNames, forceProcess)
    
    if or(~check_trip_meta(trip,['calcul_' mfilename],'OK'), forceProcess == 1) && trip.getMetaInformations.existData(inputDataName) && ~trip.getAllDataOccurences(inputDataName).isEmpty
        
        disp(['Calculating ' mfilename ' for trip : ' trip.getTripPath]);

        %% get values
        record = trip.getAllDataOccurences(inputDataName);
        timecode = cell2mat(record.getVariableValues('timecode'));
        for i_var = 1:length(inputVariablesNames)
            var.(inputVariablesNames{i_var}) = cell2mat(record.getVariableValues(inputVariablesNames{i_var}));
        end
        
        %% check timesteps coherence
        delta_timecodes = diff(timecode);
        mean_delta_timecodes = mean(delta_timecodes);
        std_delta_timecodes = std(delta_timecodes);
        disp(['Moyenne des pas de temps = ' num2str(mean_delta_timecodes)]);
        disp(['Ecart-type des pas de temps = ' num2str(std_delta_timecodes)]);
        
        %% calculate delta_gaze_point values
        var.delta_gaze_point = NaN(length(timecode),1);
        for i = 1:length(timecode)-1
            if all([~isempty(var.norm_pos_X(i)), ~isempty(var.norm_pos_X(i+1)), ~isempty(var.norm_pos_Y(i)), ~isempty(var.norm_pos_Y(i+1))])
                var.delta_gaze_point(i+1) = sqrt((var.norm_pos_X(i+1)-var.norm_pos_X(i))^2 + (var.norm_pos_Y(i+1)-var.norm_pos_Y(i))^2);
            else
                var.delta_gaze_point(i+1) = NaN;
            end
        end
        
        %% write data to the trip
        removeDataTables(trip, {outputDataName});
        addDataTable2Trip(trip, outputDataName);
        for i_var = 1:length(ouputVariablesNames)
            addDataVariable2Trip(trip, outputDataName, ouputVariablesNames{i_var}, 'REAL');
            trip.setBatchOfTimeDataVariablePairs(outputDataName, ouputVariablesNames{i_var}, [num2cell(timecode(:)), num2cell(var.(ouputVariablesNames{i_var})(:))]');
        end
        
    elseif check_trip_meta(trip,['calcul_' mfilename],'OK') && forceProcess == 0
        disp(['Process "' mfilename '" already calculated for trip : ' trip.getTripPath]);
    elseif trip.getMetaInformations.existData(inputDataName) || trip.getAllDataOccurences(inputDataName).isEmpty
        disp([inputDataName ' is empty or missing from trip : ' trip.getTripPath]);
    end
    trip.setAttribute(['calcul_' mfilename], 'OK');
end