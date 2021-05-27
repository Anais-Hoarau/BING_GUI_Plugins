% Script explorant le dossier "Donnees_Brutes" pour en lister l'ensemble
% des fichiers

% Dossier source
source_folder = '\\vrlescot\THESE_GUILLAUME\VORTEX\Data\TESTS\~DONNEES_BRUTES';
% Dossier cible
target_folder = '\\vrlescot\THESE_GUILLAUME\VORTEX\Data\TESTS';

% Parametres
do_copy = false;
write_log = true;

% Listing des fichiers *.bdf
bdf_files = dir([source_folder '/**/*.bdf']);

% Listing des fichiers *.var
var_files = dir([source_folder '/**/*.var']);

% Listing des fichiers *.mat
mat_files = dir([source_folder '/**/*.mat']);

% Listing des fichiers *.acq
acq_files = dir([source_folder '/**/*.acq']);

% Initialisation du tableau
cell_file_list = cell(length(bdf_files)+length(var_files)+length(mat_files)+length(acq_files),5);

% 1:FolderName, 2:FileName, 3:LastModifiedDate, 4:FileSize, 5:DateNum (pour le tri)
for i = 1:length(bdf_files)
    cell_file_list{i,1} = [bdf_files(i).folder filesep];        % Separateur final utilise pour differencier \P1 de \P10 etc
    cell_file_list{i,2} = bdf_files(i).name;
    cell_file_list{i,3} = bdf_files(i).date;
    cell_file_list{i,4} = bdf_files(i).bytes;
    cell_file_list{i,5} = bdf_files(i).datenum;
end
for j = 1:length(var_files)
    cell_file_list{i+j,1} = [var_files(j).folder filesep];
    cell_file_list{i+j,2} = var_files(j).name;
    cell_file_list{i+j,3} = var_files(j).date;
    cell_file_list{i+j,4} = var_files(j).bytes;
    cell_file_list{i+j,5} = var_files(j).datenum;
end
for k = 1:length(mat_files)
    cell_file_list{i+j+k,1} = [mat_files(k).folder filesep];
    cell_file_list{i+j+k,2} = mat_files(k).name;
    cell_file_list{i+j+k,3} = mat_files(k).date;
    cell_file_list{i+j+k,4} = mat_files(k).bytes;
    cell_file_list{i+j+k,5} = mat_files(k).datenum;
end
for l = 1:length(acq_files)
    cell_file_list{i+j+k+l,1} = [acq_files(l).folder filesep];
    cell_file_list{i+j+k+l,2} = acq_files(l).name;
    cell_file_list{i+j+k+l,3} = acq_files(l).date;
    cell_file_list{i+j+k+l,4} = acq_files(l).bytes;
    cell_file_list{i+j+k+l,5} = acq_files(l).datenum;
end

% On retire les '.' du format date pour coller au format Excel (ex: oct pas oct.)
cell_file_list(:,3) = strrep(cell_file_list(:,3),'.','');

% On les trie par date
cell_file_list = sortrows(cell_file_list,5);

% Ajout d'une entete
entete = {'Chemin', 'Nom de fichier', 'Date de modification', 'Taille', 'DateNum'};

% % Creation du fichier CSV
writetable(cell2table([entete; cell_file_list]),'datafile_listing.csv','writevariablenames',0)

% Log des copier/coller
log_list = cell(length(cell_file_list), 4);
log_line = 0;

% Bouclage sur les participants
for p = 1:60
    participant_folder = [target_folder filesep 'P' num2str(p)];
    if ~exist(participant_folder, 'dir')
        mkdir(participant_folder);
    end
    
    
    % Gestion cas particuliers
    skip_participant = false;   % Si vrai on se contente de tout deplacer dans le dossier PXX
    manual_ordering = false;    % Si vrai on demandera l'ordre
    
    bdf_files = cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),'.bdf'),2);
    acq_files = cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),'.acq'),2);
    var_files = cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),'.var'),2);
    participant_files_sizes = cell2mat(cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]),4));
    
    % Verification du nombre de fichier presents (supposemment 12 scenarios + 1 BL pour .acq)
    % S'il manque un fichier scenario, on saute le participant
    % NB : Des fichiers .txt vides ont ete crees manuellement avec un
    % nom.ext coherent, et sont reconnaissables par leur taille nulle
    if length(bdf_files) < 12
        warning(['Missing *.bdf files for participant n.' num2str(p)])
        skip_participant = true;
    end
    if length(acq_files(~contains(acq_files,'BL'))) < 12
        warning(['Missing *.acq files for participant n.' num2str(p)])
        skip_participant = true;
    end
    if length(var_files) < 12
        warning(['Missing *.var files for participant n.' num2str(p)])
        skip_participant = true;
    end
    
    if skip_participant
        % On deplace l'ensemble des fichiers dans le repertoire PXX sans
        % changer les noms de fichiers
        skip_files_list = cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]),1:2);
        for e = 1:length(skip_files_list)
            log_line = log_line +1;
            log_list{log_line, 1} = skip_files_list{e,1};                   % Source FolderName
            log_list{log_line, 2} = skip_files_list{e,2};                  	% Source FileName
            log_list{log_line, 3} = [participant_folder filesep];           % Destination FolderName
            log_list{log_line, 4} = skip_files_list{e,2};                   % Destination FileName
            if do_copy
                copyfile([log_list{log_line, 1} log_list{log_line, 2}], [log_list{log_line, 3} log_list{log_line, 4}]);
            end
        end
        
        continue    % Participant suivant
    end
    
    
    % Si le nombre est bon, on verifie que l'ordre des scenarios est le
    % meme entre .acq et .bdf
    clear order_bdf
    for bdf = 1:length(bdf_files)
        tmp = regexp(bdf_files{bdf},'\.','split');
        order_bdf{bdf,1} = tmp{1};
    end
    clear order_acq
    for acq = 1:length(acq_files)
        tmp = regexp(acq_files{acq},'\.','split');
        order_acq{acq,1} = tmp{1};
    end
    if ~isequal(order_bdf(~contains(order_bdf,'BL')),order_acq(~contains(order_acq,'BL')))
        warning(['Different scenario order between *.acq and *.bdf for participant n.' num2str(p)])
        manual_ordering = true;
    end
    if ~isempty(find(participant_files_sizes==0,1))
        warning(['At least one empty file detected for participant n.' num2str(p)])
        manual_ordering = true;
    end
    
    % Identification de la correspondance "scenario.bdf" <=> "date.var"
    equiv_scenario_date = cell(12,3);
    equiv_scenario_date(:,1) = cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),'.bdf'),2);
    equiv_scenario_date(:,2) = cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),'.var'),2);
    if manual_ordering
        h = warndlg('Un probleme a ete constate necessitant de specifier manuellement le lien entre scenario (*.acq et *.bdf) et date de manip (*.var). La fenetre suivante vous demandera a quel scenario correspond chaque date.','!! Warning !!');
        uiwait(h)
        answer = inputdlg(equiv_scenario_date(:,2),'Pointage manuel',1,equiv_scenario_date(:,1));
        equiv_scenario_date(:,1) = answer;
    end
    
    
    % Baseline
    baseline_files_list = cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),'BL'),1:2);
    for q = 1:length(baseline_files_list)
        log_line = log_line +1;
        log_list{log_line, 1} = baseline_files_list{q,1};               % Source FolderName
        log_list{log_line, 2} = baseline_files_list{q,2};               % Source FileName
        tmp = regexp(baseline_files_list{q,2},'\.','split');
        scenario = tmp{1};
        file_ext = tmp{2};
        destination_folder = [participant_folder filesep scenario];
        log_list{log_line, 3} = [destination_folder filesep];           % Destination FolderName
        destination_filename = ['P' num2str(p) '_' scenario '.' file_ext];
        log_list{log_line, 4} = destination_filename;                   % Destination FileName

        if ~exist(destination_folder, 'dir')
            mkdir(destination_folder);
        end
        if do_copy
            copyfile([log_list{log_line, 1} log_list{log_line, 2}], [log_list{log_line, 3} log_list{log_line, 4}]);
        end
    end
    
    % Bouclage sur les scenarii
    for r = 1:length(equiv_scenario_date)
        tmp = regexp(equiv_scenario_date{r,1},'\.','split');
        scenario = tmp{1};
        tmp = regexp(equiv_scenario_date{r,2},'\.','split');
        date = tmp{1};
        destination_folder = [participant_folder filesep scenario];
        if ~exist(destination_folder, 'dir')
            mkdir(destination_folder);
        end
        
        scenario_files_list = cell_file_list(contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),[scenario '.']),1:2); % On cherche le point avec pour ne pas confondre N1 et N1b
        for s  = 1:length(scenario_files_list)
            log_line = log_line +1;
            log_list{log_line, 1} = scenario_files_list{s,1};               % Source FolderName
            log_list{log_line, 2} = scenario_files_list{s,2};               % Source FileName
            tmp = regexp(scenario_files_list{s,2},'\.','split');
            file_ext = tmp{2};
            log_list{log_line, 3} = [destination_folder filesep];           % Destination FolderName
            destination_filename = ['P' num2str(p) '_' scenario '_' date '.' file_ext];
            log_list{log_line, 4} = destination_filename;                   % Destination FileName
            if do_copy
                copyfile([log_list{log_line, 1} log_list{log_line, 2}], [log_list{log_line, 3} log_list{log_line, 4}]);
            end
        end
        
        % .var file
        log_line = log_line +1;
        log_list{log_line, 1} = cell_file_list{contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),date),1};               % Source FolderName
        log_list{log_line, 2} = cell_file_list{contains(cell_file_list(:,1),['P' num2str(p) filesep]) & contains(cell_file_list(:,2),date),2};               % Source FileName
        log_list{log_line, 3} = [destination_folder filesep];                                       % Destination FolderName
        destination_filename = ['P' num2str(p) '_' scenario '_' date '.var'];
        log_list{log_line, 4} = destination_filename;                                               % Destination FileName
        if do_copy
            copyfile([log_list{log_line, 1} log_list{log_line, 2}], [log_list{log_line, 3} log_list{log_line, 4}]);
        end
    end
end

if write_log
    entete = {'Src_FolderName', 'Src_FileName', 'Dest_FolderName', 'Dest_FileName'};
    writetable(cell2table([entete; log_list]),'log.csv','writevariablenames',0)
end
