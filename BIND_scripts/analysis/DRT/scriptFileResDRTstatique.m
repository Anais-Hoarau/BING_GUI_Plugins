pathToLogDRTstatique = 'D:\Ldumont\DRT_MATLAB\datadrtstatique';
listdirdrtstatique = dir(pathToLogDRTstatique);
idfileres = fopen('fichierResDRTstatique','w');
fprintf(idfileres,'IdSujet\tTypeDRT\tCondition\tTpsRepDRT\n');

for i = 3: length(listdirdrtstatique)
   posstr = strfind(listdirdrtstatique(i).name, '.log');
   if ~isempty(posstr)
        namefile = listdirdrtstatique(i).name; %PDT_log_S16HS0_08-06-2012_08-22-47.log
        okfile = calculPerfDRTstatique(str2num(namefile(10:11)), ... %numsujet
                namefile(12), ... %TypeDRT
                namefile(13:14), ... %Type Tache
               [ pathToLogDRTstatique '\' namefile], ... % name file drt
               idfileres); %#ok<ST2NM> % canal file res
    end;
end;

fclose(idfileres);