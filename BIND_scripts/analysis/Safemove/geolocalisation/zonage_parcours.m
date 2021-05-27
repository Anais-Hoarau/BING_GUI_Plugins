% Tac� des tops
tops = safemove.mopad.Synchrovideo.TopCons.values;
figure, plot(tops)

% Filtrage pour ne garder que les top "zones)
topZones = tops(tops <2.02);
figure, plot(topZones);

% Trac� gps complet
lat=safemove.mopad.GPS_5Hz.Latitude_5Hz.values(safemove.mopad.GPS_5Hz.Latitude_5Hz.values~=0 & safemove.mopad.GPS_5Hz.Longitude_5Hz.values~=0);
long=safemove.mopad.GPS_5Hz.Longitude_5Hz.values(safemove.mopad.GPS_5Hz.Latitude_5Hz.values~=0 & safemove.mopad.GPS_5Hz.Longitude_5Hz.values~=0);
time=safemove.mopad.GPS_5Hz.time.values(safemove.mopad.GPS_5Hz.Latitude_5Hz.values~=0 & safemove.mopad.GPS_5Hz.Longitude_5Hz.values~=0);

% Trac� gps des sections avec les topages (on supprime les clap de d�but et
% fin)
lats=safemove.mopad.GPS_5Hz.Latitude_5Hz.values(safemove.mopad.Synchrovideo.TopCons.values>.05 & safemove.mopad.Synchrovideo.TopCons.values<2.1);
longs=safemove.mopad.GPS_5Hz.Longitude_5Hz.values(safemove.mopad.Synchrovideo.TopCons.values>.05 & safemove.mopad.Synchrovideo.TopCons.values<2.1);
times=safemove.mopad.GPS_5Hz.time.values(safemove.mopad.Synchrovideo.TopCons.values>.05 & safemove.mopad.Synchrovideo.TopCons.values<2.1);

% Trac� des points des zones de topages en superposition sur le trac�
% complet
figure, plot(long,lat,'g')
hold on
scatter(longs,lats,'r')

% Calcul de la diff�rence point a point de topZones
deltaTopCons=diff(topZones);

% Les points de d�but 
timeTopStart=time(deltaTopCons>1);
latTopStart=lat(deltaTopCons>1);
longTopStart=long(deltaTopCons>1);
hold on, scatter(longTopStart,latTopStart,'r');

% Les points de fin
timeTopEnd=time(deltaTopCons<-1);
latTopEnd=lat(deltaTopCons<-1);
longTopEnd=long(deltaTopCons<-1);
figure, scatter(longTopEnd,latTopEnd,'b');

% trac� de verifcation
figure,
scatter(longTopStart,latTopStart,'r')
hold on
scatter(longTopEnd,latTopEnd,'b')

% creation d'une matrice des points trouv�s
findTops=zeros(size(timeTopEnd),4);
for i=1:length(timeTopEnd)
findTops(i,1)=latTopStart(i);
findTops(i,2)=longTopStart(i);
findTops(i,3)=latTopEnd(i);
findTops(i,4)=longTopEnd(i);
end