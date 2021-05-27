function out =  safemove_mopad2struct(trip,full_directory,sujet)
    out = '';
    safemove.mopad = import_mopad_struct(full_directory);
    data_file = [full_directory filesep sujet '_safemove.mat'];
    save(data_file,'safemove');
end