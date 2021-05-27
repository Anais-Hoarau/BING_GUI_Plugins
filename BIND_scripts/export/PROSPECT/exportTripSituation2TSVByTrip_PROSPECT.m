function exportTripSituation2TSVByTrip_PROSPECT(trip_file, file_id, situation_id)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
split_trip = strsplit(trip_file, filesep);
split_filename = strsplit(split_trip{end}, '.');
trip_id = split_filename{1};

%% GET TRIP INFORMATIONS
if existSituation(trip.getMetaInformations(),situation_id)
    situation_occurences = trip.getAllSituationOccurences(situation_id);
    situation_variable_names = trip.getMetaInformations().getSituationVariablesNamesList(situation_id);
else
    return
end

%% EXPORT SITUATION DATA
modalities = situation_occurences.getVariableValues(situation_variable_names(1));
for i_modalities = 1:length(modalities)
    fprintf(file_id, '%s\t', trip_id);
    for i_var = 1:1:length(situation_variable_names)
        var = situation_occurences.getVariableValues(situation_variable_names(i_var));
        if isfloat(var{i_modalities})
            fprintf(file_id, '%f\t', var{i_modalities});
        else
            fprintf(file_id, '%s\t', var{i_modalities});
        end
    end
    fprintf(file_id, '\n');
end
delete(trip);
delete(timerfindall);