function compiler()
clear classes;

previousPath = path();
restoredefaultpath();

if ~isdir('bin')
    mkdir('bin');
end

%Ask the root folder of bind source code
bindPath = uigetdir('.', 'Ou est le repertoire de base de la version de BIND a compiler ?');
if ~bindPath
    return;
end
[~, bindVersion] = fileparts(bindPath);


%Ask ask the root folder of the basic plugins
basicPluginsList = {};
isPluginPathOk = false;
while(~isPluginPathOk)
    pluginsPath = uigetdir('.', ['Ou est le repertoire de base de la version ' bindVersion ' du projet BIND_plugins ?']);
    if ~pluginsPath
        return;
    else
        [~, pluginsVersion] = fileparts(pluginsPath);
        if ~strcmp(bindVersion, pluginsVersion)
            uiwait(errordlg('La version des plugins doit etre la meme que celle de BIND.', 'Erreur', 'Modal'));
        else
            isPluginPathOk = true;
        end
    end
end

basicPluginsList = selectPluginsInDirectory(pluginsPath);

includeAddPluginFolder = questdlg('Voulez-vous inclure un repertoire de plugins additionnels ?','Plugins additonnels','Oui','Non', 'Oui');
if strcmp('Oui', includeAddPluginFolder)
    specificPluginsPath = uigetdir('.', ['Indiquez l''emplacement des plugins specifiques']);
    if ~specificPluginsPath
        return;
    else
        specificPluginsList = selectPluginsInDirectory(specificPluginsPath);
    end
else
    specificPluginsList = {};
end

includeAddPluginFolder = questdlg('Avez vous un second repertoire de plugins additionnels ?','Plugins additonnels','Oui','Non', 'Oui');
if strcmp('Oui', includeAddPluginFolder)
    specificPluginsPath = uigetdir('.', ['Indiquez l''emplacement des plugins specifiques']);
    if ~specificPluginsPath
        return;
    else
        otherSpecificPluginsList = selectPluginsInDirectory(specificPluginsPath);
    end
else
    otherSpecificPluginsList = {};
end

%Ask wich loader to use
isLoaderOk = false;
[loader loaderPath] = uigetfile([pluginsPath filesep 'src' filesep '+fr' filesep '+lescot' filesep '+bind' filesep '+loading'], 'Choisissez le loader de l''application');
if ~loader
    return;
end
selectedLoaderFile = fullfile(loaderPath,loader);
loaderQualified = regexp([loaderPath loader], '\+.*\.m$', 'match', 'once');
loaderQualified = regexprep(loaderQualified, '(\\\+)||(\\)', '\.');
loaderQualified = loaderQualified(2:end-2);


%Allow the inclusion of a final ressource folder
includeResFolder = questdlg('Voulez-vous inclure un repertoire de ressources additionnelles (fichiers d''environnement ou de configuration...)?','Ressources','Oui','Non', 'Oui');
if strcmp('Oui', includeResFolder)
    resPath = uigetdir('.', ['Indiquez l''emplacement du rï¿½pertoire de ressources optionnelles']);
    if ~resPath
        return;
    end
end

%Ask for the name of the executable to produce
executableName = inputdlg('Nom de l''executable a produire ?', 'Nom', 1, {'distribution'});
if isempty(executableName)
    return;
end
executableName = executableName{1};

%Create the mini launcher used as an entry point for the application
launchScript = fopen('./minilauncher.m', 'w');
fprintf(launchScript, '%s', loaderQualified);
fclose(launchScript);

%Copy all the required files in a temp folder
mkdir('temp');
%Tout BIND
copyfile([bindPath filesep 'src'], './temp/src', 'f');
%Toutes les libs de BIND
copyfile([bindPath filesep 'lib'], './temp/lib', 'f');
% ------------- Basic Plugins ---------------------
%Les images pour les plugins
copyfile([pluginsPath filesep 'img'], './temp/img', 'f');
%Les librairies des plugins
copyfile([pluginsPath filesep 'lib'], './temp/lib', 'f');
%Tout les configurateurs
copyfile([pluginsPath filesep 'src/+fr/+lescot/+bind/+configurators'], './temp/src/+fr/+lescot/+bind/+configurators', 'f');
%Tout les widgets
copyfile([pluginsPath filesep 'src/+fr/+lescot/+bind/+widgets'], './temp/src/+fr/+lescot/+bind/+widgets', 'f');
%Uniquement les plugins requis
for i = 1:1:length(basicPluginsList)
    pathInTemp = regexp(basicPluginsList{i}, ['src.*\' filesep ], 'match', 'once');
    savePath = ['./temp/' pathInTemp];
    if ~isdir(savePath)
        mkdir(savePath);
    end
    copyfile(basicPluginsList{i}, savePath, 'f');
end
% ------------- Specific Plugins ---------------------
if exist('specificPluginsPath', 'var')
    %Les images pour les plugins
    if isdir([specificPluginsPath filesep 'img'])
        copyfile([specificPluginsPath filesep 'img'], './temp/img', 'f');
    end
    %Les librairies des plugins
    if isdir([specificPluginsPath filesep 'lib'])
        copyfile([specificPluginsPath filesep 'lib'], './temp/lib', 'f');
    end
    %les configurateurs
    if isdir([specificPluginsPath filesep 'src/+fr/+lescot/+bind/+configurators'])
        copyfile([specificPluginsPath filesep 'src/+fr/+lescot/+bind/+configurators'], './temp/src/+fr/+lescot/+bind/+configurators', 'f');
    end
    %Tout les widgets
    if isdir([specificPluginsPath filesep 'src/+fr/+lescot/+bind/+widgets'])
        copyfile([specificPluginsPath filesep 'src/+fr/+lescot/+bind/+widgets'], './temp/src/+fr/+lescot/+bind/+widgets', 'f');
    end
    %Uniquement les plugins requis
    for i = 1:1:length(specificPluginsList)
        pathInTemp = regexp(specificPluginsList{i}, ['src.*\' filesep ], 'match', 'once');
        savePath = ['./temp/' pathInTemp];
        if ~isdir(savePath)
            mkdir(savePath);
        end
        copyfile(specificPluginsList{i}, savePath, 'f');
    end
    %Et les autres plugins spe½cifiques
    for i = 1:1:length(otherSpecificPluginsList)
        pathInTemp = regexp(otherSpecificPluginsList{i}, ['src.*\' filesep ], 'match', 'once');
        savePath = ['./temp/' pathInTemp];
        if ~isdir(savePath)
            mkdir(savePath);
        end
        copyfile(otherSpecificPluginsList{i}, savePath, 'f');
    end
end
%Tout les loaders
copyfile([pluginsPath filesep 'src/+fr/+lescot/+bind/+loading'], './temp/src/+fr/+lescot/+bind/+loading', 'f');
% le loader selectionnï¿½ par l'utilisateur
copyfile(selectedLoaderFile, './temp/src/+fr/+lescot/+bind/+loading', 'f');
%Copie le dossier de ressources supplementaire
if exist('resPath', 'var')
    copyfile(resPath, './temp/res', 'f');
end
%On degage les dossiers .svn ï¿½ la con
clean('./temp');

%Build the command for the compilation
% ''-M'', ''' iconeFile ''',
command = ['mcc(''-m'', ''-N'', ''-R'', ''-logfile'', ''-R'',''' executableName '.log'',''-v'',  ''-o'', ''' executableName ''', ''-d'',''./bin'''];
cleanFilesList = dirrec('./temp');
for i = 1:1:length(cleanFilesList)
    command = [command ', ''-a'', ''' char(cleanFilesList{i}) ''''];
end
command = [command ' ,''minilauncher'')'];

disp(command);
eval(command);
% %Finish packaging and clean
copyfile(mcrinstaller, './bin');
zip([executableName '_' bindVersion '.zip'], {[executableName '.exe'] 'MCRInstaller.exe'}, ['.' filesep 'bin' filesep ]);
rmdir('bin', 's');
rmdir('temp', 's');
delete('minilauncher.m');
path(previousPath);

disp('');
disp('');
disp('');
disp('Packaging finished :-)');


function pluginsList = selectPluginsInDirectory(pluginsPath)
%Show a list to the user so that he can select some plugins among the ones
%that are present in the directory "pluginsPath"
pluginsList={};
pluginsFileList = dirrec(pluginsPath);
pluginRegExp =  [ '\' filesep() '\+fr' '\' filesep() '\+lescot' '\' filesep() '\+bind' '\'  filesep() '\+plugins' '\'  filesep() '.*\.m$'];
for i = 1:1:length(pluginsFileList)
    if ~isempty(regexp(pluginsFileList{i},pluginRegExp, 'match', 'once'))
        pluginsList{end + 1} = pluginsFileList{i};
    end
end
[pluginsIndexList, ok] = listdlg('ListString',pluginsList, 'ListSize', [700 300], 'CancelString', 'Annuler', 'InitialValue', 1:1:length(pluginsList), 'PromptString', 'Choisissez les plugins Ã  inclure dans la dsitribution');
if ~ok
    pluginsList={};
    return;
end
pluginsList = {pluginsList{pluginsIndexList}};


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
