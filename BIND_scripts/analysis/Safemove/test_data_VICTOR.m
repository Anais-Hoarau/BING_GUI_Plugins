%% Chargement des donn�es
[Val Txt ValTxt] = xlsread('Lescot_temps_brake_accel_clutch_rapportBoite_speed_angleVolant.csv');
DataLescot = ValTxt(:,:);%colonnes avec les donnees numeriques
[Val Txt ValTxt] = xlsread('CAN_temps_volcond_contfre_contEMp_rapcal_vit_anglvol.csv');
DataCan = ValTxt(:,:);
% conversion en matrice
MatDataLescot=cell2mat(DataLescot);
MatDataCan=cell2mat(DataCan);

%% Trac�s de comparaisons
figure,
% Comparaison rapport de boite calcul� sur le CAN et celui d�duit par
% instru LESCOT
hold on, 
scatter(MatDataCan(:,1),MatDataCan(:,5), 5, [1 0 0]);
scatter(MatDataLescot(:,1),MatDataLescot(:,5), 5, [0 0 1]);
title('Comparaison des rapports de boite de vitesse calcul�s et d�duits'); grid; %xlabel('timecode'); ylabel('rapport de boite');
legend('calcul CAN', 'd�duction_LESCOT');
% hgsave(['\' 'Comp rapports']);
hold off

%% Suite des traitements
disp('Ici il y aura par ex. la suite des sorties consoles')
    