% calculate context indicators : 'situation', 'level', 'disconfort', 'duration'
function MadisonIndicatorsContext(trip, inputEventName, inputVariablesNames, startTime, endTime, outputSituationName, outputIndicators, forceProcess)

    if or(~check_trip_meta(trip,['calcul_' mfilename '_' outputSituationName],'OK'), forceProcess == 1) && trip.getMetaInformations.existEvent(inputEventName) && ~trip.getAllEventOccurences(inputEventName).isEmpty
        
        disp(['Calculating ' mfilename  ' on situation ' outputSituationName ' for trip : ' trip.getTripPath]);
        
        %% get data
        strsplit(outputSituationName, '_');
        delta = str2double(outputSituationName(1:strfind(outputSituationName, '_')-1));
        record = trip.getEventOccurencesInTimeInterval(inputEventName, startTime-delta, endTime+10);
        for i_var = 1:length(inputVariablesNames)
            var.(inputVariablesNames{i_var}) = cell2mat(record.getVariableValues(inputVariablesNames{i_var}));
        end
        
        %% calculate indicators
        commentaire = cell2mat(trip.getEventOccurenceAtTime('DR2_Commentaires', startTime-delta).getVariableValues('commentaire0'));
        if contains(commentaire, '_')
            indicators.situation = commentaire(5:7);
            indicators.level = str2double(commentaire(end));
        else
            indicators.situation = commentaire;
            indicators.level = [];
        end
        indicators.disconfort = var.(inputVariablesNames{end})(end);
        indicators.duration = endTime - startTime;
        
        %% display and add indicators to the trip
%         removeSituationVariables(trip, outputSituationName, outputIndicators)
        for i = 1:length(outputIndicators)
            disp(['[' num2str(startTime) ';' num2str(endTime) '] ' outputIndicators{i} ' = ' num2str(indicators.(outputIndicators{i}))]);
            if isa(class(indicators.(outputIndicators{i})), 'double')
                addSituationVariable2Trip(trip, outputSituationName, outputIndicators{i}, 'REAL');
            elseif isa(class(indicators.(outputIndicators{i})), 'char')
                addSituationVariable2Trip(trip, outputSituationName, outputIndicators{i}, 'TEXT');
            end
            trip.setSituationVariableAtTime(outputSituationName, outputIndicators{i}, startTime, endTime, indicators.(outputIndicators{i}));
        end
        
    elseif check_trip_meta(trip,['calcul_' mfilename '_' outputSituationName],'OK') && forceProcess == 0
        disp(['Process "' mfilename '" already calculated for trip : ' trip.getTripPath]);
    elseif trip.getMetaInformations.existEvent(inputEventName) && ~trip.getAllEventOccurences(inputEventName).isEmpty
        disp([inputEventName ' is empty or missing from trip : ' trip.getTripPath]);
    end
    trip.setAttribute(['calcul_' mfilename '_' outputSituationName], 'OK');
end