file_list = dirrec('Y:\CODAGE\DATA_LEOST\TTC_LEOST\site1_ttc','.ttc');
folder_dest = 'Y:\CODAGE\TRIPS';
folder_list = dir(folder_dest)';
file_paths = {};
for i_file = 1:length(file_list)
    file_path = file_list{i_file};
    file_name = strsplit(file_path,filesep);
    file_name_without_extension = strsplit(file_name{end},'.');
    for i_folder = 1:length(folder_list)
        folder_name = [folder_dest filesep folder_list(i_folder).name];
        if isdir(folder_name) && strcmp(folder_list(i_folder).name,file_name_without_extension{1})
            file_paths = [file_paths, {file_path}];
            copyfile(file_path,folder_name)
            break
        end
    end
end
disp(length(file_list))
disp(length(file_paths))