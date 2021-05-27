function [ output_args ] = calculPerfVoie( nametrip, idfileres, namedebut , namefin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%namevar = { 'DureeSeq' ; 'PosMoyVoie'; 'NBsortieVoieDroite'; 'tpsHorsVoieDroite';'NBsortieVoieGauche'; 'tpsHorsVoieGauche'};

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(nametrip, 0.04, true);

% pathToTrip = 'D:\Ldumont\DRT_MATLAB\datatrip';
% listdir = dir(pathToTrip);
% for i = 3: length(listdir)
%     namefile = listdir(i).name;
% end

data = trip.getAllDataOccurences('localisation');

timecode  = cell2mat(data.getVariableValues('timecode'));
comments = data.getVariableValues('commentaires');

voie = cell2mat(data.getVariableValues('voie'));
cap = cell2mat(data.getVariableValues('cap'));
heureGMT  = data.getVariableValues('heureGMT');

for i=1:length(namedebut)
    indexdebut =find(cellfun('length',strfind(comments,namedebut{i})));
    indexfin =find(cellfun('length',strfind(comments,namefin{i})));
    dureeSeq = timecode(indexfin) - timecode(indexdebut);

    if isempty(indexdebut) || isempty(indexfin) 
      fprintf(idfileres,'\t%f\t%f\t%f\t%f\t%f', -1, -1,-1,-1,-1);
      disp([' pb avec ' nametrip ' condition ' namedebut{i}]);
    else
    
        voieSeq = voie(indexdebut:indexfin);
        capSeq = cap(indexdebut:indexfin);
        meanVoie = mean(voieSeq);
        stdVoie = std(voieSeq);
        heureGMT0 = heureGMT{indexdebut};
        
        numberD = (30.29 + (capSeq)) * (pi / 180); %30,29461°= arctan((1/2 essieu)/posEssieuAvant)*180/PI()= arctan((1526/2)/(2612/2))*180/PI() 
        numberG = (-30.29 + (capSeq)) * (pi / 180);
        valDeltaD = (1513 * sin(numberD)); % 1512,55 mm = 1/2essieu / sin(32,19197*PI()/180)= (1526/2)/sin(32,19197*PI()/180) 
        valDeltaG = (1513 * sin(numberG));
        valPositionRoueGauche = voieSeq + valDeltaG;
        valPositionRoueDroite = voieSeq + valDeltaD;
        if  strcmp('A',nametrip(length(nametrip) -6)) % autoroute
            largeurTunnel = 100;
            valPositionRoueDroiteSeuillee = zeros(length(valPositionRoueDroite),1);
            valPositionRoueDroiteSeuillee(valPositionRoueDroite>(7834-largeurTunnel/2))=1;
            valPositionRoueDroiteSeuillee(valPositionRoueDroite>(7834+largeurTunnel/2))=2;
            valPositionRoueGaucheSeuillee = zeros(length(valPositionRoueGauche),1);
            valPositionRoueGaucheSeuillee(valPositionRoueGauche<(4522+largeurTunnel/2))=1;
            valPositionRoueGaucheSeuillee(valPositionRoueGauche<(4522-largeurTunnel/2))=2;
        elseif  strcmp('R',nametrip(length(nametrip) -6)) % route
            largeurTunnel = 100;
            valPositionRoueDroiteSeuillee = zeros(length(valPositionRoueDroite),1);
            valPositionRoueDroiteSeuillee(valPositionRoueDroite>(3380-largeurTunnel/2))=1;
            valPositionRoueDroiteSeuillee(valPositionRoueDroite>(3380+largeurTunnel/2))=2;
            valPositionRoueGaucheSeuillee = zeros(length(valPositionRoueGauche),1);
            valPositionRoueGaucheSeuillee(valPositionRoueGauche<(0+largeurTunnel/2))=1;
            valPositionRoueGaucheSeuillee(valPositionRoueGauche<(0-largeurTunnel/2))=2;
        end;
        
        
        SortieVoieDroite = sortiesTunnel(valPositionRoueDroiteSeuillee,namedebut{i},nametrip);
        SortieVoieGauche = sortiesTunnel(valPositionRoueGaucheSeuillee,namedebut{i},nametrip);
                 
        NBsortieVoieDroite = size (SortieVoieDroite,1);
        if NBsortieVoieDroite > 0
             tpsSortieVoieDroite = timecode(SortieVoieDroite);
             dureeSortieVoieDroite = sum(tpsSortieVoieDroite(:,2) - tpsSortieVoieDroite(:,1));      
             tpsHorsVoieDroite = dureeSortieVoieDroite / dureeSeq *100;
        else
            tpsHorsVoieDroite = 0;
        end
        NBsortieVoieGauche = size (SortieVoieGauche,1);
        if NBsortieVoieGauche > 0
             tpsSortieVoieGauche = timecode(SortieVoieGauche);
             dureeSortieVoieGauche = sum(tpsSortieVoieGauche(:,2) - tpsSortieVoieGauche(:,1));      
             tpsHorsVoieGauche = dureeSortieVoieGauche / dureeSeq *100;
        else
            tpsHorsVoieGauche = 0;
        end
         fprintf(idfileres,'\t%f\t%s\t%f\t%f\t%f\t%f\t%f\t%f', dureeSeq,  heureGMT0, meanVoie, stdVoie, NBsortieVoieDroite, tpsHorsVoieDroite,NBsortieVoieGauche, tpsHorsVoieGauche);
    end
end

fprintf(idfileres,'\n');
delete(trip);  

%lengthcomments = cellfun('length',comments);
%indexComment = find(lengthcomments>1);
% commentslus = comments(indexComment)';

fprintf(idfileres,'\n');  


output_args = 1;
end


function SortieVoie =  sortiesTunnel(valPositionRoueSeuillee, namecondition,nametrip)
      indexEntreeSortieTunnel = find(diff(valPositionRoueSeuillee)~= 0);
         if valPositionRoueSeuillee(1) ==0
            debutSortie = -1;
            entreeTunnel = -1;
        elseif valPositionRoueSeuillee(1) ==1
            debutSortie = -1;
            entreeTunnel = 1;
        elseif valPositionRoueSeuillee(1) ==2
            debutSortie = 1;
            entreeTunnel = 1;
        else
            disp(['cas immpossible a l''initialisation de la sequence ' namecondition ' dans ' nametrip]);
        end;
        SortieVoie = [];
        for j = 1: length(indexEntreeSortieTunnel)
            indexval = indexEntreeSortieTunnel(j);
            val = valPositionRoueSeuillee(indexEntreeSortieTunnel(j));
            valPlus = valPositionRoueSeuillee(indexEntreeSortieTunnel(j)+1);
            if val == 0 && valPlus == 1
                entreeTunnel = indexval;
            elseif  val == 0 && valPlus == 2
                entreeTunnel = indexval;
                debutSortie = entreeTunnel;
                disp(['bizarre sortie trop rapide dans ' nametrip ' en ' num2str(indexval)]);
            elseif  val == 1 && valPlus == 2  
                if entreeTunnel > 0
                    debutSortie = entreeTunnel;
                else
                    disp(['bizarre pas d''entre tunnel avant la sortie de la voie dans ' nametrip ' en ' num2str(indexval)]);

                end;
            elseif  val == 1 && valPlus == 0  
                 if debutSortie > 0 % on est sortie de l'autre cote du tunnel sinon on est rete dans le tunnel donc on ne compte pas cette sortir
                    SortieVoie = [SortieVoie ; [debutSortie indexval]]; %#ok<AGROW>
                    debutSortie = -1;
                    entreeTunnel = -1;
                 end;
             elseif  val == 2 && valPlus == 1
             elseif  val == 2 && valPlus == 0
                 disp(['bizarre entree trop rapide dans ' nametrip ' en ' num2str(indexval)]);
               if debutSortie > 0
                    SortieVoie = [SortieVoie ; [debutSortie indexval]]; %#ok<AGROW>
                    debutSortie = -1;
                    entreeTunnel = -1;
               else
                      disp(['bizarre pas d''entre tunnel avant le retour sur la voie de la sequence ' namecondition ' dans ' nametrip ' en ' num2str(indexval)]);
                end;
            else
                 disp(['cas impossible ' nametrip ' en ' num2str(indexval)]);
            end;
        end; %for

        if valPositionRoueSeuillee(length(valPositionRoueSeuillee)) > 0
            if debutSortie > 0
                  SortieVoie = [SortieVoie ; [debutSortie length(valPositionRoueSeuillee)]]; 
             end;
        end;
end
              

