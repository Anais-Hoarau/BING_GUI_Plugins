function exportTripSituation2TSVByParticipant_CAPADYN(trip_file, file_id, header, situation_id, situations_to_get_TC)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);

split_trip = strsplit(trip_file, filesep);
split_filename = strsplit(split_trip{end}, '.');
id_participant = split_filename{1};
reg_participant = regexp(id_participant, '_');
id_scenario = trip.getAttribute('id_scenario');
id_groupe = trip.getAttribute('id_groupe');
session_date = id_participant(reg_participant(2)+1:reg_participant(3)-1);
session_time = id_participant(reg_participant(3)+1:end);

startTC_occurences = trip.getAllSituationOccurences(situations_to_get_TC).getVariableValues('startTimecode');
endTC_occurences = trip.getAllSituationOccurences(situations_to_get_TC).getVariableValues('endTimecode');

for i_startTC = 1:length(startTC_occurences)
    if strcmp(situation_id, 'stim_audio')
        situation_occurences = trip.getEventOccurencesInTimeInterval(situation_id,startTC_occurences{i_startTC},endTC_occurences{i_startTC});
        situation_variable_names = trip.getMetaInformations().getEventVariablesNamesList(situation_id);
    else
        situation_occurences = trip.getSituationOccurencesInTimeInterval(situation_id,startTC_occurences{i_startTC},endTC_occurences{i_startTC});
        situation_variable_names = trip.getMetaInformations().getSituationVariablesNamesList(situation_id);
    end
    occurrences = situation_occurences.getVariableValues(situation_variable_names(1));
    
    %% EXPORT TRIP INFORMATIONS AND SITUATION DATA
    for i_occurrence = 1:length(occurrences)
        fprintf(file_id.(situation_id), '%s\t', id_participant(1:reg_participant(1)-1));
        fprintf(file_id.(situation_id), '%s\t', id_groupe);
        fprintf(file_id.(situation_id), '%s\t', id_scenario);
        fprintf(file_id.(situation_id), '%s\t', [situation_id '_' num2str(i_occurrence)]);
        fprintf(file_id.(situation_id), '%s\t', session_date);
        fprintf(file_id.(situation_id), '%s\t', session_time);
        for i_header = 7:length(header)
%             mask_variable = strfind(situation_variable_names, header{i_header});
            indice_variable = [];
            for i_var = 1:length(situation_variable_names)
                if strcmp(situation_variable_names{i_var},header{i_header})
                    indice_variable = i_var;
                end
            end
            if ~isempty(indice_variable)
                occurrences = situation_occurences.getVariableValues(situation_variable_names(indice_variable));
                if ischar(occurrences{i_occurrence})
                    fprintf(file_id.(situation_id), '%s\t', occurrences{i_occurrence});
                else
                    fprintf(file_id.(situation_id), '%f\t', occurrences{i_occurrence});
                end
            else
                fprintf(file_id.(situation_id), '%s\t', '');
            end
        end
        fprintf(file_id.(situation_id), '\n');
    end
end
delete(trip);
end