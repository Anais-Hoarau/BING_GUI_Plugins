%% Chargement des données
[Val Txt ValTxt] = xlsread('Lescot_temps_brake_accel_clutch_rapportBoite_speed_angleVolant.csv');
DataLescot = ValTxt(:,:);%colonnes avec les donnees numeriques
[Val Txt ValTxt] = xlsread('CAN_temps_volcond_contfre_contEMp_rapcal_vit_anglvol.csv');
DataCan = ValTxt(:,:);
% conversion en matrice
MatDataLescot=cell2mat(DataLescot);
MatDataCan=cell2mat(DataCan);

%% Tracés de comparaisons
figure,
% Comparaison rapport de boite calculé sur le CAN et celui déduit par
% instru LESCOT
hold on, 
scatter(MatDataCan(:,1),MatDataCan(:,5), 5, [1 0 0]);
scatter(MatDataLescot(:,1),MatDataLescot(:,5), 5, [0 0 1]);
title('Comparaison des rapports de boite de vitesse calculés et déduits'); grid; %xlabel('timecode'); ylabel('rapport de boite');
legend('calcul CAN', 'déduction_LESCOT');
% hgsave(['\' 'Comp rapports']);
hold off

%% Suite des traitements
disp('Ici il y aura par ex. la suite des sorties consoles')
    