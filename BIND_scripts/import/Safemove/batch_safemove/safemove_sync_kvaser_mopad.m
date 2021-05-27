function out = safemove_sync_kvaser_mopad(trip,full_directory,sujet,sync_method)
    out = '';
    data_file = [full_directory filesep sujet '_safemove.mat'];
    load(data_file);

   % Synchro entre TopCons (mopad instrumentation Lescot) et Contact_Frein1 (kvaser)
   safemove.kvaser = sync_kvaser_mopad(safemove.kvaser,safemove.mopad,sync_method,'Synchrovideo','TopCons','BSI','CONTACT_FREIN1');

   % OU %

   % Synchro entre Contact_Frein1 (mopad CAN) et Contact_Frein1 (kvaser)
%    safemove.kvaser = sync_kvaser_mopad(safemove.kvaser,safemove.mopad,sync_method,'CAN','CONTACT_FREIN1','BSI','CONTACT_FREIN1');


save(data_file,'safemove');
    
    
end