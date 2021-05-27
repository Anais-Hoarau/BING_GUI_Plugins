function out =  SafeMoveSP2_mopad2struct(trip,full_directory,participant_name)
    out = '';
    
    SafeMoveSP2.(participant_name).mopad = import_mopad_struct_2(full_directory);
    data_file = [full_directory filesep 'SafeMoveSP2_structure_' participant_name '.mat'];
    save(data_file,'SafeMoveSP2');
end