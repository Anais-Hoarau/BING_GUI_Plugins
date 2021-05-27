xmlPath = uigetdir('', 'Select the folder containing the XML files.');
varDir = uigetdir(pwd, 'Select the folder containing all the ".trip" files (including sub-folders');
toConvertFiles = dirrec(varDir, '.var');

parsedXMLMappingFileDrive1 = xmlread([xmlPath filesep 'mapping_drive_1.xml']); %#ok<*NASGU>
parsedXMLMappingFileDrive2 = xmlread([xmlPath filesep 'mapping_drive_2.xml']);

log = fopen([varDir filesep 'failedImports.log'], 'w+');
for i = 1:1:length(toConvertFiles)
    pathToVar = toConvertFiles{i};
    [~, varName, ~] = fileparts(pathToVar);
    drive = varName(1);
    pathToTrip = fileparts(strrep(pathToVar, '.var', '.trip'));
    disp(['Converting ' pathToVar]);
    try
        generateSQLiteFile(eval(['parsedXMLMappingFileDrive' drive]), pathToVar , pathToTrip);
    catch ME
       fprintf(log, '%s', ['######## ' pathToVar ' ########' char(10)]);
       fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));

    end
end
fclose(log);
