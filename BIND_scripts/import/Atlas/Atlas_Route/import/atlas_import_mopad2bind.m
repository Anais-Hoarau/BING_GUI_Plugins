function out = atlas_import_mopad2bind(trip,full_directory,participant_name)
    out = '';
    data_file = [full_directory filesep 'atlas_structure_' participant_name '.mat'];
    load(data_file);
    import_data_struct_in_bind_trip(atlas.(participant_name).mopad,trip,'Mopad');
end