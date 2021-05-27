
namedebut = { 'Debut_baseline_1'; 'Debut_n_back_0' ; 'Debut_n_back_1'; 'Debut_baseline_2'; 'Debut_surt_E'; 'Debut_surt_H'; 'Debut_baseline_3' };
namefin = { 'Fin_baseline_1'; 'Fin_n_back_0'; 'Fin_n_back_1'; 'Fin_baseline_2'; 'Fin_surt_E'; 'Fin_surt_H'; 'Fin_baseline_3' };
nametaches = { 'B1'; 'N0'; 'N1'; 'B2'; 'S0'; 'S1'; 'B3'};

pathToTrip = 'D:\Ldumont\DRT_MATLAB\datatrip';
listdir = dir(pathToTrip);
idfileres = fopen('fichierResVOIE2_1s','w');
fprintf(idfileres,'IdSujet\tTrack\tTypeDRT\tCondition\tVoie\n');

for i = 3: length(listdir)
   posstr = strfind(listdir(i).name, '.trip');
   if ~isempty(posstr)
        namefile = listdir(i).name; %01061358_S11AH.trip
        okfile = calculPerfVOIE2_1s(str2num(namefile(11:12)), ... %numsujet
                namefile(13), ... % Track
                namefile(14), ... %TypeDRT
                [pathToTrip '\' namefile], ... % name file trip
                idfileres, ...% canal file res
                nametaches, ... % name tache
                namedebut, ... % commentaire debut condition
                namefin);%#ok<*ST2NM> % commentaire fin condition
    end;
end;

fclose(idfileres);

%idfileres = fopen('fichierResVit','w');
%fprintf(idfileres,'IdSujet\t Condition\t timecode \t vitesse\n');
%dirracine = '.';
%for i = 1: 1
%   filename = [dirracine '\Sujet' num2str(i) '\Route\TDRT.trip'];
%    okfile = calculIndiceperformance2( i, filename, idfileres, namecolonne, namedebut ,namefin );
%end;
%fclose(idfileres);

