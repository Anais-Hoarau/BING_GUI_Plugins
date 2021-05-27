function out = OrangeDRIVE_sync_mopad_video(trip,full_directory,participant_name,sync_method)
    out = '';
    data_file = [full_directory filesep 'OrangeDRIVE_structure_' participant_name '.mat'];
    load(data_file);
    OrangeDRIVE.(participant_name).mopad = sync_mopad_video_clap(OrangeDRIVE.(participant_name).mopad ,full_directory,sync_method,'Synchrovideo','TopCons');
    save(data_file,'OrangeDRIVE');
end