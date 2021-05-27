% This function is adapted from the compiler function in BIND_packagers.
function berkeleyImportScriptsCompiler()
    clear classes;

    %Ask the root folder of the source code to compile
    scriptPath = {'C:\Documents and Settings\matlab\Bureau\Benoit\bind-scripts\import\Berkeley'};
%     scriptPath = uigetdir('.', 'Where is the base directory of the scripts files?');
%     if ~scriptPath
%         return;
%     end
%     scriptPath = {scriptPath};
    %Ask the root folder of bind source code
    bindPath = 'C:\Documents and Settings\matlab\Bureau\Benoit\BIND';
%     bindPath = uigetdir('.', 'Where is the base directory of BIND?');
%     if ~bindPath
%         return;
%     end

    %Ask for the name of the executable to produce
%     executableName = inputdlg('Name of the new executable file?', 'Name', 1, {'Cacc2SQLiteTrip'});
%     if isempty(executableName)
%         return;
%     end
% 
%     executableName = executableName{1};
    executableName = 'Cacc2SQLiteTrip';

    main = 'mainBerkeley(''fromFileOrAskInputSameOutput'')';
    readme = 'C:\Documents and Settings\matlab\Bureau\Benoit\bind-scripts\import\Berkeley\readme.txt';
    
    % Compile everything :)
    scriptsCompiler4BIND(scriptPath,bindPath,executableName,main,readme);

end