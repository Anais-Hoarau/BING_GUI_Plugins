%% DISCO + TRAITEMENT DES DONNEES : TRAITEMENT PHASE 2/3
%
%%% DONNEES PHYSIOLOGIQUES
%
%  Projet DISCO+ 2016 : H.LOECHES et J.TAILLARD

close all ; clear all ;
warning('off');


%%%% LANCEUR DES SUJETS ANALYSES

% SUJETS ANALYSES %
numerosujet = [40]; %Sujets à analyser


%% Paramètres pré-traitement et réglages
DISCO = {'D1' 'D2' 'D3' 'D4' 'D5'};

sizewindowECG = 30;     % Taille de la fenêtre en secondes (données ECG)
slide_incr = 1;         % Incrémentation : décallage du nombre de données

sizewindowRES = 30;nbptsRES = 5000;  % Taille de la fenêtre en sec (ECG)
sizewindowEDA = 30;nbptsEDA = 5000;  % Taille de la fenêtre en sec (EDA)
FeECG = 2000; FeRES = 2000; FeEDA = 2000; % Freq d'échantillonnage

%% Traitement des données

for suj = numerosujet; % Boucle d'analyse pour chaque sujet
    filenamerepos = ['E:\PROJETS ACTUELS\TOYOTA\Discoplus\Sujets\Databrutes\S'...
        num2str(suj) 'repos.mat'];
    datarepos = load(filenamerepos);
    
    %Récupération des données brutes dans les fichiers BIOPAC
    PHYSIO.ECGrepos.valeur = datarepos.data(:,2);
    PHYSIO.EDArepos.valeur = datarepos.data(:,1);
    PHYSIO.RESrepos.valeur = datarepos.data(:,3);
    
    % Filtrage EDA repos
    filtCutOff3 = 0.5 ; % Fréquence de coupure
    [k, j] = butter(2, (2*filtCutOff3)/FeEDA, 'low'); %Filtre passe bas
    PHYSIO.EDAfiltrepos.valeur = filtfilt(k, j, PHYSIO.EDArepos.valeur);
    PHYSIO.EDAbaseline.valeur = mean(PHYSIO.EDAfiltrepos.valeur); % moyenne EDA
    % Save de la baseline pour tous les disco
    EDAbaseline = PHYSIO.EDAbaseline.valeur;
    
    
    
    for disco = [1 2 5]; % Boucle pour chaque scenario
        % NE PAS MODIFIER !
        
        try disco; % Teste si le sujet à fait le scenario 1
            filename = ['E:\PROJETS ACTUELS\TOYOTA\Discoplus\Sujets\Databrutes\S'...
                num2str(suj)  cell2mat(DISCO(disco)) '.mat'];
            data = load(filename);
            
        catch
            disco = disco + 2 ; %Si non teste le 3
            filename = ['E:\PROJETS ACTUELS\TOYOTA\Discoplus\Sujets\Databrutes\S'...
                num2str(suj)  cell2mat(DISCO(disco)) '.mat'];
            data = load(filename);
        end
        
        disp(['En cours: S' num2str(suj) cell2mat(DISCO(disco)) '.mat'])
        
        % Voies physiologiques
        EDA = data.data(:,1); % Activité electrodermale
        ECG = data.data(:,2); % Activité cardiaque
        RES = data.data(:,3); % Activité respiratoire
        
        % Voies des triggers
        DIG1 = data.data(:,4); % Voie des triggers début fin scenario
        DIG2 = data.data(:,5); % Voie des triggers des évenements
        
        DIG1 (1:2) = 0; % Enlève des erreurs dans les données
        DIG2 (1:2) = 0; % Enlève des erreurs dans les données
        
        
        %%%% TRIGGERS DETECTION %%%%
        % Triggers Debut et Fin : Voie 1
        delt1 = diff(DIG1);         % Voie digitale 1 (clap deb/fin)
        deltpos1 = find (delt1>0);  % Voie digitale 1 (clap deb/fin)
        clapdeb = deltpos1(1);
        clapfin = deltpos1(2);
        
        % Triggers Situations : Voie 2
        delt2 = diff(DIG2);              % Voie digitale 2 (situations)
        deltpos2 = find (delt2>0);  % Voie digitale 2 (situations)
        
        % Découpage des données en fonction des claps deb et fin
        EDA = EDA(clapdeb:clapfin);
        ECG = ECG(clapdeb:clapfin);
        RES = RES(clapdeb:clapfin);
        
        
        %% TRAITEMENT :  ECG
        
        % Filtrage ECG
        filtCutOff = 2; % Frequence de coupure du filtre passe haut
        [b, a] = butter(2, (2*filtCutOff)/FeECG, 'high'); %Passe haut ordre 2
        ECGfilt = filtfilt(b, a, ECG);
        PHYSIO.ECGfilt.valeur = ECGfilt;
        
        
        
        % Lecture des indices des pics FC et FC moy via peakdetect
        ECGfilt = ECGfilt(200:end); % On enleve les 200eres valeurs d'erreur
        %Fonction "peakdetect" permet de trouver la position des ondes ECG
        [R_i,heart_rate,R_R] = peakdetect(single(ECGfilt),FeECG);
        figure,plot(ECGfilt),hold on, plot(R_i,ECGfilt(R_i),'ro');
        
        uiyfif
        PHYSIO.RI.valeur = R_i+199; %R_i+199 correction
        
        
        
        
        %% TRAITEMENT : RESPIRATOIRE
        
        %%% Filtrage Respiratoire
        Tps = 0:1/FeRES:(length(RES)-1)/FeRES; % Vecteur temporel (pour affichage)
        filtCutOff2 = 0.35 ; % Frequence de coupure du filtre passe haut
        [d, c] = butter(2, (2*filtCutOff2)/FeRES, 'low'); %Passe haut ordre 2
        RESfilt = filtfilt(d, c, RES);
        
        PHYSIO.RESfilt.valeur = RESfilt;
        
        %%% Détection des pics respiratoires sur le signal brut
        [e, mi] = segmente (RESfilt, 'do_not_recenter');
        % Extrememum des positions en x => E = indices des pics respiratoires
        PHYSIO.e.valeur = e; % Stockage dans la structure PHYSIO pour indexvar6
        
        
        %% TRAITEMENT : Activité électrodermale
        
        % Filtrage EDA
        filtCutOff3 = 0.5 ; % Frequence de coupure du filtre passe haut
        [k, j] = butter(2, (2*filtCutOff3)/FeEDA, 'low'); %Passe haut ordre 2
        EDAfilt = filtfilt(k, j, EDA);
        
        PHYSIO.EDAfilt.valeur = EDAfilt;
        PHYSIO.EDAfilt.valeur = (PHYSIO.EDAfilt.valeur)/EDAbaseline;
        % EDA normalisé par rapport à la moyenne
        
        
        
        %% Trigger selon scénarios
        
        if disco == 1 % Si scenario = DISCO 1
            
            % Indices de situations + recalage
            debove1 = deltpos2(1); %Début overtaking +1 et debut camion 1
            debove1 = debove1 - (clapdeb - 1); % Recalage selon clapdeb -1
            
            fintru1 = deltpos2(2); % Fin camion 1
            fintru1 = fintru1 - (clapdeb - 1);
            
            debtru2 = deltpos2(3); % Debut camion 2
            debtru2 = debtru2 - (clapdeb - 1);
            
            finove1 = deltpos2(4); % Fin overtaking +1
            finove1 = finove1 - (clapdeb - 1);
            
            debleft = deltpos2(5);
            debleft = debleft - (clapdeb - 1);
            
            finleft = deltpos2(6);
            finleft = finleft - (clapdeb - 1);
            
            debped = deltpos2(7);
            debped = debped - (clapdeb - 1);
            
            finped = deltpos2(8);
            finped = finped - (clapdeb - 1);
            
            %Stockage des triggers evenements dans la structure physio
            PHYSIO.debove1.valeur = debove1;
            PHYSIO.fintru1.valeur = fintru1;
            PHYSIO.debtru2.valeur = debtru2;
            PHYSIO.finove1.valeur = finove1;
            PHYSIO.debleft.valeur = debleft;
            PHYSIO.finleft.valeur = finleft;
            PHYSIO.debped.valeur = debped;
            PHYSIO.finped.valeur = finped;
            
            
            % Durée du scénario et des situations
            tpstotal = (clapfin-clapdeb)/2000;
            tpsove1 = (finove1-debove1)/2000; % Tps overtaking
            tpstru1 = (fintru1-debove1)/2000; % Tps camion 1
            tpstru2 = (finove1-debtru2)/2000; % Tps camion 2
            tpsleft  = (finleft - debleft)/2000; % Tps TAG
            tpsped = (finped-debped)/2000; % Tps piéton
            
            
        end % Fin boucle scénario 1
        
        
        
        if disco == 2 % Si scénario = DISCO 2
            
            
            % Indices de situations + recalage
            debleft1 = deltpos2(1);
            debleft1 = debleft1 - (clapdeb - 1);
            finleft1 = deltpos2(2);
            finleft1 = finleft1 - (clapdeb - 1);
            debove = deltpos2(3);
            debove = debove - (clapdeb - 1);
            finove = deltpos2(4);
            finove = finove - (clapdeb - 1);
            debsb = deltpos2(5);
            debsb = debsb - (clapdeb - 1);
            finsb = deltpos2(6);
            finsb = finsb - (clapdeb - 1);
            
            PHYSIO.debove.valeur = debove;
            PHYSIO.finove.valeur = finove;
            PHYSIO.debleft1.valeur = debleft1;
            PHYSIO.finleft1.valeur = finleft1;
            PHYSIO.debsb.valeur = debsb;
            PHYSIO.finsb.valeur = finsb;
            
            
            
            
            % Durée du scénario et des situations
            tpstotal = (clapfin-clapdeb)/2000;
            tpsleft1 = (finleft1-debleft1)/2000;
            tpsove  = (finove - debove)/2000;
            tpsSB = (finsb-debsb)/2000;
            
        end % Fin boucle scénario 2
        
        
        
        if disco == 3 % Si scénario = DISCO 3
            
            % Indices de situations + recalage
            debleft = deltpos2(1);
            debleft = debleft - (clapdeb - 1);
            finleft = deltpos2(2);
            finleft = finleft - (clapdeb - 1);
            debove1 = deltpos2(3);
            debove1 = debove1 - (clapdeb - 1);
            fintru1 = deltpos2(4);
            fintru1 = fintru1 - (clapdeb - 1);
            debtru2 = deltpos2(5);
            debtru2 = debtru2 - (clapdeb - 1);
            finove1 = deltpos2(6);
            finove1 = finove1 - (clapdeb - 1);
            debped = deltpos2(7);
            debped = debped - (clapdeb - 1);
            finped = deltpos2(8);
            finped = finped - (clapdeb - 1);
            
            
            PHYSIO.debove1.valeur = debove1;
            PHYSIO.fintru1.valeur = fintru1;
            PHYSIO.debtru2.valeur = debtru2;
            PHYSIO.finove1.valeur = finove1;
            PHYSIO.debleft.valeur = debleft;
            PHYSIO.finleft.valeur = finleft;
            PHYSIO.debped.valeur = debped;
            PHYSIO.finped.valeur = finped;
            
            
            % Durée du scénario et des situations
            tpstotal = (clapfin-clapdeb)/2000;
            tpsleft1 = (finleft-debleft)/2000;
            tpsove1  = (finove1 - debove1)/2000;
            tpsped = (finped-debped)/2000;% Durée du scénario et des situations
            tpstotal = (clapfin-clapdeb)/2000;
            tpsove1 = (finove1-debove1)/2000;
            tpstru1 = (fintru1-debove1)/2000;
            tpstru2 = (finove1-debtru2)/2000;
            tpsleft  = (finleft - debleft)/2000;
            tpsped = (finped-debped)/2000;
            
        end % Fin boucle scénario 3
        
        
        
        if disco == 4 % Si fichier = DISCO 4
            
            % Indices de situations + recalage
            debove = deltpos2(1);
            debove = debove - (clapdeb - 1);
            finove = deltpos2(2);
            finove = finove - (clapdeb - 1);
            debleft1 = deltpos2(3);
            debleft1 = debleft1 - (clapdeb - 1);
            finleft1 = deltpos2(4);
            finleft1 = finleft1 - (clapdeb - 1);
            debsb = deltpos2(5);
            debsb = debsb - (clapdeb - 1);
            finsb = deltpos2(6);
            finsb = finsb - (clapdeb - 1);
            
            PHYSIO.debove.valeur = debove;
            PHYSIO.finove.valeur = finove;
            PHYSIO.debleft1.valeur = debleft1;
            PHYSIO.finleft1.valeur = finleft1;
            PHYSIO.debsb.valeur = debsb;
            PHYSIO.finsb.valeur = finsb;
            
            
            
            % Durée du scénario et des situations
            tpstotal = (clapfin-clapdeb)/2000;
            tpsove = (finove-debove)/2000;
            tpsleft1  = (finleft1 - debleft1)/2000;
            tpsSB = (finsb-debsb)/2000;
            
        end % Fin boucle scénario 4
        
        if disco == 5 % Si fichier = DISCO 5 (confort)
            
            % Indices de situations + recalage
            debleft = deltpos2(1);
            debleft = debleft - (clapdeb - 1);
            finleft = deltpos2(2);
            finleft = finleft - (clapdeb - 1);
            debove = deltpos2(3);
            debove = debove - (clapdeb - 1);
            finove = deltpos2(4);
            finove = finove - (clapdeb - 1);
            
            PHYSIO.debove.valeur = debove;
            PHYSIO.finove.valeur = finove;
            PHYSIO.debleft.valeur = debleft;
            PHYSIO.finleft.valeur = finleft;
            
            
            % Durée du scénario et des situations
            tpstotal = (clapfin-clapdeb)/2000;
            tpsleft = (finleft-debleft)/2000;
            tpsove  = (finove - debove)/2000;
            
        end
        
        
        % Save de la structure des données sujet
        namemat = ['APHYSIOS' num2str(suj) '_' cell2mat(DISCO(disco))];
        cd('E:\PROJETS ACTUELS\TOYOTA\Discoplus\Sujets\Structures')
        save (namemat,'PHYSIO')
        
        clear PHYSIO % Nettoyage et recommence !
        
    end % Fin de la boucle scenario
    
end % Fin de la boucle sujet

