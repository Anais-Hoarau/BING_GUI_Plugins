function out = TestsQualite_sync_mopad_video(trip,full_directory,participant_name,sync_method)
    out = '';
    data_file = [full_directory filesep 'TestsQualite_structure_' participant_name '.mat'];
    load(data_file);
    TestsQualite.(participant_name).mopad = sync_mopad_video_clap(TestsQualite.(participant_name).mopad ,full_directory,sync_method,'Synchrovideo','TopCons');
    save(data_file,'TestsQualite');
end