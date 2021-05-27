function out = safemove_import_kvaser2bind(trip,full_directory,sujet)
    out = '';
    data_file = [full_directory filesep sujet '_safemove.mat'];
    load(data_file);
    import_data_struct_in_bind_trip(safemove.kvaser,trip,'Kvaser');
end