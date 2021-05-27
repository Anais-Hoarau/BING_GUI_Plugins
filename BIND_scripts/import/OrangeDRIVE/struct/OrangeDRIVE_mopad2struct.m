function out =  OrangeDRIVE_mopad2struct(trip,full_directory,participant_name)
    out = '';
    
    OrangeDRIVE.(participant_name).mopad = import_mopad_struct_2(full_directory);
    data_file = [full_directory filesep 'OrangeDRIVE_structure_' participant_name '.mat'];
    save(data_file,'OrangeDRIVE');
end