% duplicate and save trip files with extension ".trip_save_date_time"
function SaveTrip(full_directory)
    trip_list = dirrec(full_directory, '.trip');
    dateTime = datestr(now, 'yyyymmdd_HHMM');
    for i_trip = 1:length(trip_list)
        source = trip_list{i_trip};
        destination = [trip_list{i_trip} '_save_' dateTime];
        disp([trip_list{i_trip} '_save_' dateTime]);
        copyfile(source,destination);
    end
end