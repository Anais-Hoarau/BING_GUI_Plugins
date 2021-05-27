function out = TestsQualite_import_kvaser2bind(trip,full_directory,participant_name)
    out = '';
    data_file = [full_directory filesep 'TestsQualite_structure_' participant_name '.mat'];
    load(data_file);
    import_data_struct_in_bind_trip(TestsQualite.(participant_name).kvaser,trip,'Kvaser');
end