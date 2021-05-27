
namedebut = { 'Debut_baseline_1'; 'Debut_n_back_0' ; 'Debut_n_back_1'; 'Debut_baseline_2'; 'Debut_surt_E'; 'Debut_surt_H'; 'Debut_baseline_3' };
namefin = { 'Fin_baseline_1'; 'Fin_n_back_0'; 'Fin_n_back_1'; 'Fin_baseline_2'; 'Fin_surt_E'; 'Fin_surt_H'; 'Fin_baseline_3' };
nametaches = { 'B1'; 'N0'; 'N1'; 'B2'; 'S0'; 'S1'; 'B3'};

pathToTrip = 'D:\Ldumont\DRT_MATLAB\datatrip';
pathToLogDRT = 'D:\Ldumont\DRT_MATLAB\datadrt';
listdir = dir(pathToTrip);
listdirdrt = dir(pathToLogDRT);
idfileres = fopen('fichierResDRT2','w');
fprintf(idfileres,'IdSujet\tTrack\tTypeDRT\tCondition\tTpsRepDRT\n');

for i = 3: length(listdir)
   posstr = strfind(listdir(i).name, '.trip');
   if ~isempty(posstr)
        namefile = listdir(i).name; %01061358_S11AH.trip
        nameracine = namefile(10:14);
        indexfiledrt = -1;
        j=3;
        while (indexfiledrt<0) && j<=length(listdirdrt)
            if ~isempty(strfind(listdirdrt(j).name, nameracine))
                indexfiledrt = j;
                namefiledrt = listdirdrt(j).name;
            end;
            j = j+1;
        end;
        if indexfiledrt<0
            disp([' pb avec ' namefile ' pas de fichier DRT associe']);
        else
            okfile = calculPerfDRT2(str2num(namefile(11:12)), ... %numsujet
                namefile(13), ... % Track
                namefile(14), ... %TypeDRT
                [pathToTrip '\' namefile], ... % name file trip
                [ pathToLogDRT '\' namefiledrt], ... % name file drt
                idfileres, ...% canal file res
                nametaches, ... % name tache
                namedebut, ... % commentaire debut condition
                namefin);%#ok<*ST2NM> % commentaire fin condition
        end;
    end;
end;
fclose(idfileres);
