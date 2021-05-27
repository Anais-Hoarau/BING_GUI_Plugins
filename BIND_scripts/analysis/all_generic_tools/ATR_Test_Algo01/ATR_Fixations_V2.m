% ATR_Fixations_V2.m
%
% expérimentation ATLAS
% Daniel LETISSERAND
% Juillet 2013

% lecture des données
load( 'data_manip.mat' );

% fréquence d'échantillonnage
Fe =60.;

% position du vecteur regard, position entre les yeux
X0 = 0.; Y0 = 0.10; Z0 = 0.70;

% assignation des variables, tableau des valeurs courantes
X1 = GAZE_PLANE_X;
Y1 = GAZE_PLANE_Y;
Z1 = -0.60;

% ces deuxièmes tableaux sont les valeurs suivantes
X2 = [GAZE_PLANE_X(2:Nb_FaceLab); GAZE_PLANE_X(Nb_FaceLab)];
Y2 = [GAZE_PLANE_Y(2:Nb_FaceLab); GAZE_PLANE_Y(Nb_FaceLab)];
Z2 = -0.60;

% calcul des distances euclidiennes (m)
D = sqrt( (X1-X2).^2 + (Y1-Y2).^2 );
% figure; plot(D); title('distances(m)')

% calcul des vitesses linéaires (m/s)
V = D.*Fe;
% figure; plot(V); title('vitesses(m/s)')

% calcul de l'angle de balayage oculaire
% utilisation des formules d'Al Kashi
% longueurs des côtés du triangle 
a = sqrt((X1-X2).^2 + (Y1-Y2).^2 + (Z1-Z2).^2);
b = sqrt((X1-X0).^2 + (Y1-Y0).^2 + (Z1-Z0).^2);
c = sqrt((X0-X2).^2 + (Y0-Y2).^2 + (Z0-Z2).^2);
cosA = (b.^2 + c.^2 - a.^2) ./ (2.* b .* c);
% angle en degrés
A = acosd(cosA);
% figure; plot(A); title('angles(°)')
% vitesse angulaire
vitA =  A .* Fe;
% figure; plot(vitA); title('vitesses angulaires(°/s)')
clear a b c

%------------------------------------------------------------


% initialisation
DD = zeros(Nb_FaceLab,6);
PS = zeros(Nb_FaceLab,6);
cosAPS = zeros(Nb_FaceLab,6);
Amax = zeros(Nb_FaceLab,1);
vitAmax = zeros(Nb_FaceLab,1);

tic
for j = 1 : Nb_FaceLab-6
    
    for k = 1:6    
        % détermination de l'angle et de la vitesse maximale de balayage oculaire sur 7 points
        Amax(j,1) = max(A(j:1:j+6));
        vitAmax(j,1) = max(vitA(j:1:j+6));
        
        % calcul à chaque pas des indices, aux 6 valeurs suivantes
        % distance du point courant aux 6 points suivants, dans le plan
        DD(j,k) = sqrt((X1(j)-X1(j+k)).^2 + (Y1(j)-Y1(j+k)).^2);
        % produit scalaire et cosinus angle produit scalaire, vecteurs dans le plan
        PS(j,k) = (X1(j+1)-X1(j)).*(X1(j+k)-X1(j)) + (Y1(j+1)-Y1(j)).*(Y1(j+k)-Y1(j)); 
        cosAPS(j,k) = PS(j,k) ./ ( DD(j,1) .* DD(j,k) );
    end
    
end
toc

% calcul moyenne et écart-type sur la variable cosAPS, cosinus de l'angle
% du produit scalaire de deux vecteurs, ceci pour les 5 vecteurs suivants
% NB: il faut transposer pour faire les calculs sur chacun des 5 points
MEANcosAPS = mean(cosAPS(:,2:6)')';
STDcosAPS  = std(cosAPS(:,2:6)')';

figure; subplot(311); plot(X1,'-.'); subplot(312); plot(Y1,'-.'); subplot(313), plot(STDcosAPS);

% ATTENTION : on a des divisions par zéros :
% > In ATR_Fixations_V2 at 71
% Warning: Divide by zero.

% stockage des données initiales et calculées
% save('data_result01.mat')

%------------------------------------------------------------
%
% % à revoir, ici on a de grands déplacements
% % peut être 5 ou 6 fixations ?
% E = [93400:93900];
% figure; plot(X1(E),Y1(E),'ro-')
% %------------------------------------------------------------
% 
% % deux plages intéressantes
% % fixations ?
% a = 107650
% b = 107750
% R = a:b;
% figure; plot(X1([R]),Y1(R),'ro',X1([R]),Y1(R),'b-')
% title(['[ ' num2str(a) ' ' num2str(b) ' ]'])
% 
% % mvt lent ?
% a = 107800
% b = 107900
% R = a:b;
% figure; plot(X1([R]),Y1(R),'ro',X1([R]),Y1(R),'b-')
% title(['[ ' num2str(a) ' ' num2str(b) ' ]'])
% %------------------------------------------------------------

% essayer trouver une plage plus calme...
%------------------------------------------------------------
