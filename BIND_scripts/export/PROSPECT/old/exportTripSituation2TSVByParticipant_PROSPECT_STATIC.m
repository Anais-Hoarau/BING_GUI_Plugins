function exportTripSituation2TSVByParticipant_PROSPECT_STATIC(trip_file, file_id, header, situation_id)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
split_trip_file = strsplit(trip_file, filesep);
split_trip_name = strsplit(split_trip_file{end}, '.');
trip_name = split_trip_name{1};
reg_scenario = regexp(trip_name, '_');
session_date = trip_name(1:reg_scenario(1)-1);
session_time = trip_name(reg_scenario(1)+1:reg_scenario(2)-1);

startTC_occurences = trip.getAllSituationOccurences(situation_id).getVariableValues('startTimecode');
endTC_occurences = trip.getAllSituationOccurences(situation_id).getVariableValues('endTimecode');

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
        situation_id_corrected = regexprep(situation_id, ' ', '_'); % to uncoment if separator is ' '
        fprintf(file_id.(situation_id_corrected), '%s\t', trip_name);
        fprintf(file_id.(situation_id_corrected), '%s\t', session_date);
        fprintf(file_id.(situation_id_corrected), '%s\t', session_time);
        for i_header = 4:length(header)
            mask_variable = strfind(situation_variable_names, header{i_header});
            indice_variable = [];
            for i_var = 1:length(mask_variable)
                if mask_variable{i_var} == 1
                    indice_variable = i_var;
                end
            end
            if ~isempty(indice_variable)
                occurrences = situation_occurences.getVariableValues(situation_variable_names(indice_variable));
                if ischar(occurrences{i_occurrence})
                    fprintf(file_id.(situation_id_corrected), '%s\t', occurrences{i_occurrence});
                else
                    fprintf(file_id.(situation_id_corrected), '%f\t', occurrences{i_occurrence});
                end
            else
                fprintf(file_id.(situation_id_corrected), '%s\t', '');
            end
        end
        fprintf(file_id.(situation_id_corrected), '\n');
    end
end
delete(trip);
end