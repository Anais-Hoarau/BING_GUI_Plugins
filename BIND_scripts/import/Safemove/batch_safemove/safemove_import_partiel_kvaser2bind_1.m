function out = safemove_import_partiel_kvaser2bind_1(trip,full_directory,sujet)
    out = '';
    data_file = [full_directory filesep sujet '_safemove.mat'];
    load(data_file);
    kvaser_partiel = struct;
    kvaser_partiel.META = safemove.kvaser.META;
    kvaser_partiel.ABR=safemove.kvaser.ABR;
    kvaser_partiel.ACCEL=safemove.kvaser.ACCEL;
    kvaser_partiel.BSI=safemove.kvaser.BSI;
    kvaser_partiel.CLIM=safemove.kvaser.CLIM;
    kvaser_partiel.CMM2=safemove.kvaser.CMM2;
    kvaser_partiel.CMM3=safemove.kvaser.CMM3;
    kvaser_partiel.CMM4=safemove.kvaser.CMM4;
    kvaser_partiel.LDW1=safemove.kvaser.LDW1;
    kvaser_partiel.LDW2=safemove.kvaser.LDW2;
    kvaser_partiel.LDW3=safemove.kvaser.LDW3;
    kvaser_partiel.SLA=safemove.kvaser.SLA;
    kvaser_partiel.VOL=safemove.kvaser.VOL;
    kvaser_partiel.VROUES=safemove.kvaser.VROUES;
    import_data_struct_in_bind_trip(kvaser_partiel,trip,'Kvaser');
end


