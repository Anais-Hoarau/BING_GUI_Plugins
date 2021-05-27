PathBase = '\\dklescot\DataLescot\ABSTRACT\';



sujetsToImport = {'01'; '02'; '03'; '04'; '05'; '07'; '10';...
    '11'; '13'; '14'; '15'; '16'; '17'; '18';'20';'21';'22';'23';'24';'25'};
%sujetsToImport = {'13'; '14'; '15'; '16' ; '17' } ;
%sujetsToImport = {'18' ; '19'  };
%sujetsToImport = {'20'; '21'; '22' ;'23'; '24'; '25'; '26' ; '27' ; '28' ; '29' };
%sujetsToImport = {''30' ; '31'; '32' ; '33'};

for i = 1:1:length(sujetsToImport)
    nomSujet = char(sujetsToImport{i});
    PathName = [ PathBase 'sujet' nomSujet '\matlab\'];
    FileName = [ 'Manip' nomSujet '.mat'];
    functionImportABSTRACT(FileName,PathName);
end
