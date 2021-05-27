function out = atlas_import_partiel_kvaser2bind_1(trip,full_directory,participant_name)
    out = '';
    data_file = [full_directory filesep 'atlas_structure_' participant_name '.mat'];
    load(data_file);
    
    % On ne garge que les parties de la structure que l'on veut importer
    atlas.(participant_name) = rmfield(atlas.(participant_name), 'mopad'); %#ok
    
    kvaser_partiel = struct;
    kvaser_partiel.META = atlas.(participant_name).kvaser.META;
    kvaser_partiel.BSI = atlas.(participant_name).kvaser.BSI;
    kvaser_partiel.CMM2 = atlas.(participant_name).kvaser.CMM2;
    kvaser_partiel.VOL = atlas.(participant_name).kvaser.VOL;
    kvaser_partiel.LDW1 = atlas.(participant_name).kvaser.LDW1;
    kvaser_partiel.LDW2 = atlas.(participant_name).kvaser.LDW2;
    kvaser_partiel.LDW3 = atlas.(participant_name).kvaser.LDW3;
    kvaser_partiel.ABR = atlas.(participant_name).kvaser.ABR;
    kvaser_partiel.SLA = atlas.(participant_name).kvaser.SLA;
    clear atlas
    
    import_data_struct_in_bind_trip(kvaser_partiel,trip,'Kvaser');
end