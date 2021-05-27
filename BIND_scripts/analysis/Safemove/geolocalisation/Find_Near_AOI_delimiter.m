tic

%% Chargement des données POI
% Import the data
[~, ~, raw] = xlsread('D:\paris\Desktop\ZoneParcoursSafemove.xlsx','Feuil1','A2:E37');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[3,4]);
raw = raw(:,[1,2,5]);

% Create output variable
data = reshape([raw{:}],size(raw));

% Allocate imported array to column variable names
latPoi = data(:,1);
longPoi = data(:,2);
Id = cellVectors(:,1);
Description = cellVectors(:,2);
Num = data(:,3);

%% Clear temporary variables
clearvars data raw cellVectors;

%% Chargement des données Sujet
load('D:\SAFEMOVE_DATA\3_sujets Safemove\SafeEld03_130912_09h32\SafeEld03_safemove.mat')

% Import des variables GPS from Mopad
latitude=safemove.mopad.GPS_5Hz.Latitude_5Hz.values;
longitude=safemove.mopad.GPS_5Hz.Longitude_5Hz.values;
time=safemove.mopad.GPS_5Hz.time_sync.values;
latitude_filtered=latitude(latitude~=0 & longitude ~=0 & ~isnan(latitude) & ~isnan(longitude));
longitude_filtered=longitude(latitude~=0 & longitude ~=0 & ~isnan(latitude) & ~isnan(longitude));

%% Processing
% For each POI GPS coords 
index_dist_min_global = 1; index_dist_min_local = 1;
vectSize = length(latitude);

for i=1:length(latPoi)
        % calcul des distances entre les gps du sujet et me POI courant
        % et on retient le point le plus proche
        latitude_remaining = latitude_filtered(index_dist_min_global:end);
        longitude_remaining = longitude_filtered(index_dist_min_global:end);
        f = @(x,y) vdist(latPoi(i), longPoi(i),x,y);
        [distanceMin , index_dist_min_local] = min(arrayfun(f,latitude_remaining,longitude_remaining));
        if i==1
        index_dist_min_global=index_dist_min_local;
        else
        index_dist_min_global=index_dist_min_global+index_dist_min_local;
        end
        % on extrait les informations du PoI
        safemove.sig.Poi.time_sync.values(i,1)=time(index_dist_min_global);
        safemove.sig.Poi.id.values(i,1)=Id(i);
        safemove.sig.Poi.latitudeFound.values(i,1)=latitude_filtered(index_dist_min_global);
        safemove.sig.Poi.longitudeFound.values(i,1)=longitude_filtered(index_dist_min_global);
        safemove.sig.Poi.id.values(i,1);
        safemove.sig.Poi.type.values(i,1)=Description(i);
        safemove.sig.Poi.num.values(i,1)=Num(i);
end
toc

% Creation des situations correspondantes
safemove.sig.AOI.time_sync.values=time;
safemove.sig.AOI.zone.values(1:vectSize,1)=0;

for j = 2:2:length(latPoi)
    timeWindow=time(time>=safemove.sig.Poi.time_sync.values(j-1,1) & time<safemove.sig.Poi.time_sync.values(j,1));
    safemove.sig.AOI.zone.values(safemove.sig.AOI.time_sync.values>=safemove.sig.Poi.time_sync.values(j-1,1) & time<safemove.sig.Poi.time_sync.values(j,1))=j/2;
end

% Suppresion de la branche POI ???


% Tracés de vérifications
figure, plot(longitude_filtered,latitude_filtered,'b')
title('Tracé du parcours');
hold on,
scatter(safemove.sig.Poi.longitudeFound.values,safemove.sig.Poi.latitudeFound.values,'r')
