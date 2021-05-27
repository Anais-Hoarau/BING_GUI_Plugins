function out =  atlas_mopad2struct(trip,full_directory,participant_name)
    out = '';
    
    atlas.(participant_name).mopad = import_mopad_struct_2(full_directory);
    data_file = [full_directory filesep 'atlas_structure_' participant_name '.mat'];
    save(data_file,'atlas');
end