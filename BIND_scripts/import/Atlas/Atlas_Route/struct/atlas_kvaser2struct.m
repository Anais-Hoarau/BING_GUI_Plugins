function out = atlas_kvaser2struct(trip,full_directory,participant_name)
    out = '';
    data_file = [full_directory filesep 'atlas_structure_' participant_name '.mat'];
    load(data_file);
    kvaser_file_name = [full_directory filesep 'kvaser.mat'];
    atlas.(participant_name).kvaser = import_kvaser_struct(kvaser_file_name);
    save(data_file,'atlas');
end