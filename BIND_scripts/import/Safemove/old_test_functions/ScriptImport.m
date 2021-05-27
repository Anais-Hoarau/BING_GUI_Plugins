% Restructuration des données CAN pour faciliter la manipulation

%% FICHIERS CAN KVASER
disp 'importer le fichier kvaser au format matlab'
uiload

% VOLONTE_COND
Kvaser.CAN_IS.VOLONTE_COND.tc = IS_DYN_CMM_2_13_VOLONTE_COND_12.time;
Kvaser.CAN_IS.VOLONTE_COND.value = IS_DYN_CMM_2_13_VOLONTE_COND_12.signals.values;

% CONTACT_FREIN2
Kvaser.CAN_IS.CONTACT_FREIN.tc = IS_DYN_CMM_2_13_CONTACT_FREI_01.time;
Kvaser.CAN_IS.CONTACT_FREIN.value = IS_DYN_CMM_2_13_CONTACT_FREI_01.signals.values;

% CONTACT_FREIN2
Kvaser.CAN_IS.ANGLE_VOLANT.tc = IS_DYN_VOL_3_15_ANGLE_VOLANT_00.time;
Kvaser.CAN_IS.ANGLE_VOLANT.value = IS_DYN_VOL_3_15_ANGLE_VOLANT_00.signals.values;

% Nettoie
clear IS*
clear ARS*
clear ALDW*
clear RadarState*
clear SLA*

%% FICHIERS MOPAD
% FICHIERS CAN MOPAD
disp 'importer le fichier Mopad CAN'
Mopad.CAN = uiimport('-file');


% FICHIERS capteurs LESCOT MOPAD
disp 'importer le fichier Mopad SensorsMeasures'
Mopad.SensorsMeasures = uiimport('-file');


% FICHIERS capteurs GPS1Hz MOPAD
disp 'importer le fichier Mopad GPS1Hz'
Mopad.GPS1Hz = uiimport('-file');


% FICHIERS capteurs GPS5Hz MOPAD
disp 'importer le fichier Mopad GPS5Hz'
Mopad.GPS5Hz = uiimport('-file');

% FICHIERS mesure de temps
disp 'importer le fichier Mopad MesuresTemps'
Mopad.MesuresTemps = uiimport('-file');
