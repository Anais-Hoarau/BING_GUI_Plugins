% calcul des delta gaze points : distance entre 2 points de regards consécutifs
function pupil_delta_gaze_point(trip)
    
    if trip.getMetaInformations.existData('PUPIL_GLASSES_gaze')
        
        % get values
        record = trip.getAllDataOccurences('PUPIL_GLASSES_gaze');
        timecode = cell2mat(record.getVariableValues('timecode'));
        confidence = cell2mat(record.getVariableValues('confidence'));
        norm_pos_X = cell2mat(record.getVariableValues('norm_pos_X'));
        norm_pos_Y = cell2mat(record.getVariableValues('norm_pos_Y'));
        
        % check timesteps coherence
        delta_timecodes = diff(timecode);
        mean_delta_timecodes = mean(delta_timecodes);
        std_delta_timecodes = std(delta_timecodes);
        disp(['Moyenne des pas de temps = ' num2str(mean_delta_timecodes)]);
        disp(['Ecart-type des pas de temps = ' num2str(std_delta_timecodes)]);
        
        % calculate delta_gaze_point values
        disp('Calculating delta gaze points ...');
        delta_gaze_point = NaN(length(timecode),1);
        for i = 1:length(timecode)-1
            if all([~isempty(norm_pos_X(i)), ~isempty(norm_pos_X(i+1)), ~isempty(norm_pos_Y(i)), ~isempty(norm_pos_Y(i+1))])
                delta_gaze_point(i+1) = sqrt((norm_pos_X(i+1)-norm_pos_X(i))^2 + (norm_pos_Y(i+1)-norm_pos_Y(i))^2);
            else
                delta_gaze_point(i+1) = NaN;
            end
        end
        
        % create PUPIL_GLASSES_processed table and delta_gaze_point column if necessary
        removeDataTables(trip, {'PUPIL_GLASSES_processed'}, 1);
        addDataTable2Trip(trip,'PUPIL_GLASSES_processed')
        addDataVariable2Trip(trip,'PUPIL_GLASSES_processed','confidence','REAL')
        addDataVariable2Trip(trip,'PUPIL_GLASSES_processed','norm_pos_X','REAL')
        addDataVariable2Trip(trip,'PUPIL_GLASSES_processed','norm_pos_Y','REAL')
        addDataVariable2Trip(trip,'PUPIL_GLASSES_processed','delta_gaze_point','REAL')
        
        % add norm_pos_X, norm_pos_Y and delta_gaze_point values to trip
        trip.setBatchOfTimeDataVariablePairs('PUPIL_GLASSES_processed', 'confidence', [num2cell(timecode(:)), num2cell(confidence(:))]')
        trip.setBatchOfTimeDataVariablePairs('PUPIL_GLASSES_processed', 'norm_pos_X', [num2cell(timecode(:)), num2cell(norm_pos_X(:))]')
        trip.setBatchOfTimeDataVariablePairs('PUPIL_GLASSES_processed', 'norm_pos_Y', [num2cell(timecode(:)), num2cell(norm_pos_Y(:))]')
        trip.setBatchOfTimeDataVariablePairs('PUPIL_GLASSES_processed', 'delta_gaze_point', [num2cell(timecode(:)), num2cell(delta_gaze_point(:))]')
        
    end
end