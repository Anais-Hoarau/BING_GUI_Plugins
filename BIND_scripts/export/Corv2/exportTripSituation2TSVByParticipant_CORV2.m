function exportTripSituation2TSVByParticipant_CORV2(trip_file, file_id, situation_id)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);

split_trip = strsplit(trip_file, filesep);
split_filename = strsplit(split_trip{end}, '.');
id_participant = split_filename{1};
reg_participant = regexp(id_participant, '_');
id_groupe = trip.getAttribute('id_groupe');
reg_groupe = regexp(id_groupe, '_');
session_date = trip.getAttribute('session_date');
session_time = trip.getAttribute('session_time');

%% EXPORT TRIP INFORMATIONS

situation_data = trip.getAllSituationOccurences(situation_id);
situation_variable_names = trip.getMetaInformations().getSituationVariablesNamesList(situation_id);

%% EXPORT SITUATION DATA
essais = situation_data.getVariableValues(situation_variable_names(3));
for i_essai = 1:length(essais)
    fprintf(file_id, '%s\t', id_participant(1:reg_participant(1)-1));
    fprintf(file_id, '%s\t', id_groupe(reg_groupe(1)+1:end));
    fprintf(file_id, '%s\t', session_date);
    fprintf(file_id, '%s\t', session_time);
    if strcmp(situation_id, 'detection_centre') || strcmp(situation_id, 'detection_periph')
        fprintf(file_id, '%s\t', situation_id);
        fprintf(file_id, '%s\t', essais{i_essai});
    end
    for i_var = 4:length(situation_variable_names)
        var = situation_data.getVariableValues(situation_variable_names(i_var));
        fprintf(file_id, '%f\t', var{i_essai});
    end
    fprintf(file_id, '\n');
    delete(trip);
end