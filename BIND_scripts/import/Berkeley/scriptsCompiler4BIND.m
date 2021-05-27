% scriptsCompiler4BIND(scriptPath,bindPath,executableName,main,readme)
%
% This function compiles is designed to compile a set of BIND scripts.
%
% This function is adapted from the compiler function in BIND_packagers.
%
% scriptPath        A cell array of string contaning the paths to the
%                   directories containing the scripts to compile.
% bindPath          A string contaning the path to the directory containing
%                   BIND.
% executableName    A string containing the name of the executable.
% main              The main sctipt to load when running the executable
% readme (optional) A string containing the path to a readme file to
%                   include in the zip package.
function scriptsCompiler4BIND(scriptPath,bindPath,executableName,main,readme)

    previousPath = path();
    restoredefaultpath();

    if ~isdir('bin')
        mkdir('bin');
    end

    %Create the mini launcher used as an entry point for the application
    launchScript = fopen('./minilauncher.m', 'w');
    fprintf(launchScript, '%s', main);
    fclose(launchScript);

    %Copy all the required files in a temp folder
    mkdir('temp');
    %Tout les scrpts
    for i=1:length(scriptPath)
        copyfile(scriptPath{i}, './temp/scripts', 'f');
    end
    %Tout BIND
    copyfile([bindPath filesep 'src'], './temp/src', 'f');
    %Toutes les libs de BIND
    copyfile([bindPath filesep 'lib'], './temp/lib', 'f');
    
    %On dégage les dossiers .svn à la con
    clean('./temp');

    %Build the command for the compilation
    command = ['mcc(''-m'', ''-N'', ''-R'', ''-logfile'', ''-R'',''' executableName '.log'',''-v'', ''-o'', ''' executableName ''', ''-d'',''./bin'''];
    cleanFilesList = dirrec('./temp');
    for i = 1:1:length(cleanFilesList)
        command = [command ', ''-a'', ''' char(cleanFilesList{i}) ''''];
    end
    command = [command ' ,''minilauncher'')'];

    disp(command);
    eval(command);
    
    % if a readme file is define
    if nargin > 4
        if exist(readme,'file');
            disp('including the readme file.');
            copyfile(readme, './bin/', 'f');
        else
            disp('Warning: the readme file could not be found.');
        end
    end
    
    % %Finish packaging and clean
    copyfile(mcrinstaller, './bin');
    zip([executableName '.zip'], {[executableName '.exe'] 'MCRInstaller.exe' 'readme.txt'}, ['.' filesep 'bin' filesep ]);
    rmdir('bin', 's');
    rmdir('temp', 's');
    delete('minilauncher.m');
    path(previousPath);

    disp('');
    disp('');
    disp('');
    disp('Packaging finished :-)');

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
