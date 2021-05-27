cd 'D:\LESCOT\Projets\SGSAS\Data simu German'


% %traitement des trip dans le dossier CURVE
% cd CURVE
% listing_trips = dir('*.trip');
% tic
% for i=1:length(listing_trips)
%     
%     % Fichier traité
%     disp(['le trip  ' listing_trips(i).name  ' est en cours de traitement'])
%     
%     %calcul des indicateurs sur l'ensemble du trip
%     disp('Calcul des indicateurs globaux')
%     Calcul_IndicateursGlobaux(listing_trips(i).name);
%     
%     %creer les situations dans le trips
%     disp('Création des situations dans le trip')
%     Creer_situation_Curve_BINDspirit(listing_trips(i).name);
%     
%     %Enrichir les situations précédement creer
%     disp(['Remplissage des situations dans le trip'])
%     Remplir_Situation_BINDspirit(listing_trips(i).name,'curve')
%     
%    fprintf('\n')
%  
% end
% cd ..
% dureeprocess=toc;
% disp(['Fin process ''Curve'' - Durée = ' num2str(dureeprocess) 's'])


%traitement des trips dans le dossier ALL

cd ALL
listing_trips = dir('*.trip');

TC_s_debut_fin = cell(length(listing_trips),1);
compteur=0;
tic
for i=1:length(listing_trips)
    
    % Fichier traité
    disp(['le trip  ' listing_trips(i).name  ' est en cours de traitement'])
    
      %calcul des indicateurs sur l'ensemble du trip
    disp('Calcul des indicateurs globaux')
    Calcul_IndicateursGlobaux(listing_trips(i).name);
    
    %creer les situations dans le trips
    disp('Création des situations dans le trip')
    TC_s_debut_fin{i,1}=Creer_situation_All_BINDspirit(listing_trips(i).name);
    
    %Enrichir les situations précédement creer
    disp(['Remplissage des situations dans le trip'])
    Remplir_Situation_BINDspirit(listing_trips(i).name,'Stimulation')
    
   fprintf('\n')
   compteur=compteur+1;
end

%Calcul de la moyenne arrondi de début et fin des situation ALL
TC_s = zeros(2,17);
TC_filled = zeros(2,17);
zero_filler = zeros(2,17);
compteur1=0;
for i=1:1:compteur
  i  
  if isempty(TC_s_debut_fin{i,1}) 
  else
      
    if length(TC_s_debut_fin{i,1})< 17
        TC_filled(:,1:length(TC_s_debut_fin{i,1})) = TC_s_debut_fin{i,1}
    end
  TC_s = TC_s +  TC_filled;
  compteur1 =compteur1+1;
  end
end


TC_s = round(TC_s/compteur1);

cd ..  
dureeprocess=toc;
disp(['Fin process ''All'' - Durée = ' num2str(dureeprocess) 's'])




%traitement des trips dans le dossier NEUTRAL
%traitement des trips dans le dossier ALL

cd NEUTRAL
listing_trips = dir('*.trip');
tic


for i=1:length(listing_trips)

    %creer les situations dans le trips
    disp('Création des situations dans le trip')
    %Creer_situation_Neutral_BINDspirit(listing_trips(i).name);
    

end













