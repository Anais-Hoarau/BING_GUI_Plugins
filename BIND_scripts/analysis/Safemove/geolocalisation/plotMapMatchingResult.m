% Chargement des variables à afficher
lat_origin = safemove.mopad.GPS_5Hz.Latitude_5Hz.values;
long_origin = safemove.mopad.GPS_5Hz.Longitude_5Hz.values;
lat_match_ign = safemove.sig.latMap.values;
long_match_ign = safemove.sig.longMap.values;

% tracé lat / long
scatter(lat_origin,long_origin, 'r');
hold on,
scatter(lat_match_ign,long_match_ign, 'b');