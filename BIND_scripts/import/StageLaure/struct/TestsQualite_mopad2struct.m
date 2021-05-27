function out =  TestsQualite_mopad2struct(trip,full_directory,participant_name)
    out = '';
    
    TestsQualite.(participant_name).mopad = import_mopad_struct_2(full_directory);
    data_file = [full_directory filesep 'TestsQualite_structure_' participant_name '.mat'];
    save(data_file,'TestsQualite');
end