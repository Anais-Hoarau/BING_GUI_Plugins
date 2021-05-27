% calculate driving indicators : SDLP, SDWA, SRR
function MadisonIndicatorsDriving(trip, inputDataName, inputVariablesNames, startTime, endTime, outputSituationName, outputIndicators, forceProcess)
    
    if or(~check_trip_meta(trip,['calcul_' mfilename '_' outputSituationName],'OK'), forceProcess == 1) && trip.getMetaInformations.existData(inputDataName) && ~trip.getAllDataOccurences(inputDataName).isEmpty
        
        disp(['Calculating ' mfilename  ' on situation ' outputSituationName ' for trip : ' trip.getTripPath]);

        %% get data
        record = trip.getDataOccurencesInTimeInterval(inputDataName, startTime, endTime);
        for i_var = 1:length(inputVariablesNames)
            var.(strrep(inputVariablesNames{i_var}, '.', '_')) = cell2mat(record.getVariableValues(inputVariablesNames{i_var}));
        end
        
        %% calculate indicators
        indicators.SDLP = std(abs(var.Voie));
        indicators.SDWA = std(abs(var.Cab_Volant*360/7500));
        diff_volant = diff(var.Cab_Volant*360/7500);
        mask_diff_volant = abs(diff_volant)>0;
        indicators.SRR = length(find(diff(sign(diff_volant(mask_diff_volant))))); % to check
        
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