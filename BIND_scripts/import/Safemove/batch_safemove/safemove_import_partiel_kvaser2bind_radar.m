function out = safemove_import_partiel_kvaser2bind_radar(trip,full_directory,sujet)
    out = '';
    data_file = [full_directory filesep sujet '_safemove.mat'];
    load(data_file);
    kvaser_partiel = struct;
    kvaser_partiel.META = safemove.kvaser.META;
    kvaser_partiel.ARSSt = safemove.kvaser.ARSSt;
    kvaser_partiel.ARS1 = safemove.kvaser.ARS1;
    kvaser_partiel.ARS2 = safemove.kvaser.ARS2;
    import_data_struct_in_bind_trip(kvaser_partiel,trip,'Kvaser');
end


