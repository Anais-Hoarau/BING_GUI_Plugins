function exportTripSituation2TSVByTrip_CAPADYN(trip_file, file_id, situation_id)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);

split_trip = strsplit(trip_file, filesep);
split_filename = strsplit(split_trip{end}, '.');
id_participant = split_filename{1};
id_groupe = trip.getAttribute('id_groupe');
reg_groupe = regexp(id_groupe, '_');
id_scenario = trip.getAttribute('id_scenario');
% reg_participant = regexp(id_participant, '_');
% session_date = trip.getAttribute('session_date');
% session_time = trip.getAttribute('session_time');

%% EXPORT TRIP INFORMATIONS

% situation_id = regexprep(situation_id, '_', ' ');
situation_data = trip.getAllSituationOccurences(situation_id);
situation_variable_names = trip.getMetaInformations().getSituationVariablesNamesList(situation_id);

%% EXPORT SITUATION DATA
modalities = situation_data.getVariableValues(situation_variable_names(3));
for i_modalities = 1:length(modalities)
    fprintf(file_id, '%s\t', id_participant);
    fprintf(file_id, '%s\t', id_groupe(reg_groupe(1)+1:end));
    fprintf(file_id, '%s\t', id_scenario);
    for i_var = 4:1:length(situation_variable_names)
        var = situation_data.getVariableValues(situation_variable_names(i_var));
        if isfloat(var{i_modalities})
            fprintf(file_id, '%f\t', var{i_modalities});
        else
            fprintf(file_id, '%s\t', var{i_modalities});
        end
    end
    fprintf(file_id, '\n');
end
delete(trip)