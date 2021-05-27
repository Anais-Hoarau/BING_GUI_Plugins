%% idée 1
% On calcule les noms des fichiers avec un indice i variant de 1 à 21
% Mais...
% Le trip 6 n'existe pas !

% for i=1:21
%     calcule_vitesse_moyenne([num2str(i) 'all.trip']);
% end

%% idée 2
% On définit un vecteur matlab qui contient les numéros des trips qui nous
% intéressent
% Mais...
% C'est fastidieux !

% mes_indices = [1 2 3 4 5 7 8];
% 
% for i=1:length(mes_indices)
%     calcule_vitesse_moyenne([num2str(mes_indices(i)) 'all.trip']);
% end

%% idée 3
% On appelle Damien....

%% idée 4
% Ok, on reprend du courage...
% On récupère la liste des trips présents dans le dossier...
% 

listing_trips = dir('*.trip');
for i=1:length(listing_trips)
    calcule_vitesse_moyenne(listing_trips(i).name);
    %construire_situations(listing_trips(i).name)
    %calcule_vitesse_moyenne_situation(listing_trips(i).name);
end