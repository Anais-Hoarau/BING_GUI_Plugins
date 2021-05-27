
namedebut = { 'Debut_baseline_1'; 'Debut_n_back_0' ; 'Debut_n_back_1'; 'Debut_baseline_2'; 'Debut_surt_E'; 'Debut_surt_H'; 'Debut_baseline_3' };
namefin = { 'Fin_baseline_1'; 'Fin_n_back_0'; 'Fin_n_back_1'; 'Fin_baseline_2'; 'Fin_surt_E'; 'Fin_surt_H'; 'Fin_baseline_3' };
nametaches = { 'B1'; 'N0'; 'N1'; 'B2'; 'S0'; 'S1'; 'B3'};


%valeurs VITESSE calculer pour chaque sequence
namevar = { 'DureeSeq' ; 'DebutSeqGMT' ;  'MoyVolant'; 'MaxVolant'; 'MinVolant'; 'StdVolant' };
idfileres = fopen('fichierResVolantGMT','w');
fprintf(idfileres,'Sujet\tTrack\tDRT'); % tirer du nom du fichier
for i=1:length(nametaches)
   for j=1:length(namevar)
       fprintf(idfileres,['\t ' nametaches{i} namevar{j} ]);
   end;
end;
fprintf(idfileres,'\n');

%calcul pour la vitesse
pathToTrip = 'D:\Ldumont\DRT_MATLAB\datatrip';
listdir = dir(pathToTrip);
for i = 3: length(listdir)
   posstr = strfind(listdir(i).name, '.trip');
   if ~isempty(posstr)
       namefile = listdir(i).name; %01061358_S11AH.trip
       fprintf(idfileres,'%d\t%s\t%s' , str2num(namefile(11:12)), namefile(13), namefile(14)); %#ok<ST2NM>
       okfile = calculPerfVolant ([pathToTrip '\' namefile], ...
                   idfileres, namedebut,namefin);
    end;
end;
fclose(idfileres);

