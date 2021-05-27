%{
For the documentation of this script is located at https://redmine.inrets.fr/projects/bindpackagers/wiki
%}
function generateDocumentation(projectVersionRootFolder, configFileFullPath, outputFolder)
    
    %Reading the content of the configuration file
    lines = {};
    configFileHandler = fopen(configFileFullPath);
    line = fgetl(configFileHandler);
    while ischar(line)
        lines{end + 1} = line;
        line = fgetl(configFileHandler);
    end
    fclose(configFileHandler);
    %Parsing the configuration file
    docFolders = {};
    docExcludedFolders = {};
    for i = 1:1:length(lines)
        %doc
        match = regexp(lines{i}, '(?<=doc=).+' ,'match', 'once');
        if ~isempty(match)
            docFolders{end +1 } = match;
        end
        %Excluded folders
        match = regexp(lines{i}, '(?<=doc\-exclude=).+' ,'match', 'once');
        if ~isempty(match)
            docExcludedFolders{end +1 } = match;
        end
        %naturalDocsConfigurationDirectory
        match = regexp(lines{i}, '(?<=naturalDocsConfigurationDirectory=).+' ,'match', 'once');
        if ~isempty(match)
            naturalDocsConfigurationDirectory = match;
        end
    end
        
    disp('Generating documentation');
    docGenerationCommand = [ '"' which('NaturalDocs.bat') '" -code '];
    for i = 1:1:length(docFolders)
        docGenerationCommand = [docGenerationCommand '-i ' [projectVersionRootFolder filesep docFolders{i}] ' ']; %#ok<AGROW>
    end
    for i = 1:1:length(docExcludedFolders)
        docGenerationCommand = [docGenerationCommand '-xi ' [projectVersionRootFolder filesep docExcludedFolders{i}] ' ']; %#ok<AGROW>
    end
    docGenerationCommand = [docGenerationCommand '-o HTML ' outputFolder ' -p ' projectVersionRootFolder filesep naturalDocsConfigurationDirectory];
    disp(['Executing doc generation command : ' docGenerationCommand]);
    system(docGenerationCommand);

end

