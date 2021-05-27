function out = TestsQualite_kvaser2struct(trip,full_directory,participant_name)
    out = '';
    data_file = [full_directory filesep 'TestsQualite_structure_' participant_name '.mat'];
    load(data_file);
    kvaser_file_name = [full_directory filesep participant_name '_kvaser.mat'];
    TestsQualite.(participant_name).kvaser = import_kvaser_struct(kvaser_file_name);
    save(data_file,'TestsQualite');
end