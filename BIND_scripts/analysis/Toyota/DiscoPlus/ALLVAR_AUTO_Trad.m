%% DISCO + TRAITEMENT DES DONNEES: TRAITEMENT PHASE 1/3
%
%%% DONNEES COMPORTEMENTALES
%
%  Projet DISCO+ 2016 : H.LOECHES et J.TAILLARD

%% Param�tres d'initialisation avant lancement
close all ; clear all ;
warning('off')

%% LANCEUR DES SUJETS ANALYSES
%%% SUJETS ANALYSES

numerosujet = [52]; %Num�ro(s) des sujets que l'on souhaite analyser


%% Param�tres de traitement
% Nombre de points interpol�s(Anciennement utlis� pour interpolation)
sizewindow = 10;
% Taille de la fen�tre glissante (sec)
slide_incr = 1;
% Incr�mentation : d�callage du nombre de donn�es = 99%

%% Chargement des donn�es
DISCO = {'D1' 'D2' 'D3' 'D4' 'D5'};
%ATTENTION : Session confort not�e D5 pour le traitement automatis�
%D1 = Sc�nario 1 � D4  = Sc�nario 4.

for suj = numerosujet % Boucle d'analyse pour chaque sujet
    for disco = [1 2 5] % Boucle d'analyse pour chaque scenario mais
        % NE PAS MODIFIER : d�tection automatique des sceanrio du sujet !
        
        try disco; % Teste si le sujet � fait le scenario 1
            filename = ['E:\PROJETS ACTUELS\TOYOTA\Discoplus\Sujets\Databrutes\S' ...
                num2str(suj)  cell2mat(DISCO(disco)) '.var'];
            % Initialize variables.
            delimiter = '\t';
            startRow = 2;
            % Read columns of data as strings:
            % For more information, see the TEXTSCAN documentation.
            formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
            % Open the text file.
            fileID = fopen(filename,'r');
            % Read columns of data according to format string.
            % This call is based on the structure of the file used to generate this
            % code. If an error occurs for a different file, try regenerating the code
            % from the Import Tool.
            dataArray = textscan(fileID, formatSpec, 'Delimiter',...
                delimiter,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
            % Si le sujet n'a pas fait le sceanrio 1, il a fait un scenario impair
            
        catch
            disco = disco + 2;
            
            %%%%%%%%%%%% IMPORTANT
            % A partir d'ici jusqu'� la ligne 128
            % Ce morceau de script a �t� automatiquement g�n�r� par Matlab afin de
            % lire les fichiers .var issus du simulateur
            % Les annotations entre temps sont elles aussi g�n�r�es par le logiciel
            
            
            filename = ['E:\PROJETS ACTUELS\TOYOTA\Discoplus\Sujets\Databrutes\S' ...
                num2str(suj) cell2mat(DISCO(disco)) '.var'];
            % Initialize variables.
            delimiter = '\t';
            startRow = 2;
            % Read columns of data as strings:
            % For more information, see the TEXTSCAN documentation.
            formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
            % Open the text file.
            fileID = fopen(filename,'r');
            % Read columns of data according to format string.
            % This call is based on the structure of the file used to generate this
            % code. If an error occurs for a different file, try regenerating the code
            % from the Import Tool.
            dataArray = textscan(fileID, formatSpec, 'Delimiter', ...
                delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
        end
        
        disp(['En cours: S' num2str(suj) cell2mat(DISCO(disco)) '.var'])
        % Close the text file.
        fclose(fileID);
        
        % Convert the contents of columns containing numeric strings to numbers.
        % Replace non-numeric strings with NaN.
        raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
        for col=1:length(dataArray)-1
            raw(1:length(dataArray{col}),col) = dataArray{col};
        end
        numericData = NaN(size(dataArray{1},1),size(dataArray,2));
        
        for col=[1,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
            % Converts strings in the input cell array to numbers. Replaced non-numeric
            % strings with NaN.
            rawData = dataArray{col};
            for row=1:size(rawData, 1);
                % Create a regular expression to detect and remove non-numeric prefixes and
                % suffixes.
                regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\.]*)+[\,]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\.]*)*[\,]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                try
                    result = regexp(rawData{row}, regexstr, 'names');
                    numbers = result.numbers;
                    
                    % Detected commas in non-thousand locations.
                    invalidThousandsSeparator = false;
                    if any(numbers=='.');
                        thousandsRegExp = '^\d+?(\.\d{3})*\,{0,1}\d*$';
                        if isempty(regexp(thousandsRegExp, '.', 'once'));
                            numbers = NaN;
                            invalidThousandsSeparator = true;
                        end
                    end
                    % Convert numeric strings to numbers.
                    if ~invalidThousandsSeparator;
                        numbers = strrep(numbers, '.', '');
                        numbers = strrep(numbers, ',', '.');
                        numbers = textscan(numbers, '%f');
                        numericData(row, col) = numbers{1};
                        raw{row, col} = numbers{1};
                    end
                catch me
                end
            end
        end
        
        
        % Split data into numeric and cell columns.
        rawNumericColumns = raw(:, [1,4,5,6,7,8,9,10,11,12,13,14,15,16,17]);
        rawCellColumns = raw(:, [2,3,18,19,20,21,22,23,24,25,26,27,28,29,30,31,...
            32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,...
            53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,...
            74,75,76,77,78,79,80,81,82,83,84]);
        
        
        % Replace non-numeric cells with NaN
        R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns);
        rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
        
        % Create output variable
        data = raw;
        % Clear temporary variables
        clearvars filename delimiter startRow formatSpec fileID dataArray ans...
            raw col numericData rawData row regexstr result numbers...
            invalidThousandsSeparator thousandsRegExp me ...
            rawNumericColumns rawCellColumns R;
        
        
        
        
        
        % FIN DU SCRIPT AUTOMATIQUEMENT GENERE !
        
        
        %% Traitement
        
        % Conversion de la colonne "Temps du simulateur" en dur�e exploitable
        for i = 1: length(data(:,2))
            deltaT= cell2mat(data(i,2));
            %On transforme les cellules avec le temps du simulateur en matrice
            min(i) = str2double(deltaT(4:5));
            % Pour les minutes conversion des 4e et 5e �lements de deltaT en ASCII
            min(i) = min(i)*60;
            sec(i) = str2double(deltaT(7:8));
            % Idem que pour les minutes mais pour les secondes
            mil(i) = (str2double(deltaT(10:14)))/100000;
            Tps(i) = min(i)+sec(i)+mil(i);
            % On aditionne le tout pour obtenir le temps � l'instant i
        end
        
        %%  Detection des Triggers pour la synchronisation des systemes de collecte
        % Chercher les indices des commentaires
        
        mask_commentaires = find(~cellfun(@isempty, data(:,23)));
        % Cherche les cases non vides dans la colonne "commentaire"
        table_commentaires = [data(mask_commentaires, 1) ...
            data(mask_commentaires, 2) data(mask_commentaires, 23)]; %Sert � rien !
        indexcom = cell2mat(data(mask_commentaires, 1)) + 1;...
            %+1 pour que la 1ere valeur soit a l'indice 1 // Rangement des comms
        
        if disco ==1 % Si Sc�nario 1
            %Stockage des triggers du sc�nario 1 et de ses  diff�rents �venements
            
            PERF.clapdeb.valeur = indexcom(1);  % D�but enregistrement
            PERF.clapfin.valeur = indexcom(10);  % Fin enregistement
            
            PERF.debove1.valeur = indexcom(2); % Debut overtaking +1 + d�b camion 1
            PERF.debove1.valeur = PERF.debove1.valeur -(PERF.clapdeb.valeur -1);
            % Recalage de l'�venement en fonction du clap d�but
            PERF.fintru1.valeur = indexcom(3);  % Fin camion 1
            PERF.fintru1.valeur  = PERF.fintru1.valeur  -(PERF.clapdeb.valeur -1);
            PERF.debtru2.valeur = indexcom(4); % D�but camion 2
            PERF.debtru2.valeur = PERF.debtru2.valeur-(PERF.clapdeb.valeur -1);
            PERF.finove1.valeur = indexcom(5); % Fin overtaking +1 et fin camion 2
            PERF.finove1.valeur = PERF.finove1.valeur -(PERF.clapdeb.valeur -1);
            PERF.debleft.valeur = indexcom(6); % D�but tourne � gauche simple
            PERF.debleft.valeur = PERF.debleft.valeur -(PERF.clapdeb.valeur -1);
            PERF.finleft.valeur = indexcom(7); % Fin tourne � gauche simple
            PERF.finleft.valeur  = PERF.finleft.valeur  -(PERF.clapdeb.valeur -1);
            PERF.debped.valeur = indexcom(8);  % D�but pi�ton
            PERF.debped.valeur = PERF.debped.valeur -(PERF.clapdeb.valeur -1);
            PERF.finped.valeur = indexcom(9);  % Fin pi�ton
            PERF.finped.valeur = PERF.finped.valeur -(PERF.clapdeb.valeur -1);
            
            
            % Temps de Disco 1
            Camion1 = (Tps(PERF.fintru1.valeur)...
                -(Tps(PERF.debove1.valeur)));   %Temps du camion 1
            Camion2 = (Tps(PERF.finove1.valeur)...
                -(Tps(PERF.debtru2.valeur)));   %Temps du camion 2
            
            total = Camion1+Camion2
            TIME.tpstotal.valeur = Tps(PERF.clapfin.valeur)...
                -Tps(PERF.clapdeb.valeur); %Dur�e totale du sc�nario
            
            TIME.overt1.valeur = (Tps(PERF.finove1.valeur)...
                -(Tps(PERF.debove1.valeur))); % Dur�e depassement +1
            TIME.left.valeur = (Tps(PERF.finleft.valeur)...
                -(Tps(PERF.debleft.valeur))); % Dur�e tourne � gauche
            TIME.ped.valeur = (Tps(PERF.finped.valeur)...
                -(Tps(PERF.debped.valeur)));  % Dur�e du p�destre
            disp(['Disco 1 : la dur�e du d�passement+1 est de  ' ...
                num2str(TIME.overt1.valeur) ' secondes']) %Temps lors traitement
            disp(['Disco 1 : la dur�e du tourne � gauche est de  ' ...
                num2str(TIME.left.valeur) ' secondes']) %Temps lors traitement
            disp(['Disco 1 : la dur�e du pi�ton est de ' ...
                num2str(TIME.ped.valeur) ' secondes']) %Temps lors traitement
            
            % Calcul de la fr�quence d'�chantillonage du simu de clapdeb � clapfin
            % car fr�quence du simu variable entre 2 variables
            % cf calcul du temps (D�but du traitement)
            Tpsclapfin = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsclapdeb = cell2mat(data(PERF.clapdeb.valeur,2));
            Tpsfinsuiv = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsdebsuiv = cell2mat(data(PERF.clapdeb.valeur,2));
            min = str2double(Tpsfinsuiv(4:5)) - str2double(Tpsdebsuiv(4:5));
            min = min*60;
            sec = str2double(Tpsfinsuiv(7:8)) - str2double(Tpsdebsuiv(7:8));
            mil = (str2double(Tpsfinsuiv(10:14))-str2double(Tpsdebsuiv(10:14)))/100000;
            Fe = length(PERF.clapdeb.valeur:PERF.clapfin.valeur)/(min+sec+mil);
            PERF.Freq.valeur = Fe;
            % Dur�e totale en secondes de l'essai
            tempsorigin = Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            
            
            
            
        end
        
        if disco ==2 % Si scenario 2
            %Stockage des triggers du sc�nario 2 et de ses  diff�rents �venements
            PERF.clapdeb.valeur = indexcom(1);  % Debut enregistrement
            PERF.clapfin.valeur = indexcom(8);  % Fin enregistrement
            
            PERF.debleft1.valeur = indexcom(2); % Debut tourne � gauche +1
            PERF.debleft1.valeur = PERF.debleft1.valeur-(PERF.clapdeb.valeur -1);
            PERF.finleft1.valeur = indexcom(3); % Fin toune � gauche +1
            PERF.finleft1.valeur = PERF.finleft1.valeur -(PERF.clapdeb.valeur -1);
            PERF.debove.valeur = indexcom(4);   % Debut overtake simple
            PERF.debove.valeur = PERF.debove.valeur -(PERF.clapdeb.valeur -1);
            PERF.finove.valeur = indexcom(5);   % Fin overtake simple
            PERF.finove.valeur = PERF.finove.valeur -(PERF.clapdeb.valeur -1);
            PERF.debsb.valeur = indexcom(6);    % D�but jaillissement
            PERF.debsb.valeur = PERF.debsb.valeur -(PERF.clapdeb.valeur -1);
            PERF.finsb.valeur = indexcom(7);    % Fin jaillissement
            PERF.finsb.valeur = PERF.finsb.valeur -(PERF.clapdeb.valeur -1);
            
            % Temps de Disco 2
            TIME.tpstotal.valeur=Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            TIME.left1.valeur=(Tps(PERF.finleft1.valeur)-(Tps(PERF.debleft1.valeur)));
            TIME.overt.valeur=(Tps(PERF.finove.valeur)-(Tps(PERF.debove.valeur)));
            TIME.SB.valeur=(Tps(PERF.finsb.valeur)-(Tps(PERF.debsb.valeur)));
            disp(['Disco 2 : la dur�e du left+1 est de  ' ...
                num2str(TIME.left1.valeur) ' secondes'])
            disp(['Disco 2 : la dur�e du d�passement est de  ' ...
                num2str(TIME.overt.valeur) ' secondes'])
            disp(['Disco 2 : la dur�e du jaillissement est de ' ...
                num2str(TIME.SB.valeur) ' secondes'])
            
            
            % Calcul de la fr�quence d'�chantillonage du simu de clapdeb � clapfin
            Tpsclapfin = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsclapdeb = cell2mat(data(PERF.clapdeb.valeur,2));
            Tpsfinsuiv = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsdebsuiv = cell2mat(data(PERF.clapdeb.valeur,2));
            min = str2double(Tpsfinsuiv(4:5)) - str2double(Tpsdebsuiv(4:5));
            min = min*60;
            sec = str2double(Tpsfinsuiv(7:8)) - str2double(Tpsdebsuiv(7:8));
            mil = (str2double(Tpsfinsuiv(10:14))-str2double(Tpsdebsuiv(10:14)))/100000;
            Fe = length(PERF.clapdeb.valeur:PERF.clapfin.valeur)/(min+sec+mil);
            PERF.Freq.valeur = Fe;
            % Dur�e totale en secondes
            tempsorigin = Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            
        end
        
        if disco ==3
            
            PERF.clapdeb.valeur = indexcom(1); % Debut enregistrement
            PERF.clapfin.valeur = indexcom(10);%Fin enregistrement
            
            PERF.debleft.valeur = indexcom(2); % D�but tourne � gauche simple
            PERF.debleft.valeur = PERF.debleft.valeur-(PERF.clapdeb.valeur -1);
            PERF.finleft.valeur = indexcom(3); % Fin tourne � gauche simple
            PERF.finleft.valeur = PERF.finleft.valeur-(PERF.clapdeb.valeur -1);
            PERF.debove1.valeur =indexcom(4); % Debut overtaking +1 et d�b camion 1
            PERF.debove1.valeur = PERF.debove1.valeur-(PERF.clapdeb.valeur -1);
            PERF.fintru1.valeur = indexcom(5); % Fin camion 1
            PERF.fintru1.valeur = PERF.fintru1.valeur-(PERF.clapdeb.valeur -1);
            PERF.debtru2.valeur = indexcom(6); % D�but camion 2
            PERF.debtru2.valeur = PERF.debtru2.valeur-(PERF.clapdeb.valeur -1);
            PERF.finove1.valeur = indexcom(7); % Fin overtaking +1 et fin camion 2
            PERF.finove1.valeur = PERF.finove1.valeur-(PERF.clapdeb.valeur -1);
            PERF.debped.valeur = indexcom(8);  % D�but pi�ton
            PERF.debped.valeur = PERF.debped.valeur-(PERF.clapdeb.valeur -1);
            PERF.finped.valeur = indexcom(9);  % Fin pi�ton
            PERF.finped.valeur = PERF.finped.valeur-(PERF.clapdeb.valeur -1);
            
            %Temps Disco 3
            TIME.tpstotal.valeur=Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            TIME.left.valeur=(Tps(PERF.finleft.valeur)-(Tps(PERF.debleft.valeur)));
            TIME.overt1.valeur=(Tps(PERF.finove1.valeur)-(Tps(PERF.debove1.valeur)));
            TIME.ped.valeur=(Tps(PERF.finped.valeur)-(Tps(PERF.debped.valeur)));
            disp(['Disco 3 : la dur�e du toune � gauche est de  ' ...
                num2str(TIME.left.valeur) ' secondes'])
            disp(['Disco 3 : la dur�e du depassement +1 est de  ' ...
                num2str(TIME.overt1.valeur) ' secondes'])
            disp(['Disco 3 : la dur�e du pi�ton est de ' ...
                num2str(TIME.ped.valeur) ' secondes'])
            
            
            
            % Calcul de la fr�quence d'�chantillonage du simu de clapdeb � clapfin
            Tpsclapfin = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsclapdeb = cell2mat(data(PERF.clapdeb.valeur,2));
            Tpsfinsuiv = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsdebsuiv = cell2mat(data(PERF.clapdeb.valeur,2));
            min = str2double(Tpsfinsuiv(4:5)) - str2double(Tpsdebsuiv(4:5));
            min = min*60;
            sec = str2double(Tpsfinsuiv(7:8)) - str2double(Tpsdebsuiv(7:8));
            mil = (str2double(Tpsfinsuiv(10:14))-str2double(Tpsdebsuiv(10:14)))/100000;
            Fe = length(PERF.clapdeb.valeur:PERF.clapfin.valeur)/(min+sec+mil);
            PERF.Freq.valeur = Fe;
            % Dur�e totale en secondes
            tempsorigin = Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            
        end
        
        if disco ==4
            
            PERF.clapdeb.valeur = indexcom(1);  % Debut enregistrement
            PERF.clapfin.valeur = indexcom(8);  % Fin enregistrement
            
            PERF.debove.valeur = indexcom(2);   % D�but overtake simple
            PERF.debove.valeur = PERF.debove.valeur-(PERF.clapdeb.valeur -1);
            PERF.finove.valeur = indexcom(3);   % Fin overtake simple
            PERF.finove.valeur = PERF.finove.valeur-(PERF.clapdeb.valeur -1);
            PERF.debleft1.valeur = indexcom(4); % Debut tourne � gauche +1
            PERF.debleft1.valeur = PERF.debleft1.valeur-(PERF.clapdeb.valeur -1);
            PERF.finleft1.valeur = indexcom(5); % Fin tourne � gauche +1
            PERF.finleft1.valeur = PERF.finleft1.valeur-(PERF.clapdeb.valeur -1);
            PERF.debsb.valeur = indexcom(6);    % D�but jaillissement
            PERF.debsb.valeur = PERF.debsb.valeur-(PERF.clapdeb.valeur -1);
            PERF.finsb.valeur = indexcom(7);    % Fin jaillissement
            PERF.finsb.valeur = PERF.finsb.valeur-(PERF.clapdeb.valeur -1);
            
            % Temps Disco 4
            TIME.tpstotal.valeur=Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            TIME.overt.valeur = (Tps(PERF.finove.valeur)-(Tps(PERF.debove.valeur)));
            TIME.left1.valeur=(Tps(PERF.finleft1.valeur)-(Tps(PERF.debleft1.valeur)));
            TIME.SB.valeur = (Tps(PERF.finsb.valeur)-(Tps(PERF.debsb.valeur)));
            disp(['Disco 4 : la dur�e du d�passement est de  ' ...
                num2str(TIME.overt.valeur) ' secondes'])
            disp(['Disco 4 : la dur�e du tourne � gauche+1 est de  ' ...
                num2str(TIME.left1.valeur) ' secondes'])
            disp(['Disco 4 : la dur�e du jaillissement est de ' ...
                num2str(TIME.SB.valeur) ' secondes'])
            
            
            % Calcul de la fr�quence d'�chantillonage du simu de clapdeb � clapfin
            Tpsclapfin = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsclapdeb = cell2mat(data(PERF.clapdeb.valeur,2));
            Tpsfinsuiv = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsdebsuiv = cell2mat(data(PERF.clapdeb.valeur,2));
            min = str2double(Tpsfinsuiv(4:5)) - str2double(Tpsdebsuiv(4:5));
            min = min*60;
            sec = str2double(Tpsfinsuiv(7:8)) - str2double(Tpsdebsuiv(7:8));
            mil = (str2double(Tpsfinsuiv(10:14))-str2double(Tpsdebsuiv(10:14)))/100000;
            Fe = length(PERF.clapdeb.valeur:PERF.clapfin.valeur)/(min+sec+mil);
            PERF.Freq.valeur = Fe;
            % Dur�e totale en secondes
            tempsorigin = Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            
        end
        
        % Session de conduite confort : Conduite � tr�s faibles perturbations
        if disco ==5
            
            PERF.clapdeb.valeur = indexcom(1);  % Debut enregistrement
            %PERF.clapfin.valeur = indexcom(5);  % Fin enregistrement
            PERF.clapfin.valeur = indexcom(6);  % Fin enregistrement
            
            PERF.debleft.valeur = indexcom(2); % D�but tourne � gauche simple
            PERF.debleft.valeur = PERF.debleft.valeur -(PERF.clapdeb.valeur -1);
            PERF.finleft.valeur = indexcom(3); % Fin tourne � gauche simple
            PERF.finleft.valeur  = PERF.finleft.valeur  -(PERF.clapdeb.valeur -1);
            PERF.debove.valeur = indexcom(4);   % D�but overtake simple
            PERF.debove.valeur = PERF.debove.valeur-(PERF.clapdeb.valeur -1);
            PERF.finove.valeur = indexcom(5);   % Fin overtake simple
            PERF.finove.valeur = PERF.finove.valeur-(PERF.clapdeb.valeur -1);
            
            % Temps Disco 5
            TIME.tpstotal.valeur = Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            TIME.left.valeur = (Tps(PERF.finleft.valeur)-(Tps(PERF.debleft.valeur)));
            TIME.overt.valeur = (Tps(PERF.finove.valeur)-(Tps(PERF.debove.valeur)));
            disp(['Disco 5 : la dur�e du toune � gauche est de  ' ...
                num2str(TIME.left.valeur) ' secondes'])
            disp(['Disco 5 : la dur�e du d�passement est de  ' ...
                num2str(TIME.overt.valeur) ' secondes'])
            
            
            % Calcul de la fr�quence d'�chantillonage du simu de clapdeb � clapfin
            Tpsclapfin = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsclapdeb = cell2mat(data(PERF.clapdeb.valeur,2));
            Tpsfinsuiv = cell2mat(data(PERF.clapfin.valeur,2));
            Tpsdebsuiv = cell2mat(data(PERF.clapdeb.valeur,2));
            min = str2double(Tpsfinsuiv(4:5)) - str2double(Tpsdebsuiv(4:5));
            min = min*60;
            sec = str2double(Tpsfinsuiv(7:8)) - str2double(Tpsdebsuiv(7:8));
            mil = (str2double(Tpsfinsuiv(10:14))-str2double(Tpsdebsuiv(10:14)))/100000;
            Fe = length(PERF.clapdeb.valeur:PERF.clapfin.valeur)/(min+sec+mil);
            PERF.Freq.valeur = Fe;
            % Dur�e totale en secondes
            tempsorigin = Tps(PERF.clapfin.valeur)-Tps(PERF.clapdeb.valeur);
            
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %% Signaux bruts
        
        % Point Kilom�trique PK (en m�tres)
        POSvp = data(:,9);
        POSvp = POSvp(PERF.clapdeb.valeur : PERF.clapfin.valeur);
        %Retranchement selon les claps d�but et fin
        PERF.POSvp.valeur = cell2mat(POSvp);
        PERF.POSvp.valeur = PERF.POSvp.valeur./1000 ; %Conversion en km
        
        % Standard deviation lateral position SDLP (en m�tres)
        POSLATvp = data(:,7);
        POSLATvp = POSLATvp(PERF.clapdeb.valeur : PERF.clapfin.valeur);
        PERF.POSLATvp.valeur = cell2mat(POSLATvp);
        PERF.POSLATvp.valeur = PERF.POSLATvp.valeur./1000 ; %Conversion en km
        
        % Vitesse sujet (m/s) ==> V�rifi�e
        VITvp = data(:,10);
        VITvp = VITvp(PERF.clapdeb.valeur : PERF.clapfin.valeur);
        PERF.VITvp.valeur = cell2mat (VITvp);
        PERF.VITvp.valeur = PERF.VITvp.valeur.* 3.6; % Conversion en km/h
        
        % Freinage (% de capacit�) ==> V�rifi� / Freinage maximal = 255(sans unit�)
        maxfrein = 255;
        FREINvp = data(:,13);
        FREINvp = FREINvp(PERF.clapdeb.valeur : PERF.clapfin.valeur);
        PERF.FREIN.valeur = cell2mat(FREINvp);
        PERF.FREIN.valeur = (PERF.FREIN.valeur/maxfrein).*100;
        % Calcul du % d'utilisation de la p�dale de frein en fonction du max (255)
        
        % Volant (mV) : valeurs positives = rotation � gauche
        VOLvp = data(:,12);
        VOLvp = VOLvp(PERF.clapdeb.valeur : PERF.clapfin.valeur);
        PERF.VOLvp.valeur = cell2mat(VOLvp);
        PERF.VOLvp.valeur = PERF.VOLvp.valeur.*0.0455; %Sortie en degr�s /
        %Avec 0.0455 : taux de conversion mV vers degr�s
        
        %figure,plot(PERF.VOLvp.valeur)
        %figure, plot(PERF.VOLvp.valeur),title('Angle du volant en degr�s'),
        %xlabel('Data'),ylabel('Angle (degr�s)')
        
        %%% D�tection des revirements de position du volant
        
        rv = wheelreversal(PERF.VOLvp.valeur);
        PERF.rv.valeur = rv;
        
        
        
        %% D�tection des indices d'inconforts
        %=> Utilisation des commodos Phare et Lave Glace
        
        % Colonne dans laquelle est indiqu�e s'il y a eu utilsation des commodos
        strs = data(:,14);
        
        % Si appui sur commodo phare not� NmPh % Commodo Gauche (Phare)
        indph=find(ismember(strs,'NmPh')); % D�tection de caract�re
        if indph >0
            diffindph = diff(indph);
            sautdiffindph = find(diffindph>1);
            
            %indice pour r�cup�rer les indices des 1er appuis sur le bouton "phare"
            PERF.indph.valeur = indph([1;find(diffindph>1)+1]);
            % Recalage par rapport au clap debut
            PERF.indph.valeur = PERF.indph.valeur-(PERF.clapdeb.valeur -1);
            
            
            
        else
            disp('Aucun appui comodo Phare'); % Si pas d'appuis, on affiche cela
            PERF.indph.valeur = [];
        end
        
        % Si appui sur commodo lave glace not� NmLg
        % Idem que pr�c�demment mais avec commodo droit
        indlg=find(ismember(strs,'NmLg'));
        if indlg > 0
            diffindlg = diff(indlg);
            sautdiffindlg = find(diffindlg>1);
            %R�cup�rer les indices des 1er appuis sur le bouton "lave glace"
            PERF.indlg.valeur = indlg([1;find(diffindlg>1)+1]);
            PERF.indlg.valeur = PERF.indlg.valeur-(PERF.clapdeb.valeur -1);
            
            
        else
            disp('Aucun appui comodo Lave Glace');
            PERF.indlg.valeur = [];
        end
        
        % Sauvegarde de la structure des donn�es simu du sujet
        namemat = ['APERFS' num2str(suj) '_' cell2mat(DISCO(disco))];
        cd('E:\PROJETS ACTUELS\TOYOTA\Discoplus\Sujets\Structures')% Directory de sauvegarde
        save (namemat,'PERF')
        
        clear PERF % On nettoye et on recommence !
        
        
    end % Fin de la boucle sc�nario
    
end % Fin de la boucle sujet
