function exportTripDataBySituation2TSVByParticipant(trip_file, file_id, situationName, dataName, variableName, subsampling)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    %     id_participant = trip.getAttribute('id_participant');
    trip_file_split = strsplit(trip_file, '\');
    id_participant = trip_file_split{end}(1:end-4);
    id_scenario = trip.getAttribute('id_scenario');
    
    startTC_occurrences = trip.getAllSituationOccurences(situationName).getVariableValues('startTimecode');
    endTC_occurrences = trip.getAllSituationOccurences(situationName).getVariableValues('endTimecode');
    names_occurrences = trip.getAllSituationOccurences(situationName).getVariableValues('name');
    
    %% EXPORT SITUATION DATA
    for i_occurrence = 1:length(startTC_occurrences)
        fprintf(file_id, '%s\t', id_participant);
        fprintf(file_id, '%s\t', id_scenario);
        fprintf(file_id, '%f\t', startTC_occurrences{i_occurrence});
        fprintf(file_id, '%f\t', endTC_occurrences{i_occurrence});
        fprintf(file_id, '%s\t', names_occurrences{i_occurrence});
        if trip.getMetaInformations().existDataVariable(dataName, variableName)
            variable_values = trip.getDataOccurencesInTimeInterval(dataName,startTC_occurrences{i_occurrence},endTC_occurrences{i_occurrence}).getVariableValues(variableName);
            for i_value = 1:subsampling:length(variable_values)
                if strcmp(variableName,'HRinterp')
                    fprintf(file_id, '%f\t', variable_values{i_value});
                end
            end
        end
        fprintf(file_id, '\n');
        clear 'variable_data'
    end
    delete(trip);
end