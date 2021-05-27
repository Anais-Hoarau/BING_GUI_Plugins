function out = safemove_sync_mopad_video(trip,full_directory,sujet,sync_method)
    out = '';
    data_file = [full_directory filesep sujet '_safemove.mat'];
    load(data_file);
    safemove.mopad = sync_mopad_video_clap(safemove.mopad,full_directory,sync_method,'Synchrovideo','TopCons');
    save(data_file,'safemove');
end