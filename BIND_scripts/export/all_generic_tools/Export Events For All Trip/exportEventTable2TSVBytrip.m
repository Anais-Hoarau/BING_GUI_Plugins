function exportEventTable2TSVBytrip(trip_file, file_id, event_id)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    split_trip = strsplit(trip_file, filesep);
    trip_id = cell2mat(strsplit(split_trip{end-1}, '.'));
    
    %% GET TRIP INFORMATIONS
    if existEvent(trip.getMetaInformations(),event_id)
        event_occurences = trip.getAllEventOccurences(event_id);
        event_variable_names = trip.getMetaInformations().getEventVariablesNamesList(event_id);
    else
        return
    end
    
    %% EXPORT EVENT DATA
    modalities = event_occurences.getVariableValues(event_variable_names(1));
    for i_modalities = 1:length(modalities)
        fprintf(file_id, '%s\t', trip_id);
        for i_var = 1:1:length(event_variable_names)
            var = event_occurences.getVariableValues(event_variable_names(i_var));
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
    
end