function addComments2Events(trip_file, comments_table_name,comments_column_name)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    if trip.getMetaInformations().existEvent('all_simu_comments')
        removeEventsTables(trip, {'all_simu_comments'})
    end
    timecodes = trip.getAllDataOccurences(comments_table_name).getVariableValues('timecode');
    comments = trip.getAllDataOccurences(comments_table_name).getVariableValues(comments_column_name);
    addEventTable2Trip(trip, 'all_simu_comments', 'comment', 'importe depuis le simulateur')
    addEventVariable2Trip(trip, 'all_simu_comments', 'comment', 'TEXT')
    for i = 1:length(comments)
        if ~isempty(comments{i})
            timecode = timecodes(i);
            comment_splited = strsplit(comments{i}, '__');
            comment_parsed = comment_splited(end);
            trip.setBatchOfTimeEventVariablePairs('all_simu_comments', 'comment', [timecode, comment_parsed]')
        end
    end
    trip.setAttribute('add_comments2Events', 'OK');
    delete(trip)
end

