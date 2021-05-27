function [ output_args ] = calculPerfVolant(nametrip, idfileres, namedebut , namefin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%namevar = { 'DureeSeq' ; 'DebutSeqGMT' ;  'MoyVit'; 'MaxVit'; 'MinVit'; 'StdVit'; };

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(nametrip, 0.04, true);


data = trip.getAllDataOccurences('localisation');


timecode  = cell2mat(data.getVariableValues('timecode'));
comments = data.getVariableValues('commentaires');

cabvolant = cell2mat(data.getVariableValues('angle volant'));
anglevolant = cabvolant*2*360/10000;

heureGMT  = data.getVariableValues('heureGMT');

for i=1:length(namedebut)
    indexdebut =find(cellfun('length',strfind(comments,namedebut{i})));
    indexfin =find(cellfun('length',strfind(comments,namefin{i})));
    dureeSeq = timecode(indexfin) - timecode(indexdebut);
    if isempty(indexdebut) || isempty(indexfin) 
          fprintf(idfileres,'\t%f\t%f\t%f\t%f\t%f', -1, -1,-1,-1,-1);
           disp([' pb avec ' nametrip ' condition ' namedebut{i}]);
    else
        meanVolant = mean(anglevolant(indexdebut:indexfin));
        maxVolant = max(anglevolant(indexdebut:indexfin));
        minVolant= min(anglevolant(indexdebut:indexfin));
        stdVolant= std(anglevolant(indexdebut:indexfin));
        heureGMT0 = heureGMT{indexdebut};
        fprintf(idfileres,'\t%f\t%s\t%f\t%f\t%f\t%f', dureeSeq,heureGMT0, meanVolant,maxVolant,minVolant,stdVolant);
    end
    
end
fprintf(idfileres,'\n');

delete(trip);
%lengthcomments = cellfun('length',comments);
%indexComment = find(lengthcomments>1);
% commentslus = comments(indexComment)';

fprintf(idfileres,'\n');  


output_args = 1;
