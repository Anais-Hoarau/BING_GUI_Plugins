function import307ScriptsCompiler()
    clear classes;

    previousPath = path();
    restoredefaultpath();

    if ~isdir('bin')
        mkdir('bin');
    end

    %Ask the root folder of the source code to compile
    scriptPath = uigetdir('.', 'What is the base folder of the script files to compile?');
     if ~scriptPath
         return;
     end
    %Ask the root folder of bind source code
     bindPath = uigetdir('.', 'What is the base folder (with lib, src...) of BIND?');
     if ~bindPath
         return;
     end
    %Ask the root folder of the VideoReader toolbox source code
 %   videoReaderPath = 'C:\Program Files\MATLAB\R2010b\toolbox\matlab\audiovideo';
%     videoReaderPath = uigetdir('.', 'Where is the base directory of the VideoReader toolbox?');
%     if ~videoReaderPath
%         return;
%     end

    %Ask for the name of the executable to produce
    executableName = inputdlg('Name of the new executable file to produce?', 'Name', 1, {'MyExe'});
    if isempty(executableName)
        return;
    end

    executableName = executableName{1};

    %Create the mini launcher used as an entry point for the application
    launchScript = fopen('./minilauncher.m', 'w');
    % MODIFY HERE LAUNCH COMMAND
    fprintf(launchScript, '%s', 'singleDirectoryImport307()');
    fclose(launchScript);
    
    %Copy all the required files in a temp folder
    mkdir('temp');
    %Tout les scrpts
    copyfile([scriptPath '\*.m'] , './temp/', 'f');
    %Tout le VideoReader
   % copyfile(videoReaderPath, './temp/video', 'f');
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
    % %Finish packaging and clean
    copyfile(mcrinstaller, './bin');
%     zip([executableName '_' bindVersion '.zip'], {[executableName '.exe'] 'MCRInstaller.exe'}, ['.' filesep 'bin' filesep ]);
    zip([executableName '.zip'], {[executableName '.exe'] 'MCRInstaller.exe'}, ['.' filesep 'bin' filesep ]);
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
