function exportTripSituation2TSVByParticipant_RCE2_breathing(trip_file, file_id, event_id)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);

split_trip = strsplit(trip_file, filesep);
split_filename = strsplit(split_trip{end}, '.');
id_participant = split_filename{1};
reg_participant = regexp(id_participant, '_');
id_groupe = trip.getAttribute('id_groupe');
id_scenario = trip.getAttribute('id_scenario');
session_date = trip.getAttribute('session_date');
session_time = trip.getAttribute('session_time');

event_data = trip.getAllEventOccurences(event_id);
events = event_data.getVariableValues('name');
events_timecodes = cell2mat(event_data.getVariableValues('timecode'));

%% EXPORT SITUATION DATA
for i_event = 1:length(events)
    %% EXPORT TRIP INFORMATIONS
    fprintf(file_id, '%s\t', id_participant(1:reg_participant(1)-1));
    fprintf(file_id, '%s\t', id_groupe); %id_groupe(reg_groupe(1)+1:end));
    fprintf(file_id, '%s\t', id_scenario);
    fprintf(file_id, '%s\t', session_date);
    fprintf(file_id, '%s\t', session_time);
    fprintf(file_id, '%s\t', events{i_event});
    
    if trip.getMetaInformations().existData('MP150_data')
        breathing_values = cell2mat(trip.getDataOccurencesInTimeInterval('MP150_data', events_timecodes(i_event)-6, events_timecodes(i_event)+6).getVariableValues('Respiration'));
        timecodes_values = cell2mat(trip.getDataOccurencesInTimeInterval('MP150_data', events_timecodes(i_event)-6, events_timecodes(i_event)+6).getVariableValues('timecode'));
        breathing_values_interp = interp1(timecodes_values-timecodes_values(1), breathing_values, 0:0.1:12);
        fprintf(file_id, '%f\t', breathing_values_interp);
    end
    
    fprintf(file_id, '\n');
    
end
delete(trip);
end