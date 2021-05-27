%Returns the list of converted trip files
function out = LEPSIS2BIND_all_trips()
[xmlName,xmlPath]= uigetfile('*.xml', 'Selectionnez le fichier .xml correspondant aux manips');
varDir = uigetdir(pwd, 'Selectionnez le dossier qui contient tout les .var (y compris dans des sous-dossiers');
%varPrefix = inputdlg('Préfixe des fichiers var', 'Choisissez le préfixe des fichiers var à importer');
toConvertFiles = dirrec(varDir, '.var');
toRemoveFromConversionList = [];
for i = 1:1:length(toConvertFiles)
    if ~isempty(strfind(toConvertFiles{i},'@'))
        toConvertFiles{i} = [];
    end
    %     [~, filename] = fileparts(toConvertFiles{i});
    %     if ~strncmp(varPrefix, filename, length(varPrefix))
    %         toRemoveFromConversionList(end + 1) = i;
    %     end
end
toConvertFiles(toRemoveFromConversionList) = [];

parsedXMLMappingFile = xmlread([xmlPath xmlName]);
out = cell(length(toConvertFiles),1);
log = fopen([varDir filesep 'failedImports.log'], 'w+');
for i = 1:length(toConvertFiles)
    if ~isempty(toConvertFiles{i})
        pathToVar = toConvertFiles{i};
        pathToTrip = fileparts(strrep(pathToVar, '.var', '.trip'));
        disp(['Converting ' pathToVar]);
        try
            generateSQLiteFile_simu(parsedXMLMappingFile, pathToVar , pathToTrip);
            out{end+1} = strrep(pathToVar, '.var', '.trip');
        catch ME
            fprintf(log, '%s', ['######## ' pathToVar ' ########' char(10)]);
            fprintf(log, '%s', ME.getReport());
            
        end
    end
end
fclose(log);