% calculate Heart Rate interpolated
function HRInterp(trip, inputDataName, inputVariablesNames, outputDataName, ouputVariablesNames, forceProcess)

    if  or(~check_trip_meta(trip,['calcul_' mfilename],'OK'), forceProcess == 1) && trip.getMetaInformations().existData(inputDataName) && ~trip.getAllDataOccurences(inputDataName).isEmpty
        
        disp(['Calculating ' mfilename ' for trip : ' trip.getTripPath]);

        %% get data
        record = trip.getAllDataOccurences(inputDataName);
        timecodes = cell2mat(record.getVariableValues('timecode'));
        RRintervals = record.getVariableValues(inputVariablesNames{1});
        
        %% calculate HRInterp
        timecodes_RRintervals = timecodes(logical(~cellfun(@isempty,RRintervals)));
        RRintervals = cell2mat(RRintervals);
        HR = 60./RRintervals;
        HR_interp = interp1(timecodes_RRintervals,HR,timecodes,'pchip');
        
        %% plot figure
%         plot(timecodes_RRintervals,HR,'Marker','o','LineStyle','none')
%         hold on
%         plot(timecodes,HR_interp')
%         hold off
        
        %% add indicators to the trip
        addDataVariable2Trip(trip,outputDataName,ouputVariablesNames{1},'REAL','unit','bpm','comment','Heart_rate_interpolated_calculated');
        trip.setBatchOfTimeDataVariablePairs(outputDataName, ouputVariablesNames{1}, [num2cell(timecodes(:)), num2cell(HR_interp(:))]')
        
    elseif check_trip_meta(trip,['calcul_' mfilename],'OK') && forceProcess == 0
        disp(['Process "' mfilename '" already calculated for trip : ' trip.getTripPath]);
    elseif trip.getMetaInformations.existData(inputDataName) || trip.getAllDataOccurences(inputDataName).isEmpty
        disp([inputDataName ' is empty or missing from trip : ' trip.getTripPath]);
    end
    trip.setAttribute(['calcul_' mfilename], 'OK');
end