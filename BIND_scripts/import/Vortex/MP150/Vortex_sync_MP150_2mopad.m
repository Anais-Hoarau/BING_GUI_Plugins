function out = Vortex_sync_MP150_2mopad(trip,full_directory,participant_name,sync_method)
    
    out = '';
    
    
    data_file = [full_directory filesep 'atlas_structure_' participant_name '.mat'];
    load(data_file);
    
    atlas.(participant_name).MP150 = sync_MP150_mopad(atlas.(participant_name).MP150,atlas.(participant_name).mopad,sync_method,'Synchrovideo','TopCons','data','TopCons');
    
    save(data_file,'atlas');
    
    
end