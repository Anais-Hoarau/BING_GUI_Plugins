% tracé des valeurs de frein du CAN et de Mopad
% à partir d'une strcutre déja dans le workspace

%% Chargement des données
% mopad
tps_mopad=safemove.mopad.SensorsMeasures.time_sync.values;
tps_mopadCAN=safemove.mopad.CAN.time_sync.values;
Brake=safemove.mopad.SensorsMeasures.Brake.values;
Accelerator=safemove.mopad.SensorsMeasures.Accelerator.values;
pourcentBrake=safemove.mopad.SensorsData.POURCENT_Brake.values;
ContactFreinMopad=safemove.mopad.CAN.CONTACT_FREIN1.values;
TopCons=safemove.mopad.Synchrovideo.TopCons.values;
swa_mop=safemove.mopad.SensorsMeasures.SteeringwheelAngle.values;

% CAN
tps_kvaser=safemove.kvaser.BSI.time_sync.values;
FreinCan=safemove.kvaser.BSI.CONTACT_FREIN1.values;
tps_kvaVOL=safemove.kvaser.VOL.time_sync.values;
swa_kva=safemove.kvaser.VOL.ANGLE_VOLANT.values;
% volCondKva=safemove.kvaser.CMM2.VOLONTE_COND.values;
% volCondMop=safemove.mopad.CAN.VOLONTE_COND.values;
% tps_volCond_Kva=safemove.kvaser.CMM2.time_sync.values;

% %% Comparaison SWA Kvaser vs SWA Mopad
% figure, hold on
% stairs(tps_kvaVOL,-swa_kva,'b');
% stairs(tps_mopad,swa_mop,'r');
% stairs(tps_mopad2,swa_mop,'g');
% hleg=legend('kvaVol','mopVol','mopVol2');


% %% Comparaison sources CAN et enregistrement KVASER VS MOPAD
% 
% %contact_frein1 Kvaser VS contact_frein1 Mopad
% figure,
% plot(tps_mopadCAN,ContactFreinMopad,'red');
% hold on, 
% plot(tps_kvaser,FreinCan,'blue');
% hleg=legend('contFrein1Mopad','contFrein1Kvaser')
% 
% %vol_cond Kvaser VS vol_cond Mopad versus accelerator
% figure,
% plot(tps_mopadCAN,volCondMop,'red');
% hold on, 
% plot(tps_volCond_Kva,volCondKva,'blue');
% hleg=legend('vol_condMopad','vol_condKvaser')


%% Comparaison sources CAN et LESCOT + enregistrement CAN KVASER VS LESCOT MOPAD

% %contactFrein1 et Brake
% figure,
% plot(tps_mopad,Brake,'blue');
% hold on,
% plot(tps_kvaser,FreinCan,'green');
% hleg=legend('Brake','contactFrein1')

%TopCons Mopad VS Contact_Frein1 Kvaser VS Contact_Frein1 Mopad VS Brake
%Mopad

% tracé avec tps mopad sync
figure,hold on,
stairs(tps_mopad, TopCons,'cyan');
stairs(tps_kvaser,FreinCan,'blue');
stairs(tps_mopadCAN,ContactFreinMopad,'m'); 
stairs(tps_mopad,Brake,'red');
hleg=legend('TopCons','contactFrein1_KVA','contactFrein1_Mop','Brake')
title('Tracé avec temps Mopad sync');

%tracé avec tps_mopad2 (offset de 120ms)
tps_mopad2=tps_mopad-0.120;
figure,hold on,
stairs(tps_mopad2, TopCons,'cyan');
stairs(tps_kvaser,FreinCan,'blue');
stairs(tps_mopadCAN,ContactFreinMopad,'m'); 
stairs(tps_mopad2,Brake,'red');
hleg=legend('TopCons','contactFrein1_KVA','contactFrein1_Mop','Brake')
title('Tracé avec temps Mopad sync OFSSET 120ms');

%% Comparaison sources CAN et LESCOT enregistrement KVASER CAN VS MOPAD CAN VS MOPAD LESCOT
 
% %contact_frein1 Kvaser versus contact_frein1 Mopad versus brake
% figure,
% plot(tps_mopadCAN,ContactFreinMopad,'red');
% hold on, 
% plot(tps_kvaser,FreinCan,'blue');
% tps_mopad2=tps_mopad-0.16;
% plot(tps_mopad2,Brake/10,'cyan');
% hleg=legend('contFrein1Mopad','contFrein1Kvaser','brake')
% 
% %vol_cond Kvaser versus vol_cond Mopad versus accelerator
% figure,
% plot(tps_mopadCAN,volCondMop,'red');
% hold on, 
% plot(tps_volCond_Kva,volCondKva,'blue');
% tps_mopad2=tps_mopad-0.2;
% plot(tps_mopad2,-Accelerator*10,'cyan');
% hleg=legend('vol_condMopad','vol_condKvaser','accel')

% %% Pour les mises en forme de SensorsMeasures vers SensorsData
% %brake versus pourcentBrake
% figure,
% plot(tps_mopad,pourcentBrake/10,'red');
% hold on, 
% plot(tps_mopad,Brake,'blue');
% hleg=legend('pourcentBrake','Brake')
% 
% % le tracé avec IGN_500.
% lat=safemove.mopad.CentraleInertielle_IGN500.GPSraw_latitude.values;
% long=safemove.mopad.CentraleInertielle_IGN500.GPSraw_longitude.values;
% plot(long,lat,'r');
% 
% % le tracé avec GPS5Hz
% lat2=safemove.mopad.GPS_5Hz.Latitude_5Hz.values;
% long2=safemove.mopad.GPS_5Hz.Longitude_5Hz.values;
% hold on, plot(long2,lat2,'b');