function out = SafeMoveSP2_sync_mopad_video(trip,full_directory,participant_name,sync_method)
    out = '';
    data_file = [full_directory filesep 'SafeMoveSP2_structure_' participant_name '.mat'];
    load(data_file);
    SafeMoveSP2.(participant_name).mopad = sync_mopad_video_clap(SafeMoveSP2.(participant_name).mopad ,full_directory,sync_method,'Synchrovideo','TopCons');
    save(data_file,'SafeMoveSP2');
end