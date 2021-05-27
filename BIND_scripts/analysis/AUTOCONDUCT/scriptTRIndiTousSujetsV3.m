dbstop if error
load('listefileconditions.mat');
datareseau = 0;
prepartipant = 2;
derpartipant = 20;
listeIndDuree = {'DureeReelle10s' 'DureeReelle30s' 'DureeReelle120s'};
listeIndCard = {'ConfSDRR10s' 'ConfSDRR30s' 'ConfSDRR120s' 'ConfRMSSD10s' 'ConfRMSSD30s' 'ConfRMSSD120s' 'SDNN10s' 'SDNN30s' 'SDNN120s' 'RMSSD10s' 'RMSSD10s' 'RMSSD30s' 'RMSSD120s' ...
     'RRMax10s' 'RRMax30s' 'RRMax120s' 'RRMin10s' 'RRMin30s' 'RRMin120s' };
listeIndResp = {'DureeReelleResp10s' 'DureeReelleResp20s' 'DureeReelleRespi40s' 'DureeReelleRespi130s' ...
 'RespiInspExp' 'AmpliRespi' 'AmpliRespiMoy10s' 'DeltaAmpliRespiMoy10sAvecMoy10sP' 'DeltaAmpliRespiMoy10sAvecMoy30sP' 'DeltaAmpliRespiMoy10sAvecMoy120sP'...
'PeriodeRespi' 'PeriodeRespi10s' 'DeltaPeriodeRespiMoy10sAvecMoy10sP' 'DeltaPeriodeRespiMoy10sAvecMoy30sP' 'DeltaPeriodeRespiMoy10sAvecMoy120sP' ...
'StabiliteRespi'   'StabiliteRespi0s10s' 'StabiliteRespi10s20s' 'StabiliteRespi10s40s' 'StabiliteRespi10s130s'};
listeIndElDer = { };
listeConditions = { 'Audio_triste', 'Audio_neutre' , 'Rappel',  'Histoire' };
nomfilelog = ['logfiletableREMINDTous' num2str(prepartipant) 'To'  num2str(derpartipant)  '.txt'];
nomfiletableREMTousNum = ['tableREMINDV2TousNum' num2str(prepartipant) 'To'  num2str(derpartipant)  '.mat'];
nomfiletableREMTousTxt = ['tableREMINDV2Tous' num2str(prepartipant) 'To'  num2str(derpartipant)  '.txt'];
dirData = 'Y:\WP3\Data\manip\';
tableREMINDTousNum = [];
tableREMINDTousTxt = {};

logfile = fopen(nomfilelog,'w');
for i=prepartipant:derpartipant
    disp(['Suj ' num2str(i)]);
    for j=1:length(listeConditions)
        disp(['condition ' listeConditions{j}]);
        if datareseau
            nomdirBIND =dir([dirData 'P' num2str(i) '\' listeConditions{j} '\*BIND']); %#ok<UNRCH>
        else
            nomdirBIND = '.\data\trips';
        end
        if ( length(nomdirBIND)>= 1)
            
            if datareseau 
                nomdirTrip =dir([dirData 'P' num2str(i) '\' listeConditions{j} '\'  nomdirBIND.name '\*.trip']); %#ok<UNRCH>
                NomFolder = nomdirTrip.folder;
                Tripname = nomdirTrip.name;
            else
                Tripname = findnomtrip(listefileconditions,i,listeConditions{j});
                NomFolder=nomdirBIND;
            end
            %disp([nomdirTrip.folder '\' nomdirTrip.name]);
           [tableREMINDNum,  tableREMINDTxt ]= extractTRINDV3(i,j,[ NomFolder '\' Tripname],listeConditions,logfile) ;
           tableREMINDTousTxt = [ tableREMINDTousTxt tableREMINDTxt]; %#ok<AGROW>
           tableREMINDTousNum = [ tableREMINDTousNum ; tableREMINDNum]; %#ok<AGROW>
        else
            fprintf(logfile,'%s\n',[' manque participant ' num2str(i) ' condition ' listeConditions{j}]);
        end
    end
end
fclose(logfile);

fileID = fopen(nomfiletableREMTousTxt,'w');
fprintf(fileID,'%s','Sujet,Condition,timecode,typeREM,Route,Duree');
for i=1:length(listeIndDuree)
   fprintf(fileID,',%s', listeIndDuree{i});
end
for i=1:length(listeIndCard)
   fprintf(fileID,',%s', listeIndCard{i});
end
for i=1:length(listeIndResp)
   fprintf(fileID,',%s', listeIndResp{i});
end
fprintf(fileID,'\n');

for i=1:length(tableREMINDTousTxt)
    fprintf(fileID,'%s\n',tableREMINDTousTxt{i});
end
fclose(fileID);

save(nomfiletableREMTousNum,'tableREMINDTousNum');
