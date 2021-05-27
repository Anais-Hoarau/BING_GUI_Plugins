function Step2_importVarFile(xmlFile, varFile, pathToTrip)

[~, name, ~] = fileparts(varFile);
tripFile = [pathToTrip filesep name '.trip'];

if exist(tripFile, 'file')
    delete(tripFile);
end
parsedXMLMappingFile = xmlread(xmlFile);
generateSQLiteFile(parsedXMLMappingFile, varFile, pathToTrip);