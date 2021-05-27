csv_files_list = dirrec('Y:\CODAGE\DATA_LEOST\Trajectoires_LEOST\csv','.csv');
ddd_files_list = dirrec('Y:\CODAGE\DATA_LEOST\Trajectoires_LEOST\csv.3d','.3d');
ttc_files_list = dirrec('Y:\CODAGE\DATA_LEOST\TTC_LEOST','.ttc');

missing_ddd_files_csv = {};
missing_ttc_files_csv = {};
missing_csv_files_ddd = {};
missing_ttc_files_ddd = {};
missing_csv_files_ttc = {};
missing_ddd_files_ttc = {};

ddd_files_ok_csv = 0;
ttc_files_ok_csv = 0;
csv_files_ok_ddd = 0;
ttc_files_ok_ddd = 0;
csv_files_ok_ttc = 0;
ddd_files_ok_ttc = 0;

for i_csv = 1:length(csv_files_list)
    csv_file = strsplit(csv_files_list{i_csv}, '\');
    if ~isempty(cell2mat(strfind(ddd_files_list, csv_file{end}(1:end-4))))
       ddd_files_ok_csv = ddd_files_ok_csv + 1;
    else
        missing_ddd_files_csv = [missing_ddd_files_csv, csv_file{end}(1:end-4)];
    end
    if ~isempty(cell2mat(strfind(ttc_files_list, csv_file{end}(1:end-4))))
       ttc_files_ok_csv = ttc_files_ok_csv + 1;
    else
        missing_ttc_files_csv = [missing_ttc_files_csv, csv_file{end}(1:end-4)];
    end
end

for i_ddd = 1:length(ddd_files_list)
    ddd_file = strsplit(ddd_files_list{i_ddd}, '\');
    if ~isempty(cell2mat(strfind(csv_files_list, ddd_file{end}(1:end-4))))
       csv_files_ok_ddd = csv_files_ok_ddd + 1;
    else
        missing_csv_files_ddd = [missing_csv_files_ddd, ddd_file{end}(1:end-4)];
    end
    if ~isempty(cell2mat(strfind(ttc_files_list, ddd_file{end}(1:end-4))))
       ttc_files_ok_ddd = ttc_files_ok_ddd + 1;
    else
        missing_ttc_files_ddd = [missing_ttc_files_ddd, ddd_file{end}(1:end-4)];
    end
end

for i_ttc = 1:length(ttc_files_list)
    ttc_file = strsplit(ttc_files_list{i_ttc}, '\');
    if ~isempty(cell2mat(strfind(csv_files_list, ttc_file{end}(1:end-4))))
       csv_files_ok_ttc = csv_files_ok_ttc + 1;
    else
        missing_csv_files_ttc = [missing_csv_files_ttc, ttc_file{end}(1:end-4)];
    end
    if ~isempty(cell2mat(strfind(ddd_files_list, ttc_file{end}(1:end-4))))
       ddd_files_ok_ttc = ddd_files_ok_ttc + 1;
    else
        missing_ddd_files_ttc = [missing_ddd_files_ttc, ttc_file{end}(1:end-4)];
    end
end

missing_ddd_files_csv = missing_ddd_files_csv';
missing_ttc_files_csv = missing_ttc_files_csv';
missing_csv_files_ddd = missing_csv_files_ddd';
missing_ttc_files_ddd = missing_ttc_files_ddd';
missing_csv_files_ttc = missing_csv_files_ttc';
missing_ddd_files_ttc = missing_ddd_files_ttc';

%% Copy files
file_list = dirrec('Y:\CODAGE\DATA_LEOST\Trajectoires_LEOST\csv','.csv');
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