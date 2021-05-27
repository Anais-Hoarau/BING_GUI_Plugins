PathBase = 'c:\AIDE\';

%sujetsToImport = {'19'}; %; '11'}
%sujetsToImport = {'13'; '14'; '15'; '16' ; '17' } ;
%sujetsToImport = {'18' ; '19'  };
sujetsToImport = {'01'; '02'; '03' ;'04'; '06'; '07' ; '08' ; '09' ; '10'; '11'; '12'; '13'; '14'; '15' };
%sujetsToImport = {''30' ; '31'; '32' ; '33'};

for i = 1:1:length(sujetsToImport)
    nomSujet = char(sujetsToImport{i});
    PathName = [ PathBase 'sujet' nomSujet '\matlab\'];
    FileName = [ 'Manip' nomSujet '.mat'];
    functionImportAIDE(FileName,PathName);
end
