% duplicate and save files with extension ".ext_save_date_time"
function SaveFile(full_directory,extension)
    file_list = dirrec(full_directory, extension);
    dateTime = datestr(now, 'yyyymmdd_HHMM');
    for i_file = 1:length(file_list)
        source = file_list{i_file};
        destination = [file_list{i_file} '_save_' dateTime];
        copyfile(source,destination);
    end
end