% Script de traitement de données pour l'expériementation ACT 3
function ACT3_DATAPROCESSING_fab()
clear all

%% CREATION VARIABLES GLOBALES ET MAIN_FOLDER

global lim_voie_gauche
lim_voie_gauche  = 4400 ;

global lim_voie_droite
lim_voie_droite = 5800 ;

global centre_voie
centre_voie = (lim_voie_gauche + lim_voie_droite)/2;

close all

MAIN_FOLDER = 'E:\PROJETS ACTUELS\ACT\ACT3\Simulateur';

%% CREATION DU DOSSIER DES FIGURES

FIG_FOLDER = fullfile(MAIN_FOLDER,['figs_' date]);
if ~exist(FIG_FOLDER, 'dir')
    mkdir(FIG_FOLDER)
    mkdir([FIG_FOLDER filesep 'matlab_figs'])
end

%% STRUCTURATION ET CREATION DU FICHIER EXCEL

xls_filename = fullfile(MAIN_FOLDER,['ACT3_LOG_' date '_en_cours.xlsx']);

nom_columns_TR = {'Groupe' 'Nom Sujet' 'Scenario' 'Essai SV' 't_changement cap (s)' 't_deb (s)' 't_fin' 'TR (s)' 'Delta AngleVolant (°)'};
nom_columns_SV = {'Groupe' 'Nom Sujet' 'Scenario' 'Essai SV' 't_deb (s)' 't_fin (s)' 'duree (s)' 'surface (m²)' 'pic ang_vol (°/s²)' 'écart_max (m)' 'retour>centre_voie' 't_deb_dt (s)' 't_fin_dt (s)' 'duree_dt (s)'};
nom_columns_id = {'Groupe' 'Nom Sujet' 'Scenario' 'ecart surface (m²)' 'nb sorties tot' 'nb sorties hors DT' 'durée sorties tot (s)' 'durée sorties moy (s)'};

xls_column = 1;
xls_ligne = 1;
xls_ligne_var = 1;

range_TR = length(nom_columns_TR);
range_SV = length(nom_columns_SV);
range_ID = length(nom_columns_id);

% Ecriture de l'entête des données aggrégées
xlswrite(xls_filename,nom_columns_TR,'TR',xls_range(xls_column,xls_ligne,range_TR,1));
xlswrite(xls_filename,nom_columns_SV,'SV',xls_range(xls_column,xls_ligne,range_SV,1));
xlswrite(xls_filename,nom_columns_id,'ID_var',xls_range(xls_column,xls_ligne,range_ID,1));

xls_ligne = xls_ligne + 1;
xls_ligne_var = xls_ligne_var + 1;

%% LISTAGE ET BOUCLAGE DES FICHIERS VAR

list_var = dirrec(MAIN_FOLDER,'.var');
%list_var ={'E:\PROJETS ACTUELS\ACT\ACT3\Simulateur\Groupe2 (83%)\S22\03030944_S22_G2_S1P.var'};

for i_var = 1:1:length(list_var)
    %% Import des fichiers VAR
    tic
    data = import_var_ACT3(list_var{i_var});
    display(['file imported in ' num2str(toc) ' s']);
    
    mask_commentaires = ~cellfun('isempty',data.commentaires);
    data.timecode = cellfun(@formatageTempsSimulateurLepsis,data.temps);
    indice = 1:1:length(data.timecode);
    data.commentaires = [num2cell(indice(mask_commentaires))' num2cell(data.timecode(mask_commentaires)) data.commentaires(mask_commentaires)];
    
    [folder,Nom_var,~] = fileparts(list_var{i_var});
    temp = strsplit(folder,'\');
    Nom_sujet = temp{end};
    Group_sujet = temp{end-1};
    
    if strcmp(data.scenario, 'Scenario0')
        display('Skipping Scenario0 ...')
        continue
    end
    
    if ~strcmp(data.scenario(9:end), Nom_var(18:end))
        error(['Scenario number "' data.scenario '" is not matching with filename "' Nom_var(17:end) '", ' sprintf('\n') 'please verify it...'])
    else
        display(['Processing : '  Group_sujet ' - ' Nom_sujet ' - ' Nom_var ' - ' data.scenario ' ...'])
    end
    
    %% Calcul des indicateurs par Essai
    
    i_SV=0;
    for i_dt=1:1:length(data.commentaires)
        if ~isempty(strfind(data.commentaires{i_dt,3},'__SV'))
            commentaire_SV = data.commentaires{i_dt,3};
            commentaire_SV = commentaire_SV(3:end);
            
            i_SV = i_SV +1;
            data.commentaire_SV{i_SV,1} = data.commentaires{i_dt,1};
            data.commentaire_SV{i_SV,2} = data.commentaires{i_dt,2};
            data.commentaire_SV{i_SV,3} = data.commentaires{i_dt,3};
            
            for i_fin=i_dt:1:length(data.commentaires)
                if ~isempty(strfind(data.commentaires{i_fin,3},'__FIN_SORTIE_VOIE'))
                    id = (data.commentaires{i_dt,1} : data.commentaires{i_fin,1} + 5*60); % +5sec de visu à la fin de l'essai (5s x 60Hz)
                    break
                end
            end
            
            mask_essai = zeros(1,length(data.timecode));
            mask_essai(id) =1;
            mask_essai = logical(mask_essai);
            
            data.essai.mask = mask_essai;
            data.essai.timecode = data.timecode(mask_essai);
            data.essai.voie = data.vp.voie(mask_essai);
            data.essai.pk = data.vp.pk(mask_essai);
            data.essai.angleVolant = data.vp.angleVolant(mask_essai);
            State_SV = true;
            
            %% CALCUL indicateurs
            [data, SV, indicateurs, message] = calculerIndicateur(data, mask_essai);
            
            %% VISUALISATION
            %             try
            %                 visualisation_ACT3(data, SV, indicateurs, message)
            %             catch
            %                 close all
            %             end
            %visualisation_ACT3(data, SV, indicateurs, message)
            
            %% log excel file
            
            % nom_columns_TR = {'Groupe' 'Nom Sujet' 'Scenario' 'Essai SV' 't_changement cap (s)' 't_deb (s)' 't_fin' 'TR (s)' 'Delta AngleVolant (°)'}
            TR_data = {Group_sujet, Nom_sujet, data.scenario, commentaire_SV,...
                indicateurs.TR.capChange, indicateurs.TR.t_debut, indicateurs.TR.t_fin, indicateurs.TR.duree, indicateurs.SV.deltaAV};
            
            % nom_columns_SV = {'Groupe' 'Nom Sujet' 'Scenario' 't_deb (s)' 't_fin (s)' 'duree (s)' 'surface (m²)' 'pic ang_vol (°/s²)' 'écart_max (m)' 'retour>centre_voie' 't_deb_dt (s)' 't_fin_dt (s)' 'duree_dt (s)'};
            SV_data = {Group_sujet, Nom_sujet, data.scenario, commentaire_SV, ...
                indicateurs.SV.t_debut, indicateurs.SV.t_fin, indicateurs.SV.duree, indicateurs.SV.surface, indicateurs.SV.pic_angleVolant, indicateurs.SV.ecartMax/1000, SV.retour_state, data.essai.timecode(1), data.SV.timecode(1), (data.SV.timecode(1)-data.essai.timecode(1))};
            
            xlswrite(xls_filename,TR_data,'TR',xls_range(xls_column,xls_ligne,range_TR,1));
            xlswrite(xls_filename,SV_data,'SV',xls_range(xls_column,xls_ligne,range_SV,1));
            
            xls_ligne = xls_ligne + 1;
            
            clear indicateur SV
        end
    end
    
    %% Calcul des indicateurs globaux
    
    mask_hors_DT = logical(ones(1,length(data.timecode)));%#ok
    mask_hors_DT( data.timecode < data.commentaire_SV{1,2} + 15 ) = 0; % 15 s après le début de double tache
    
    for i_comSV = 2:1:size(data.commentaire_SV,1)
        mask_hors_DT( data.timecode > data.commentaire_SV{i_comSV,2} & data.timecode < data.commentaire_SV{i_comSV,2}+15 ) = 0;
    end
    d_x=[0 ; diff(data.vp.pk(mask_hors_DT))]/1000;
    d_x(d_x>1)= mean(d_x(d_x<1));
    
    pk_hors_DT = zeros(length(d_x),1);
    pk_hors_DT(1) = d_x(1);
    for ii=2:1:length(d_x)
        pk_hors_DT(ii) = pk_hors_DT(ii-1) + d_x(ii);
    end
    data.id_globaux.surface = trapz(pk_hors_DT, abs(data.vp.voie(mask_hors_DT)/1000 - 5.100)); % centre de la voie 5100 mm
    
    % nb sorties tot
    mask_SV_tot = data.vp.voie <= lim_voie_gauche | data.vp.voie >= lim_voie_droite;
    data.id_globaux.nbSortiesTot = floor((nnz(diff(mask_SV_tot))-1)/2);
    
    % nb sorties hors DT
    data_out.hors_DT.voie = data.vp.voie(mask_hors_DT);
    data_out.hors_DT.timecode = data.timecode(mask_hors_DT);
    mask_SV_hors_DT = data_out.hors_DT.voie <= lim_voie_gauche | data_out.hors_DT.voie >= lim_voie_droite;
    data.id_globaux.nbSortiesHorsDT = floor(nnz(diff(mask_SV_hors_DT))/2);
    
    % Durée sorties hors DT total
    data.id_globaux.DureeSortiesHorsDT = 0;
    if data.id_globaux.nbSortiesHorsDT ~= 0
        data_out.hors_DT.SV = data_out.hors_DT.voie(mask_SV_hors_DT);
        data_out.hors_DT.SV.timecode = data_out.hors_DT.timecode(mask_SV_hors_DT);
        for i_SVhDT = 1:(length(data_out.hors_DT.SV.timecode)-1)
            if data_out.hors_DT.SV.timecode(i_SVhDT+1)-data_out.hors_DT.SV.timecode(i_SVhDT) < 0.03
                data.id_globaux.DureeSortiesHorsDT = (data.id_globaux.DureeSortiesHorsDT + (data_out.hors_DT.SV.timecode(i_SVhDT+1)-data_out.hors_DT.SV.timecode(i_SVhDT)));
            end
        end
    end
    
    % Durée sorties hors DT moyenne
    data.id_globaux.DureeSortiesHorsDTmoy = 0;
    if data.id_globaux.nbSortiesHorsDT ~= 0
        data.id_globaux.DureeSortiesHorsDTmoy = data.id_globaux.DureeSortiesHorsDT/data.id_globaux.nbSortiesHorsDT;
    end
    
    %nom_columns_id = {'Groupe' 'Nom Sujet' 'Scenario' 'ecart surface (m²)' 'nb sorties tot' 'nb sorties hors DT' 'durée sorties tot (s)' 'durée sorties moy (s)'};
    ID_data = {Group_sujet, Nom_sujet, data.scenario, data.id_globaux.surface, data.id_globaux.nbSortiesTot, data.id_globaux.nbSortiesHorsDT, data.id_globaux.DureeSortiesHorsDT, data.id_globaux.DureeSortiesHorsDTmoy};
    
    % log excel id globaux
    xlswrite(xls_filename,ID_data,'ID_var',xls_range(xls_column,xls_ligne_var,range_ID,1));
    xls_ligne_var = xls_ligne_var + 1;
    
    % redimensionnement automatique des colonnes
    xlsAutoFitCol(xls_filename,'TR','A:P');
    xlsAutoFitCol(xls_filename,'SV','A:P');
    xlsAutoFitCol(xls_filename,'ID_var','A:P');
    
    %% FERMETURE DES PROCESSUS EXCELL POUR EVITER LES ERREURS
    
    [~, computer] = system('hostname');
    
    [~, user] = system('whoami');
    
    [~, alltask] = system(['tasklist /S ', computer, ' /U ', user]);
    
    excelPID = regexp(alltask, 'EXCEL.EXE\s*(\d+)\s', 'tokens');
    
    for i_excel = 1 : length(excelPID)
        
        killPID = cell2mat(excelPID{i_excel});
        
        system(['taskkill /f /pid ', killPID]);
    end
    
end

%% SUBFUNCTION CALCUL INDICATEURS

    function [data_out, SV, indicateurs, message, mask_SV] = calculerIndicateur(data, mask_essai)
        data_out = data;
        
        mask_SV = data_out.essai.voie <= lim_voie_gauche | data_out.essai.voie >= lim_voie_droite;
        
        if State_SV ~= false
            if  nnz(diff(mask_SV)) > 2
                id_SV_essai = find(diff(mask_SV));
                [indicateurs.essai.max, id_max] = max(abs(data_out.essai.voie-centre_voie));
                for i=1:1:length(id_SV_essai)-1
                    if round(data_out.essai.timecode(id_SV_essai(i))) == round(data.commentaires{i_dt+1,2})
                        mask_SV(1:id_SV_essai(i))=0;
                        mask_SV(id_SV_essai(i+1):end)=0;
                        break
                    elseif id_max>id_SV_essai(i) && id_max<id_SV_essai(i+1)
                        mask_SV(1:id_SV_essai(i))=0;
                        mask_SV(id_SV_essai(i+1):end)=0;
                        break
                    end
                end
                SV.state = true;
            elseif nnz(mask_SV)==0;
                SV.state = false;
                mask_SV = mask_essai;
            else
                SV.state = true;
            end
        else
            SV.state = false;
            mask_SV = mask_essai;
        end
        
        % Durée de sortie de voie
        if SV.state
            data_out.SV.mask = mask_SV;
            data_out.SV.timecode = data_out.essai.timecode(mask_SV);
            data_out.SV.voie = data_out.essai.voie(mask_SV);
            data_out.SV.pk = data_out.essai.pk(mask_SV);
            data_out.SV.angleVolant = data_out.essai.angleVolant(mask_SV);
            
            indicateurs.SV.t_debut = data_out.SV.timecode(1);
            indicateurs.SV.t_fin = data_out.SV.timecode(end);
            indicateurs.SV.duree = indicateurs.SV.t_fin - indicateurs.SV.t_debut;
            message.temps_SV = ['Temps sortie' sprintf('\n') 'de voie : ' num2str(indicateurs.SV.duree) ' s'];
            
            % Alternative surface
            message.decalage_textSV = 400;
            if mean(data_out.SV.voie) > lim_voie_droite
                SV.type='droite';
                indicateurs.SV.surface = trapz(data_out.SV.pk/1000,(data_out.SV.voie - lim_voie_droite)/1000); % limite voie droite :7
                message.decalage_textSV =-message.decalage_textSV;
            elseif mean(data_out.SV.voie) < lim_voie_gauche
                SV.type='gauche';
                indicateurs.SV.surface = trapz(data_out.SV.pk/1000,abs((data_out.SV.voie - lim_voie_gauche))/1000);
            end
            message.aire_SV = ['Surface sortie' sprintf('\n') 'de voie : ' num2str(indicateurs.SV.surface) ' m^2'];
            
        else
            data_out.SV.mask = mask_essai;
            data_out.SV.timecode = nan;
            data_out.SV.voie = nan;
            data_out.SV.pk = nan;
            data_out.SV.angleVolant = nan;
            
            indicateurs.SV.t_debut = t_finTache;
            indicateurs.SV.t_fin = nan;
            indicateurs.SV.duree = nan;
            indicateurs.SV.surface = nan;
            
            message.decalage_textSV = 100;
            message.temps_SV = 'Pas de sortie de voie';
            message.aire_SV = 'Pas de sortie de voie';
        end
        
        % Pic d'angle au volant (derivée seconde)
        n_largeur = 4;
        square = ones(n_largeur,1)/n_largeur;
        
        dt = diff(data_out.essai.timecode);
        
        d_angleVolant = diff(data_out.essai.angleVolant)./ dt;
        data_out.essai.d_angleVolant = conv(d_angleVolant,square,'same');
        
        dd_angleVolant = diff(data_out.essai.d_angleVolant)./ dt(1:end-1);
        data_out.essai.dd_angleVolant = conv(dd_angleVolant,square,'same');
        
        ddd_angleVolant = diff(data_out.essai.dd_angleVolant)./ dt(1:end-2);
        data_out.essai.ddd_angleVolant = conv(ddd_angleVolant,square,'same');
        
        if SV.state
            [~,id_maxSV]=max(abs(data_out.SV.voie-data_out.SV.voie(1)));
            mask_TR = mask_SV;
            mask_TR(find(mask_SV, 1, 'first')+id_maxSV:end)=0;
            data_out.TR.mask = mask_TR;
            data_out.TR.timecode = data_out.essai.timecode(mask_TR);
            data_out.TR.d_angleVolant = data_out.essai.d_angleVolant(mask_TR);
            data_out.TR.dd_angleVolant = data_out.essai.dd_angleVolant(mask_TR);
            data_out.TR.ddd_angleVolant = data_out.essai.ddd_angleVolant(mask_TR);
            
            [pic_max,id_pic]=find_TR_Pic(data_out,SV);
            
            indicateurs.SV.pic_angleVolant = pic_max;
        else
            indicateurs.SV.pic_angleVolant = nan;
        end
        
        % Temps de reaction
        if SV.state
            indicateurs.TR.capChange = data_out.essai.timecode(1)+3;
            indicateurs.TR.t_debut = indicateurs.SV.t_debut;
            if ~isnan(id_pic)
                indicateurs.TR.t_fin = data_out.TR.timecode(id_pic);
                indicateurs.TR.duree = indicateurs.TR.t_fin - indicateurs.TR.t_debut;
            else
                indicateurs.TR.t_fin = nan;
                indicateurs.TR.duree = nan;
            end
        else
            indicateurs.TR.capChange = nan;
            indicateurs.TR.t_debut = nan;
            indicateurs.TR.t_fin = nan;
            indicateurs.TR.duree = nan;
        end
        
        % Delta Angle au volant
        if SV.state
            mask_afterCapChange = data_out.essai.timecode > indicateurs.TR.capChange;
            angleVolant_afterCapChange = data_out.essai.angleVolant(mask_afterCapChange);
            detla_mask = mask_afterCapChange & mask_SV;
            [indicateurs.SV.deltaAV, id_deltaAV] = max(abs(data_out.essai.angleVolant(detla_mask) - angleVolant_afterCapChange(1)));
            delta_timecode = data_out.essai.timecode(detla_mask);
            indicateurs.SV.deltaAV_time = delta_timecode(id_deltaAV);
            clear mask_afterCapChange angleVolant_afterCapChange detla_mask delta_timecode
        else
            indicateurs.SV.deltaAV = nan;
            indicateurs.SV.deltaAV_time = nan;
        end
        
        % Ecart maximal de sortie de voie
        if SV.state
            [indicateurs.SV.ecartMax, id_max] = max(abs(-centre_voie+data_out.SV.voie));
            indicateurs.SV.t_ecartMax = data_out.SV.timecode(id_max);
            message.ecartMax_SV = ['Ecart maximal' sprintf('\n') 'sortie de voie : ' num2str(indicateurs.SV.ecartMax/1000) ' m'];
            
            % Retour au-delà du centre après sortie de voie (oui/non?)
            indicateurs.SV.t_fin5sec = indicateurs.SV.t_fin + 5.0;
            mask_apSV = data_out.essai.timecode >= indicateurs.SV.t_fin & data_out.essai.timecode <= indicateurs.SV.t_fin5sec;
            data_out.SV.retour = data_out.essai.voie(mask_apSV);
            data_out.SV.timecode_retour = data_out.essai.timecode(mask_apSV);
            
            %figure
            %plot(data_out.SV.timecode_retour,data_out.SV.retour, data_out.SV.timecode_retour , centre_voie* ones(1,length(data_out.SV.timecode_retour)))
            switch SV.type
                case 'droite'
                    data_test_retour = data_out.SV.retour - centre_voie;
                case 'gauche'
                    data_test_retour = centre_voie - data_out.SV.retour;
            end
            if any(data_test_retour<0)
                SV.retour_state = true;
                id_premierRetour = find(data_test_retour<0,1,'first');
                
                indicateurs.SV.t_premierRetour = data_out.SV.timecode_retour(id_premierRetour);
                message.retour_SV = ['Retour avec dépassement' sprintf('\n') 'du centre de la voie : Oui'];
            else
                SV.retour_state = false;
                message.retour_SV = ['Retour avec dépassement' sprintf('\n') 'du centre de la voie : Non'];
            end
        else
            indicateurs.SV.ecartMax = nan;
            indicateurs.SV.t_ecartMax = nan;
            SV.retour_state = false;
        end
    end

%% SUBFUNCTIONS FIND_TR_PIC

    function [pic_max,id_pic]=find_TR_Pic(data,SV)
        dAV = data.TR.d_angleVolant;
        ddAV = data.TR.dd_angleVolant;
        dddAV = data.TR.ddd_angleVolant;
        
        i_zeros=0;
        for i=4:1:length(dddAV)-3
            if dddAV(i)*dddAV(i+1) < 0
                i_zeros=i_zeros+1;
                [extrema.max(i_zeros),~] = max(abs(ddAV(i-3:i+3)));
                extrema.id(i_zeros) = i+1;
                if dAV(i+1)>=0
                    extrema.sign(i_zeros) =1;
                else
                    extrema.sign(i_zeros) =-1;
                end
            end
        end
        
        switch SV.type
            case 'droite'
                mask_sign = (extrema.sign==1);
                extrema.id = extrema.id(mask_sign);
                extrema.max = extrema.max(mask_sign);
                extrema.sign = extrema.sign(mask_sign);
            case 'gauche'
                mask_sign = (extrema.sign==-1);
                extrema.id = extrema.id(mask_sign);
                extrema.max = extrema.max(mask_sign);
                extrema.sign = extrema.sign(mask_sign);
        end
        
        seuil = 250;
        mask_seuil = extrema.max>seuil;
        while nnz(mask_seuil)==0 && seuil>0
            mask_seuil = extrema.max>seuil;
            seuil = seuil - 50;
        end
        
        extrema.sign = extrema.sign(mask_seuil);
        extrema.id = extrema.id(mask_seuil);
        extrema.max = extrema.max(mask_seuil);
        
        if isempty(extrema.id)
            id_pic = nan;
            pic_max = nan;
        else
            id_pic = extrema.id(1);
            pic_max = extrema.max(1);
        end
    end

%% SUBFUNCTION VISUALISATION

    function visualisation_ACT3(data, SV, indicateurs, message)
        h1=figure('units','pixel','outerposition',get(0,'ScreenSize'));
        subplot(2,1,1);
        
        time = data.essai.timecode;
        pk = data.essai.pk/1000;
        left_side = lim_voie_gauche-2000;
        right_side = lim_voie_droite+2000;
        hold on
        
        % Plot #1 : Position sur la voie
        h_title = title([data.scenario ' : ' commentaire_SV ],'Interpreter','none');
        
        plot(pk,lim_voie_gauche*ones(length(time)),'k--','LineWidth',2)
        plot(pk,lim_voie_droite*ones(length(time)),'k--','LineWidth',2)
        plot(pk,centre_voie*ones(length(time)),'Linestyle','--','LineWidth',2,'Color',[0 0.498 0])
        ax1 =gca;
        set(ax1,'XLim',[min(pk) max(pk)], 'Xtick', floor(linspace(min(pk),max(pk),10)),'XAxisLocation','bottom');
        set(ax1,'YLim',[left_side right_side], 'Ytick', left_side:1000:right_side);
        
        ax2 = axes('Position',get(ax1,'Position'),'XAxisLocation','top','Color','none','XColor','k','YColor','k');
        line(time,data.vp.voie(id),'Parent',ax2)
        ylabel('Position sur la voie')
        set(ax2,'XLim',[min(time) max(time)], 'Xtick', floor(linspace(min(time),max(time),10)*10)/10,'XAxisLocation','top');
        set(ax2,'YLim',[left_side right_side], 'Ytick', left_side:1000:right_side);
        
        Pos =get(h_title,'Position');
        set(h_title,'Position',Pos(1:2)+[0 700])
        
        if SV.state
            %h_fill = fill(data.timecode(id_SV),data.vp.voie(id_SV),'b');
            %hatchfill(h_fill);
            vline(indicateurs.SV.t_debut,'r--','')
            vline(indicateurs.SV.t_ecartMax,'b--','')
            vline(indicateurs.SV.t_fin,'r--','')
            
            text(data.SV.timecode(1)+0.2, 6400, message.temps_SV, 'Fontsize', 9 ,'Color','r')
            text(indicateurs.SV.t_ecartMax+0.2, 7400, message.ecartMax_SV, 'Fontsize', 9 ,'Color','b')
            
            if SV.retour_state
                vline(indicateurs.SV.t_premierRetour,'k--','')
                text(indicateurs.SV.t_premierRetour+0.2, 6400, message.retour_SV, 'Fontsize', 9,'Color', [0 0.498 0])
            else
                text(data.SV.timecode(end)+0.2, 6400, message.retour_SV, 'Fontsize', 9 ,'Color', [0 0.498 0])
            end
        end
        text(data.SV.timecode(1)+0.2 , data.SV.voie(1)+ message.decalage_textSV, message.aire_SV, 'Fontsize', 9)
        hold off
        
        % Plot #2 : Angle au volant et Dérivé
        subplot(2,1,2);
        
        [AX,~,~] = plotyy(data.essai.timecode, data.essai.angleVolant,data.essai.timecode(1:end-2),data.essai.dd_angleVolant);
        set(AX(1),'Units','pixels','XLim',[min(time) max(time)], 'Xtick', floor(linspace(min(time),max(time),10)*10)/10,'XAxisLocation','bottom','box','off');
        Pos = get(AX(1),'Position');
        yWidth =100;
        xOffset = yWidth*(max(time)-min(time))/Pos(3);
        
        set(AX(2),'Units','pixels','Position',Pos,'XLim',[min(time) max(time)],'Color','none', 'Xtick',[],'XtickLabel',[],'YAxisLocation','right','box','off');
        AX(3)=axes;
        plot(AX(3),data.essai.timecode(1:end-1),data.essai.d_angleVolant,'Color','r');
        set(AX(3),'Units','pixels','Position',Pos + yWidth*[0 0 1 0],'Units','pixels','XLim',[min(time) max(time)+xOffset],...
            'Color','none', 'Xtick',[],'XtickLabel',[],'YAxisLocation','right','YColor','red','box','off');
        
        ylim(AX(1),[-max(abs(ylim(AX(1)))) max(abs(ylim(AX(1))))])
        ylim(AX(2),[-max(abs(ylim(AX(2)))) max(abs(ylim(AX(2))))])
        ylim(AX(3),[-max(abs(ylim(AX(3)))) max(abs(ylim(AX(3))))])
        
        ylabel(AX(1),'Angle au volant')
        h_yy = ylabel(AX(2),'Dérivée 2^{nd}  Angle Volant');
        Pos_label = get(h_yy,'Position');
        set(h_yy,'Position', [Pos_label(1)-0.15 Pos_label(2)])
        h_yyy = ylabel(AX(3),'Dérivée 1^{ere} Angle Volant');
        Pos_label = get(h_yyy,'Position');
        set(h_yyy,'Position', [Pos_label(1)-0.2 Pos_label(2)])
        
        vline(indicateurs.TR.capChange,'k--',['Changement' sprintf('\n') 'du cap'],0,0.2)
        vline(indicateurs.SV.t_debut,'k--',['Fin' sprintf('\n') 'double tache'])
        vline(indicateurs.TR.t_fin,'r--',['TR = ' num2str(indicateurs.TR.duree) ' s'])
        vline(indicateurs.SV.deltaAV_time,'b--',['DeltaAV = ' num2str(indicateurs.SV.deltaAV) ' °'],0,0.2)
        
        text(indicateurs.TR.t_fin + 0.2 , max(data.essai.angleVolant)*1.1, ['max derivée :' num2str(indicateurs.SV.pic_angleVolant) ' °/s^2' ] ,...
            'Fontsize', 9,'Color',[0 0.498 0])
        
        set(AX(1),'Units','normalized')
        set(AX(2),'Units','normalized')
        set(AX(3),'Units','normalized')
        
        hold off
        %set(h1,'Visible','on')
        print(h1,[FIG_FOLDER filesep Nom_var '_' data.scenario '_' commentaire_SV '.jpeg'],'-djpeg','-r400')
        
        if isnan(indicateurs.SV.surface) || isnan(indicateurs.SV.duree) || isnan(indicateurs.TR.duree) || isnan(indicateurs.SV.pic_angleVolant)
            h2=figure('units','pixel','outerposition',get(0,'ScreenSize'));
            [AX,~,~] = plotyy(data.essai.timecode, data.essai.angleVolant,data.essai.timecode(1:end-2),data.essai.dd_angleVolant);
            vline(indicateurs.SV.t_debut,'r--','deb SV')
            vline(indicateurs.SV.t_fin,'r--','fin SV')
            vline(indicateurs.TR.capChange,'k--',['Changement' sprintf('\n') 'du cap'],0,0.2)
            vline(indicateurs.TR.t_fin,'r--',['TR = ' num2str(indicateurs.TR.duree) ' s'])
            legend('angle au volant')
            linkaxes(AX,'x')
            hgsave(h1,[FIG_FOLDER filesep 'matlab_figs' filesep Nom_var '_' data.scenario '_' commentaire_SV '_1.fig'])
            hgsave(h2,[FIG_FOLDER filesep 'matlab_figs' filesep Nom_var '_' data.scenario '_' commentaire_SV '_2.fig'])
            delete(h2)
        end
        
        delete(h1)
    end
end
