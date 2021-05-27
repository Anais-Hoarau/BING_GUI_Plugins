% ATR_Detections_V2.m
%
% Algorithme de détection des fixations, Version 2
%
% expérimentation ATLAS
% Daniel LETISSERAND
% Juillet 2013

close all; clear; clc;
% lecture des données
load('data_result01.mat');

% initialisation du seuil en dessous duquel on va détecter une fixation sur
% l'écart-type de la répartition du cosinus de l'angle sur une plage de 100m/s,
% ( variable STDcosAPS )
seuilcosA = 0.2;
% initialisatiuon du tableau des mouvements oculaires
MvtOc = zeros(Nb_FaceLab,1);

for k = 1:Nb_FaceLab-6
    k
    % test sur les vitesses (°/s) de balayage oculaire sur 100 ms
    if (vitAmax(k,1)> 400.) && (vitAmax(k,1) <= 600.)
        % saccade
        MvtOc(k,1) = 3.;
    end
        
    if (vitAmax(k,1) > 1.) && (vitAmax(k,1) <= 30.)
        
        if (STDcosAPS(k,1) > seuilcosA) && (Amax(k,1) <= 1.)
            % fixation
            MvtOc(k,1) = 1.;
        end
        
        if (STDcosAPS(k,1) <= seuilcosA) && (Amax(k,1) > 1.)
            % poursuite
            MvtOc(k,1) = 2.;
        end
        
    end
    
end

% 
% figure;
% subplot(311); plot(X1(a:b));
% subplot(312); plot(Y1(a:b));
% subplot(313); plot(MvtOc(a:b));
