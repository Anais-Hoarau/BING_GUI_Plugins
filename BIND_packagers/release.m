%{
For the documentation of this script is located at https://redmine.inrets.fr/projects/bindpackagers/wiki
%}
function release()
    %%%%%%%% Checking presence of svn command %%%%%%%%
    [status ~] = system('svn help');
    if status ~= 0
        disp('Pour fonctionner, ce script requiert la commande svn, par exemple celle disponible sur http://www.sliksvn.com/en/download');
        return;
    end
    
    %%%%%%%% Checking presence of perl command %%%%%%%%
    [status ~] = system('perl -h');
    if status ~= 0
        disp('Pour fonctionner, ce script requiert la commande perl, par exemple celle disponible sur http://www.activestate.com/activeperl/downloads');
        return;
    end
    
    %%%%% Asking the config file of the project %%%%%
    [configFile pathToConfigFile] = uigetfile('*.conf', 'Sélectionnez le fichier de configuration du projet');
    if ~configFile
        return;
    end
    
    %%%%%%%%% Asking the root of the project %%%%%%%%%
    root = uigetdir('.', 'Choisissez la racine de votre copie de travail pour ce projet (par exemple lescot-expl/BIND)');
    if ~root
        return;
    end

    %%%%%%%%% Asking the new version number %%%%%%%%%%
    version = char(inputdlg('Numéro de la version à releaser', 'Numéro de version'));
    if isempty(version)
        return;
    end
    
    % Asking if the svn commands have to be executed %
    answer = questdlg('Faut-il exécuter les commandes svn ou uniquement regénerer les zips ?','SVN','Zips + svn','Zips','Zips + svn'); 
    executeSVN = strcmp(answer, 'Zips + svn');
    
    %%%%%%%%%%%%%%%% Config variables %%%%%%%%%%%%%%%%
    %Reading the content of the configuration file
    lines = {};
    configFileHandler = fopen([pathToConfigFile configFile]);
    line = fgetl(configFileHandler);
    while ischar(line)
        lines{end + 1} = line;
        line = fgetl(configFileHandler);
    end
    fclose(configFileHandler);
    %Parsing the configuration file
    copiesToExecute = {};
    for i = 1:1:length(lines)
        %repositoryURL
        match = regexp(lines{i}, '(?<=repositoryURL=)http(s)?:\/\/.+' ,'match', 'once');
        if ~isempty(match)
            repositoryURL = match;
        end
        %copy
        match = regexp(lines{i}, '(?<=copy=).+;.+' ,'match', 'once');
        if ~isempty(match)
           splittedLine = regexp(match, ';' ,'split');
           copiesToExecute(end + 1, 1:2) = splittedLine(:); %#ok<AGROW>
        end
        %projectName
        match = regexp(lines{i}, '(?<=projectName=).+' ,'match', 'once');
        if ~isempty(match)
            projectName = match;
        end
    end 
    
    %%%%%%%%%%%%%%%%%%% Processing %%%%%%%%%%%%%%%%%%%
    if executeSVN
        disp('Executing the following SVN commands : ');
        updateCommand = ['svn update ' root];
        disp(['--> ' updateCommand]);
        system(updateCommand);
        copyCommand = ['svn copy ' repositoryURL '/trunk ' repositoryURL '/tags/' version ' -m "Release de la version ' version ' du projet"'];
        disp(['--> ' copyCommand]);
        system(copyCommand);
        disp(['--> ' updateCommand]);
        system(updateCommand);
    end
    
    %Copying all the files in a temp folder
    versionRoot = [root filesep 'tags' filesep version];
    
    relativePathToTemp = ['.' filesep projectName '_' version];
    
    if isdir(relativePathToTemp)
        disp('Deleting previously existing temp folder');
        rmdir(relativePathToTemp, 's');
    end
    disp('Creating working folder');
    mkdir(relativePathToTemp);
    
    %Parsing the copies array and iterating on it to perform the copies
    for i = 1:1:length(copiesToExecute)
        source = [versionRoot filesep copiesToExecute{i, 1}];
        destination = [relativePathToTemp filesep copiesToExecute{i, 2}];
        disp(['Copying ' source ' to ' destination]);
        copyfile(source, destination, 'f');
    end
    
    disp('Cleaning .svn folders');
    clean(relativePathToTemp);
    
    disp('Creating source code archive');
    zipname = [projectName '_' version '.zip'];
    if exist(zipname, 'file')
        disp('Deleting previously existing release with the same name');
        delete(zipname);
    end
    zip(zipname, relativePathToTemp);
    
    disp('Cleaning ');
    rmdir(relativePathToTemp, 's');
    
    %%%%%%%%%%%%%%%%% Doc generation %%%%%%%%%%%%%%%%%
    relativePathToDocTemp = ['.' filesep projectName '_' version '_doc'];
    if isdir(relativePathToDocTemp)
        disp('Deleting previously existing temp folder');
        rmdir(relativePathToDocTemp, 's');
    end
    disp('Creating working folder');
    mkdir(relativePathToDocTemp);
    
    generateDocumentation([root filesep 'tags' filesep version], [pathToConfigFile configFile], relativePathToDocTemp);

    zipname = [projectName '_' version '_doc.zip'];
    if exist(zipname, 'file')
        disp('Deleting previously existing release with the same name');
        delete(zipname);
    end

    zip(zipname, relativePathToDocTemp);

    rmdir(relativePathToDocTemp, 's');
    
%{
This function goes recursivly through a directory and eliminates .svn folders.
%}
function clean(folder)

    dirResult = dir(folder);
    for i = 1:1:length(dirResult)
        if dirResult(i).isdir
            if ~strcmp(dirResult(i).name, '.') && ~strcmp(dirResult(i).name, '..')
                if strcmp(dirResult(i).name, '.svn')
                    rmdir([folder filesep dirResult(i).name], 's');
                else
                    clean([folder filesep dirResult(i).name]);
                end
            end
        end
    end

