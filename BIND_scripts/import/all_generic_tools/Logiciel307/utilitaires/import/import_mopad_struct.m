%% import_mopad_struct
% This function loads Mopad files (.txt files and config.ini file recorded
% with Mopad v3+), parse the variables to construct a Matlab structure that
% can be shared with other people. The structure has been defined in the
% Safemove project. It can be reused in any project.
% 
% Remarks: This function does not calculate any synchronisation. It only
% converts the data into a Matlab strcture.
%
% input argument:
% full_directory:  location of the folder containing MOPAD (v3+) files
%                  (config.ini + associated .txt files)
%
% output argument:
% mopad:           a structure containing the relevant Mopad data.

function mopad = import_mopad_struct(full_directory)

    mopad = struct;
    
    [ ~, name, ~] =  fileparts(full_directory);

    meta = regexp(name, '_', 'split');
    mopad.META = struct;
    mopad.META.nomSujet = meta{1};
    mopad.META.dateSujet = meta{2};

    
    % find the ini file
    iniFile =  fullfile(full_directory, '*.ini');
    listing = dir(iniFile);
    % find the correct directory and file
    iniFile = fullfile(full_directory, listing.name);

    % Parse the .ini file
    [nomManip, frequenceData, infos] = parse_ini_file(iniFile);

    mopad.META.nomManip = nomManip;
    mopad.META.frequenceData = frequenceData;
    
    % for each data file .txt
    for i=1:length(infos)
        new_struct = parse_data_file(infos{i},full_directory);
        mopad = setfield(mopad,infos{i}{1},new_struct);
    end


end

%% parse_ini_file
% Parse the config.ini file.
%
% input argument:
% ini_file_path:    the path to the Mopad config.ini file
%
% output argument:
% nomManip:         Valeur du champs "NomEssai" de la section "INFO_ESSAI"
% frequenceData:    Fréquence d'acquisition du DAQ
%                   ("FrequenceBaseOuDecimation")
% infos:            Cell array de longueur le nombre de sauvegarde, qui
%                   contient dans chaque cellule 5 informations extraites
%                   du fichier de config :
%                   1-NomDeBaseFichier- nom de base du fichier de sauvegarde
%                   2- NomDataEntree  - nom des colonnes de variables
%                   3-NombreDataEntree- nombre de variables
%                   4-   BIND_units   - unité des variables
%                   5- BIND_comments  - commentaires associés aux variables

function [nomManip, frequenceData, infos] = parse_ini_file(ini_file_path)

    % open the ini file
    fileID = fopen(ini_file_path);

    % initialise parameters
    compteur = 1;
    infos = {};
    nomManip = '';
    frequenceData = 0;

    disp('Parsing Mopad ini file.');
    
    % parse config.ini file, line by line.
    while ~feof(fileID)
        tline = fgetl(fileID);
        if ~isempty(tline)

            % determination des spécificités du TRAJET
            expr = '[^\n]*INFO_ESSAI[^\n]*';
            infoTrip= regexp(tline, expr, 'match');
            if ~isempty(infoTrip)
                % on a trouvé un bloc de description du TRIP
                while ~feof(fileID)
                    tline = fgetl(fileID);
                    test_str = sscanf(tline, 'NomEssai=%s');
                    if ~isempty(test_str)
                        nomManip = test_str;
                        break;
                    end
                end
            end


            % determination des spécificités de l'acquisition
            expr = '[^\n]*DAQ_0[^\n]*';
            infoAcqui= regexp(tline, expr, 'match');
            if ~isempty(infoAcqui)
                % on a trouvé un bloc de description de l'acquisition
                while ~feof(fileID)
                    tline = fgetl(fileID);
                    test_str = sscanf(tline, 'FrequenceBaseOuDecimation=%s');
                    if ~isempty(test_str)
                        frequenceData = test_str;
                        break;
                    end
                end
            end

            % determination des DATAS et VARIABLES a importer
            expr = '[^\n]*SAUVEGARDE_[^\n]*';
            infoSauvegardes = regexp(tline, expr, 'match');
            if ~isempty(infoSauvegardes)
                % on a trouvé un bloc de sauvegarde
                % réinitialisation des variables intermédiaires
                sauvegarde_actif = '';
                saveFile = '';
                variables = '';
                nombreVariables = '';
                bind_units = '';
                bind_comments = '';
                while ~feof(fileID)
                    tline = fgetl(fileID);
                    test_str = sscanf(tline, 'Actif=%s');
                    if ~isempty(test_str)
                        sauvegarde_actif = test_str;
                    end
                    test_str = sscanf(tline, 'NomDeBaseFichier=%s');
                    if ~isempty(test_str)
                        saveFile = test_str;
                    end
                    test_str = sscanf(tline, 'NomDataEntree=%s');
                    if ~isempty(test_str)
                        variables = test_str;
                    end
                    test_str = sscanf(tline, 'NombreDataEntree=%d');
                    if ~isempty(test_str)
                        nombreVariables = test_str;
                    end
                    test_str = sscanf(tline, 'BIND_units=%s');
                    if ~isempty(test_str)
                        bind_units = test_str;
                    end
                    test_str = sscanf(tline, 'BIND_comments=%s');
                    if ~isempty(test_str)
                        bind_comments = tline(15:end);
                    end
                    if isempty(tline) || feof(fileID)
                        % we've reached the end of the block, time to backup
                        % things
                        if strcmp(sauvegarde_actif,'oui')
                            % info is a buffer struct : a quintuplet 'name of mopad output
                            % file; list of all MOPAD variable separated by ','; number
                            % of variables; list of bind units separated by
                            % ','; list of bind comments separated by ','.
                            info = {saveFile,variables,nombreVariables,bind_units,bind_comments};
                            % store in general structure 'infos'
                            infos{compteur} = info;
                            compteur = compteur + 1;
                        end
                        break;
                    end
                end
            end
        end
    end
    fclose(fileID);
    % A la sortie de cette boucle, info est un cell array de descripteur de fichier de sauvegarde!!



end


%% parse_data_file
% parse a .txt data file collected with Mopad v3+
%
% input argument:
% infos_backup_file: a cell array containing the informations needed to
%                   parse the current .txt file:
%                   1- base name of the backup file
%                   2- name of the variables
%                   3- number of variables
%                   4- units of the variables
%                   5- comments related to the variables
% full_directory:  location of the folder containing MOPAD (v3+) files
%                  (config.ini + associated .txt files)
% 
%
% output argument:
% new_struct:       an intermediate strcture that will be added to the
%                   Mopad structure.

function new_struct = parse_data_file(infos_backup_file,full_directory)

    new_struct = struct;

    nomData = infos_backup_file{1};
    N = infos_backup_file{3};
    infoUtilisateur = [ 'Processing data : ' nomData];
    disp(infoUtilisateur);
    
    
    pattern = '';
    for i=1:N
        if i == N
            pattern = [pattern '%q'];
        else
            pattern = [pattern '%q '];
        end
    end
    lesVariables = infos_backup_file{2};
    listeVariables =  textscan(lesVariables,pattern,'Delimiter',',');
    listeVariables = horzcat({'time'},listeVariables{:});
    lesUnits = infos_backup_file{4};
    if  ~isempty(lesUnits)
        listeUnits = textscan(lesUnits,pattern,'Delimiter',',');
    else
        listeUnits = {};
    end
    listeUnits = horzcat({'ms'},listeUnits{:});
    lesComments = infos_backup_file{5};
    if  ~isempty(lesComments)
        listeComments = textscan(lesComments,pattern,'Delimiter',',');
    else
        listeComments = {};
    end
    listeComments = horzcat({''},listeComments{:});
    
    
    pattern = ['*' infos_backup_file{1} '*.txt'];
    saveFile = fullfile(full_directory, pattern);
    listing = dir(saveFile);
    if ~isempty(listing)
        saveFile = fullfile(full_directory, listing.name);
        fid = fopen(saveFile);
        
        pattern = '%f '; %toujours une colonne au debut pour le temps
        N = infos_backup_file{3};
        for i=1:N
            pattern = [pattern '%f '];
        end
        if ~check_mopad_version(fid)
            disp('This version of the converter is not compatible with files recorded with old versions of Mopad (support v3.0.3 and more recent)');
            return;
        end
        
        all_data = textscan(fid, pattern);
        fclose(fid);
        % a cette étape, dans all_data, on a un cell array avec toutes les valeurs
        % du fichier
         
        for i=1:length(listeVariables)

            disp([char(listeVariables{i}) '... ']);

            new_variable = struct;

            new_variable.values = all_data{i};
            new_variable.unit = '';
            new_variable.comments = '';
            % check if unit is defined
            if length(listeVariables) == length(listeUnits)
                new_variable.unit = listeUnits{i};            
            end
            % check if comment is defined
            if length(listeVariables) == length(listeComments)
                new_variable.comments = listeComments{i};
            end

            % save the result in the structure
            nom_var = strrep(listeVariables{i},'%','POURCENT_'); % replace the '%' special character in the struct
            new_struct = setfield(new_struct,nom_var,new_variable);
        end
        
    end
end

%% check_mopad_version
% This function checks the version of a newly opened mopad file (.txt). If
% the file has been recorded with Mopad v3+, then it returns true,
% otherwise it returns false.
%
% input argument:
% fid:          A handler to the (opened) data file.
%
% output argument:
% version_ok:   Is the version of Mopad ok (v3+)?
%

function version_ok = check_mopad_version(fid)
    tline = fgetl(fid); % check the first line
    mopad_version = sscanf(tline, 'Application :	MOPAD v%d.%d.%d');
    if isempty(mopad_version) || mopad_version(1) < 3
        version_ok = false;
    else
        version_ok = true;
    end
end