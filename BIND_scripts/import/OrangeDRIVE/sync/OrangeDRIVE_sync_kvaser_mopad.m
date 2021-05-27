function out = OrangeDRIVE_sync_kvaser_mopad(trip,full_directory,participant_name,sync_method)

out = '';
data_file = [full_directory filesep 'OrangeDRIVE_structure_' participant_name '.mat'];
load(data_file);

%% Synchro entre TopCons (mopad instrumentation Lescot) et Contact_Frein1 (kvaser)

OrangeDRIVE.(participant_name).kvaser = sync_kvaser_mopad(OrangeDRIVE.(participant_name).kvaser,OrangeDRIVE.(participant_name).mopad,sync_method,'Synchrovideo','TopCons','BSI','CONTACT_FREIN1');

% OU %

%% Synchro entre Contact_Frein1 (mopad CAN) et Contact_Frein1 (kvaser)

% safemove.test.kvaser = sync_kvaser_mopad(safemove.test.kvaser,safemove.test.mopad,sync_method,'CAN','CONTACT_FREIN1','BSI','CONTACT_FREIN1');

%% Sauvegarde

save(data_file,'OrangeDRIVE');

end