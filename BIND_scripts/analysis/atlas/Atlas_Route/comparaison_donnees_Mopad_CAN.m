function comparaison_donnees_Mopad_CAN(full_directory)

format longg

fullfile(full_directory,'atlas_structure_[*].mat');
m_file = dir(fullfile(full_directory,'atlas_structure_*.mat'));
load(fullfile(full_directory,m_file.name))

%% Mopad variables
timecode_mopad_SensorsData = atlas.test.mopad.SensorsData.time_sync.values;
timecode_mopad_TopCons = atlas.test.mopad.Synchrovideo.time_sync.values; 
TopCons = atlas.test.mopad.Synchrovideo.TopCons.values;
%acc_mopad = atlas.test.mopad.SensorsData.POURCENT_Accelerator.values;
brake_mopad = atlas.test.mopad.SensorsData.POURCENT_Brake.values;
%clutch_mopad = atlas.test.mopad.SensorsData.POURCENT_Clutch.values;
timecode_mopad_SensorsMeasures = atlas.test.mopad.SensorsMeasures.time_sync.values;
anglevolant_mopad = atlas.test.mopad.SensorsMeasures.SteeringwheelAngle.values;

vitesse_AG_mopad = atlas.test.mopad.SensorsMeasures.Speed_L.values;
vitesse_AD_mopad = atlas.test.mopad.SensorsMeasures.Speed.values;

distance_AG = atlas.test.mopad.SensorsMeasures.DistanceDriven_L.values;
distance_AR = atlas.test.mopad.SensorsMeasures.DistanceDriven.values;

acclongi_Mopad = atlas.test.mopad.SensorsMeasures.AccX.values;


%%CAN Variables

timecode_CAN_CMM2 = atlas.test.kvaser.CMM2.time_sync.values;
contactfrein2_CAN = atlas.test.kvaser.CMM2.CONTACT_FREIN2.values;

timecode_CAN_BSI = atlas.test.kvaser.BSI.time_sync.values;
contactfrein1_CAN = atlas.test.kvaser.BSI.CONTACT_FREIN1.values;

timecode_CAN_VOL = atlas.test.kvaser.VOL.time_sync.values;
anglevolant_CAN = atlas.test.kvaser.VOL.ANGLE_VOLANT.values;

timecode_CAN_ABR = atlas.test.kvaser.ABR.time_sync.values;
distance_roues_CAN_ABR = atlas.test.kvaser.ABR.DISTANCE_ROUES.values;
vitesse_CAN_ABR = atlas.test.kvaser.ABR.VITESSE_VEH_ROUES.values;
acclongi_CAN = atlas.test.kvaser.ABR.ACCEL_LONGI_ROUES.values;

timecode_CAN_VROUES = atlas.test.kvaser.VROUES.time_sync.values;
vitesseAG_CAN = atlas.test.kvaser.VROUES.VIT_ROUE_ARG.values;
vitesseAD_CAN = atlas.test.kvaser.VROUES.VIT_ROUE_ARD.values;
vitesse_RouesAV_CAN = atlas.test.kvaser.VROUES.VIT_VEH_ROUES_AV.values;





%% Traitement des signaux
timecode_Mopad_angleVolant = timecode_mopad_SensorsMeasures + 0.25;

angleVolant_Mopad_traite = anglevolant_mopad - mean(anglevolant_CAN(1:100));

indice_rupt=find((diff(distance_roues_CAN_ABR)./ diff(timecode_CAN_ABR))< -5);
N=length(indice_rupt);
distance_roues_CAN_ABR_traite =zeros(size( distance_roues_CAN_ABR));
indice_precedent = 1 ;
distance_parcourue_prec = 0;
for i=1:1:N
distance_roues_CAN_ABR_traite(indice_precedent : indice_rupt(i))  = distance_roues_CAN_ABR(indice_precedent : indice_rupt(i)) + distance_parcourue_prec ;
indice_precedent = indice_rupt(i)+1;
distance_parcourue_prec = distance_roues_CAN_ABR_traite(indice_rupt(i)-1);
end
distance_roues_CAN_ABR_traite(indice_precedent : end)  = distance_roues_CAN_ABR(indice_precedent : end) + distance_parcourue_prec ;


%% Comparaison enfoncement pédales (brake)
figure ;
t_max=4500;

subplot(5,1,1); 
plot(timecode_mopad_SensorsData,brake_mopad,timecode_mopad_TopCons,TopCons,timecode_CAN_BSI,contactfrein1_CAN,timecode_CAN_CMM2,contactfrein2_CAN)
xlim([0 t_max]);
title ('Comparaison Mopad/CAN : Enfoncement pédale')
legend('Enfoncement Frein Mopad','TopCons : synchro','Contact Frein 1',' Contact Freain2')

%% Comparaison dynamique véhicule : vitesse, accéleration , etc...


subplot(5,1,2); 
plot(timecode_mopad_SensorsMeasures,vitesse_AG_mopad,timecode_mopad_SensorsMeasures,vitesse_AD_mopad, ...
    timecode_CAN_VROUES,vitesseAG_CAN,timecode_CAN_VROUES,vitesseAD_CAN,timecode_CAN_VROUES,vitesse_RouesAV_CAN,timecode_CAN_ABR,vitesse_CAN_ABR);
xlim([0 t_max]);
title ('Comparaison Mopad/CAN : Dynamique véhicule ->  vitesse')
legend('Vitesse Arr gauche Mopad','Vitesse Arr Droite Mopad','Vitesse Arr Gauche CAN','Vitesse Arr Droite CAN','Vitesse Roues Av CAN','Vitesse CAN ABR')


subplot(5,1,3); 
plot( timecode_mopad_SensorsMeasures, acclongi_Mopad,timecode_CAN_ABR,acclongi_CAN);
xlim([0 t_max]);
title ('Comparaison Mopad/CAN : Dynamique véhicule  -> Accelération longi')
legend('Accelaration Longi Mopad','Accélération Longi CAN')


subplot(5,1,4); 
plot(timecode_mopad_SensorsMeasures,(distance_AG - distance_AG(1))/1000, timecode_mopad_SensorsMeasures, (distance_AR -distance_AR(1))/1000, timecode_CAN_ABR, (distance_roues_CAN_ABR_traite-distance_roues_CAN_ABR_traite(1))/1000);
xlim([0 t_max]);
title ('Comparaison Mopad/CAN : Dynamique véhicule  -> Distance parcourue')
legend('Distance parcourue Arr Gauche Mopad','Distance parcourue Arr Droite Mopad','Distance parcourue CAN')


%% Comparaison angle au volant

subplot(5,1,5); 
plot(timecode_mopad_SensorsMeasures,anglevolant_mopad,timecode_Mopad_angleVolant,angleVolant_Mopad_traite ,timecode_CAN_VOL,-anglevolant_CAN)
xlim([0 t_max]);
title('Comparaison données angle au volant')
legend('Angle au volant Mopad','AngleVolant traité','Angle au volant CAN')


end