function out = atlas_import_MP150_2bind(trip,full_directory,participant_name)
    out = '';
    data_file = [full_directory filesep 'atlas_structure_' participant_name '.mat'];
    load(data_file);
    atlas.(participant_name).MP150.data.Cardiaque_filtre.comments = 'no comment';
    struct_MP150 = atlas.(participant_name).MP150;
    clear atlas
    
    import_data_struct_in_bind_trip(struct_MP150,trip,'MP150');
end