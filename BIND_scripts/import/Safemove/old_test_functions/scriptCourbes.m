
% Pour charger les donn�es
%ScriptImport;

% Pour afficher suffisemment de d�cimales
format longg

% Pour trouver les tops et en d�duire un offset
% (il faut v�rifier que les offset sont bons (si les coups de freins ne
% sont pas les premiers/derniers)
% CONTACT_FREIN2 via Mopad
%extract_seuils_frein(collecteSync.Mopad.CAN.tc,collecteSync.Mopad.CAN.CONTACT_FREIN2,1,0)
% CONTACT_FREIN2 via Kvaser
%extract_seuils_frein(collecteSync.Kvaser.CAN_IS.CONTACT_FREIN.tc,collecteSync.Kvaser.CAN_IS.CONTACT_FREIN.value,1,0)

% import 2013-01-17
offset_mopad = 411728169655.02;
offset_kvaser = 123.3451;

% import 2013-01-23
%extract_seuils_frein(Mopad.CAN.tc,Mopad.CAN.CONTACT_FREIN2,4,2)
%offset_mopad = 412266661656.14;
%extract_seuils_frein(Kvaser.CAN_IS.CONTACT_FREIN.tc,Kvaser.CAN_IS.CONTACT_FREIN.value,2,2
%offset_kvaser = 20.69752;

collecteSync = resyncCollecteUnPoint(Mopad,Kvaser,offset_mopad,offset_kvaser);

%% Tests de variation de fr�quence d'�chantillonage

disp 'GPS 1Hz';
extract_variation_frequence_echantillonage(collecteSync.Mopad.MesuresTemps.tc_sync,collecteSync.Mopad.MesuresTemps.TempsGPS_1Hz)

disp 'GPS 5Hz';
extract_variation_frequence_echantillonage(collecteSync.Mopad.MesuresTemps.tc_sync,collecteSync.Mopad.MesuresTemps.TempsGPS_5Hz)

disp 'Magnetoscope';
extract_variation_frequence_echantillonage(collecteSync.Mopad.MesuresTemps.tc_sync,collecteSync.Mopad.MesuresTemps.TempsMagneto)

%% Courbe volant
figure
offset_CAN = median(Mopad.CAN.ANGLE_VOLANT);
offset_Mopad = median(Mopad.SensorsMeasures.SteeringwheelAngle);
plot(collecteSync.Mopad.CAN.tc_sync,collecteSync.Mopad.CAN.ANGLE_VOLANT-offset_CAN,...
    collecteSync.Mopad.SensorsMeasures.tc_sync,-collecteSync.Mopad.SensorsMeasures.SteeringwheelAngle-offset_Mopad,...
    collecteSync.Kvaser.CAN_IS.ANGLE_VOLANT.tc_sync,collecteSync.Kvaser.CAN_IS.ANGLE_VOLANT.value-offset_CAN);
title('Angle volant')
xlabel('temps (secondes)')
ylabel('angle volant (degr�s)')
legend('Mopad CAN','Mopad capteurs LESCOT','Kvaser CAN');

%% Courbe Frein
figure
plot(collecteSync.Mopad.CAN.tc_sync,collecteSync.Mopad.CAN.CONTACT_FREIN2,...
    collecteSync.Mopad.SensorsMeasures.tc_sync,collecteSync.Mopad.SensorsMeasures.Brake,...
    collecteSync.Kvaser.CAN_IS.CONTACT_FREIN.tc_sync,collecteSync.Kvaser.CAN_IS.CONTACT_FREIN.value);
title('P�dale de frein')
xlabel('temps (secondes)')
ylabel('enfoncement p�dale (volts / booleen)')
legend('Mopad CAN','Mopad capteurs LESCOT','Kvaser CAN');

%% Courbe Embrayage
figure
plot(collecteSync.Mopad.CAN.tc_sync,collecteSync.Mopad.CAN.CONT_EMBR_CMM,...
    collecteSync.Mopad.SensorsMeasures.tc_sync,collecteSync.Mopad.SensorsMeasures.Clutch);
title('P�dale d''embrayage')
xlabel('temps (secondes)')
ylabel('enfoncement p�dale (volts / booleen)')
legend('Mopad CAN','Mopad capteurs LESCOT');

%% Courbe Acc
coeff = - max(collecteSync.Mopad.CAN.VOLONTE_COND)/max(-collecteSync.Mopad.SensorsMeasures.Accelerator);
figure
plot(collecteSync.Mopad.CAN.tc_sync,collecteSync.Mopad.CAN.VOLONTE_COND,...
    collecteSync.Mopad.SensorsMeasures.tc_sync,collecteSync.Mopad.SensorsMeasures.Accelerator*coeff,...
    collecteSync.Kvaser.CAN_IS.VOLONTE_COND.tc_sync,collecteSync.Kvaser.CAN_IS.VOLONTE_COND.value);
title('P�dale d''accel�rateur')
xlabel('temps (secondes)')
ylabel('enfoncement p�dale (mis � l''�chelle) / volont� conducteur (%)')
legend('Mopad CAN','Mopad capteurs LESCOT','Kvaser CAN');