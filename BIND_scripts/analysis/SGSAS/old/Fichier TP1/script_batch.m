%% id�e 1
% On calcule les noms des fichiers avec un indice i variant de 1 � 21
% Mais...
% Le trip 6 n'existe pas !

% for i=1:21
%     calcule_vitesse_moyenne([num2str(i) 'all.trip']);
% end

%% id�e 2
% On d�finit un vecteur matlab qui contient les num�ros des trips qui nous
% int�ressent
% Mais...
% C'est fastidieux !

% mes_indices = [1 2 3 4 5 7 8];
% 
% for i=1:length(mes_indices)
%     calcule_vitesse_moyenne([num2str(mes_indices(i)) 'all.trip']);
% end

%% id�e 3
% On appelle Damien....

%% id�e 4
% Ok, on reprend du courage...
% On r�cup�re la liste des trips pr�sents dans le dossier...
% 

listing_trips = dir('*.trip');
for i=1:length(listing_trips)
    calcule_vitesse_moyenne(listing_trips(i).name);
    %construire_situations(listing_trips(i).name)
    %calcule_vitesse_moyenne_situation(listing_trips(i).name);
end