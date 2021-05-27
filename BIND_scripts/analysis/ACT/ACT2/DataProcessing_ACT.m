% This scripts processes the data from the ACT experimentation
clc
%clear all
close all

%% REPERTOIRE DATA
REP = 'D:\LESCOT\PROJETS\2013- ACT2\DATA';
if  ~exist(fullfile(REP,'figs'),'dir')
    mkdir(REP,'figs');
end
REP_fig = fullfile(REP,'figs');

%% FICHIER EXCEL
nom_columns = {'Nom Sujet' 'Scenario' 'Systeme' 'Type Essai'  'ligne deb essai' ' ligne fin essai' ...
               'ligne relachement acc' 'timecode relachement acc (s)' 'TR_acc (ms)' ...
               'ligne appui frein' 'timecode appui frein (s)' 'TR_frein (ms)' ...
               'ligne relachement frein' 'timecode relachement frein (s)' 'TR_rela_frein (ms)' ...
               'vitesse deb essai (m/s)' 'vitesse appui frein (m/s)' 'distance frein age (m)' 'duree freinage (s)' 'TIV frein (s)' 'TTC_frein (s)' ...
               'deceleration1 (m/s^2)' 'deceleration2 (m/s^2)'...
               'vitesse moyenne hors virage (m/s)' 'vitesse moyenne hors virage (km/h)'};
xls_column = 1;
xls_ligne =1;
range=length(nom_columns);
xls_filename =(fullfile(REP,['ACT1_data_' date '.xlsx']));

% Creation de l'entête des données aggrégées 
xlswrite(xls_filename,nom_columns,xls_range(1,xls_ligne,range,1));
xls_ligne =xls_ligne + 1;

%% GROUPES
GROUPE = {'75-FA' '75-M' '90-FA' '90-M' 'NS'}; % A MODIFIER EN FONCTION DES GROUPES
N_groupe = length(GROUPE);

for i_groupe=1:1:1%N_groupe
    
    REP_groupe = fullfile(REP , GROUPE{i_groupe});
    listing = dir(REP_groupe);
    %% RECUPERATION DES REPERTOIRES A TRAITER : on garde les repertoires et on oublie '.' et '..'
    jj=1;
    for i_listing=1:1:length(listing)
        if listing(i_listing).isdir && ~(strcmp(listing(i_listing).name,'.') || strcmp(listing(i_listing).name,'..'))
            REP_sujet{jj} = fullfile(REP_groupe, listing(i_listing).name); %#ok
            jj=jj+1;
        end
    end
    
    %% DEBUT BOUCLE TRAITEMENT DES DONNEES
    N_sujet = length(REP_sujet);
    for i_sujet=1:1:1%N_sujet
        %% RECUPERATION DES FICHIER .var A TRAITER
        listing =  dir ([REP_sujet{i_sujet} '\*.var']);
        for i_listing =1:1:length(listing)
            FILE_var{i_listing} = fullfile(REP_sujet{i_sujet}, listing(i_listing).name);%#ok
        end
        
        %% TRAITEMENT DES FICHIER .var POUR LE SUJET
        N_var = length(FILE_var);
        for i_var =1:1:N_var
            
            %%IMPORT DU FICHIER VAR
            [temps,pk,vitesse,TIV,TTC,acc,frein,com1,com2] = import_var_ACT(FILE_var{i_var});          
            
            %% INFOS : sujet, scenario, systeme
            SYSTEME =  GROUPE{i_groupe};
            [~,NOM_SUJET,~] = fileparts(REP_sujet{i_sujet});
            SCENARIO = com1{1}(3:5);
            disp(['Processing group : ' SYSTEME  ' - participant : ' NOM_SUJET ' -  SCENARIO : ' SCENARIO])
            
            %% FORMATGE DU TIMECODE et FORMATAGE DES COMMENTAIRES 'debutEssai' 'FinEssai
            % cette fonction boucle sur l'ensemble des données
            [timecode,Scenario,Essai,Virage] = formatageTimecodeEssaiVirage(temps,com1);
            
            %% FILTRAGE DE LA VARIABLE ACC
            n_largeur =4;
            [acc_filt] = filtrage_acc(acc,n_largeur,true);
            
            %% CALCUL DES TEMPS DE REACTION PEDALE ACC
            
            ReactionTime_acc = CalculerReactionTime_acc(timecode,acc,Essai);
            %ReactionTime_acc = CalculerReactionTime_acc(timecode,acc_filt,Essai);
            ReactionTime_frein = CalculerReactionTime_frein(timecode,frein,Essai);
            
            %% TRACER DES GRAPHES
            Plot_ReactionTime_acc_frein(timecode,acc,acc_filt,frein,Essai,ReactionTime_acc,ReactionTime_frein,2,FILE_var{i_var},REP_fig,SCENARIO)
            
            %% TRAITEMENT DE TOUT CE QUI EST TEMPS DE FREINAGE A FAIRE
            
            [deceleration,vitesse_deb,vitesse_ini,distance_freinage,duree_freinage,TIV_frein,TTC_frein]=CalculerIndicateurFreinage(timecode,Essai,ReactionTime_frein,pk,vitesse,TIV,TTC);
            
            %% CALCUL DE LA VITESSE MOYENNE HORS COURBE (m/s) et (km/h)           
            mask_vitesse = ones(length(vitesse),1); 
                %On ne garde que le scenario entre le début de l'essai 1 et
                %la fin du dernier essai
            mask_vitesse(1:Scenario(1,3),1)=0;
            mask_vitesse(Scenario(end,4):end,1)=0;
                % On supprime les virages
            for i_Virage =1:1:size(Virage,1)
                mask_vitesse(Virage(i_Virage,4):Virage(i_Virage,5),1)=0;
            end
            mask_vitesse = logical(mask_vitesse);
            mean_vitesse_horsvirage = mean(vitesse(mask_vitesse));
            mean_vitesse_horsvirage_kmh = 3.6*mean_vitesse_horsvirage;
            %% LOG FICHIER ECXEL
            nbre_ligne = size(Essai,1);
            NOM_SUJET_cell=cell(size(Essai,1),1);
            SCENARIO_cell=cell(size(Essai,1),1);
            SYSTEM_cell=cell(size(Essai,1),1);
            mean_vitesse_cell=cell(size(Essai,1),1);
            mean_vitesse_kmh_cell=cell(size(Essai,1),1);
            for i_ligne=1:1:nbre_ligne
                NOM_SUJET_cell{i_ligne,1} = NOM_SUJET; 
                SCENARIO_cell{i_ligne,1} = SCENARIO; 
                SYSTEM_cell{i_ligne,1} = SYSTEME;
                mean_vitesse_cell{i_ligne,1} = mean_vitesse_horsvirage;
                mean_vitesse_kmh_cell{i_ligne,1} = mean_vitesse_horsvirage_kmh;
            end
            if ~isempty(Essai)
                data2write = [NOM_SUJET_cell SCENARIO_cell  SYSTEM_cell num2cell(Essai(:,3:5)) ...
                    num2cell(ReactionTime_acc) num2cell(ReactionTime_frein) ...
                    num2cell(vitesse_deb) num2cell(vitesse_ini) num2cell(distance_freinage) num2cell(duree_freinage) ...
                    num2cell(TIV_frein) num2cell(TTC_frein) num2cell(deceleration(:,1)) num2cell(deceleration(:,2))...
                    mean_vitesse_cell mean_vitesse_kmh_cell ...
                    ];
                
                xlswrite(xls_filename,data2write,xls_range(1,xls_ligne,range,nbre_ligne));
                xls_ligne = xls_ligne + nbre_ligne;
            end
        end 
    end  
end