function out = atlas_sync_mopad_video(trip,full_directory,participant_name,sync_method)
    out = '';
    data_file = [full_directory filesep 'atlas_structure_' participant_name '.mat'];
    load(data_file);
    atlas.(participant_name).mopad = sync_mopad_video_clap(atlas.(participant_name).mopad ,full_directory,sync_method,'Synchrovideo','TopCons');
    save(data_file,'atlas');
end