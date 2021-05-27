%% DISCO + TRAITEMENT DES DONNEES : TRAITEMENT PHASE 3/3
%
%%% CALCUL DE L'INDICE D'INCONFORT %%%
%
%  Projet DISCO+ 2016 : H.LOECHES et J.TAILLARD

% VERSION 6 %

%% A NOTER :
% Role du Script : Script Permet d'observer l'ensemble des variables pour chaque sujet/disco
% Prise en compte des SWO et SWL différents !

% Combinaison index Haut level + 1 --> [C1 : C25]
% Combinaison index Haut level --> [C26 : C50]
% Combinaison index Piéton --> [C51 : C75]
% Combinaison index Jaillissement --> [C76 : C100]

%% Päramètres de réglages %%
clear all ; close all;
warning('off');

%%%% LANCEUR DES SUJETS ANALYSES %%%%

%%% SUJETS ANALYSES %%%
numerosujet = [11]; % Sujets analysés

%%%% Reglages Index %%%%
sizewindowPHYSIO = 30; % Taille de la fenêtre en secondes (PHYSIO)
sizewindowPERF = sizewindowPHYSIO; % Taille de la fenêtre en secondes (PERF)
overlap = 1; % Overlap 0% = 1 /// %Overlap 50% = 0.5 /// Overlap = 25% = 0.25
FePHYSIO = 2000; % Fréquence échantillonage données physio

%%%% Reglage Baseline %%%%
coeffSTD = 1;  % Paramètres de réglage du STD (affichage baseline)

%%%% Réglage : Pourcentage de points enlevés au début et à la fin de chaque signal %%%%
out = 0.15; % Ici  0.1 = 10% des points enlevé quelque soit SWL ou SWO

%% Traitement des données
fichierdisco = [1 2]; % NE JAMAIS CHANGER : Prise en compte auto du Disco !
DISCO = {'D1' 'D2' 'D3' 'D4' 'D5'};
identity = 'E:\PROJETS ACTUELS\TOYOTA\Discoplus\Sujets\Structures\';

for suj = numerosujet % Boucle d'analyse du sujet en cours
    tic % Début enregistrement du temps que met matlab à analyser chaque scénario
    
    %% ANALYSE SESSION CONFORT
    for disco = 5 % Scénario Confort
        
        % Lieu de lecture du fichier
        filenamephysio = [identity 'PHYSIOS' num2str(suj) '_' cell2mat(DISCO(disco)) '.mat'];
        dataphysio = load(filenamephysio);
        filenameperf = [identity 'PERFS' num2str(suj) '_' cell2mat(DISCO(disco)) '.mat'];
        dataperf = load(filenameperf);
        
        % Variables physio DISCO 5
        
        % TEST EN ECG Coupé
        ECG = dataphysio.PHYSIO.ECGfilt.valeur;
        RI = dataphysio.PHYSIO.RI.valeur;
        %     newRI = dataphysio.PHYSIO.newRI.valeur;
        e = dataphysio.PHYSIO.e.valeur;
        
        EDA = dataphysio.PHYSIO.EDAfilt.valeur;
        EDAinterpol = dataphysio.PHYSIO.EDAinterpol.valeur;
        ECGinterpol = dataphysio.PHYSIO.ECGinterpol.valeur;
        
        % Paramétrage fenêtre physio DISCO 5
        win_widthPHYSIO = sizewindowPHYSIO*FePHYSIO; %Nombres d'indices par fenêtre = Fréquence échantillonnage physio x Nombre de secondes Sliding window width (round(X) rounds the elements of X to the nearest integers) ancien = round(10*sec)
        slide_incrPHYSIO = win_widthPHYSIO*overlap;  %Incrémentation : décallage du nombre de données = 99% (appelé Slide for each iteration)
        numstpsPHYSIO = floor((length(ECG)-win_widthPHYSIO)/slide_incrPHYSIO); %Nombre de fenêtres glissantes
        
        % Calcul index physio DISCO 5
        
        count = 1; % Compteur : nombre de fois où la boucle a tourné
        for i = 1:numstpsPHYSIO % A chaque fenêtre on fait :
            HR(i) = sum(ismember(RI,count:count+win_widthPHYSIO))*(60/sizewindowPHYSIO);            % Fréquence cardiaque
            HRV(i) = std(diff(RI(find((ismember(RI,count:count+win_widthPHYSIO)==1)))))/FePHYSIO;   % Variabilité FC
            EDAstep(i)= max(EDA(count:count+win_widthPHYSIO))-min(EDA(count:count+win_widthPHYSIO));% EDA normalisé
            EDArms (i) = rms((EDA(count:count+win_widthPHYSIO)));
            RYT(i) = sum(ismember(e,count:count+win_widthPHYSIO))*(60/sizewindowPHYSIO);            % Rythme Cardiaque
            
            count = count + win_widthPHYSIO*overlap; %Compteur = Compteur + 1
        end
        %
        % Recoupage des données pour enlever les erreurs au début et à la fin
        sizeout = round(numstpsPHYSIO*out);
        HR = HR(sizeout:end-sizeout);
        HRV = HRV(sizeout:end-sizeout);
        EDAstep = EDAstep(sizeout:end-sizeout);
        EDArms = EDArms(sizeout:end-sizeout);
        RYT = RYT(sizeout:end-sizeout);
        
        %%%% NORMALISATION Physio DISCO 5 entre 0 et 1 %%%%
        ampHR = max(HR); HR = HR/ampHR;
        ampHRV = max(HRV); HRV = HRV/ampHRV;
        ampEDAstep = max(EDAstep);EDAstep=EDAstep/ampEDAstep;
        ampEDArms = max(EDArms);EDArms=EDArms/ampEDArms;
        ampRYT = max(RYT);RYT = RYT/ampRYT;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Modification du sens de HRV
        HRV = (HRV*-1)+1;
        
        % Calcul des baselines physiologiques sur DISCO 5
        EDAbaseline = ones(length(EDAstep),1)' .* (mean(EDAstep)) + coeffSTD * std(EDAstep);
        EDArmsbaseline = ones(length(EDArms),1)' .* (mean(EDArms)) + coeffSTD * std(EDArms);
        HRbaseline = ones(length(HR),1)' .* (mean(HR)) + coeffSTD * std(HR);
        HRVbaseline = ones(length(HRV),1)' .* (mean(HRV)) + coeffSTD * std(HRV);
        RYTbaseline = ones(length(RYT),1)' .* (mean(RYT)) + coeffSTD * std(RYT);
        
        % Importation des variables Perf DISCO 5
        FePERF =  dataperf.PERF.Freq.valeur;
        POSLATvp = dataperf.PERF.POSLATvp.valeur;
        VITvp = dataperf.PERF.VITvp.valeur;
        FREIN = dataperf.PERF.FREIN.valeur;
        VOLvp = dataperf.PERF.VOLvp.valeur;
        rv = dataperf.PERF.rv.valeur;
        
        % Paramétrage fenêtre perf
        win_widthPERF = round(sizewindowPERF*FePERF);                         %Nombres d'indices par fenêtre = Fréquence échantillonnage physio x Nombre de secondes Sliding window width (round(X) rounds the elements of X to the nearest integers) ancien = round(10*sec)
        slide_incrPERF = win_widthPERF*overlap;                               %Incrémentation : décallage du nombre de données = 99% (appelé Slide for each iteration)
        numstpsPERF = floor((length(POSLATvp)-win_widthPERF)/slide_incrPERF); %Number of windows
        
        count = 1;
        for i = 1:numstpsPERF
            SDLP(i) = std(POSLATvp(count:count+win_widthPERF)); % Position latérale
            SDS(i) = std(VITvp(count:count+win_widthPERF));     % Vitesse Avancement
            RV(i) =   sum(ismember(rv,count:count+win_widthPERF))*(60/sizewindowPERF); % Revirement du volant
            SDSW(i) = std(VOLvp(count:count+win_widthPERF)); % Volant
            RMSfrein(i) = max((gradient(gradient(FREIN(count:count+win_widthPERF)))))-min((gradient(gradient(FREIN(count:count+win_widthPERF)))));% Frein
            
            count = count + win_widthPERF*overlap;
            
        end
        
        % Recoupage des données pour enlever les erreurs au début et à la fin
        sizeout1 = round(numstpsPERF*out);
        SDLP = SDLP(sizeout1:end-sizeout1);
        SDS = SDS(sizeout1:end-sizeout1);
        SDSW = SDSW(sizeout1:end-sizeout1);
        RV = RV(sizeout1:end-sizeout1);
        RMSfrein = RMSfrein(sizeout1:end-sizeout1);
        
        
        %%%% Normalisation Perfomance DISCO 5 %%%%
        ampSDLP = max(SDLP);SDLP = SDLP/ampSDLP;
        ampSDS = max(SDS);SDS = SDS/ampSDS;
        SDSW = abs(SDSW);ampSDSW = max(SDSW);SDSW = SDSW/ampSDSW;
        ampRV = max(RV);RV = RV/ampRV;
        ampRMSfrein = max(RMSfrein);RMSfrein = RMSfrein/ampRMSfrein;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Calcul des baselines comportementales sur DISCO 5
        SDLPbaseline = ones(length(SDLP),1)' .* (mean(SDLP)) + coeffSTD * std(SDLP);
        SDSbaseline = ones(length(SDS),1)' .* (mean(SDS)) + coeffSTD * std(SDS);
        SDSWbaseline = ones(length(SDSW),1)' .* (mean(SDSW)) + coeffSTD * std(SDSW);
        RVbaseline = ones(length(RV),1)' .* (mean(RV)) + coeffSTD * std(RV);
        RMSfreinbaseline = ones(length(RMSfrein),1)' .* (mean(RMSfrein)) + coeffSTD * std(RMSfrein);

    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% ANALYSE SESSIONS INCONFORT
    
    for disco = fichierdisco %Pour chaque sceanrio inconfortable
        
        
        % Essai 1 : Si sujet a fait DISCO 1 et DISCO 2
        try
            filenamephysio = [identity 'PHYSIOS' num2str(suj) '_' cell2mat(DISCO(disco)) '.mat'];
            dataphysio = load(filenamephysio);
            filenameperf = [identity 'PERFS' num2str(suj) '_' cell2mat(DISCO(disco)) '.mat'];
            dataperf = load(filenameperf);
            % Essai 2 : Si sujet a fait DISCO 3 et DISCO 4
        catch
            fichierdisco = fichierdisco + 2;
            disco = disco + 2;
            filenamephysio = [identity 'PHYSIOS' num2str(suj) '_' cell2mat(DISCO(disco)) '.mat'];
            dataphysio = load(filenamephysio);
            filenameperf = [identity 'PERFS' num2str(suj) '_' cell2mat(DISCO(disco)) '.mat'];
            dataperf = load(filenameperf);
            fichierdisco = [1 2];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Variables physio importées
        
        ECG = dataphysio.PHYSIO.ECGfilt.valeur;
        RI = dataphysio.PHYSIO.RI.valeur;
        %     newRI = dataphysio.PHYSIO.newRI.valeur;
        e = dataphysio.PHYSIO.e.valeur;
        
        EDA = dataphysio.PHYSIO.EDAfilt.valeur;
        EDAinterpol = dataphysio.PHYSIO.EDAinterpol.valeur;
        ECGinterpol = dataphysio.PHYSIO.ECGinterpol.valeur;
        
        % Paramétrage fenêtre physio
        win_widthPHYSIO = sizewindowPHYSIO*FePHYSIO;                           %Nombres d'indices par fenêtre = Fréquence échantillonnage physio x Nombre de secondes Sliding window width (round(X) rounds the elements of X to the nearest integers) ancien = round(10*sec)
        slide_incrPHYSIO = win_widthPHYSIO*overlap;                            %Incrémentation : décallage du nombre de données = 99% (appelé Slide for each iteration)
        numstpsPHYSIO = floor((length(ECG)-win_widthPHYSIO)/slide_incrPHYSIO); %Nombre de fenêtres
        
        % Calcul index physio
        count = 1;
        for i = 1:numstpsPHYSIO
            HR(i) = sum(ismember(RI,count:count+win_widthPHYSIO))*(60/sizewindowPHYSIO);             % Fréquence cardiaque
            HRV(i) = std(diff(RI(find((ismember(RI,count:count+win_widthPHYSIO)==1)))))/FePHYSIO;    % Variabilité FC
            EDAstep(i)= max(EDA(count:count+win_widthPHYSIO))-min(EDA(count:count+win_widthPHYSIO)); % EDA normalisé
            EDArms (i) = rms((EDA(count:count+win_widthPHYSIO)));
            
            RYT(i) = sum(ismember(e,count:count+win_widthPHYSIO))*(60/sizewindowPHYSIO);             % Rythme Cardiaque
            
            count = count + win_widthPHYSIO*overlap;
            
        end
        
        % NORMALISATION Physio
        ampHR = max(HR);HR = HR/ampHR;
        ampHRV = max(HRV);HRV = HRV/ampHRV;
        ampEDAstep = max(EDAstep);EDAstep=EDAstep/ampEDAstep;
        ampEDArms = max(EDArms);EDArms=EDArms/ampEDArms;
        ampRYT = max(RYT);RYT = RYT/ampRYT;
        
        
        
        % Modification du sens de HRV
        HRV = (HRV*-1)+1;
        
        if disco == 1 %Pour chaque sceanrio inconfortable 1
            % On récupère les triggers physio
            debove1 = dataphysio.PHYSIO.debove1.valeur;
            fintru1  = dataphysio.PHYSIO.fintru1.valeur;
            debtru2 = dataphysio.PHYSIO.debtru2.valeur;
            finove1 = dataphysio.PHYSIO.finove1.valeur;
            debleft = dataphysio.PHYSIO.debleft.valeur;
            finleft = dataphysio.PHYSIO.finleft.valeur;
            debped = dataphysio.PHYSIO.debped.valeur;
            finped = dataphysio.PHYSIO.finped.valeur;
            
            % Conversion des triggers en position de fenêtre (??)
            trigger = [debove1 finove1 debleft finleft debped finped];
            trigger2 = (trigger/2000);
            trigger3 = round(trigger2);
            triggerphys = ceil(trigger3/sizewindowPHYSIO);
            
            HR1 = HR; % On scinde la variable HR en deux variables HR et HR1
            EDA1 = EDAstep; % On scinde la variable EDA en deux variables EDA et EDA step
            
        end
        
        if disco == 2 % idem que disco 1
            debleft1 = dataphysio.PHYSIO.debleft1.valeur;
            finleft1 = dataphysio.PHYSIO.finleft1.valeur;
            debove = dataphysio.PHYSIO.debove.valeur;
            finove = dataphysio.PHYSIO.finove.valeur;
            debsb = dataphysio.PHYSIO.debsb.valeur;
            finsb = dataphysio.PHYSIO.finsb.valeur;
            
            trigger = [debleft1 finleft1 debove finove debsb finsb];
            trigger2 = (trigger/2000);
            trigger3 = round(trigger2);
            triggerphys = ceil(trigger3/sizewindowPHYSIO);
            
            HR1 = HR;
            EDA1 = EDAstep;
        end
        
        if disco == 3 % idem que disco 1
            debleft = dataphysio.PHYSIO.debleft.valeur;
            finleft = dataphysio.PHYSIO.finleft.valeur;
            debove1 = dataphysio.PHYSIO.debove1.valeur;
            fintru1  = dataphysio.PHYSIO.fintru1.valeur;
            debtru2 = dataphysio.PHYSIO.debtru2.valeur;
            finove1 = dataphysio.PHYSIO.finove1.valeur;
            debped = dataphysio.PHYSIO.debped.valeur;
            finped = dataphysio.PHYSIO.finped.valeur;
            
            trigger = [debleft finleft debove1 finove1 debped finped];
            trigger2 = (trigger/2000);
            trigger3 = round(trigger2);
            triggerphys = ceil(trigger3/sizewindowPHYSIO);
            
            HR1 = HR;
            EDA1 = EDAstep;
        end
        
        if disco == 4 % idem que disco 1
            debove = dataphysio.PHYSIO.debove.valeur;
            finove = dataphysio.PHYSIO.finove.valeur;
            debleft1 = dataphysio.PHYSIO.debleft1.valeur;
            finleft1 = dataphysio.PHYSIO.finleft1.valeur;
            debsb = dataphysio.PHYSIO.debsb.valeur;
            finsb = dataphysio.PHYSIO.finsb.valeur;
            
            trigger = [debove finove debleft1 finleft1 debsb finsb];
            trigger2 = (trigger/2000);
            trigger3 = round(trigger2);
            triggerphys = ceil(trigger3/sizewindowPHYSIO);
            
            HR1 = HR;
            EDA1 = EDAstep;
        end
        
        % Boucle pour éviter d'avoir 2 triggers physiologiques superposés
        for w = 1:length(triggerphys)-1
            if triggerphys(w+1) == triggerphys(w)
                triggerphys(w+1) = triggerphys(w+1)+1;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Variables perf récupérées depuis fichiers précédent
        FePERF =  dataperf.PERF.Freq.valeur;
        POSLATvp = dataperf.PERF.POSLATvp.valeur;
        VITvp = dataperf.PERF.VITvp.valeur;
        FREIN = dataperf.PERF.FREIN.valeur;
        VOLvp = dataperf.PERF.VOLvp.valeur;
        rv = dataperf.PERF.rv.valeur;
        
        
        % Paramétrage fenêtre perf
        
        win_widthPERF = round(sizewindowPERF*FePERF);                         %Nombres d'indices par fenêtre = Fréquence échantillonnage physio x Nombre de secondes Sliding window width (round(X) rounds the elements of X to the nearest integers) ancien = round(10*sec)
        slide_incrPERF = win_widthPERF*overlap;                               %Incrémentation : décallage du nombre de données = 99% (appelé Slide for each iteration)
        numstpsPERF = floor((length(POSLATvp)-win_widthPERF)/slide_incrPERF); %Number of windows
        
        % Calcul index perf
        count = 1;
        for i = 1:numstpsPERF
            SDLP(i) = std(POSLATvp(count:count+win_widthPERF)); % Position latérale
            SDS(i) = std(VITvp(count:count+win_widthPERF));     % Vitesse Avancement
            RV(i) =   sum(ismember(rv,count:count+win_widthPERF))*(60/sizewindowPERF); % Revirement du volant
            SDSW(i) = std(VOLvp(count:count+win_widthPERF)); % Volant
            RMSfrein(i) = max((gradient(gradient(FREIN(count:count+win_widthPERF)))))-min((gradient(gradient(FREIN(count:count+win_widthPERF)))));%- min((gradient(gradient(FREIN(count:count+win_widthPERF))))); % Frein
            
            count = count + win_widthPERF*overlap;
            
        end
        
        %%% Normalisation Perfomance
        ampSDLP = max(SDLP);SDLP = SDLP/ampSDLP;
        ampSDS = max(SDS);SDS = SDS/ampSDS;
        SDSW = abs(SDSW);ampSDSW = max(SDSW);SDSW = SDSW/ampSDSW;
        ampRV = max(RV);RV = RV/ampRV;
        ampRMSfrein = max(RMSfrein);RMSfrein = RMSfrein/ampRMSfrein;
        
        if disco == 1 % Scénario 1 Trigger Performance
            adebove1 = dataperf.PERF.debove1.valeur;
            afintru1  = dataperf.PERF.fintru1.valeur;
            adebtru2 = dataperf.PERF.debtru2.valeur;
            afinove1 = dataperf.PERF.finove1.valeur;
            adebleft = dataperf.PERF.debleft.valeur;
            afinleft = dataperf.PERF.finleft.valeur;
            adebped = dataperf.PERF.debped.valeur;
            afinped = dataperf.PERF.finped.valeur;
            
            atrigger = [adebove1 afinove1 adebleft afinleft adebped afinped];
            atrigger2 = (atrigger/FePERF);
            atrigger3 = round(atrigger2);
            triggerperf = ceil(atrigger3/sizewindowPERF);
            
            RV1 = RV;
        end
        
        if disco == 2 % Scénario 2 Trigger Performance
            adebleft1 = dataperf.PERF.debleft1.valeur;
            afinleft1 = dataperf.PERF.finleft1.valeur;
            adebove = dataperf.PERF.debove.valeur;
            afinove = dataperf.PERF.finove.valeur;
            adebsb = dataperf.PERF.debsb.valeur;
            afinsb = dataperf.PERF.finsb.valeur;
            
            atrigger = [adebleft1 afinleft1 adebove afinove adebsb afinsb];
            atrigger2 = (atrigger/FePERF);
            atrigger3 = round(atrigger2);
            triggerperf = ceil(atrigger3/sizewindowPERF);
            
            RV1 = RV;
        end
        
        if disco == 3 % Scénario 3 Trigger Performance
            adebleft = dataperf.PERF.debleft.valeur;
            afinleft = dataperf.PERF.finleft.valeur;
            adebove1 = dataperf.PERF.debove1.valeur;
            afintru1  = dataperf.PERF.fintru1.valeur;
            adebtru2 = dataperf.PERF.debtru2.valeur;
            afinove1 = dataperf.PERF.finove1.valeur;
            adebped = dataperf.PERF.debped.valeur;
            afinped = dataperf.PERF.finped.valeur;
            
            atrigger = [adebleft afinleft adebove1 afinove1 adebped afinped];
            atrigger2 = (atrigger/FePERF);
            atrigger3 = round(atrigger2);
            triggerperf = ceil(atrigger3/sizewindowPERF);
            
            RV1 = RV;
            
        end
        
        if disco == 4 % Scénario 4 Trigger Performance
            adebove = dataperf.PERF.debove.valeur;
            afinove = dataperf.PERF.finove.valeur;
            adebleft1 = dataperf.PERF.debleft1.valeur;
            afinleft1 = dataperf.PERF.finleft1.valeur;
            adebsb = dataperf.PERF.debsb.valeur;
            afinsb = dataperf.PERF.finsb.valeur;
            
            atrigger = [adebove afinove adebleft1 afinleft1 adebsb afinsb];
            atrigger2 = (atrigger/FePERF);
            atrigger3 = round(atrigger2);
            triggerperf = ceil(atrigger3/sizewindowPERF);
            
            RV1 = RV;
        end
        
        % Boucle pour éviter d'avoir 2 triggers "performance" superposés
        for y = 1:length(triggerperf)-1
            if triggerperf(y+1) == triggerperf(y)
                triggerperf(y+1) = triggerperf(y+1)+1;
            end
        end
        
        
        %% Figure complète des variables physiologiques et perfs
        tps1 = (1 : length(EDA1)).*sizewindowPHYSIO*overlap; % Vecteur temps pour EDA
        vitefait1 = ((1:1:size(EDA1,2))*0)+1; % Création d'une ligne affichable graphquement
        EDAbaselineG = EDAbaseline(1).*vitefait1;... % Ligne x valeur de la baseline
            tps2 = (1 : length(EDArms)).*sizewindowPHYSIO*overlap;
        vitefait2 = ((1:1:size(EDArms,2))*0)+1;
        EDArmsbaselineG = EDArmsbaseline(1).*vitefait2;...
            tps3 = (1 : length(HR1)).*sizewindowPHYSIO*overlap;
        vitefait3 = ((1:1:size(HR1,2))*0)+1;
        HRbaselineG = HRbaseline(1).*vitefait3;...
            tps4 = (1 : length(HRV)).*sizewindowPHYSIO*overlap;
        vitefait4 = ((1:1:size(HRV,2))*0)+1;
        HRVbaselineG = HRVbaseline(1).*vitefait4;...
            tps5 = (1 : length(RYT)).*sizewindowPHYSIO*overlap;
        vitefait5 = ((1:1:size(RYT,2))*0)+1;
        RYTbaselineG = RYTbaseline(1).*vitefait5;...
            
    % Pour affichage des données PHYSIO au sein des zones de situations selon overlap : cf HRV
    triggerphys1 = triggerphys/overlap;
    
    % Figure complète : Affichage de toutes les variables physio
    M = figure('Units','Normalized','Position', [0.05 0.05 0.9 0.85],'Name',(['DISCO+ Sujet N°' num2str(suj) 'disco ' num2str(disco)]),'NumberTitle','off'),
    subplot(5,2,1),plot(tps1,EDA1),hold on,plot(tps1,EDAbaselineG),title('Physiological'),%area((tps(triggerphys(1):triggerphys(2))),EDA1(triggerphys(1):triggerphys(2)),'FaceColor',[0 0 0]),area(tps(triggerphys(1):triggerphys(2)),EDAbaseline(triggerphys(1):triggerphys(2)),'FaceColor',[1 1 1]),
    for j = 1:length(triggerphys) % Affichage des triggers
        line([triggerphys(j)*sizewindowPHYSIO triggerphys(j)*sizewindowPHYSIO], ylim,'LineWidth',1.5)
    end
    ylabel('Amp EDA'),xlabel('Time (s)'),xlim([tps1(1) tps1(end)]);
    
    subplot(5,2,3),plot(tps2,EDArms),hold on,plot(tps2,EDArmsbaselineG)
    for j = 1:length(triggerphys)
        line([triggerphys(j)*sizewindowPHYSIO triggerphys(j)*sizewindowPHYSIO], ylim,'LineWidth',1.5)
    end
    ylabel('EDA RMS'),xlabel('Time (s)'),xlim([tps2(1) tps2(end)])%,hold on, hold on, area((tps(triggerphys(5):triggerphys(6))),EDArms(triggerphys(5):triggerphys(6)),'FaceColor',[0 0 0])
    
    subplot(5,2,5),plot(tps3,HR1),hold on,plot(tps3,HRbaselineG),%area((tps(triggerphys(1):triggerphys(2))),HR1(triggerphys(1):triggerphys(2),'FaceColor',[0 0 0])),%area(tps(triggerphys(1):triggerphys(2)),HRbaseline(triggerphys(1):triggerphys(2)),'FaceColor',[1 1 1]),
    for j = 1:length(triggerphys)
        line([triggerphys(j)*sizewindowPHYSIO triggerphys(j)*sizewindowPHYSIO], ylim,'LineWidth',1.5)
    end
    ylabel('Heart Rate'),xlabel('Time (s)'),xlim([tps3(1) tps3(end)])%,hold on, area((tps(triggerphys(5):triggerphys(6))),HR(triggerphys(5):triggerphys(6)),'FaceColor',[0 0 0])
    
    subplot(5,2,7),plot(tps4,HRV),hold on,plot(tps4,HRVbaselineG),%area((tps4(triggerphys1(1):triggerphys1(2))),HRV(triggerphys1(1):triggerphys1(2)),'FaceColor',[0 0.5 1]),area(tps4(triggerphys1(3):triggerphys1(4)),HRV(triggerphys1(3):triggerphys1(4)),'FaceColor',[0 0.5 1]),area(tps4(triggerphys1(5):triggerphys1(6)),HRV(triggerphys1(5):triggerphys1(6)),'FaceColor',[0 0.5 1]),
    for j = 1:length(triggerphys)
        line([triggerphys(j)*sizewindowPHYSIO triggerphys(j)*sizewindowPHYSIO], ylim,'LineWidth',1.5)
    end
    ylabel('Heart Rate Variability'),xlabel('Time (s)'),xlim([tps4(1) tps4(end)])%,hold on, area((tps(triggerphys(5):triggerphys(6))),HRV(triggerphys(5):triggerphys(6)),'FaceColor',[0 0 0])
    
    subplot(5,2,9),plot(tps5,RYT),hold on,plot(tps5,RYTbaselineG)
    for j = 1:length(triggerphys)
        line([triggerphys(j)*sizewindowPHYSIO triggerphys(j)*sizewindowPHYSIO], ylim,'LineWidth',1.5)
    end
    ylabel('Respiratory Rate'),xlabel('Time (s)'),xlim([tps5(1) tps5(end)])%,hold on, area((tps(triggerphys(5):triggerphys(6))),RYT(triggerphys(5):triggerphys(6)),'FaceColor',[0 0 0])
    
    
    
    %% Figures Comportementales (cf. précédent, méthode identique)
    tps6 = (1 : length(SDLP)).*sizewindowPERF*overlap;
    vitefait6 = ((1:1:size(SDLP,2))*0)+1;
    SDLPbaselineG = SDLPbaseline(1).*vitefait6;
    tps7 = (1 : length(SDS)).*sizewindowPERF*overlap;
    vitefait7 = ((1:1:size(SDS,2))*0)+1;
    SDSbaselineG = SDSbaseline(1).*vitefait7;
    tps8 = (1 : length(RV)).*sizewindowPERF*overlap;
    vitefait8 = ((1:1:size(RV,2))*0)+1;
    RVbaselineG = RVbaseline(1).*vitefait8;
    tps9 = (1 : length(SDSW)).*sizewindowPERF*overlap;
    vitefait9 = ((1:1:size(SDSW,2))*0)+1;
    SDSWbaselineG = SDSWbaseline(1).*vitefait9;
    tps10 = (1 : length(RMSfrein)).*sizewindowPERF*overlap;
    vitefait10 = ((1:1:size(RMSfrein,2))*0)+1;
    RMSfreinbaselineG = RMSfreinbaseline(1).*vitefait10;
    
    % Pour affichage des données PERF au sein des zones de situations selon overlap
    triggerperf1 = triggerperf/overlap;
    
    subplot(5,2,2),plot(tps6,SDLP),hold on,plot(tps6,SDLPbaselineG),title('Behavioural')
    for j = 1:length(triggerperf)
        line([triggerperf(j)*sizewindowPERF triggerperf(j)*sizewindowPERF], ylim,'LineWidth',1.5)
    end
    ylabel('SDLP'),xlabel('Time (s)'),xlim([tps6(1) tps6(end)]);
    
    subplot(5,2,4),plot(tps7,SDS),hold on,plot(tps7,SDSbaselineG)
    for j = 1:length(triggerperf)
        line([triggerperf(j)*sizewindowPERF triggerperf(j)*sizewindowPERF], ylim,'LineWidth',1.5)
    end
    ylabel('SDS'),xlabel('Time (s)'),xlim([tps7(1) tps7(end)]);
    
    subplot(5,2,6),plot(tps8,RV1),hold on,plot(tps8,RVbaselineG)
    for j = 1:length(triggerperf)
        line([triggerperf(j)*sizewindowPERF triggerperf(j)*sizewindowPERF], ylim,'LineWidth',1.5)
    end
    ylabel('RV'),xlabel('Time (s)'),xlim([tps8(1) tps8(end)]);
    
    subplot(5,2,8),plot(tps9,SDSW),hold on,plot(tps9,SDSWbaselineG)
    for j = 1:length(triggerperf)
        line([triggerperf(j)*sizewindowPERF triggerperf(j)*sizewindowPERF], ylim,'LineWidth',1.5)
    end
    ylabel('SDSW'),xlabel('Time (s)'),xlim([tps9(1) tps9(end)]);
    
    subplot(5,2,10),plot(tps10,RMSfrein),hold on,plot(tps10,RMSfreinbaselineG)
    for j = 1:length(triggerperf)
        line([triggerperf(j)*sizewindowPERF triggerperf(j)*sizewindowPERF], ylim,'LineWidth',1.5)
    end
    ylabel('Amp Accel Brake'),xlabel('Time (s)'),xlim([tps10(1) tps10(end)])
    
    %suplabel(['Pre-test Participant N°' num2str(suj) ' --- Short Scenario ' num2str(disco)],'t')
    
    timeur(suj,disco)= toc; % Calcul du temps de chaque traitement d'index disco + mise en place de la figure
    
    
    %% Calcul de la précision des variables
    
    % Précision = (NPIS/(NPISH+NPIS))*100
    % NPIS : nombre de points du signal de l'indice au dessus du seuil dans la zone de situation
    % NPISH : nombre de points du signal du même indice au dessus du seuil d'inconfort en dehors de la zone de situations
    
    triggerphys = triggerphys1;   %?
    triggerperf = triggerperf1;   %?
    
    if disco == 1
        % Calcul de précision pour : chaque scenario, chaque situation et chaque groupe de données (phsyio et comportemental)
        % DISCO 1 , Situation 1 : ove 1
        
        % Physio ove 1 Disco 1
        
        NPIS.ove1.EDA = length(find((EDA1(triggerphys(1):triggerphys(2))) > (EDAbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.EDA = length(find((EDA1(1:triggerphys(1))) > (EDAbaselineG(1:triggerphys(1)))));
        NPISH2.EDA = length(find((EDA1(triggerphys(2):triggerphys(3))) > (EDAbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.EDA = length(find((EDA1(triggerphys(4):triggerphys(5))) > (EDAbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.EDA = length(find((EDA1(triggerphys(6): end)) > (EDAbaselineG(triggerphys(6): end))));
        %4 NPISH différents car 4 zones de données où il n'y a pas de situations
        NPISH.EDA  = NPISH1.EDA + NPISH2.EDA + NPISH3.EDA + NPISH4.EDA;
        precision.ove1.EDA = (NPIS.ove1.EDA / (NPISH.EDA + NPIS.ove1.EDA))*100;
        
        NPIS.ove1.EDArms = length(find((EDArms(triggerphys(1):triggerphys(2))) > (EDArmsbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.EDArms = length(find((EDArms(1:triggerphys(1))) > (EDArmsbaselineG(1:triggerphys(1)))));
        NPISH2.EDArms = length(find((EDArms(triggerphys(2):triggerphys(3))) > (EDArmsbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.EDArms = length(find((EDArms(triggerphys(4):triggerphys(5))) > (EDArmsbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.EDArms = length(find((EDArms(triggerphys(6): end)) > (EDArmsbaselineG(triggerphys(6): end))));
        NPISH.EDArms  = NPISH1.EDArms + NPISH2.EDArms + NPISH3.EDArms + NPISH4.EDArms;
        precision.ove1.EDArms = (NPIS.ove1.EDArms / (NPISH.EDArms + NPIS.ove1.EDArms))*100;
        
        NPIS.ove1.HR = length(find((HR1(triggerphys(1):triggerphys(2))) > (HRbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.HR = length(find((HR1(1:triggerphys(1))) > (HRbaselineG(1:triggerphys(1)))));
        NPISH2.HR = length(find((HR1(triggerphys(2):triggerphys(3))) > (HRbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.HR = length(find((HR1(triggerphys(4):triggerphys(5))) > (HRbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.HR = length(find((HR1(triggerphys(6): end)) > (HRbaselineG(triggerphys(6): end))));
        NPISH.HR  = NPISH1.HR + NPISH2.HR + NPISH3.HR + NPISH4.HR;
        precision.ove1.HR = (NPIS.ove1.HR / (NPISH.HR+NPIS.ove1.HR))*100;
        
        NPIS.ove1.HRV = length(find((HRV(triggerphys(1):triggerphys(2))) > (HRVbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.HRV = length(find((HRV(1:triggerphys(1))) > (HRVbaselineG(1:triggerphys(1)))));
        NPISH2.HRV = length(find((HRV(triggerphys(2):triggerphys(3))) > (HRVbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.HRV = length(find((HRV(triggerphys(4):triggerphys(5))) > (HRVbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.HRV = length(find((HRV(triggerphys(6): end)) > (HRVbaselineG(triggerphys(6): end))));
        NPISH.HRV  = NPISH1.HRV + NPISH2.HRV + NPISH3.HRV + NPISH4.HRV;
        precision.ove1.HRV = (NPIS.ove1.HRV / (NPISH.HRV + NPIS.ove1.HRV))*100;
        
        NPIS.ove1.RYT = length(find((RYT(triggerphys(1):triggerphys(2))) > (RYTbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.RYT = length(find((RYT(1:triggerphys(1))) > (RYTbaselineG(1:triggerphys(1)))));
        NPISH2.RYT = length(find((RYT(triggerphys(2):triggerphys(3))) > (RYTbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.RYT = length(find((RYT(triggerphys(4):triggerphys(5))) > (RYTbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.RYT = length(find((RYT(triggerphys(6): end)) > (RYTbaselineG(triggerphys(6): end))));
        NPISH.RYT  = NPISH1.RYT + NPISH2.RYT + NPISH3.RYT + NPISH4.RYT;
        precision.ove1.RYT = (NPIS.ove1.RYT / (NPISH.RYT + NPIS.ove1.RYT))*100;
        
        % Perf ove 1 Disco 1
        NPIS.ove1.SDLP = length(find((SDLP(triggerperf(1):triggerperf(2))) > (SDLPbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDLP = length(find((SDLP(1:triggerperf(1))) > (SDLPbaselineG(1:triggerperf(1)))));
        NPISH2.SDLP = length(find((SDLP(triggerperf(2):triggerperf(3))) > (SDLPbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDLP = length(find((SDLP(triggerperf(4):triggerperf(5))) > (SDLPbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDLP = length(find((SDLP(triggerperf(6): end)) > (SDLPbaselineG(triggerperf(6): end))));
        NPISH.SDLP  = NPISH1.SDLP + NPISH2.SDLP + NPISH3.SDLP + NPISH4.SDLP;
        precision.ove1.SDLP = (NPIS.ove1.SDLP / (NPISH.SDLP + NPIS.ove1.SDLP))*100;
        
        NPIS.ove1.SDS = length(find((SDS(triggerperf(1):triggerperf(2))) > (SDSbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDS = length(find((SDS(1:triggerperf(1))) > (SDSbaselineG(1:triggerperf(1)))));
        NPISH2.SDS = length(find((SDS(triggerperf(2):triggerperf(3))) > (SDSbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDS = length(find((SDS(triggerperf(4):triggerperf(5))) > (SDSbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDS = length(find((SDS(triggerperf(6): end)) > (SDSbaselineG(triggerperf(6): end))));
        NPISH.SDS  = NPISH1.SDS + NPISH2.SDS + NPISH3.SDS + NPISH4.SDS;
        precision.ove1.SDS = (NPIS.ove1.SDS / (NPISH.SDS+NPIS.ove1.SDS))*100;
        
        NPIS.ove1.RV = length(find((RV(triggerperf(1):triggerperf(2))) > (RVbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.RV = length(find((RV(1:triggerperf(1))) > (RVbaselineG(1:triggerperf(1)))));
        NPISH2.RV = length(find((RV(triggerperf(2):triggerperf(3))) > (RVbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.RV = length(find((RV(triggerperf(4):triggerperf(5))) > (RVbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.RV = length(find((RV(triggerperf(6): end)) > (RVbaselineG(triggerperf(6): end))));
        NPISH.RV  = NPISH1.RV + NPISH2.RV + NPISH3.RV + NPISH4.RV;
        precision.ove1.RV = (NPIS.ove1.RV / (NPISH.RV+NPIS.ove1.RV))*100;
        
        NPIS.ove1.SDSW = length(find((SDSW(triggerperf(1):triggerperf(2))) > (SDSWbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDSW = length(find((SDSW(1:triggerperf(1))) > (SDSWbaselineG(1:triggerperf(1)))));
        NPISH2.SDSW = length(find((SDSW(triggerperf(2):triggerperf(3))) > (SDSWbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDSW = length(find((SDSW(triggerperf(4):triggerperf(5))) > (SDSWbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDSW = length(find((SDSW(triggerperf(6): end)) > (SDSWbaselineG(triggerperf(6): end))));
        NPISH.SDSW  = NPISH1.SDSW + NPISH2.SDSW + NPISH3.SDSW + NPISH4.SDSW;
        precision.ove1.SDSW = (NPIS.ove1.SDSW / (NPISH.SDSW+NPIS.ove1.SDSW))*100;
        
        NPIS.ove1.RMSfrein = length(find((RMSfrein(triggerperf(1):triggerperf(2))) > (RMSfreinbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.RMSfrein = length(find((RMSfrein(1:triggerperf(1))) > (RMSfreinbaselineG(1:triggerperf(1)))));
        NPISH2.RMSfrein = length(find((RMSfrein(triggerperf(2):triggerperf(3))) > (RMSfreinbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.RMSfrein = length(find((RMSfrein(triggerperf(4):triggerperf(5))) > (RMSfreinbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.RMSfrein = length(find((RMSfrein(triggerperf(6): end)) > (RMSfreinbaselineG(triggerperf(6): end))));
        NPISH.RMSfrein  = NPISH1.RMSfrein + NPISH2.RMSfrein + NPISH3.RMSfrein + NPISH4.RMSfrein;
        precision.ove1.RMSfrein = (NPIS.ove1.RMSfrein / (NPISH.RMSfrein + NPIS.ove1.RMSfrein))*100;
        
        % Disco  1 : Situation 2 : left
        % Physio left Disco 1
        NPIS.left.EDA = length(find((EDA1(triggerphys(3):triggerphys(4))) > (EDAbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left.EDA = (NPIS.left.EDA / (NPIS.left.EDA + NPISH.EDA))*100;
        NPIS.left.EDArms = length(find((EDArms(triggerphys(3):triggerphys(4))) > (EDArmsbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left.EDArms = (NPIS.left.EDArms / (NPIS.left.EDArms + NPISH.EDArms))*100;
        NPIS.left.HR = length(find((HR1(triggerphys(3):triggerphys(4))) > (HRbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left.HR = (NPIS.left.HR / (NPIS.left.HR + NPISH.HR))*100;
        NPIS.left.HRV = length(find((HRV(triggerphys(3):triggerphys(4))) > (HRVbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left.HRV = (NPIS.left.HRV / (NPIS.left.HRV + NPISH.HRV))*100;
        NPIS.left.RYT = length(find((RYT(triggerphys(3):triggerphys(4))) > (RYTbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left.RYT = (NPIS.left.RYT / (NPIS.left.RYT + NPISH.RYT))*100;
        % Perf left Disco 1
        NPIS.left.SDLP = length(find((SDLP(triggerperf(3):triggerperf(4))) > (SDLPbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left.SDLP = (NPIS.left.SDLP / (NPIS.left.SDLP + NPISH.SDLP))*100;
        NPIS.left.SDS = length(find((SDS(triggerperf(3):triggerperf(4))) > (SDSbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left.SDS = (NPIS.left.SDS / (NPIS.left.SDS + NPISH.SDS))*100;
        NPIS.left.RV = length(find((RV(triggerperf(3):triggerperf(4))) > (RVbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left.RV = (NPIS.left.RV / (NPIS.left.RV + NPISH.RV))*100;
        NPIS.left.SDSW = length(find((SDSW(triggerperf(3):triggerperf(4))) > (SDSWbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left.SDSW = (NPIS.left.SDSW / (NPISH.SDSW + NPIS.left.SDSW))*100;
        NPIS.left.RMSfrein = length(find((RMSfrein(triggerperf(3):triggerperf(4))) > (RMSfreinbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left.RMSfrein = (NPIS.left.RMSfrein / (NPIS.left.RMSfrein + NPISH.RMSfrein))*100;
        
        % Disco  1 : Situation 3 : ped
        % Physio ped Disco 1
        NPIS.ped.EDA = length(find((EDA1(triggerphys(5):triggerphys(6))) > (EDAbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.EDA = (NPIS.ped.EDA / (NPIS.ped.EDA + NPISH.EDA))*100;
        NPIS.ped.EDArms = length(find((EDArms(triggerphys(5):triggerphys(6))) > (EDArmsbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.EDArms = (NPIS.ped.EDArms / (NPIS.ped.EDArms + NPISH.EDArms))*100;
        NPIS.ped.HR = length(find((HR1(triggerphys(5):triggerphys(6))) > (HRbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.HR = (NPIS.ped.HR / (NPIS.ped.HR + NPISH.HR))*100;
        NPIS.ped.HRV = length(find((HRV(triggerphys(5):triggerphys(6))) > (HRVbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.HRV = (NPIS.ped.HRV / (NPIS.ped.HRV + NPISH.HRV))*100;
        NPIS.ped.RYT = length(find((RYT(triggerphys(5):triggerphys(6))) > (RYTbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.RYT = (NPIS.ped.RYT / (NPIS.ped.RYT + NPISH.RYT))*100;
        % Perf ped Disco 1
        NPIS.ped.SDLP = length(find((SDLP(triggerperf(5):triggerperf(6))) > (SDLPbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.SDLP = (NPIS.ped.SDLP / (NPIS.ped.SDLP + NPISH.SDLP))*100;
        NPIS.ped.SDS = length(find((SDS(triggerperf(5):triggerperf(6))) > (SDSbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.SDS = (NPIS.ped.SDS / (NPISH.SDS + NPIS.ped.SDS))*100;
        NPIS.ped.RV = length(find((RV(triggerperf(5):triggerperf(6))) > (RVbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.RV = (NPIS.ped.RV / (NPIS.ped.RV + NPISH.RV))*100;
        NPIS.ped.SDSW = length(find((SDSW(triggerperf(5):triggerperf(6))) > (SDSWbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.SDSW = (NPIS.ped.SDSW / (NPIS.ped.SDSW + NPISH.SDSW))*100;
        NPIS.ped.RMSfrein = length(find((RMSfrein(triggerperf(5):triggerperf(6))) > (RMSfreinbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.RMSfrein = (NPIS.ped.RMSfrein / (NPISH.RMSfrein + NPIS.ped.RMSfrein))*100;
    end
    
    
    if disco == 2
        %DISCO 2 : Situation 1 :left 1
        % Physio left1 Disco 2
        NPIS.left1.EDA = length(find((EDA1(triggerphys(1):triggerphys(2))) > (EDAbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.EDA = length(find((EDA1(1:triggerphys(1))) > (EDAbaselineG(1:triggerphys(1)))));
        NPISH2.EDA = length(find((EDA1(triggerphys(2):triggerphys(3))) > (EDAbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.EDA = length(find((EDA1(triggerphys(4):triggerphys(5))) > (EDAbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.EDA = length(find((EDA1(triggerphys(6): end)) > (EDAbaselineG(triggerphys(6): end))));
        NPISH.EDA  = NPISH1.EDA + NPISH2.EDA + NPISH3.EDA + NPISH4.EDA;
        precision.left1.EDA = (NPIS.left1.EDA / (NPISH.EDA + NPIS.left1.EDA))*100;
        
        NPIS.left1.EDArms = length(find((EDArms(triggerphys(1):triggerphys(2))) > (EDArmsbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.EDArms = length(find((EDArms(1:triggerphys(1))) > (EDArmsbaselineG(1:triggerphys(1)))));
        NPISH2.EDArms = length(find((EDArms(triggerphys(2):triggerphys(3))) > (EDArmsbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.EDArms = length(find((EDArms(triggerphys(4):triggerphys(5))) > (EDArmsbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.EDArms = length(find((EDArms(triggerphys(6): end)) > (EDArmsbaselineG(triggerphys(6): end))));
        NPISH.EDArms  = NPISH1.EDArms + NPISH2.EDArms + NPISH3.EDArms + NPISH4.EDArms;
        precision.left1.EDArms = (NPIS.left1.EDArms / (NPIS.left1.EDArms + NPISH.EDArms))*100;
        
        NPIS.left1.HR = length(find((HR1(triggerphys(1):triggerphys(2))) > (HRbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.HR = length(find((HR1(1:triggerphys(1))) > (HRbaselineG(1:triggerphys(1)))));
        NPISH2.HR = length(find((HR1(triggerphys(2):triggerphys(3))) > (HRbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.HR = length(find((HR1(triggerphys(4):triggerphys(5))) > (HRbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.HR = length(find((HR1(triggerphys(6): end)) > (HRbaselineG(triggerphys(6): end))));
        NPISH.HR  = NPISH1.HR + NPISH2.HR + NPISH3.HR + NPISH4.HR;
        precision.left1.HR = (NPIS.left1.HR / (NPIS.left1.HR + NPISH.HR))*100;
        
        NPIS.left1.HRV = length(find((HRV(triggerphys(1):triggerphys(2))) > (HRVbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.HRV = length(find((HRV(1:triggerphys(1))) > (HRVbaselineG(1:triggerphys(1)))));
        NPISH2.HRV = length(find((HRV(triggerphys(2):triggerphys(3))) > (HRVbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.HRV = length(find((HRV(triggerphys(4):triggerphys(5))) > (HRVbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.HRV = length(find((HRV(triggerphys(6): end)) > (HRVbaselineG(triggerphys(6): end))));
        NPISH.HRV  = NPISH1.HRV + NPISH2.HRV + NPISH3.HRV + NPISH4.HRV;
        precision.left1.HRV = (NPIS.left1.HRV / (NPIS.left1.HRV + NPISH.HRV))*100;
        
        NPIS.left1.RYT = length(find((RYT(triggerphys(1):triggerphys(2))) > (RYTbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.RYT = length(find((RYT(1:triggerphys(1))) > (RYTbaselineG(1:triggerphys(1)))));
        NPISH2.RYT = length(find((RYT(triggerphys(2):triggerphys(3))) > (RYTbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.RYT = length(find((RYT(triggerphys(4):triggerphys(5))) > (RYTbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.RYT = length(find((RYT(triggerphys(6): end)) > (RYTbaselineG(triggerphys(6): end))));
        NPISH.RYT  = NPISH1.RYT + NPISH2.RYT + NPISH3.RYT + NPISH4.RYT;
        precision.left1.RYT = (NPIS.left1.RYT / (NPIS.left1.RYT + NPISH.RYT))*100;
        
        % Perf left1 Disco 2
        NPIS.left1.SDLP = length(find((SDLP(triggerperf(1):triggerperf(2))) > (SDLPbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDLP = length(find((SDLP(1:triggerperf(1))) > (SDLPbaselineG(1:triggerperf(1)))));
        NPISH2.SDLP = length(find((SDLP(triggerperf(2):triggerperf(3))) > (SDLPbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDLP = length(find((SDLP(triggerperf(4):triggerperf(5))) > (SDLPbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDLP = length(find((SDLP(triggerperf(6): end)) > (SDLPbaselineG(triggerperf(6): end))));
        NPISH.SDLP  = NPISH1.SDLP + NPISH2.SDLP + NPISH3.SDLP + NPISH4.SDLP;
        precision.left1.SDLP = (NPIS.left1.SDLP / (NPIS.left1.SDLP + NPISH.SDLP))*100;
        
        NPIS.left1.SDS = length(find((SDS(triggerperf(1):triggerperf(2))) > (SDSbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDS = length(find((SDS(1:triggerperf(1))) > (SDSbaselineG(1:triggerperf(1)))));
        NPISH2.SDS = length(find((SDS(triggerperf(2):triggerperf(3))) > (SDSbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDS = length(find((SDS(triggerperf(4):triggerperf(5))) > (SDSbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDS = length(find((SDS(triggerperf(6): end)) > (SDSbaselineG(triggerperf(6): end))));
        NPISH.SDS  = NPISH1.SDS + NPISH2.SDS + NPISH3.SDS + NPISH4.SDS;
        precision.left1.SDS = (NPIS.left1.SDS / (NPIS.left1.SDS + NPISH.SDS))*100;
        
        NPIS.left1.RV = length(find((RV(triggerperf(1):triggerperf(2))) > (RVbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.RV = length(find((RV(1:triggerperf(1))) > (RVbaselineG(1:triggerperf(1)))));
        NPISH2.RV = length(find((RV(triggerperf(2):triggerperf(3))) > (RVbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.RV = length(find((RV(triggerperf(4):triggerperf(5))) > (RVbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.RV = length(find((RV(triggerperf(6): end)) > (RVbaselineG(triggerperf(6): end))));
        NPISH.RV  = NPISH1.RV + NPISH2.RV + NPISH3.RV + NPISH4.RV;
        precision.left1.RV = (NPIS.left1.RV / (NPIS.left1.RV + NPISH.RV))*100;
        
        NPIS.left1.SDSW = length(find((SDSW(triggerperf(1):triggerperf(2))) > (SDSWbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDSW = length(find((SDSW(1:triggerperf(1))) > (SDSWbaselineG(1:triggerperf(1)))));
        NPISH2.SDSW = length(find((SDSW(triggerperf(2):triggerperf(3))) > (SDSWbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDSW = length(find((SDSW(triggerperf(4):triggerperf(5))) > (SDSWbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDSW = length(find((SDSW(triggerperf(6): end)) > (SDSWbaselineG(triggerperf(6): end))));
        NPISH.SDSW  = NPISH1.SDSW + NPISH2.SDSW + NPISH3.SDSW + NPISH4.SDSW;
        precision.left1.SDSW = (NPIS.left1.SDSW / (NPIS.left1.SDSW + NPISH.SDSW))*100;
        
        NPIS.left1.RMSfrein = length(find((RMSfrein(triggerperf(1):triggerperf(2))) > (RMSfreinbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.RMSfrein = length(find((RMSfrein(1:triggerperf(1))) > (RMSfreinbaselineG(1:triggerperf(1)))));
        NPISH2.RMSfrein = length(find((RMSfrein(triggerperf(2):triggerperf(3))) > (RMSfreinbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.RMSfrein = length(find((RMSfrein(triggerperf(4):triggerperf(5))) > (RMSfreinbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.RMSfrein = length(find((RMSfrein(triggerperf(6): end)) > (RMSfreinbaselineG(triggerperf(6): end))));
        NPISH.RMSfrein  = NPISH1.RMSfrein + NPISH2.RMSfrein + NPISH3.RMSfrein + NPISH4.RMSfrein;
        precision.left1.RMSfrein = (NPIS.left1.RMSfrein / (NPIS.left1.RMSfrein + NPISH.RMSfrein))*100;
        
        % Disco  2 : Situation 2 : ove
        % Physio ove Disco 2
        NPIS.ove.EDA = length(find((EDA1(triggerphys(3):triggerphys(4))) > (EDAbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove.EDA = (NPIS.ove.EDA / (NPIS.ove.EDA + NPISH.EDA))*100;
        NPIS.ove.EDArms = length(find((EDArms(triggerphys(3):triggerphys(4))) > (EDArmsbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove.EDArms = (NPIS.ove.EDArms / (NPIS.ove.EDArms + NPISH.EDArms))*100;
        NPIS.ove.HR = length(find((HR1(triggerphys(3):triggerphys(4))) > (HRbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove.HR = (NPIS.ove.HR / (NPIS.ove.HR + NPISH.HR))*100;
        NPIS.ove.HRV = length(find((HRV(triggerphys(3):triggerphys(4))) > (HRVbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove.HRV = (NPIS.ove.HRV / (NPIS.ove.HRV + NPISH.HRV))*100;
        NPIS.ove.RYT = length(find((RYT(triggerphys(3):triggerphys(4))) > (RYTbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove.RYT = (NPIS.ove.RYT / (NPIS.ove.RYT + NPISH.RYT))*100;
        % Perf ove Disco 2
        NPIS.ove.SDLP = length(find((SDLP(triggerperf(3):triggerperf(4))) > (SDLPbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove.SDLP = (NPIS.ove.SDLP / (NPIS.ove.SDLP + NPISH.SDLP))*100;
        NPIS.ove.SDS = length(find((SDS(triggerperf(3):triggerperf(4))) > (SDSbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove.SDS = (NPIS.ove.SDS / (NPIS.ove.SDS + NPISH.SDS))*100;
        NPIS.ove.RV = length(find((RV(triggerperf(3):triggerperf(4))) > (RVbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove.RV = (NPIS.ove.RV / (NPIS.ove.RV + NPISH.RV))*100;
        NPIS.ove.SDSW = length(find((SDSW(triggerperf(3):triggerperf(4))) > (SDSWbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove.SDSW = (NPIS.ove.SDSW / (NPIS.ove.SDSW + NPISH.SDSW))*100;
        NPIS.ove.RMSfrein = length(find((RMSfrein(triggerperf(3):triggerperf(4))) > (RMSfreinbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove.RMSfrein = (NPIS.ove.RMSfrein / (NPIS.ove.RMSfrein + NPISH.RMSfrein))*100;
        
        % Disco  2 : Situation 3 : sb
        % Physio sb Disco 2
        NPIS.sb.EDA = length(find((EDA1(triggerphys(5):triggerphys(6))) > (EDAbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.EDA = (NPIS.sb.EDA / (NPIS.sb.EDA + NPISH.EDA))*100;
        NPIS.sb.EDArms = length(find((EDArms(triggerphys(5):triggerphys(6))) > (EDArmsbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.EDArms = (NPIS.sb.EDArms / (NPIS.sb.EDArms + NPISH.EDArms))*100;
        NPIS.sb.HR = length(find((HR1(triggerphys(5):triggerphys(6))) > (HRbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.HR = (NPIS.sb.HR / (NPIS.sb.HR  + NPISH.HR))*100;
        NPIS.sb.HRV = length(find((HRV(triggerphys(5):triggerphys(6))) > (HRVbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.HRV = (NPIS.sb.HRV / (NPIS.sb.HRV + NPISH.HRV))*100;
        NPIS.sb.RYT = length(find((RYT(triggerphys(5):triggerphys(6))) > (RYTbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.RYT = (NPIS.sb.RYT / (NPIS.sb.RYT + NPISH.RYT))*100;
        % Perf sb Disco 2
        NPIS.sb.SDLP = length(find((SDLP(triggerperf(5):triggerperf(6))) > (SDLPbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.SDLP = (NPIS.sb.SDLP / (NPIS.sb.SDLP + NPISH.SDLP))*100;
        NPIS.sb.SDS = length(find((SDS(triggerperf(5):triggerperf(6))) > (SDSbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.SDS = (NPIS.sb.SDS / (NPIS.sb.SDS+ NPISH.SDS))*100;
        NPIS.sb.RV = length(find((RV(triggerperf(5):triggerperf(6))) > (RVbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.RV = (NPIS.sb.RV / (NPIS.sb.RV + NPISH.RV))*100;
        NPIS.sb.SDSW = length(find((SDSW(triggerperf(5):triggerperf(6))) > (SDSWbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.SDSW = (NPIS.sb.SDSW / (NPIS.sb.SDSW + NPISH.SDSW))*100;
        NPIS.sb.RMSfrein = length(find((RMSfrein(triggerperf(5):triggerperf(6))) > (RMSfreinbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.RMSfrein = (NPIS.sb.RMSfrein / (NPIS.sb.RMSfrein + NPISH.RMSfrein))*100;
    end
    
    
    if disco == 3
        %DISCO 3 : Situation 1 :left
        % Physio left Disco 3
        NPIS.left.EDA = length(find((EDA1(triggerphys(1):triggerphys(2))) > (EDAbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.EDA = length(find((EDA1(1:triggerphys(1))) > (EDAbaselineG(1:triggerphys(1)))));
        NPISH2.EDA = length(find((EDA1(triggerphys(2):triggerphys(3))) > (EDAbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.EDA = length(find((EDA1(triggerphys(4):triggerphys(5))) > (EDAbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.EDA = length(find((EDA1(triggerphys(6): end)) > (EDAbaselineG(triggerphys(6): end))));
        NPISH.EDA  = NPISH1.EDA + NPISH2.EDA + NPISH3.EDA + NPISH4.EDA;
        precision.left.EDA = (NPIS.left.EDA / (NPIS.left.EDA + NPISH.EDA))*100;
        
        NPIS.left.EDArms = length(find((EDArms(triggerphys(1):triggerphys(2))) > (EDArmsbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.EDArms = length(find((EDArms(1:triggerphys(1))) > (EDArmsbaselineG(1:triggerphys(1)))));
        NPISH2.EDArms = length(find((EDArms(triggerphys(2):triggerphys(3))) > (EDArmsbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.EDArms = length(find((EDArms(triggerphys(4):triggerphys(5))) > (EDArmsbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.EDArms = length(find((EDArms(triggerphys(6): end)) > (EDArmsbaselineG(triggerphys(6): end))));
        NPISH.EDArms  = NPISH1.EDArms + NPISH2.EDArms + NPISH3.EDArms + NPISH4.EDArms;
        precision.left.EDArms = (NPIS.left.EDArms / (NPIS.left.EDArms + NPISH.EDArms))*100;
        
        NPIS.left.HR = length(find((HR1(triggerphys(1):triggerphys(2))) > (HRbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.HR = length(find((HR1(1:triggerphys(1))) > (HRbaselineG(1:triggerphys(1)))));
        NPISH2.HR = length(find((HR1(triggerphys(2):triggerphys(3))) > (HRbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.HR = length(find((HR1(triggerphys(4):triggerphys(5))) > (HRbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.HR = length(find((HR1(triggerphys(6): end)) > (HRbaselineG(triggerphys(6): end))));
        NPISH.HR  = NPISH1.HR + NPISH2.HR + NPISH3.HR + NPISH4.HR;
        precision.left.HR = (NPIS.left.HR / (NPIS.left.HR + NPISH.HR))*100;
        
        NPIS.left.HRV = length(find((HRV(triggerphys(1):triggerphys(2))) > (HRVbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.HRV = length(find((HRV(1:triggerphys(1))) > (HRVbaselineG(1:triggerphys(1)))));
        NPISH2.HRV = length(find((HRV(triggerphys(2):triggerphys(3))) > (HRVbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.HRV = length(find((HRV(triggerphys(4):triggerphys(5))) > (HRVbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.HRV = length(find((HRV(triggerphys(6): end)) > (HRVbaselineG(triggerphys(6): end))));
        NPISH.HRV  = NPISH1.HRV + NPISH2.HRV + NPISH3.HRV + NPISH4.HRV;
        precision.left.HRV = (NPIS.left.HRV / (NPIS.left.HRV + NPISH.HRV))*100;
        
        NPIS.left.RYT = length(find((RYT(triggerphys(1):triggerphys(2))) > (RYTbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.RYT = length(find((RYT(1:triggerphys(1))) > (RYTbaselineG(1:triggerphys(1)))));
        NPISH2.RYT = length(find((RYT(triggerphys(2):triggerphys(3))) > (RYTbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.RYT = length(find((RYT(triggerphys(4):triggerphys(5))) > (RYTbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.RYT = length(find((RYT(triggerphys(6): end)) > (RYTbaselineG(triggerphys(6): end))));
        NPISH.RYT  = NPISH1.RYT + NPISH2.RYT + NPISH3.RYT + NPISH4.RYT;
        precision.left.RYT = (NPIS.left.RYT / (NPIS.left.RYT + NPISH.RYT))*100;
        
        % Perf left Disco 3
        NPIS.left.SDLP = length(find((SDLP(triggerperf(1):triggerperf(2))) > (SDLPbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDLP = length(find((SDLP(1:triggerperf(1))) > (SDLPbaselineG(1:triggerperf(1)))));
        NPISH2.SDLP = length(find((SDLP(triggerperf(2):triggerperf(3))) > (SDLPbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDLP = length(find((SDLP(triggerperf(4):triggerperf(5))) > (SDLPbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDLP = length(find((SDLP(triggerperf(6): end)) > (SDLPbaselineG(triggerperf(6): end))));
        NPISH.SDLP  = NPISH1.SDLP + NPISH2.SDLP + NPISH3.SDLP + NPISH4.SDLP;
        precision.left.SDLP = (NPIS.left.SDLP / (NPIS.left.SDLP + NPISH.SDLP))*100;
        
        NPIS.left.SDS = length(find((SDS(triggerperf(1):triggerperf(2))) > (SDSbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDS = length(find((SDS(1:triggerperf(1))) > (SDSbaselineG(1:triggerperf(1)))));
        NPISH2.SDS = length(find((SDS(triggerperf(2):triggerperf(3))) > (SDSbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDS = length(find((SDS(triggerperf(4):triggerperf(5))) > (SDSbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDS = length(find((SDS(triggerperf(6): end)) > (SDSbaselineG(triggerperf(6): end))));
        NPISH.SDS  = NPISH1.SDS + NPISH2.SDS + NPISH3.SDS + NPISH4.SDS;
        precision.left.SDS = (NPIS.left.SDS / (NPIS.left.SDS + NPISH.SDS))*100;
        
        NPIS.left.RV = length(find((RV(triggerperf(1):triggerperf(2))) > (RVbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.RV = length(find((RV(1:triggerperf(1))) > (RVbaselineG(1:triggerperf(1)))));
        NPISH2.RV = length(find((RV(triggerperf(2):triggerperf(3))) > (RVbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.RV = length(find((RV(triggerperf(4):triggerperf(5))) > (RVbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.RV = length(find((RV(triggerperf(6): end)) > (RVbaselineG(triggerperf(6): end))));
        NPISH.RV  = NPISH1.RV + NPISH2.RV + NPISH3.RV + NPISH4.RV;
        precision.left.RV = (NPIS.left.RV / (NPIS.left.RV + NPISH.RV))*100;
        
        NPIS.left.SDSW = length(find((SDSW(triggerperf(1):triggerperf(2))) > (SDSWbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDSW = length(find((SDSW(1:triggerperf(1))) > (SDSWbaselineG(1:triggerperf(1)))));
        NPISH2.SDSW = length(find((SDSW(triggerperf(2):triggerperf(3))) > (SDSWbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDSW = length(find((SDSW(triggerperf(4):triggerperf(5))) > (SDSWbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDSW = length(find((SDSW(triggerperf(6): end)) > (SDSWbaselineG(triggerperf(6): end))));
        NPISH.SDSW  = NPISH1.SDSW + NPISH2.SDSW + NPISH3.SDSW + NPISH4.SDSW;
        precision.left.SDSW = (NPIS.left.SDSW / (NPIS.left.SDSW + NPISH.SDSW))*100;
        
        NPIS.left.RMSfrein = length(find((RMSfrein(triggerperf(1):triggerperf(2))) > (RMSfreinbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.RMSfrein = length(find((RMSfrein(1:triggerperf(1))) > (RMSfreinbaselineG(1:triggerperf(1)))));
        NPISH2.RMSfrein = length(find((RMSfrein(triggerperf(2):triggerperf(3))) > (RMSfreinbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.RMSfrein = length(find((RMSfrein(triggerperf(4):triggerperf(5))) > (RMSfreinbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.RMSfrein = length(find((RMSfrein(triggerperf(6): end)) > (RMSfreinbaselineG(triggerperf(6): end))));
        NPISH.RMSfrein  = NPISH1.RMSfrein + NPISH2.RMSfrein + NPISH3.RMSfrein + NPISH4.RMSfrein;
        precision.left.RMSfrein = (NPIS.left.RMSfrein / (NPIS.left.RMSfrein + NPISH.RMSfrein))*100;
        
        % Disco  3 : Situation 2 : ove1
        % Physio ove1 Disco 3
        NPIS.ove1.EDA = length(find((EDA1(triggerphys(3):triggerphys(4))) > (EDAbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove1.EDA = (NPIS.ove1.EDA / (NPIS.ove1.EDA + NPISH.EDA))*100;
        NPIS.ove1.EDArms = length(find((EDArms(triggerphys(3):triggerphys(4))) > (EDArmsbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove1.EDArms = (NPIS.ove1.EDArms / (NPIS.ove1.EDArms  + NPISH.EDArms))*100;
        NPIS.ove1.HR = length(find((HR1(triggerphys(3):triggerphys(4))) > (HRbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove1.HR = (NPIS.ove1.HR / (NPIS.ove1.HR + NPISH.HR))*100;
        NPIS.ove1.HRV = length(find((HRV(triggerphys(3):triggerphys(4))) > (HRVbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove1.HRV = (NPIS.ove1.HRV / (NPIS.ove1.HRV + NPISH.HRV))*100;
        NPIS.ove1.RYT = length(find((RYT(triggerphys(3):triggerphys(4))) > (RYTbaselineG(triggerphys(3):triggerphys(4)))));
        precision.ove1.RYT = (NPIS.ove1.RYT / (NPIS.ove1.RYT + NPISH.RYT))*100;
        % Perf ove1 Disco 3
        NPIS.ove1.SDLP = length(find((SDLP(triggerperf(3):triggerperf(4))) > (SDLPbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove1.SDLP = (NPIS.ove1.SDLP / (NPIS.ove1.SDLP + NPISH.SDLP))*100;
        NPIS.ove1.SDS = length(find((SDS(triggerperf(3):triggerperf(4))) > (SDSbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove1.SDS = (NPIS.ove1.SDS / (NPIS.ove1.SDS + NPISH.SDS))*100;
        NPIS.ove1.RV = length(find((RV(triggerperf(3):triggerperf(4))) > (RVbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove1.RV = (NPIS.ove1.RV /(NPIS.ove1.RV + NPISH.RV))*100;
        NPIS.ove1.SDSW = length(find((SDSW(triggerperf(3):triggerperf(4))) > (SDSWbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove1.SDSW = (NPIS.ove1.SDSW / (NPIS.ove1.SDSW + NPISH.SDSW))*100;
        NPIS.ove1.RMSfrein = length(find((RMSfrein(triggerperf(3):triggerperf(4))) > (RMSfreinbaselineG(triggerperf(3):triggerperf(4)))));
        precision.ove1.RMSfrein = (NPIS.ove1.RMSfrein / (NPIS.ove1.RMSfrein + NPISH.RMSfrein))*100;
        
        % Disco  3 : Situation 3 : ped
        % Physio ped Disco 3
        NPIS.ped.EDA = length(find((EDA1(triggerphys(5):triggerphys(6))) > (EDAbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.EDA = (NPIS.ped.EDA / (NPIS.ped.EDA + NPISH.EDA))*100;
        NPIS.ped.EDArms = length(find((EDArms(triggerphys(5):triggerphys(6))) > (EDArmsbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.EDArms = (NPIS.ped.EDArms / (NPIS.ped.EDArms + NPISH.EDArms))*100;
        NPIS.ped.HR = length(find((HR1(triggerphys(5):triggerphys(6))) > (HRbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.HR = (NPIS.ped.HR / (NPIS.ped.HR + NPISH.HR))*100;
        NPIS.ped.HRV = length(find((HRV(triggerphys(5):triggerphys(6))) > (HRVbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.HRV = (NPIS.ped.HRV / (NPIS.ped.HRV + NPISH.HRV))*100;
        NPIS.ped.RYT = length(find((RYT(triggerphys(5):triggerphys(6))) > (RYTbaselineG(triggerphys(5):triggerphys(6)))));
        precision.ped.RYT = (NPIS.ped.RYT / (NPIS.ped.RYT + NPISH.RYT))*100;
        % Perf ped Disco 1
        NPIS.ped.SDLP = length(find((SDLP(triggerperf(5):triggerperf(6))) > (SDLPbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.SDLP = (NPIS.ped.SDLP / (NPIS.ped.SDLP + NPISH.SDLP))*100;
        NPIS.ped.SDS = length(find((SDS(triggerperf(5):triggerperf(6))) > (SDSbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.SDS = (NPIS.ped.SDS / (NPISH.SDS + NPIS.ped.SDS))*100;
        NPIS.ped.RV = length(find((RV(triggerperf(5):triggerperf(6))) > (RVbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.RV = (NPIS.ped.RV / (NPIS.ped.RV + NPISH.RV))*100;
        NPIS.ped.SDSW = length(find((SDSW(triggerperf(5):triggerperf(6))) > (SDSWbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.SDSW = (NPIS.ped.SDSW / (NPIS.ped.SDSW + NPISH.SDSW))*100;
        NPIS.ped.RMSfrein = length(find((RMSfrein(triggerperf(5):triggerperf(6))) > (RMSfreinbaselineG(triggerperf(5):triggerperf(6)))));
        precision.ped.RMSfrein = (NPIS.ped.RMSfrein / (NPISH.RMSfrein + NPIS.ped.RMSfrein))*100;
    end
    
    if disco == 4
        %DISCO 4 : Situation 1 : ove
        % Physio ove Disco 4
        NPIS.ove.EDA = length(find((EDA1(triggerphys(1):triggerphys(2))) > (EDAbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.EDA = length(find((EDA1(1:triggerphys(1))) > (EDAbaselineG(1:triggerphys(1)))));
        NPISH2.EDA = length(find((EDA1(triggerphys(2):triggerphys(3))) > (EDAbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.EDA = length(find((EDA1(triggerphys(4):triggerphys(5))) > (EDAbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.EDA = length(find((EDA1(triggerphys(6): end)) > (EDAbaselineG(triggerphys(6): end))));
        NPISH.EDA  = NPISH1.EDA + NPISH2.EDA + NPISH3.EDA + NPISH4.EDA;
        precision.ove.EDA = (NPIS.ove.EDA / (NPIS.ove.EDA + NPISH.EDA))*100;
        
        NPIS.ove.EDArms = length(find((EDArms(triggerphys(1):triggerphys(2))) > (EDArmsbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.EDArms = length(find((EDArms(1:triggerphys(1))) > (EDArmsbaselineG(1:triggerphys(1)))));
        NPISH2.EDArms = length(find((EDArms(triggerphys(2):triggerphys(3))) > (EDArmsbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.EDArms = length(find((EDArms(triggerphys(4):triggerphys(5))) > (EDArmsbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.EDArms = length(find((EDArms(triggerphys(6): end)) > (EDArmsbaselineG(triggerphys(6): end))));
        NPISH.EDArms  = NPISH1.EDArms + NPISH2.EDArms + NPISH3.EDArms + NPISH4.EDArms;
        precision.ove.EDArms = (NPIS.ove.EDArms / (NPIS.ove.EDArms + NPISH.EDArms))*100;
        
        NPIS.ove.HR = length(find((HR1(triggerphys(1):triggerphys(2))) > (HRbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.HR = length(find((HR1(1:triggerphys(1))) > (HRbaselineG(1:triggerphys(1)))));
        NPISH2.HR = length(find((HR1(triggerphys(2):triggerphys(3))) > (HRbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.HR = length(find((HR1(triggerphys(4):triggerphys(5))) > (HRbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.HR = length(find((HR1(triggerphys(6): end)) > (HRbaselineG(triggerphys(6): end))));
        NPISH.HR  = NPISH1.HR + NPISH2.HR + NPISH3.HR + NPISH4.HR;
        precision.ove.HR = (NPIS.ove.HR / (NPIS.ove.HR + NPISH.HR))*100;
        
        NPIS.ove.HRV = length(find((HRV(triggerphys(1):triggerphys(2))) > (HRVbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.HRV = length(find((HRV(1:triggerphys(1))) > (HRVbaselineG(1:triggerphys(1)))));
        NPISH2.HRV = length(find((HRV(triggerphys(2):triggerphys(3))) > (HRVbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.HRV = length(find((HRV(triggerphys(4):triggerphys(5))) > (HRVbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.HRV = length(find((HRV(triggerphys(6): end)) > (HRVbaselineG(triggerphys(6): end))));
        NPISH.HRV  = NPISH1.HRV + NPISH2.HRV + NPISH3.HRV + NPISH4.HRV;
        precision.ove.HRV = (NPIS.ove.HRV / (NPIS.ove.HRV + NPISH.HRV))*100;
        
        NPIS.ove.RYT = length(find((RYT(triggerphys(1):triggerphys(2))) > (RYTbaselineG(triggerphys(1):triggerphys(2)))));
        NPISH1.RYT = length(find((RYT(1:triggerphys(1))) > (RYTbaselineG(1:triggerphys(1)))));
        NPISH2.RYT = length(find((RYT(triggerphys(2):triggerphys(3))) > (RYTbaselineG(triggerphys(2):triggerphys(3)))));
        NPISH3.RYT = length(find((RYT(triggerphys(4):triggerphys(5))) > (RYTbaselineG(triggerphys(4):triggerphys(5)))));
        NPISH4.RYT = length(find((RYT(triggerphys(6): end)) > (RYTbaselineG(triggerphys(6): end))));
        NPISH.RYT  = NPISH1.RYT + NPISH2.RYT + NPISH3.RYT + NPISH4.RYT;
        precision.ove.RYT = (NPIS.ove.RYT / (NPIS.ove.RYT + NPISH.RYT))*100;
        
        % Perf ove Disco 4
        NPIS.ove.SDLP = length(find((SDLP(triggerperf(1):triggerperf(2))) > (SDLPbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDLP = length(find((SDLP(1:triggerperf(1))) > (SDLPbaselineG(1:triggerperf(1)))));
        NPISH2.SDLP = length(find((SDLP(triggerperf(2):triggerperf(3))) > (SDLPbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDLP = length(find((SDLP(triggerperf(4):triggerperf(5))) > (SDLPbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDLP = length(find((SDLP(triggerperf(6): end)) > (SDLPbaselineG(triggerperf(6): end))));
        NPISH.SDLP  = NPISH1.SDLP + NPISH2.SDLP + NPISH3.SDLP + NPISH4.SDLP;
        precision.ove.SDLP = (NPIS.ove.SDLP / (NPIS.ove.SDLP  + NPISH.SDLP))*100;
        
        NPIS.ove.SDS = length(find((SDS(triggerperf(1):triggerperf(2))) > (SDSbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDS = length(find((SDS(1:triggerperf(1))) > (SDSbaselineG(1:triggerperf(1)))));
        NPISH2.SDS = length(find((SDS(triggerperf(2):triggerperf(3))) > (SDSbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDS = length(find((SDS(triggerperf(4):triggerperf(5))) > (SDSbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDS = length(find((SDS(triggerperf(6): end)) > (SDSbaselineG(triggerperf(6): end))));
        NPISH.SDS  = NPISH1.SDS + NPISH2.SDS + NPISH3.SDS + NPISH4.SDS;
        precision.ove.SDS = (NPIS.ove.SDS / (NPIS.ove.SDS + NPISH.SDS))*100;
        
        NPIS.ove.RV = length(find((RV(triggerperf(1):triggerperf(2))) > (RVbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.RV = length(find((RV(1:triggerperf(1))) > (RVbaselineG(1:triggerperf(1)))));
        NPISH2.RV = length(find((RV(triggerperf(2):triggerperf(3))) > (RVbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.RV = length(find((RV(triggerperf(4):triggerperf(5))) > (RVbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.RV = length(find((RV(triggerperf(6): end)) > (RVbaselineG(triggerperf(6): end))));
        NPISH.RV  = NPISH1.RV + NPISH2.RV + NPISH3.RV + NPISH4.RV;
        precision.ove.RV = (NPIS.ove.RV / (NPIS.ove.RV + NPISH.RV))*100;
        
        NPIS.ove.SDSW = length(find((SDSW(triggerperf(1):triggerperf(2))) > (SDSWbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.SDSW = length(find((SDSW(1:triggerperf(1))) > (SDSWbaselineG(1:triggerperf(1)))));
        NPISH2.SDSW = length(find((SDSW(triggerperf(2):triggerperf(3))) > (SDSWbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.SDSW = length(find((SDSW(triggerperf(4):triggerperf(5))) > (SDSWbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.SDSW = length(find((SDSW(triggerperf(6): end)) > (SDSWbaselineG(triggerperf(6): end))));
        NPISH.SDSW  = NPISH1.SDSW + NPISH2.SDSW + NPISH3.SDSW + NPISH4.SDSW;
        precision.ove.SDSW = (NPIS.ove.SDSW / (NPIS.ove.SDSW + NPISH.SDSW))*100;
        
        NPIS.ove.RMSfrein = length(find((RMSfrein(triggerperf(1):triggerperf(2))) > (RMSfreinbaselineG(triggerperf(1):triggerperf(2)))));
        NPISH1.RMSfrein = length(find((RMSfrein(1:triggerperf(1))) > (RMSfreinbaselineG(1:triggerperf(1)))));
        NPISH2.RMSfrein = length(find((RMSfrein(triggerperf(2):triggerperf(3))) > (RMSfreinbaselineG(triggerperf(2):triggerperf(3)))));
        NPISH3.RMSfrein = length(find((RMSfrein(triggerperf(4):triggerperf(5))) > (RMSfreinbaselineG(triggerperf(4):triggerperf(5)))));
        NPISH4.RMSfrein = length(find((RMSfrein(triggerperf(6): end)) > (RMSfreinbaselineG(triggerperf(6): end))));
        NPISH.RMSfrein  = NPISH1.RMSfrein + NPISH2.RMSfrein + NPISH3.RMSfrein + NPISH4.RMSfrein;
        precision.ove.RMSfrein = (NPIS.ove.RMSfrein / (NPIS.ove.RMSfrein  + NPISH.RMSfrein))*100;
        
        % Disco  4 : Situation 2 : left1
        % Physio left1 Disco 4
        NPIS.left1.EDA = length(find((EDA1(triggerphys(3):triggerphys(4))) > (EDAbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left1.EDA = (NPIS.left1.EDA / (NPIS.left1.EDA+ NPISH.EDA))*100;
        NPIS.left1.EDArms = length(find((EDArms(triggerphys(3):triggerphys(4))) > (EDArmsbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left1.EDArms = (NPIS.left1.EDArms / (NPIS.left1.EDArms + NPISH.EDArms))*100;
        NPIS.left1.HR = length(find((HR1(triggerphys(3):triggerphys(4))) > (HRbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left1.HR = (NPIS.left1.HR / (NPIS.left1.HR + NPISH.HR))*100;
        NPIS.left1.HRV = length(find((HRV(triggerphys(3):triggerphys(4))) > (HRVbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left1.HRV = (NPIS.left1.HRV / (NPIS.left1.HRV+ NPISH.HRV))*100;
        NPIS.left1.RYT = length(find((RYT(triggerphys(3):triggerphys(4))) > (RYTbaselineG(triggerphys(3):triggerphys(4)))));
        precision.left1.RYT = (NPIS.left1.RYT / (NPIS.left1.RYT + NPISH.RYT))*100;
        % Perf left1 Disco 4
        NPIS.left1.SDLP = length(find((SDLP(triggerperf(3):triggerperf(4))) > (SDLPbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left1.SDLP = (NPIS.left1.SDLP / (NPIS.left1.SDLP + NPISH.SDLP))*100;
        NPIS.left1.SDS = length(find((SDS(triggerperf(3):triggerperf(4))) > (SDSbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left1.SDS = (NPIS.left1.SDS / (NPIS.left1.SDS + NPISH.SDS))*100;
        NPIS.left1.RV = length(find((RV(triggerperf(3):triggerperf(4))) > (RVbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left1.RV = (NPIS.left1.RV / (NPIS.left1.RV + NPISH.RV))*100;
        NPIS.left1.SDSW = length(find((SDSW(triggerperf(3):triggerperf(4))) > (SDSWbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left1.SDSW = (NPIS.left1.SDSW / (NPIS.left1.SDSW + NPISH.SDSW))*100;
        NPIS.left1.RMSfrein = length(find((RMSfrein(triggerperf(3):triggerperf(4))) > (RMSfreinbaselineG(triggerperf(3):triggerperf(4)))));
        precision.left1.RMSfrein = (NPIS.left1.RMSfrein / (NPIS.left1.RMSfrein + NPISH.RMSfrein))*100;
        
        % Disco  4 : Situation 3 : sb
        % Physio sb Disco 4
        NPIS.sb.EDA = length(find((EDA1(triggerphys(5):triggerphys(6))) > (EDAbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.EDA = (NPIS.sb.EDA / (NPIS.sb.EDA + NPISH.EDA))*100;
        NPIS.sb.EDArms = length(find((EDArms(triggerphys(5):triggerphys(6))) > (EDArmsbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.EDArms = (NPIS.sb.EDArms / (NPIS.sb.EDArms + NPISH.EDArms))*100;
        NPIS.sb.HR = length(find((HR1(triggerphys(5):triggerphys(6))) > (HRbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.HR = (NPIS.sb.HR / (NPIS.sb.HR  + NPISH.HR))*100;
        NPIS.sb.HRV = length(find((HRV(triggerphys(5):triggerphys(6))) > (HRVbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.HRV = (NPIS.sb.HRV / (NPIS.sb.HRV + NPISH.HRV))*100;
        NPIS.sb.RYT = length(find((RYT(triggerphys(5):triggerphys(6))) > (RYTbaselineG(triggerphys(5):triggerphys(6)))));
        precision.sb.RYT = (NPIS.sb.RYT / (NPIS.sb.RYT + NPISH.RYT))*100;
        % Perf sb Disco 2
        NPIS.sb.SDLP = length(find((SDLP(triggerperf(5):triggerperf(6))) > (SDLPbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.SDLP = (NPIS.sb.SDLP / (NPIS.sb.SDLP + NPISH.SDLP))*100;
        NPIS.sb.SDS = length(find((SDS(triggerperf(5):triggerperf(6))) > (SDSbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.SDS = (NPIS.sb.SDS / (NPIS.sb.SDS+ NPISH.SDS))*100;
        NPIS.sb.RV = length(find((RV(triggerperf(5):triggerperf(6))) > (RVbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.RV = (NPIS.sb.RV / (NPIS.sb.RV + NPISH.RV))*100;
        NPIS.sb.SDSW = length(find((SDSW(triggerperf(5):triggerperf(6))) > (SDSWbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.SDSW = (NPIS.sb.SDSW / (NPIS.sb.SDSW + NPISH.SDSW))*100;
        NPIS.sb.RMSfrein = length(find((RMSfrein(triggerperf(5):triggerperf(6))) > (RMSfreinbaselineG(triggerperf(5):triggerperf(6)))));
        precision.sb.RMSfrein = (NPIS.sb.RMSfrein / (NPIS.sb.RMSfrein + NPISH.RMSfrein))*100;
    end
    
    %% Calcul des variables retranchées
    
    if disco ~= 5
        
        EDA1sousseuil = EDA1;
        EDArmssousseuil = EDArms;
        HR1sousseuil = HR1;
        HRVsousseuil = HRV;
        RYTsousseuil = RYT;
        
        
        SDLPsousseuil = SDLP;
        SDSsousseuil = SDS;
        RVsousseuil = RV;
        SDSWsousseuil = SDSW;
        RMSfreinsousseuil = RMSfrein;
        
        
        % Retranchement des données au dessous de la baseline
        for k = 1:length(EDA1)%(triggerphys(1):triggerphys(2)))
            if EDA1(k) < EDAbaselineG(k)
                EDA1(k) = EDAbaselineG(k);
            end
            if EDArms(k) < EDArmsbaselineG(k)
                EDArms(k) = EDArmsbaselineG(k);
            end
            if HR1(k) < HRbaselineG(k)
                HR1(k) = HRbaselineG(k);
            end
            if HRV(k) < HRVbaselineG(k)
                HRV(k) = HRVbaselineG(k);
            end
            if RYT(k) < RYTbaselineG(k)
                RYT(k) = RYTbaselineG(k);
            end
        end
        
        for l = 1:length(SDLP)
            if SDLP(l) < SDLPbaselineG(l)
                SDLP(l) = SDLPbaselineG(l);
            end
            if SDS(l) < SDSbaselineG(l)
                SDS(l) = SDSbaselineG(l);
            end
            if RV(l) < RVbaselineG(l)
                RV(l) = RVbaselineG(l);
            end
            if SDSW(l) < SDSWbaselineG(l)
                SDSW(l) = SDSWbaselineG(l);
            end
            if RMSfrein(l) < RMSfreinbaselineG(l)
                RMSfrein(l) = RMSfreinbaselineG(l);
            end
        end
        
        % Retranchement des données au dessus la baseline
        for k = 1:length(EDA1sousseuil)%(triggerphys(1):triggerphys(2)))
            if EDA1sousseuil(k) > EDAbaselineG(k)
                EDA1sousseuil(k) = EDAbaselineG(k);
            end
            if EDArmssousseuil(k) > EDArmsbaselineG(k)
                EDArmssousseuil(k) = EDArmsbaselineG(k);
            end
            if HR1sousseuil(k) > HRbaselineG(k)
                HR1sousseuil(k) = HRbaselineG(k);
            end
            if HRVsousseuil(k) > HRVbaselineG(k)
                HRVsousseuil(k) = HRVbaselineG(k);
            end
            if RYTsousseuil(k) > RYTbaselineG(k)
                RYTsousseuil(k) = RYTbaselineG(k);
            end
        end
        
        for l = 1:length(SDLPsousseuil)
            if SDLPsousseuil(l) > SDLPbaselineG(l)
                SDLPsousseuil(l) = SDLPbaselineG(l);
            end
            if SDSsousseuil(l) > SDSbaselineG(l)
                SDSsousseuil(l) = SDSbaselineG(l);
            end
            if RVsousseuil(l) > RVbaselineG(l)
                RVsousseuil(l) = RVbaselineG(l);
            end
            if SDSWsousseuil(l) > SDSWbaselineG(l)
                SDSWsousseuil(l) = SDSWbaselineG(l);
            end
            if RMSfreinsousseuil(l) > RMSfreinbaselineG(l)
                RMSfreinsousseuil(l) = RMSfreinbaselineG(l);
            end
        end
        
        
        
    end
    
    
    
    %% Calcul de sensibilité
    
    % Sensibilité = ACSI/ACS*100
    % ACSI = aire de la courbe du signal de l'indice au dessus du seuil d'inconfort
    % ACS = aire sous le seuil d'inconfort aau sein de la zone de situation
    
    
    if disco == 1
        % Calcul de sensibilité pour : chaque scenario, chaque situation et chaque groupe de données (phsyio et comportemental)
        
        % Disco 1 : Situation 1 : Ove 1
        % Physio ove1 Disco 1
        ASCI.ove1.EDA = trapz(tps1(triggerphys(1):triggerphys(2)),EDA1(triggerphys(1):triggerphys(2)))-trapz(tps1(triggerphys(1):triggerphys(2)),EDAbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove1.EDA = trapz(tps1(triggerphys(1):triggerphys(2)),EDA1sousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove1.EDA = ASCI.ove1.EDA/ACS.ove1.EDA;
        
        ASCI.ove1.EDArms = trapz(tps2(triggerphys(1):triggerphys(2)),EDArms(triggerphys(1):triggerphys(2)))-trapz(tps2(triggerphys(1):triggerphys(2)),EDArmsbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove1.EDArms = trapz(tps2(triggerphys(1):triggerphys(2)),EDArmssousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove1.EDArms = (ASCI.ove1.EDArms)/ACS.ove1.EDArms;
        
        ASCI.ove1.HR = trapz(tps3(triggerphys(1):triggerphys(2)),HR1(triggerphys(1):triggerphys(2)))-trapz(tps3(triggerphys(1):triggerphys(2)),HRbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove1.HR = trapz(tps3(triggerphys(1):triggerphys(2)),HR1sousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove1.HR = (ASCI.ove1.HR)/ACS.ove1.HR;
        
        ASCI.ove1.HRV = trapz(tps4(triggerphys(1):triggerphys(2)),HRV(triggerphys(1):triggerphys(2)))-trapz(tps4(triggerphys(1):triggerphys(2)),HRVbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove1.HRV = trapz(tps4(triggerphys(1):triggerphys(2)),HRVsousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove1.HRV = (ASCI.ove1.HRV)/ACS.ove1.HRV;
        
        ASCI.ove1.RYT = trapz(tps5(triggerphys(1):triggerphys(2)),RYT(triggerphys(1):triggerphys(2)))-trapz(tps5(triggerphys(1):triggerphys(2)),RYTbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove1.RYT = trapz(tps5(triggerphys(1):triggerphys(2)),RYTsousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove1.RYT = (ASCI.ove1.RYT)/ACS.ove1.RYT;
        
        % Perf ove1 Disco 1
        ASCI.ove1.SDLP = trapz(tps6(triggerperf(1):triggerperf(2)),SDLP(triggerperf(1):triggerperf(2)))-trapz(tps6(triggerperf(1):triggerperf(2)),SDLPbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove1.SDLP = trapz(tps6(triggerperf(1):triggerperf(2)),SDLPsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove1.SDLP = (ASCI.ove1.SDLP)/ACS.ove1.SDLP;
        
        ASCI.ove1.SDS = trapz(tps7(triggerperf(1):triggerperf(2)),SDS(triggerperf(1):triggerperf(2)))-trapz(tps7(triggerperf(1):triggerperf(2)),SDSbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove1.SDS = trapz(tps7(triggerperf(1):triggerperf(2)),SDSsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove1.SDS = (ASCI.ove1.SDS)/ACS.ove1.SDS;
        
        ASCI.ove1.RV = trapz(tps8(triggerperf(1):triggerperf(2)),RV(triggerperf(1):triggerperf(2)))-trapz(tps8(triggerperf(1):triggerperf(2)),RVbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove1.RV = trapz(tps8(triggerperf(1):triggerperf(2)),RVsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove1.RV = (ASCI.ove1.RV)/ACS.ove1.RV;
        
        ASCI.ove1.SDSW = trapz(tps9(triggerperf(1):triggerperf(2)),SDSW(triggerperf(1):triggerperf(2)))-trapz(tps9(triggerperf(1):triggerperf(2)),SDSWbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove1.SDSW = trapz(tps9(triggerperf(1):triggerperf(2)),SDSWsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove1.SDSW = (ASCI.ove1.SDSW)/ACS.ove1.SDSW;
        
        ASCI.ove1.RMSfrein = trapz(tps10(triggerperf(1):triggerperf(2)),RMSfrein(triggerperf(1):triggerperf(2)))-trapz(tps10(triggerperf(1):triggerperf(2)),RMSfreinbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove1.RMSfrein = trapz(tps10(triggerperf(1):triggerperf(2)),RMSfreinsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove1.RMSfrein = (ASCI.ove1.RMSfrein)/ACS.ove1.RMSfrein;
        
        % Disco 1 : Situation 2 : left
        % Physio left Disco 1
        ASCI.left.EDA = trapz(tps1(triggerphys(3):triggerphys(4)),EDA1(triggerphys(3):triggerphys(4)))-trapz(tps1(triggerphys(3):triggerphys(4)),EDAbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left.EDA = trapz(tps1(triggerphys(3):triggerphys(4)),EDA1sousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left.EDA = (ASCI.left.EDA)/ACS.left.EDA;
        
        ASCI.left.EDArms = trapz(tps2(triggerphys(3):triggerphys(4)),EDArms(triggerphys(3):triggerphys(4)))-trapz(tps2(triggerphys(3):triggerphys(4)),EDArmsbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left.EDArms = trapz(tps2(triggerphys(3):triggerphys(4)),EDArmssousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left.EDArms = (ASCI.left.EDArms)/ACS.left.EDArms;
        
        ASCI.left.HR = trapz(tps3(triggerphys(3):triggerphys(4)),HR1(triggerphys(3):triggerphys(4)))-trapz(tps3(triggerphys(3):triggerphys(4)),HRbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left.HR = trapz(tps3(triggerphys(3):triggerphys(4)),HR1sousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left.HR = (ASCI.left.HR)/ACS.left.HR;
        
        ASCI.left.HRV = trapz(tps4(triggerphys(3):triggerphys(4)),HRV(triggerphys(3):triggerphys(4)))-trapz(tps4(triggerphys(3):triggerphys(4)),HRVbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left.HRV = trapz(tps4(triggerphys(3):triggerphys(4)),HRVsousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left.HRV = (ASCI.left.HRV)/ACS.left.HRV;
        
        ASCI.left.RYT = trapz(tps5(triggerphys(3):triggerphys(4)),RYT(triggerphys(3):triggerphys(4)))-trapz(tps5(triggerphys(3):triggerphys(4)),RYTbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left.RYT = trapz(tps5(triggerphys(3):triggerphys(4)),RYTsousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left.RYT = (ASCI.left.RYT)/ACS.left.RYT;
        
        %Perf left Disco 1
        ASCI.left.SDLP = trapz(tps6(triggerperf(3):triggerperf(4)),SDLP(triggerperf(3):triggerperf(4)))-trapz(tps6(triggerperf(3):triggerperf(4)),SDLPbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left.SDLP = trapz(tps6(triggerperf(3):triggerperf(4)),SDLPsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left.SDLP = (ASCI.left.SDLP)/ACS.left.SDLP;
        
        ASCI.left.SDS = trapz(tps7(triggerperf(3):triggerperf(4)),SDS(triggerperf(3):triggerperf(4)))-trapz(tps7(triggerperf(3):triggerperf(4)),SDSbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left.SDS = trapz(tps7(triggerperf(3):triggerperf(4)),SDSsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left.SDS = (ASCI.left.SDS)/ACS.left.SDS;
        
        ASCI.left.RV = trapz(tps8(triggerperf(3):triggerperf(4)),RV(triggerperf(3):triggerperf(4)))-trapz(tps8(triggerperf(3):triggerperf(4)),RVbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left.RV = trapz(tps8(triggerperf(3):triggerperf(4)),RVsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left.RV = (ASCI.left.RV)/ACS.left.RV;
        
        ASCI.left.SDSW = trapz(tps9(triggerperf(3):triggerperf(4)),SDSW(triggerperf(3):triggerperf(4)))-trapz(tps9(triggerperf(3):triggerperf(4)),SDSWbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left.SDSW = trapz(tps9(triggerperf(3):triggerperf(4)),SDSWsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left.SDSW = (ASCI.left.SDSW)/ACS.left.SDSW;
        
        ASCI.left.RMSfrein = trapz(tps10(triggerperf(3):triggerperf(4)),RMSfrein(triggerperf(3):triggerperf(4)))-trapz(tps10(triggerperf(3):triggerperf(4)),RMSfreinbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left.RMSfrein = trapz(tps10(triggerperf(3):triggerperf(4)),RMSfreinsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left.RMSfrein = (ASCI.left.RMSfrein)/ACS.left.RMSfrein;
        
        % Disco 1 : Situation 3 : ped
        
        % Physio ped Disco 1
        ASCI.ped.EDA = trapz(tps1(triggerphys(5):triggerphys(6)),EDA1(triggerphys(5):triggerphys(6)))-trapz(tps1(triggerphys(5):triggerphys(6)),EDAbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.EDA = trapz(tps1(triggerphys(5):triggerphys(6)),EDA1sousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.EDA = (ASCI.ped.EDA)/ACS.ped.EDA;
        
        ASCI.ped.EDArms = trapz(tps2(triggerphys(5):triggerphys(6)),EDArms(triggerphys(5):triggerphys(6)))-trapz(tps2(triggerphys(5):triggerphys(6)),EDArmsbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.EDArms = trapz(tps2(triggerphys(5):triggerphys(6)),EDArmssousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.EDArms = (ASCI.ped.EDArms)/ACS.ped.EDArms;
        
        ASCI.ped.HR = trapz(tps3(triggerphys(5):triggerphys(6)),HR1(triggerphys(5):triggerphys(6)))-trapz(tps3(triggerphys(5):triggerphys(6)),HRbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.HR = trapz(tps3(triggerphys(5):triggerphys(6)),HR1sousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.HR = (ASCI.ped.HR)/ACS.ped.HR;
        
        ASCI.ped.HRV = trapz(tps4(triggerphys(5):triggerphys(6)),HRV(triggerphys(5):triggerphys(6)))-trapz(tps4(triggerphys(5):triggerphys(6)),HRVbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.HRV = trapz(tps4(triggerphys(5):triggerphys(6)),HRVsousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.HRV = (ASCI.ped.HRV)/ACS.ped.HRV;
        
        ASCI.ped.RYT = trapz(tps5(triggerphys(5):triggerphys(6)),RYT(triggerphys(5):triggerphys(6)))-trapz(tps5(triggerphys(5):triggerphys(6)),RYTbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.RYT = trapz(tps5(triggerphys(5):triggerphys(6)),RYTsousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.RYT = (ASCI.ped.RYT)/ACS.ped.RYT;
        
        
        % Perf ped Disco 1
        ASCI.ped.SDLP = trapz(tps6(triggerperf(5):triggerperf(6)),SDLP(triggerperf(5):triggerperf(6)))-trapz(tps6(triggerperf(5):triggerperf(6)),SDLPbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.SDLP = trapz(tps6(triggerperf(5):triggerperf(6)),SDLPsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.SDLP = (ASCI.ped.SDLP)/ACS.ped.SDLP;
        
        ASCI.ped.SDS = trapz(tps7(triggerperf(5):triggerperf(6)),SDS(triggerperf(5):triggerperf(6)))-trapz(tps7(triggerperf(5):triggerperf(6)),SDSbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.SDS = trapz(tps7(triggerperf(5):triggerperf(6)),SDSsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.SDS = (ASCI.ped.SDS)/ACS.ped.SDS;
        
        ASCI.ped.RV = trapz(tps8(triggerperf(5):triggerperf(6)),RV(triggerperf(5):triggerperf(6)))-trapz(tps8(triggerperf(5):triggerperf(6)),RVbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.RV = trapz(tps8(triggerperf(5):triggerperf(6)),RVsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.RV = (ASCI.ped.RV)/ACS.ped.RV;
        
        ASCI.ped.SDSW = trapz(tps9(triggerperf(5):triggerperf(6)),SDSW(triggerperf(5):triggerperf(6)))-trapz(tps9(triggerperf(5):triggerperf(6)),SDSWbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.SDSW = trapz(tps9(triggerperf(5):triggerperf(6)),SDSWsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.SDSW = (ASCI.ped.SDSW)/ACS.ped.SDSW;
        
        ASCI.ped.RMSfrein = trapz(tps10(triggerperf(5):triggerperf(6)),RMSfrein(triggerperf(5):triggerperf(6)))-trapz(tps10(triggerperf(5):triggerperf(6)),RMSfreinbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.RMSfrein = trapz(tps10(triggerperf(5):triggerperf(6)),RMSfreinsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.RMSfrein = (ASCI.ped.RMSfrein)/ACS.ped.RMSfrein;
        
    end
    
    
    if disco == 2
        % Disco 2 : Situation 1 : Left 1
        
        % Physio left 1 Disco 2
        ASCI.left1.EDA = trapz(tps1(triggerphys(1):triggerphys(2)),EDA1(triggerphys(1):triggerphys(2)))-trapz(tps1(triggerphys(1):triggerphys(2)),EDAbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left1.EDA = trapz(tps1(triggerphys(1):triggerphys(2)),EDA1sousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left1.EDA = (ASCI.left1.EDA)/ACS.left1.EDA;
        
        ASCI.left1.EDArms = trapz(tps2(triggerphys(1):triggerphys(2)),EDArms(triggerphys(1):triggerphys(2)))-trapz(tps2(triggerphys(1):triggerphys(2)),EDArmsbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left1.EDArms = trapz(tps2(triggerphys(1):triggerphys(2)),EDArmssousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left1.EDArms = (ASCI.left1.EDArms)/ACS.left1.EDArms;
        
        ASCI.left1.HR = trapz(tps3(triggerphys(1):triggerphys(2)),HR1(triggerphys(1):triggerphys(2)))-trapz(tps3(triggerphys(1):triggerphys(2)),HRbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left1.HR = trapz(tps3(triggerphys(1):triggerphys(2)),HR1sousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left1.HR = (ASCI.left1.HR)/ACS.left1.HR;
        
        ASCI.left1.HRV = trapz(tps4(triggerphys(1):triggerphys(2)),HRV(triggerphys(1):triggerphys(2)))-trapz(tps4(triggerphys(1):triggerphys(2)),HRVbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left1.HRV = trapz(tps4(triggerphys(1):triggerphys(2)),HRVsousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left1.HRV = (ASCI.left1.HRV)/ACS.left1.HRV;
        
        ASCI.left1.RYT = trapz(tps5(triggerphys(1):triggerphys(2)),RYT(triggerphys(1):triggerphys(2)))-trapz(tps5(triggerphys(1):triggerphys(2)),RYTbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left1.RYT = trapz(tps5(triggerphys(1):triggerphys(2)),RYTsousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left1.RYT = (ASCI.left1.RYT)/ACS.left1.RYT;
        
        %Perf left 1 Disco 2
        ASCI.left1.SDLP = trapz(tps6(triggerperf(1):triggerperf(2)),SDLP(triggerperf(1):triggerperf(2)))-trapz(tps6(triggerperf(1):triggerperf(2)),SDLPbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left1.SDLP = trapz(tps6(triggerperf(1):triggerperf(2)),SDLPsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left1.SDLP = (ASCI.left1.SDLP)/ACS.left1.SDLP;
        
        ASCI.left1.SDS = trapz(tps7(triggerperf(1):triggerperf(2)),SDS(triggerperf(1):triggerperf(2)))-trapz(tps7(triggerperf(1):triggerperf(2)),SDSbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left1.SDS = trapz(tps7(triggerperf(1):triggerperf(2)),SDSsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left1.SDS = (ASCI.left1.SDS)/ACS.left1.SDS;
        
        ASCI.left1.RV = trapz(tps8(triggerperf(1):triggerperf(2)),RV(triggerperf(1):triggerperf(2)))-trapz(tps8(triggerperf(1):triggerperf(2)),RVbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left1.RV = trapz(tps8(triggerperf(1):triggerperf(2)),RVsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left1.RV = (ASCI.left1.RV)/ACS.left1.RV;
        
        ASCI.left1.SDSW = trapz(tps9(triggerperf(1):triggerperf(2)),SDSW(triggerperf(1):triggerperf(2)))-trapz(tps9(triggerperf(1):triggerperf(2)),SDSWbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left1.SDSW = trapz(tps9(triggerperf(1):triggerperf(2)),SDSWsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left1.SDSW = (ASCI.left1.SDSW)/ACS.left1.SDSW;
        
        ASCI.left1.RMSfrein = trapz(tps10(triggerperf(1):triggerperf(2)),RMSfrein(triggerperf(1):triggerperf(2)))-trapz(tps10(triggerperf(1):triggerperf(2)),RMSfreinbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left1.RMSfrein = trapz(tps10(triggerperf(1):triggerperf(2)),RMSfreinsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left1.RMSfrein = (ASCI.left1.RMSfrein)/ACS.left1.RMSfrein;
        
        % Disco 2 : Situation 2 : Ove
        % Physio ove Disco 2
        ASCI.ove.EDA = trapz(tps1(triggerphys(3):triggerphys(4)),EDA1(triggerphys(3):triggerphys(4)))-trapz(tps1(triggerphys(3):triggerphys(4)),EDAbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove.EDA = trapz(tps1(triggerphys(3):triggerphys(4)),EDA1sousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove.EDA = (ASCI.ove.EDA)/ACS.ove.EDA;
        
        ASCI.ove.EDArms = trapz(tps2(triggerphys(3):triggerphys(4)),EDArms(triggerphys(3):triggerphys(4)))-trapz(tps2(triggerphys(3):triggerphys(4)),EDArmsbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove.EDArms = trapz(tps2(triggerphys(3):triggerphys(4)),EDArmssousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove.EDArms = (ASCI.ove.EDArms)/ACS.ove.EDArms;
        
        ASCI.ove.HR = trapz(tps3(triggerphys(3):triggerphys(4)),HR1(triggerphys(3):triggerphys(4)))-trapz(tps3(triggerphys(3):triggerphys(4)),HRbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove.HR = trapz(tps3(triggerphys(3):triggerphys(4)),HR1sousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove.HR = (ASCI.ove.HR)/ACS.ove.HR;
        
        ASCI.ove.HRV = trapz(tps4(triggerphys(3):triggerphys(4)),HRV(triggerphys(3):triggerphys(4)))-trapz(tps4(triggerphys(3):triggerphys(4)),HRVbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove.HRV = trapz(tps4(triggerphys(3):triggerphys(4)),HRVsousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove.HRV = (ASCI.ove.HRV)/ACS.ove.HRV;
        
        ASCI.ove.RYT = trapz(tps5(triggerphys(3):triggerphys(4)),RYT(triggerphys(3):triggerphys(4)))-trapz(tps5(triggerphys(3):triggerphys(4)),RYTbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove.RYT = trapz(tps5(triggerphys(3):triggerphys(4)),RYTsousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove.RYT = (ASCI.ove.RYT)/ACS.ove.RYT;
        
        % Perf ove Disco 2
        ASCI.ove.SDLP = trapz(tps6(triggerperf(3):triggerperf(4)),SDLP(triggerperf(3):triggerperf(4)))-trapz(tps6(triggerperf(3):triggerperf(4)),SDLPbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove.SDLP = trapz(tps6(triggerperf(3):triggerperf(4)),SDLPsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove.SDLP = (ASCI.ove.SDLP)/ACS.ove.SDLP;
        
        ASCI.ove.SDS = trapz(tps7(triggerperf(3):triggerperf(4)),SDS(triggerperf(3):triggerperf(4)))-trapz(tps7(triggerperf(3):triggerperf(4)),SDSbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove.SDS = trapz(tps7(triggerperf(3):triggerperf(4)),SDSsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove.SDS = (ASCI.ove.SDS)/ACS.ove.SDS;
        
        ASCI.ove.RV = trapz(tps8(triggerperf(3):triggerperf(4)),RV(triggerperf(3):triggerperf(4)))-trapz(tps8(triggerperf(3):triggerperf(4)),RVbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove.RV = trapz(tps8(triggerperf(3):triggerperf(4)),RVsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove.RV = (ASCI.ove.RV)/ACS.ove.RV;
        
        ASCI.ove.SDSW = trapz(tps9(triggerperf(3):triggerperf(4)),SDSW(triggerperf(3):triggerperf(4)))-trapz(tps9(triggerperf(3):triggerperf(4)),SDSWbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove.SDSW = trapz(tps9(triggerperf(3):triggerperf(4)),SDSWsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove.SDSW = (ASCI.ove.SDSW)/ACS.ove.SDSW;
        
        ASCI.ove.RMSfrein = trapz(tps10(triggerperf(3):triggerperf(4)),RMSfrein(triggerperf(3):triggerperf(4)))-trapz(tps10(triggerperf(3):triggerperf(4)),RMSfreinbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove.RMSfrein = trapz(tps10(triggerperf(3):triggerperf(4)),RMSfreinsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove.RMSfrein = (ASCI.ove.RMSfrein)/ACS.ove.RMSfrein;
        
        % Disco 2 : Situation 3 : Jaillissement
        % Physio SB Disco 2
        ASCI.sb.EDA = trapz(tps1(triggerphys(5):triggerphys(6)),EDA1(triggerphys(5):triggerphys(6)))-trapz(tps1(triggerphys(5):triggerphys(6)),EDAbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.EDA = trapz(tps1(triggerphys(5):triggerphys(6)),EDA1sousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.EDA = (ASCI.sb.EDA)/ACS.sb.EDA;
        
        ASCI.sb.EDArms = trapz(tps2(triggerphys(5):triggerphys(6)),EDArms(triggerphys(5):triggerphys(6)))-trapz(tps2(triggerphys(5):triggerphys(6)),EDArmsbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.EDArms = trapz(tps2(triggerphys(5):triggerphys(6)),EDArmssousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.EDArms = (ASCI.sb.EDArms)/ACS.sb.EDArms;
        
        ASCI.sb.HR = trapz(tps3(triggerphys(5):triggerphys(6)),HR1(triggerphys(5):triggerphys(6)))-trapz(tps3(triggerphys(5):triggerphys(6)),HRbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.HR = trapz(tps3(triggerphys(5):triggerphys(6)),HR1sousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.HR = (ASCI.sb.HR)/ACS.sb.HR;
        
        ASCI.sb.HRV = trapz(tps4(triggerphys(5):triggerphys(6)),HRV(triggerphys(5):triggerphys(6)))-trapz(tps4(triggerphys(5):triggerphys(6)),HRVbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.HRV = trapz(tps4(triggerphys(5):triggerphys(6)),HRVsousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.HRV = (ASCI.sb.HRV)/ACS.sb.HRV;
        
        ASCI.sb.RYT = trapz(tps5(triggerphys(5):triggerphys(6)),RYT(triggerphys(5):triggerphys(6)))-trapz(tps5(triggerphys(5):triggerphys(6)),RYTbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.RYT = trapz(tps5(triggerphys(5):triggerphys(6)),RYTsousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.RYT = (ASCI.sb.RYT)/ACS.sb.RYT;
        
        
        % Perf SB Disco 2
        ASCI.sb.SDLP = trapz(tps6(triggerperf(5):triggerperf(6)),SDLP(triggerperf(5):triggerperf(6)))-trapz(tps6(triggerperf(5):triggerperf(6)),SDLPbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.SDLP = trapz(tps6(triggerperf(5):triggerperf(6)),SDLPsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.SDLP = (ASCI.sb.SDLP)/ACS.sb.SDLP;
        
        ASCI.sb.SDS = trapz(tps7(triggerperf(5):triggerperf(6)),SDS(triggerperf(5):triggerperf(6)))-trapz(tps7(triggerperf(5):triggerperf(6)),SDSbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.SDS = trapz(tps7(triggerperf(5):triggerperf(6)),SDSsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.SDS = (ASCI.sb.SDS)/ACS.sb.SDS;
        
        ASCI.sb.RV = trapz(tps8(triggerperf(5):triggerperf(6)),RV(triggerperf(5):triggerperf(6)))-trapz(tps8(triggerperf(5):triggerperf(6)),RVbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.RV = trapz(tps8(triggerperf(5):triggerperf(6)),RVsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.RV = (ASCI.sb.RV)/ACS.sb.RV;
        
        ASCI.sb.SDSW = trapz(tps9(triggerperf(5):triggerperf(6)),SDSW(triggerperf(5):triggerperf(6)))-trapz(tps9(triggerperf(5):triggerperf(6)),SDSWbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.SDSW = trapz(tps9(triggerperf(5):triggerperf(6)),SDSWsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.SDSW = (ASCI.sb.SDSW)/ACS.sb.SDSW;
        
        ASCI.sb.RMSfrein = trapz(tps10(triggerperf(5):triggerperf(6)),RMSfrein(triggerperf(5):triggerperf(6)))-trapz(tps10(triggerperf(5):triggerperf(6)),RMSfreinbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.RMSfrein = trapz(tps10(triggerperf(5):triggerperf(6)),RMSfreinsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.RMSfrein = (ASCI.sb.RMSfrein)/ACS.sb.RMSfrein;
    end
    
    if disco == 3
        % Physio left Disco 3
        ASCI.left.EDA = trapz(tps1(triggerphys(1):triggerphys(2)),EDA1(triggerphys(1):triggerphys(2)))-trapz(tps1(triggerphys(1):triggerphys(2)),EDAbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left.EDA = trapz(tps1(triggerphys(1):triggerphys(2)),EDA1sousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left.EDA = (ASCI.left.EDA)/ACS.left.EDA;
        
        ASCI.left.EDArms = trapz(tps2(triggerphys(1):triggerphys(2)),EDArms(triggerphys(1):triggerphys(2)))-trapz(tps2(triggerphys(1):triggerphys(2)),EDArmsbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left.EDArms = trapz(tps2(triggerphys(1):triggerphys(2)),EDArmssousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left.EDArms = (ASCI.left.EDArms)/ACS.left.EDArms;
        
        ASCI.left.HR = trapz(tps3(triggerphys(1):triggerphys(2)),HR1(triggerphys(1):triggerphys(2)))-trapz(tps3(triggerphys(1):triggerphys(2)),HRbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left.HR = trapz(tps3(triggerphys(1):triggerphys(2)),HR1sousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left.HR = (ASCI.left.HR)/ACS.left.HR;
        
        ASCI.left.HRV = trapz(tps4(triggerphys(1):triggerphys(2)),HRV(triggerphys(1):triggerphys(2)))-trapz(tps4(triggerphys(1):triggerphys(2)),HRVbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left.HRV = trapz(tps4(triggerphys(1):triggerphys(2)),HRVsousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left.HRV = (ASCI.left.HRV)/ACS.left.HRV;
        
        ASCI.left.RYT = trapz(tps5(triggerphys(1):triggerphys(2)),RYT(triggerphys(1):triggerphys(2)))-trapz(tps5(triggerphys(1):triggerphys(2)),RYTbaselineG(triggerphys(1):triggerphys(2)));
        ACS.left.RYT = trapz(tps5(triggerphys(1):triggerphys(2)),RYTsousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.left.RYT = (ASCI.left.RYT)/ACS.left.RYT;
        
        %Perf left Disco 3
        ASCI.left.SDLP = trapz(tps6(triggerperf(1):triggerperf(2)),SDLP(triggerperf(1):triggerperf(2)))-trapz(tps6(triggerperf(1):triggerperf(2)),SDLPbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left.SDLP = trapz(tps6(triggerperf(1):triggerperf(2)),SDLPsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left.SDLP = (ASCI.left.SDLP)/ACS.left.SDLP;
        
        ASCI.left.SDS = trapz(tps7(triggerperf(1):triggerperf(2)),SDS(triggerperf(1):triggerperf(2)))-trapz(tps7(triggerperf(1):triggerperf(2)),SDSbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left.SDS = trapz(tps7(triggerperf(1):triggerperf(2)),SDSsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left.SDS = (ASCI.left.SDS)/ACS.left.SDS;
        
        ASCI.left.RV = trapz(tps8(triggerperf(1):triggerperf(2)),RV(triggerperf(1):triggerperf(2)))-trapz(tps8(triggerperf(1):triggerperf(2)),RVbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left.RV = trapz(tps8(triggerperf(1):triggerperf(2)),RVsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left.RV = (ASCI.left.RV)/ACS.left.RV;
        
        ASCI.left.SDSW = trapz(tps9(triggerperf(1):triggerperf(2)),SDSW(triggerperf(1):triggerperf(2)))-trapz(tps9(triggerperf(1):triggerperf(2)),SDSWbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left.SDSW = trapz(tps9(triggerperf(1):triggerperf(2)),SDSWsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left.SDSW = (ASCI.left.SDSW)/ACS.left.SDSW;
        
        ASCI.left.RMSfrein = trapz(tps10(triggerperf(1):triggerperf(2)),RMSfrein(triggerperf(1):triggerperf(2)))-trapz(tps10(triggerperf(1):triggerperf(2)),RMSfreinbaselineG(triggerperf(1):triggerperf(2)));
        ACS.left.RMSfrein = trapz(tps10(triggerperf(1):triggerperf(2)),RMSfreinsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.left.RMSfrein = (ASCI.left.RMSfrein)/ACS.left.RMSfrein;
        
        
        % Physio ove1 Disco 3
        ASCI.ove1.EDA = trapz(tps1(triggerphys(3):triggerphys(4)),EDA1(triggerphys(3):triggerphys(4)))-trapz(tps1(triggerphys(3):triggerphys(4)),EDAbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove1.EDA = trapz(tps1(triggerphys(3):triggerphys(4)),EDA1sousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove1.EDA = (ASCI.ove1.EDA)/ACS.ove1.EDA;
        
        ASCI.ove1.EDArms = trapz(tps2(triggerphys(3):triggerphys(4)),EDArms(triggerphys(3):triggerphys(4)))-trapz(tps2(triggerphys(3):triggerphys(4)),EDArmsbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove1.EDArms = trapz(tps2(triggerphys(3):triggerphys(4)),EDArmssousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove1.EDArms = (ASCI.ove1.EDArms)/ACS.ove1.EDArms;
        
        ASCI.ove1.HR = trapz(tps3(triggerphys(3):triggerphys(4)),HR1(triggerphys(3):triggerphys(4)))-trapz(tps3(triggerphys(3):triggerphys(4)),HRbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove1.HR = trapz(tps3(triggerphys(3):triggerphys(4)),HR1sousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove1.HR = (ASCI.ove1.HR)/ACS.ove1.HR;
        
        ASCI.ove1.HRV = trapz(tps4(triggerphys(3):triggerphys(4)),HRV(triggerphys(3):triggerphys(4)))-trapz(tps4(triggerphys(3):triggerphys(4)),HRVbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove1.HRV = trapz(tps4(triggerphys(3):triggerphys(4)),HRVsousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove1.HRV = (ASCI.ove1.HRV)/ACS.ove1.HRV;
        
        ASCI.ove1.RYT = trapz(tps5(triggerphys(3):triggerphys(4)),RYT(triggerphys(3):triggerphys(4)))-trapz(tps5(triggerphys(3):triggerphys(4)),RYTbaselineG(triggerphys(3):triggerphys(4)));
        ACS.ove1.RYT = trapz(tps5(triggerphys(3):triggerphys(4)),RYTsousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.ove1.RYT = (ASCI.ove1.RYT)/ACS.ove1.RYT;
        
        % Perf ove1 Disco 3
        ASCI.ove1.SDLP = trapz(tps6(triggerperf(3):triggerperf(4)),SDLP(triggerperf(3):triggerperf(4)))-trapz(tps6(triggerperf(3):triggerperf(4)),SDLPbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove1.SDLP = trapz(tps6(triggerperf(3):triggerperf(4)),SDLPsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove1.SDLP = (ASCI.ove1.SDLP)/ACS.ove1.SDLP;
        
        ASCI.ove1.SDS = trapz(tps7(triggerperf(3):triggerperf(4)),SDS(triggerperf(3):triggerperf(4)))-trapz(tps7(triggerperf(3):triggerperf(4)),SDSbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove1.SDS = trapz(tps7(triggerperf(3):triggerperf(4)),SDSsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove1.SDS = (ASCI.ove1.SDS)/ACS.ove1.SDS;
        
        ASCI.ove1.RV = trapz(tps8(triggerperf(3):triggerperf(4)),RV(triggerperf(3):triggerperf(4)))-trapz(tps8(triggerperf(3):triggerperf(4)),RVbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove1.RV = trapz(tps8(triggerperf(3):triggerperf(4)),RVsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove1.RV = (ASCI.ove1.RV)/ACS.ove1.RV;
        
        ASCI.ove1.SDSW = trapz(tps9(triggerperf(3):triggerperf(4)),SDSW(triggerperf(3):triggerperf(4)))-trapz(tps9(triggerperf(3):triggerperf(4)),SDSWbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove1.SDSW = trapz(tps9(triggerperf(3):triggerperf(4)),SDSWsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove1.SDSW = (ASCI.ove1.SDSW)/ACS.ove1.SDSW;
        
        ASCI.ove1.RMSfrein = trapz(tps10(triggerperf(3):triggerperf(4)),RMSfrein(triggerperf(3):triggerperf(4)))-trapz(tps10(triggerperf(3):triggerperf(4)),RMSfreinbaselineG(triggerperf(3):triggerperf(4)));
        ACS.ove1.RMSfrein = trapz(tps10(triggerperf(3):triggerperf(4)),RMSfreinsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.ove1.RMSfrein = (ASCI.ove1.RMSfrein)/ACS.ove1.RMSfrein;
        
        % Physio ped Disco 3
        ASCI.ped.EDA = trapz(tps1(triggerphys(5):triggerphys(6)),EDA1(triggerphys(5):triggerphys(6)))-trapz(tps1(triggerphys(5):triggerphys(6)),EDAbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.EDA = trapz(tps1(triggerphys(5):triggerphys(6)),EDA1sousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.EDA = (ASCI.ped.EDA)/ACS.ped.EDA;
        
        ASCI.ped.EDArms = trapz(tps2(triggerphys(5):triggerphys(6)),EDArms(triggerphys(5):triggerphys(6)))-trapz(tps2(triggerphys(5):triggerphys(6)),EDArmsbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.EDArms = trapz(tps2(triggerphys(5):triggerphys(6)),EDArmssousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.EDArms = (ASCI.ped.EDArms)/ACS.ped.EDArms;
        
        ASCI.ped.HR = trapz(tps3(triggerphys(5):triggerphys(6)),HR1(triggerphys(5):triggerphys(6)))-trapz(tps3(triggerphys(5):triggerphys(6)),HRbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.HR = trapz(tps3(triggerphys(5):triggerphys(6)),HR1sousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.HR = (ASCI.ped.HR)/ACS.ped.HR;
        
        ASCI.ped.HRV = trapz(tps4(triggerphys(5):triggerphys(6)),HRV(triggerphys(5):triggerphys(6)))-trapz(tps4(triggerphys(5):triggerphys(6)),HRVbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.HRV = trapz(tps4(triggerphys(5):triggerphys(6)),HRVsousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.HRV = (ASCI.ped.HRV)/ACS.ped.HRV;
        
        ASCI.ped.RYT = trapz(tps5(triggerphys(5):triggerphys(6)),RYT(triggerphys(5):triggerphys(6)))-trapz(tps5(triggerphys(5):triggerphys(6)),RYTbaselineG(triggerphys(5):triggerphys(6)));
        ACS.ped.RYT = trapz(tps5(triggerphys(5):triggerphys(6)),RYTsousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.ped.RYT = (ASCI.ped.RYT)/ACS.ped.RYT;
        
        % Perf ped Disco 3
        ASCI.ped.SDLP = trapz(tps6(triggerperf(5):triggerperf(6)),SDLP(triggerperf(5):triggerperf(6)))-trapz(tps6(triggerperf(5):triggerperf(6)),SDLPbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.SDLP = trapz(tps6(triggerperf(5):triggerperf(6)),SDLPsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.SDLP = (ASCI.ped.SDLP)/ACS.ped.SDLP;
        
        ASCI.ped.SDS = trapz(tps7(triggerperf(5):triggerperf(6)),SDS(triggerperf(5):triggerperf(6)))-trapz(tps7(triggerperf(5):triggerperf(6)),SDSbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.SDS = trapz(tps7(triggerperf(5):triggerperf(6)),SDSsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.SDS = (ASCI.ped.SDS)/ACS.ped.SDS;
        
        ASCI.ped.RV = trapz(tps8(triggerperf(5):triggerperf(6)),RV(triggerperf(5):triggerperf(6)))-trapz(tps8(triggerperf(5):triggerperf(6)),RVbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.RV = trapz(tps8(triggerperf(5):triggerperf(6)),RVsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.RV = (ASCI.ped.RV)/ACS.ped.RV;
        
        ASCI.ped.SDSW = trapz(tps9(triggerperf(5):triggerperf(6)),SDSW(triggerperf(5):triggerperf(6)))-trapz(tps9(triggerperf(5):triggerperf(6)),SDSWbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.SDSW = trapz(tps9(triggerperf(5):triggerperf(6)),SDSWsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.SDSW = (ASCI.ped.SDSW)/ACS.ped.SDSW;
        
        ASCI.ped.RMSfrein = trapz(tps10(triggerperf(5):triggerperf(6)),RMSfrein(triggerperf(5):triggerperf(6)))-trapz(tps10(triggerperf(5):triggerperf(6)),RMSfreinbaselineG(triggerperf(5):triggerperf(6)));
        ACS.ped.RMSfrein = trapz(tps10(triggerperf(5):triggerperf(6)),RMSfreinsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.ped.RMSfrein = (ASCI.ped.RMSfrein)/ACS.ped.RMSfrein;
    end
    
    
    if disco == 4
        % DISCO 4 situation 1 : ove
        % Physio ove Disco 4
        ASCI.ove.EDA = trapz(tps1(triggerphys(1):triggerphys(2)),EDA1(triggerphys(1):triggerphys(2)))-trapz(tps1(triggerphys(1):triggerphys(2)),EDAbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove.EDA = trapz(tps1(triggerphys(1):triggerphys(2)),EDA1sousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove.EDA = (ASCI.ove.EDA)/ACS.ove.EDA;
        
        ASCI.ove.EDArms = trapz(tps2(triggerphys(1):triggerphys(2)),EDArms(triggerphys(1):triggerphys(2)))-trapz(tps2(triggerphys(1):triggerphys(2)),EDArmsbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove.EDArms = trapz(tps2(triggerphys(1):triggerphys(2)),EDArmssousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove.EDArms = (ASCI.ove.EDArms)/ACS.ove.EDArms;
        
        ASCI.ove.HR = trapz(tps3(triggerphys(1):triggerphys(2)),HR1(triggerphys(1):triggerphys(2)))-trapz(tps3(triggerphys(1):triggerphys(2)),HRbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove.HR = trapz(tps3(triggerphys(1):triggerphys(2)),HR1sousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove.HR = (ASCI.ove.HR)/ACS.ove.HR;
        
        ASCI.ove.HRV = trapz(tps4(triggerphys(1):triggerphys(2)),HRV(triggerphys(1):triggerphys(2)))-trapz(tps4(triggerphys(1):triggerphys(2)),HRVbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove.HRV = trapz(tps4(triggerphys(1):triggerphys(2)),HRVsousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove.HRV = (ASCI.ove.HRV)/ACS.ove.HRV;
        
        ASCI.ove.RYT = trapz(tps5(triggerphys(1):triggerphys(2)),RYT(triggerphys(1):triggerphys(2)))-trapz(tps5(triggerphys(1):triggerphys(2)),RYTbaselineG(triggerphys(1):triggerphys(2)));
        ACS.ove.RYT = trapz(tps5(triggerphys(1):triggerphys(2)),RYTsousseuil(triggerphys(1):triggerphys(2)));
        sensibilite.ove.RYT = (ASCI.ove.RYT)/ACS.ove.RYT;
        
        % Perf ove Disco 4
        ASCI.ove.SDLP = trapz(tps6(triggerperf(1):triggerperf(2)),SDLP(triggerperf(1):triggerperf(2)))-trapz(tps6(triggerperf(1):triggerperf(2)),SDLPbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove.SDLP = trapz(tps6(triggerperf(1):triggerperf(2)),SDLPsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove.SDLP = (ASCI.ove.SDLP)/ACS.ove.SDLP;
        
        ASCI.ove.SDS = trapz(tps7(triggerperf(1):triggerperf(2)),SDS(triggerperf(1):triggerperf(2)))-trapz(tps7(triggerperf(1):triggerperf(2)),SDSbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove.SDS = trapz(tps7(triggerperf(1):triggerperf(2)),SDSsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove.SDS = (ASCI.ove.SDS)/ACS.ove.SDS;
        
        ASCI.ove.RV = trapz(tps8(triggerperf(1):triggerperf(2)),RV(triggerperf(1):triggerperf(2)))-trapz(tps8(triggerperf(1):triggerperf(2)),RVbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove.RV = trapz(tps8(triggerperf(1):triggerperf(2)),RVsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove.RV = (ASCI.ove.RV)/ACS.ove.RV;
        
        ASCI.ove.SDSW = trapz(tps9(triggerperf(1):triggerperf(2)),SDSW(triggerperf(1):triggerperf(2)))-trapz(tps9(triggerperf(1):triggerperf(2)),SDSWbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove.SDSW = trapz(tps9(triggerperf(1):triggerperf(2)),SDSWsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove.SDSW = (ASCI.ove.SDSW)/ACS.ove.SDSW;
        
        ASCI.ove.RMSfrein = trapz(tps10(triggerperf(1):triggerperf(2)),RMSfrein(triggerperf(1):triggerperf(2)))-trapz(tps10(triggerperf(1):triggerperf(2)),RMSfreinbaselineG(triggerperf(1):triggerperf(2)));
        ACS.ove.RMSfrein = trapz(tps10(triggerperf(1):triggerperf(2)),RMSfreinsousseuil(triggerperf(1):triggerperf(2)));
        sensibilite.ove.RMSfrein = (ASCI.ove.RMSfrein)/ACS.ove.RMSfrein;
        
        % DISCO 4 : Situation 2 : Left 1
        % Physio left1 Disco 4
        ASCI.left1.EDA = trapz(tps1(triggerphys(3):triggerphys(4)),EDA1(triggerphys(3):triggerphys(4)))-trapz(tps1(triggerphys(3):triggerphys(4)),EDAbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left1.EDA = trapz(tps1(triggerphys(3):triggerphys(4)),EDA1sousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left1.EDA = (ASCI.left1.EDA)/ACS.left1.EDA;
        
        ASCI.left1.EDArms = trapz(tps2(triggerphys(3):triggerphys(4)),EDArms(triggerphys(3):triggerphys(4)))-trapz(tps2(triggerphys(3):triggerphys(4)),EDArmsbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left1.EDArms = trapz(tps2(triggerphys(3):triggerphys(4)),EDArmssousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left1.EDArms = (ASCI.left1.EDArms)/ACS.left1.EDArms;
        
        ASCI.left1.HR = trapz(tps3(triggerphys(3):triggerphys(4)),HR1(triggerphys(3):triggerphys(4)))-trapz(tps3(triggerphys(3):triggerphys(4)),HRbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left1.HR = trapz(tps3(triggerphys(3):triggerphys(4)),HR1sousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left1.HR = (ASCI.left1.HR)/ACS.left1.HR;
        
        ASCI.left1.HRV = trapz(tps4(triggerphys(3):triggerphys(4)),HRV(triggerphys(3):triggerphys(4)))-trapz(tps4(triggerphys(3):triggerphys(4)),HRVbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left1.HRV = trapz(tps4(triggerphys(3):triggerphys(4)),HRVsousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left1.HRV = (ASCI.left1.HRV)/ACS.left1.HRV;
        
        ASCI.left1.RYT = trapz(tps5(triggerphys(3):triggerphys(4)),RYT(triggerphys(3):triggerphys(4)))-trapz(tps5(triggerphys(3):triggerphys(4)),RYTbaselineG(triggerphys(3):triggerphys(4)));
        ACS.left1.RYT = trapz(tps5(triggerphys(3):triggerphys(4)),RYTsousseuil(triggerphys(3):triggerphys(4)));
        sensibilite.left1.RYT = (ASCI.left1.RYT)/ACS.left1.RYT;
        
        %Perf left1 Disco 4
        ASCI.left1.SDLP = trapz(tps6(triggerperf(3):triggerperf(4)),SDLP(triggerperf(3):triggerperf(4)))-trapz(tps6(triggerperf(3):triggerperf(4)),SDLPbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left1.SDLP = trapz(tps6(triggerperf(3):triggerperf(4)),SDLPsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left1.SDLP = (ASCI.left1.SDLP)/ACS.left1.SDLP;
        
        ASCI.left1.SDS = trapz(tps7(triggerperf(3):triggerperf(4)),SDS(triggerperf(3):triggerperf(4)))-trapz(tps7(triggerperf(3):triggerperf(4)),SDSbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left1.SDS = trapz(tps7(triggerperf(3):triggerperf(4)),SDSsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left1.SDS = (ASCI.left1.SDS)/ACS.left1.SDS;
        
        ASCI.left1.RV = trapz(tps8(triggerperf(3):triggerperf(4)),RV(triggerperf(3):triggerperf(4)))-trapz(tps8(triggerperf(3):triggerperf(4)),RVbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left1.RV = trapz(tps8(triggerperf(3):triggerperf(4)),RVsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left1.RV = (ASCI.left1.RV)/ACS.left1.RV;
        
        ASCI.left1.SDSW = trapz(tps9(triggerperf(3):triggerperf(4)),SDSW(triggerperf(3):triggerperf(4)))-trapz(tps9(triggerperf(3):triggerperf(4)),SDSWbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left1.SDSW = trapz(tps9(triggerperf(3):triggerperf(4)),SDSWsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left1.SDSW = (ASCI.left1.SDSW)/ACS.left1.SDSW;
        
        ASCI.left1.RMSfrein = trapz(tps10(triggerperf(3):triggerperf(4)),RMSfrein(triggerperf(3):triggerperf(4)))-trapz(tps10(triggerperf(3):triggerperf(4)),RMSfreinbaselineG(triggerperf(3):triggerperf(4)));
        ACS.left1.RMSfrein = trapz(tps10(triggerperf(3):triggerperf(4)),RMSfreinsousseuil(triggerperf(3):triggerperf(4)));
        sensibilite.left1.RMSfrein = (ASCI.left1.RMSfrein)/ACS.left1.RMSfrein;
        
        % DISCO 4 : Situation 3 : Jaillissement
        % Physio SB Disco 4
        ASCI.sb.EDA = trapz(tps1(triggerphys(5):triggerphys(6)),EDA1(triggerphys(5):triggerphys(6)))-trapz(tps1(triggerphys(5):triggerphys(6)),EDAbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.EDA = trapz(tps1(triggerphys(5):triggerphys(6)),EDA1sousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.EDA = (ASCI.sb.EDA)/ACS.sb.EDA;
        
        ASCI.sb.EDArms = trapz(tps2(triggerphys(5):triggerphys(6)),EDArms(triggerphys(5):triggerphys(6)))-trapz(tps2(triggerphys(5):triggerphys(6)),EDArmsbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.EDArms = trapz(tps2(triggerphys(5):triggerphys(6)),EDArmssousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.EDArms = (ASCI.sb.EDArms)/ACS.sb.EDArms;
        
        ASCI.sb.HR = trapz(tps3(triggerphys(5):triggerphys(6)),HR1(triggerphys(5):triggerphys(6)))-trapz(tps3(triggerphys(5):triggerphys(6)),HRbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.HR = trapz(tps3(triggerphys(5):triggerphys(6)),HR1sousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.HR = (ASCI.sb.HR)/ACS.sb.HR;
        
        ASCI.sb.HRV = trapz(tps4(triggerphys(5):triggerphys(6)),HRV(triggerphys(5):triggerphys(6)))-trapz(tps4(triggerphys(5):triggerphys(6)),HRVbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.HRV = trapz(tps4(triggerphys(5):triggerphys(6)),HRVsousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.HRV = (ASCI.sb.HRV)/ACS.sb.HRV;
        
        ASCI.sb.RYT = trapz(tps5(triggerphys(5):triggerphys(6)),RYT(triggerphys(5):triggerphys(6)))-trapz(tps5(triggerphys(5):triggerphys(6)),RYTbaselineG(triggerphys(5):triggerphys(6)));
        ACS.sb.RYT = trapz(tps5(triggerphys(5):triggerphys(6)),RYTsousseuil(triggerphys(5):triggerphys(6)));
        sensibilite.sb.RYT = (ASCI.sb.RYT)/ACS.sb.RYT;
        
        % Perf SB Disco 4
        ASCI.sb.SDLP = trapz(tps6(triggerperf(5):triggerperf(6)),SDLP(triggerperf(5):triggerperf(6)))-trapz(tps6(triggerperf(5):triggerperf(6)),SDLPbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.SDLP = trapz(tps6(triggerperf(5):triggerperf(6)),SDLPsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.SDLP = (ASCI.sb.SDLP)/ACS.sb.SDLP;
        
        ASCI.sb.SDS = trapz(tps7(triggerperf(5):triggerperf(6)),SDS(triggerperf(5):triggerperf(6)))-trapz(tps7(triggerperf(5):triggerperf(6)),SDSbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.SDS = trapz(tps7(triggerperf(5):triggerperf(6)),SDSsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.SDS = (ASCI.sb.SDS)/ACS.sb.SDS;
        
        ASCI.sb.RV = trapz(tps8(triggerperf(5):triggerperf(6)),RV(triggerperf(5):triggerperf(6)))-trapz(tps8(triggerperf(5):triggerperf(6)),RVbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.RV = trapz(tps8(triggerperf(5):triggerperf(6)),RVsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.RV = (ASCI.sb.RV)/ACS.sb.RV;
        
        ASCI.sb.SDSW = trapz(tps9(triggerperf(5):triggerperf(6)),SDSW(triggerperf(5):triggerperf(6)))-trapz(tps9(triggerperf(5):triggerperf(6)),SDSWbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.SDSW = trapz(tps9(triggerperf(5):triggerperf(6)),SDSWsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.SDSW = (ASCI.sb.SDSW)/ACS.sb.SDSW;
        
        ASCI.sb.RMSfrein = trapz(tps10(triggerperf(5):triggerperf(6)),RMSfrein(triggerperf(5):triggerperf(6)))-trapz(tps10(triggerperf(5):triggerperf(6)),RMSfreinbaselineG(triggerperf(5):triggerperf(6)));
        ACS.sb.RMSfrein = trapz(tps10(triggerperf(5):triggerperf(6)),RMSfreinsousseuil(triggerperf(5):triggerperf(6)));
        sensibilite.sb.RMSfrein = (ASCI.sb.RMSfrein)/ACS.sb.RMSfrein;
        
    end
    
    
    
    % Vidage des variables pour le disco suivant : Evite les beugs et permet de traiter différents sujets en même temps.
    clear HR HRV EDA EDA1 EDAstep EDArms RYT
    clear SDLP SDS RV SDSW RMSfrein
    end
    %% Enregistrement des données de sujets : sensibilité et précision
    
    % Ordre situations = left / ove / left+1 / ove+1 / sb / ped
    % Ordre variables physio : ampEDA / EDArms / HR / HRV / RYT
    % Ordre variables compor : SDLP / SDS / RV / SDSW / RMSfrein
    
    % Stockage : Matrice sensiblité physiologique (MSP)+ Filtrage des NaN
    MSP (suj,:)= [sensibilite.left.EDA,sensibilite.left.EDArms,sensibilite.left.HR,sensibilite.left.HRV,sensibilite.left.RYT,...
        sensibilite.ove.EDA,sensibilite.ove.EDArms,sensibilite.ove.HR,sensibilite.ove.HRV,sensibilite.ove.RYT,...
        sensibilite.sb.EDA,sensibilite.sb.EDArms,sensibilite.sb.HR,sensibilite.sb.HRV,sensibilite.sb.RYT,...
        sensibilite.left1.EDA,sensibilite.left1.EDArms,sensibilite.left1.HR,sensibilite.left1.HRV,sensibilite.left1.RYT,...
        sensibilite.ove1.EDA,sensibilite.ove1.EDArms,sensibilite.ove1.HR,sensibilite.ove1.HRV,sensibilite.ove1.RYT,...
        sensibilite.ped.EDA,sensibilite.ped.EDArms,sensibilite.ped.HR,sensibilite.ped.HRV,sensibilite.ped.RYT];
    
    % Filtrage des données NaN
    Beta = isfinite(MSP(suj,:));
    for q = 1 : length(MSP(suj,:))
        if Beta(q) == 0
            MSP(suj,q) = 0;
        end
        % Mise en pourcentage des données / Si erreur et > 100 x = 100;
        MSP(suj,q) = MSP(suj,q)*100;
        if MSP(suj,q) >= 100
            MSP(suj,q) = 100;
        end
    end
    
    
    % Matrice sensiblité comportemental (MSC)+ Filtrage des NaN
    MSC(suj,:)= [sensibilite.left.SDLP,sensibilite.left.SDS,sensibilite.left.RV,sensibilite.left.SDSW,sensibilite.left.RMSfrein,...
        sensibilite.ove.SDLP,sensibilite.ove.SDS,sensibilite.ove.RV,sensibilite.ove.SDSW,sensibilite.ove.RMSfrein,...
        sensibilite.sb.SDLP,sensibilite.sb.SDS,sensibilite.sb.RV,sensibilite.sb.SDSW,sensibilite.sb.RMSfrein,...
        sensibilite.left1.SDLP,sensibilite.left1.SDS,sensibilite.left1.RV,sensibilite.left1.SDSW,sensibilite.left1.RMSfrein,...
        sensibilite.ove1.SDLP,sensibilite.ove1.SDS,sensibilite.ove1.RV,sensibilite.ove1.SDSW,sensibilite.ove1.RMSfrein,...
        sensibilite.ped.SDLP,sensibilite.ped.SDS,sensibilite.ped.RV,sensibilite.ped.SDSW,sensibilite.ped.RMSfrein];
    
    Delta = isfinite(MSC(suj,:)); % Idem qu'en précision
    for r = 1 : length(MSC(suj,:))
        if Delta(r) == 0
            MSC(suj,r) = 0;
        end
        MSC(suj,r) = MSC(suj,r)*100;
        if MSC(suj,r) >= 100
            MSC(suj,r) = 100;
        end
    end
    
    
    % Matrice précision physiologique (MPP) + Filtrage des NaN
    MPP(suj,:)= [precision.left.EDA,precision.left.EDArms,precision.left.HR,precision.left.HRV,precision.left.RYT,...
        precision.ove.EDA,precision.ove.EDArms,precision.ove.HR,precision.ove.HRV,precision.ove.RYT,...
        precision.sb.EDA,precision.sb.EDArms,precision.sb.HR,precision.sb.HRV,precision.sb.RYT,...
        precision.left1.EDA,precision.left1.EDArms,precision.left1.HR,precision.left1.HRV,precision.left1.RYT,...
        precision.ove1.EDA,precision.ove1.EDArms,precision.ove1.HR,precision.ove1.HRV,precision.ove1.RYT,...
        precision.ped.EDA,precision.ped.EDArms,precision.ped.HR,precision.ped.HRV,precision.ped.RYT];
    Theta = isfinite(MPP(suj,:));
    for t = 1 : length(MPP(suj,:))
        if Theta(t) == 0
            MPP(suj,t) = 0;
        end
    end
    
    % Matrice précision comportemental (MPC)+ Filtrage des NaN
    MPC(suj,:)= [precision.left.SDLP,precision.left.SDS,precision.left.RV,precision.left.SDSW,precision.left.RMSfrein,...
        precision.ove.SDLP,precision.ove.SDS,precision.ove.RV,precision.ove.SDSW,precision.ove.RMSfrein,...
        precision.sb.SDLP,precision.sb.SDS,precision.sb.RV,precision.sb.SDSW,precision.sb.RMSfrein,...
        precision.left1.SDLP,precision.left1.SDS,precision.left1.RV,precision.left1.SDSW,precision.left1.RMSfrein,...
        precision.ove1.SDLP,precision.ove1.SDS,precision.ove1.RV,precision.ove1.SDSW,precision.ove1.RMSfrein,...
        precision.ped.SDLP,precision.ped.SDS,precision.ped.RV,precision.ped.SDSW,precision.ped.RMSfrein];
    Alpha = isfinite(MPC(suj,:));
    for p = 1 : length(MPC(suj,:))
        if Alpha(p) == 0
            MPC(suj,p) = 0;
        end
    end
    
end

% On enleve les sujets non retenus
MSP ([1:10 37 39 49],:)= [];

MSC ([1:10 37 39 49],:)= [];

MPP ([1:10 37 39 49],:)= [];

MPC ([1:10 37 39 49],:)= [];


close all


































%% Affichage plot Physio

%figure;hold on;plot(HR),plot(triggerphys,HR(triggerphys),'ro')
%figure, plot(EDA1,'r'), hold on, plot(EDAinterpol,'b'),plot(newtriggerphys,EDA1(newtriggerphys),'ko'),...
%legend('Short Scenario 1','Resting Session','Start/Finish Event'),title('Electrodermal Activity')...
%EDA1 = EDAinterpol disco1 // EDAinterpol = EDA interpol disco5

% FIGURE TOYOTA
%tps = (1 : length(EDA1)).*10;
% % % figure, plot(tps,((EDA1*100)+0.8*HRbaseline),'r'),hold on,plot(tps,HR1,'k'),plot(tps,((EDAbaseline*100)+0.8*HRbaseline),'r:','LineWidth',1.5),plot(tps,HRbaseline,'k:','LineWidth',1.5),...
% % % legend('Skin Conductance Level (SCL)','Heart Rate (HR)','SCR baseline','HR baseline','Location','northwest'),...
% % %
% % % for j = 1:length(triggerphys)
% % % line([triggerphys(j)*10 triggerphys(j)*10], ylim,'LineWidth',1.5)
% % % end
% % % xlabel('Time (s)');


%%  Figure des différents paramètres
% Figures Physiologiques




%% Figure complete 2 variables + seuil : Version 1
% tps = (1 : length(EDA1)).*10;
% tps2 = (1 : length(SDLP)).*10;
% figuremonitor(1), plot(tps,(EDA1*1000000000),'r'),hold on,plot(tps2,RMSfrein+20,'b'),...
%     plot(tps2,((((EDA1(1:end-1)*100000000).*RMSfrein))+40),'k'),...
%     legend('Skin Conductance Level (SCL)','Standard Deviation Speed (SDS)','Index of Confort (SDS x SCL)'),...
%     %ylim([0 50]),...
% for j = 1:length(triggerphys)
%     line([triggerphys(j)*10 triggerphys(j)*10], ylim,'LineWidth',1.5,'Color',[0 0 0])


% % %% Figure complete 2 variables + seuil : Version 2
% % tps = (1 : length(EDA1)).*10;
% % tps2 = (1 : length(SDLP)).*10;
% %
% % figure, plot(tps,(EDA1),'r','LineWidth',4),hold on,plot(tps2,RV1+1,'b','LineWidth',4),...
% %     plot(tps2,((((EDA1(1:end-1).*RV1))+2)),'k','LineWidth',4),...
% %     legend('Skin Conductance Level (SCL)','Wheel Reversal (RV)','Index of Confort (SCL x RV)'),...
% %     ylabel('Signal Value (Arbitrary Unit)'),xlabel('Time(seconds)')
% %     %ylim([0 50]),...
% % for j = 1:length(triggerphys)
% %     line([triggerphys(j)*10 triggerphys(j)*10], ylim,'LineWidth',1.0,'Color',[0 0 0])
% % end
% % Ajout des couleurs pour indiquer les zones de situations
% %     ShadePlotForEmpahsis([triggerphys(1)*10 triggerphys(2)*10],'black',{0.1,0.5,0.5}); % Situation 1
% %     ShadePlotForEmpahsis([triggerphys(3)*10 triggerphys(4)*10],'black',{0.1,0.5,0.5}); % Situation 2
% %     ShadePlotForEmpahsis([triggerphys(5)*10 triggerphys(6)*10],'black',{0.1,0.5,0.5}); % Situation 3
% %
% % % Rangement des combinaisons dans le tableau
