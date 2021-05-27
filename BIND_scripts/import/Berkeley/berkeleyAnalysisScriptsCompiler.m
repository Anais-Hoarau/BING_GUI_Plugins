% This function is adapted from the compiler function in BIND_packagers.
function berkeleyAnalysisScriptsCompiler()
    clear classes;

    %Ask the root folder of the source code to compile
    scriptPath = {...
        'C:\Documents and Settings\matlab\Bureau\Benoit\bind-scripts\analysis\berkeley\cacc',...
        'C:\Documents and Settings\matlab\Bureau\Benoit\bind-scripts\analysis\transverse'...
        };
%     scriptPath = uigetdir('.', 'Where is the base directory of the scripts files?');
%     if ~scriptPath
%         return;
%     end
    %Ask the root folder of bind source code
    bindPath = 'C:\Documents and Settings\matlab\Bureau\Benoit\BIND';
%     bindPath = uigetdir('.', 'Where is the base directory of BIND?');
%     if ~bindPath
%         return;
%     end

    %Ask for the name of the executable to produce
%     executableName = inputdlg('Name of the new executable file?', 'Name', 1, {'CaccAnalysis'});
%     if isempty(executableName)
%         return;
%     end
% 
%     executableName = executableName{1};
    executableName = 'CaccAnalysis';

    main = 'mainBerkeleyCaccAnalysis(''fromFile'')';
 %   readme = '';
    
    % Compile everything :)
    scriptsCompiler4BIND(scriptPath,bindPath,executableName,main);

end