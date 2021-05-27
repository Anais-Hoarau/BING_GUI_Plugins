%% xls_merge

clear all;
MAIN_FOLDER = 'E:\PROJETS ACTUELS\ACT\ACT4\Simulateur';
list_xls = dirrec([MAIN_FOLDER '\Fusion fichiers xls'],'.xlsx');

%% STRUCTURE FICHIER EXCEL

xls_filename =(fullfile(MAIN_FOLDER,['ACT3_LOG_' date '.xlsx']));

nom_columns_TR = {'Groupe' 'Nom Sujet' 'Scenario' 'Essai SV' 't_changement cap (s)' 't_deb (s)' 't_fin' 'TR (s)' 'Delta AngleVolant (°)'};
nom_columns_SV = {'Groupe' 'Nom Sujet' 'Scenario' 'Essai SV' 't_deb (s)' 't_fin (s)' 'duree (s)' 'surface (m²)' 'pic ang_vol (°/s²)' 'écart_max (m)' 'retour>centre_voie' 't_deb_dt (s)' 't_fin_dt (s)' 'duree_dt (s)'};
nom_columns_id = {'Groupe' 'Nom Sujet' 'Scenario' 'ecart surface (m²)'};

range_TR = length(nom_columns_TR);
range_SV = length(nom_columns_SV);
range_ID = length(nom_columns_id);

%% FUSION DES TABLEAUX

DATAS_TR_Cat = {};
DATAS_SV_Cat = {};
DATAS_IDvar_Cat = {};

for i=1:length(list_xls)
    [~, ~, DATAS_TR] = xlsread(list_xls{i},'TR',xls_range(1,2,range_TR,length(xlsread(list_xls{i},'TR'))));
    DATAS_TR(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),DATAS_TR)) = {''};
    DATAS_TR_Cat = cat(1, DATAS_TR_Cat, DATAS_TR);
    
    [~, ~, DATAS_SV] = xlsread(list_xls{i},'SV',xls_range(1,2,range_SV,length(xlsread(list_xls{i},'SV'))));
    DATAS_SV(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),DATAS_SV)) = {''};
    DATAS_SV_Cat = cat(1, DATAS_SV_Cat, DATAS_SV);
    
    [~, ~, DATAS_IDvar] = xlsread(list_xls{i},'ID_var',xls_range(1,2,range_ID,length(xlsread(list_xls{i},'ID_var'))));
    DATAS_IDvar(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),DATAS_IDvar)) = {''};
    DATAS_IDvar_Cat = cat(1, DATAS_IDvar_Cat, DATAS_IDvar);
end

%% ECRITURE DES DONNEES

xlswrite(xls_filename, nom_columns_TR, 'TR', xls_range(1,1,range_TR,1));
xlswrite(xls_filename, DATAS_TR_Cat, 'TR', xls_range(1,2,range_TR,length(DATAS_TR_Cat)));
xlsAutoFitCol(xls_filename,'TR','A:P');

xlswrite(xls_filename,nom_columns_SV,'SV',xls_range(1,1,range_SV,1));
xlswrite(xls_filename, DATAS_SV_Cat, 'SV', xls_range(1,2,range_SV,length(DATAS_SV_Cat)));
xlsAutoFitCol(xls_filename,'SV','A:P');

xlswrite(xls_filename,nom_columns_id,'ID_var',xls_range(1,1,range_ID,1));
xlswrite(xls_filename, DATAS_IDvar_Cat, 'ID_var', xls_range(1,2,range_ID,length(DATAS_IDvar_Cat)));
xlsAutoFitCol(xls_filename,'ID_var','A:P');

clear all;