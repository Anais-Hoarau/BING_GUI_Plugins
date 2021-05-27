% Suppose le load d'un .mat dans le workspace pour les données conduite et
% un .mat pour la définition du parcous
tic

load('D:\paris\Downloads\traceJC_IGN.mat')
load('D:\paris\Downloads\Eld00_safemove.mat')

% Chargement des données Mopad
latitude=safemove.mopad.GPS_5Hz.Latitude_5Hz.values;
longitude=safemove.mopad.GPS_5Hz.Longitude_5Hz.values;
latitude_filtered=latitude(latitude~=0 & longitude ~=0 & ~isnan(latitude) & ~isnan(longitude));
longitude_filtered=longitude(latitude~=0 & longitude ~=0 & ~isnan(latitude) & ~isnan(longitude));

% Chargement des données extraites de la base IGN
lat_parcours=traceJC_IGN.latitude;
long_parcours=traceJC_IGN.longitude;

% For each GPS point of the trip
for i=1:length(latitude_filtered)
    
    % empan initial de la zone de recherche
    alpha = 0.0001;
    
    % delimitation zone de recherche
    [index, lats_area, longs_area] = defineSearchArea (lat_parcours, long_parcours, latitude_filtered(i), longitude_filtered(i), alpha); % FIXME seuil de recherche variable.
    
    % si elle n''est pas vide
    if ~isempty (index)
        
        % calcul des distances entre les points de référence de la zone de recherche
        % et le point gps courant
        % et on retient le point le plus proche
        f = @(x,y) vdist(latitude_filtered(i), longitude_filtered(i),x,y);
        [distanceMin , index_dist_min] = min(arrayfun(f,lats_area,longs_area));
        safemove.sig.index.values(i,1) = index(index_dist_min);
        % on extrait les informations du point de référence
        safemove.sig.latMap.values(i,1) = lat_parcours(index(index_dist_min));%lat
        safemove.sig.longMap.values(i,1) = long_parcours(index(index_dist_min));%long
        safemove.sig.troncon.values(i,1) = traceJC_IGN.id(index(index_dist_min));%id_troncon
        safemove.sig.ecart.values(i,1) = distanceMin;% la distance au point de ref
        % si la zone de recherche est vide, on poursuit en agrandissant la
        % zone
    else
        % on agrandit la zone
        alpha = alpha *2;
        
        % delimitation nouvelle zone de recherche
        [index, lats_area, longs_area] = defineSearchArea (lat_parcours, long_parcours, latitude_filtered(i), longitude_filtered(i), alpha); % FIXME seuil de recherche variable.
        
        if ~isempty (index)
            % calcul des distances entre les points de référence de la zone de recherche
            % et le point gps courant
            % et on retient le point le plus proche
            f = @(x,y) vdist(latitude_filtered(i), longitude_filtered(i),x,y);
            [distanceMin , index_dist_min] = min(arrayfun(f,lats_area,longs_area));
            safemove.sig.index.values(i,1) = index(index_dist_min);
            % on extrait les informations du point de référence
            safemove.sig.latMap.values(i,1) = lat_parcours(index(index_dist_min));%lat
            safemove.sig.longMap.values(i,1) = long_parcours(index(index_dist_min));%long
            safemove.sig.troncon.values(i,1) = traceJC_IGN.id(index(index_dist_min));%id_troncon
            safemove.sig.ecart.values(i,1) = distanceMin;% la distance au point de ref
        else
            safemove.sig.index.values(i,1) = nan;
            safemove.sig.latMap.values(i,1) = nan;
            safemove.sig.longMap.values(i,1) = nan;
            safemove.sig.troncon.values(i,1) = nan;
        end
    end
    i
end
toc

