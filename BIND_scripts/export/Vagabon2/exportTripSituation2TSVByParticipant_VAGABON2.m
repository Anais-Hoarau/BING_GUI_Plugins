function exportTripSituation2TSVByParticipant_VAGABON2(trip_file, file_id, situation_id, situations_to_get_TC)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);

split_trip = strsplit(trip_file, filesep);
split_filename = strsplit(split_trip{end}, '.');
id_participant = split_filename{1};
reg_participant = regexp(id_participant, '_');
id_scenario = trip.getAttribute('id_scenario');
session_date = trip.getAttribute('session_date');
session_time = trip.getAttribute('session_time');

startTC_occurences = trip.getAllSituationOccurences(situations_to_get_TC).getVariableValues('startTimecode');
endTC_occurences = trip.getAllSituationOccurences(situations_to_get_TC).getVariableValues('endTimecode');
names_occurences = trip.getAllSituationOccurences(situations_to_get_TC).getVariableValues('name');

for i_startTC = 1:length(startTC_occurences)
    situation_occurences = trip.getSituationOccurencesInTimeInterval(situation_id,startTC_occurences{i_startTC},endTC_occurences{i_startTC});
    situation_occurences_startTimecodes = situation_occurences.getVariableValues('startTimecode');
    situation_occurences_endTimecodes = situation_occurences.getVariableValues('endTimecode');
    situation_variable_names = trip.getMetaInformations().getSituationVariablesNamesList(situation_id);
    occurrences = situation_occurences.getVariableValues(situation_variable_names(1));
    
    first_occurrence = 1;
    last_occurrence = length(occurrences);
    % filtering of self-report which are not consistent (not the same number of self-responses before and after)
    if strcmp(situation_id,'self_report_before')
        if ~isempty(situation_occurences_startTimecodes) && (situation_occurences_endTimecodes{end}+6) >= endTC_occurences{i_startTC}
            last_occurrence = length(occurrences)-1;
        end
    elseif strcmp(situation_id,'self_report_after')
        if ~isempty(situation_occurences_startTimecodes) && (situation_occurences_startTimecodes{1} - 6) <= startTC_occurences{i_startTC}
            first_occurrence = 2;
        end
    end
    
    %% EXPORT TRIP INFORMATIONS AND SITUATION DATA
    for i_occurrence = first_occurrence:last_occurrence
        fprintf(file_id.(situation_id), '%s\t', id_participant(1:reg_participant(1)-1));
        fprintf(file_id.(situation_id), '%s\t', id_scenario);
        fprintf(file_id.(situation_id), '%s\t', [situation_id '_' num2str(i_occurrence)]);
        fprintf(file_id.(situation_id), '%s\t', session_date);
        fprintf(file_id.(situation_id), '%s\t', session_time);
        for i_var = 4:length(situation_variable_names)
            occurrences = situation_occurences.getVariableValues(situation_variable_names(i_var));
            if ischar(occurrences{i_occurrence})
                fprintf(file_id.(situation_id), '%s\t', occurrences{i_occurrence});
            else
                fprintf(file_id.(situation_id), '%f\t', occurrences{i_occurrence});
            end
        end
        fprintf(file_id.(situation_id), '\n');
    end
end
delete(trip);
end