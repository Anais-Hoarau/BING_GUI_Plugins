function out = safemove_kvaser2struct(trip,full_directory,sujet)
    out = '';
    data_file = [full_directory filesep sujet '_safemove.mat'];
    load(data_file);
    kvaser_file_name = [full_directory filesep sujet '_kvaser.mat'];
    safemove.kvaser = import_kvaser_struct(kvaser_file_name);
    save(data_file,'safemove');
end