function [ecgValuesClean, seuilpic]= ligneBaseCardiaque(ecgValues)
nbpointOverlap=200;
nbOverlapFenetre = 2;
echellehisto = -2:0.01:2;
nbfenetre = floor(length(ecgValues)/nbpointOverlap);
histoglissant = zeros(nbOverlapFenetre,length(echellehisto));
lignebas = zeros(nbfenetre,1);
i=0;
while i < nbfenetre 
    histoglissant(mod(i,nbOverlapFenetre)+1,:)= hist(ecgValues(i*nbpointOverlap+1:(i+1)*nbpointOverlap),echellehisto);
    [~,indexmax] = max(sum(histoglissant));
    lignebas(i+1,1) = echellehisto(indexmax);
    i=i+1;
end

ecgValuesClean= ecgValues - interp1((0:nbfenetre-1)*nbpointOverlap,lignebas,1:length(ecgValues));
xx=-2:0.1:2;
hh = hist(ecgValuesClean,xx);
ii=find(cumsum(hh)/sum(hh)>0.97,1);
seuilpic = xx(ii);

%  plot((0:nbfenetre-1)*nbpointOverlap,lignebas+10);
%  hold on;
%  plot(1:length(ecgValues),ecgValues+5,'r');
%   plot(1:length(ecgValuesClean),ecgValuesClean,'g');
%   plot(2:length(ecgValuesClean),diff(ecgValuesClean)*10-10);