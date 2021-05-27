function out = safemove_import_mopad2bind(trip,full_directory,sujet)
    out = '';
    data_file = [full_directory filesep sujet '_safemove.mat'];
    load(data_file);
    import_data_struct_in_bind_trip(safemove.mopad,trip,'Mopad');
end