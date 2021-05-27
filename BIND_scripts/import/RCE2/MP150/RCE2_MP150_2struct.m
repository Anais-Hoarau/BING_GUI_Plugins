function out = atlas_MP150_2struct(trip,full_directory,participant_name)
    out = '';
    
    data_file = [full_directory filesep 'atlas_structure_' participant_name '.mat'];
    load(data_file);
    
    MP150_file_name = [full_directory filesep 'MP150.mat'];
    atlas.(participant_name).MP150 = import_MP150_struct(MP150_file_name);
    
    %Sauvegarde de la structure créee
    save(data_file,'atlas');


end
