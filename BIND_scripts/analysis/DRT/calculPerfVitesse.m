function [ output_args ] = calculPerfVitesse( nametrip, idfileres, namedebut , namefin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%namevar = { 'DureeSeq' ; 'DebutSeqGMT' ;  'MoyVit'; 'MaxVit'; 'MinVit'; 'StdVit'; };

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(nametrip, 0.04, true);


data = trip.getAllDataOccurences('localisation');


timecode  = cell2mat(data.getVariableValues('timecode'));
comments = data.getVariableValues('commentaires');

vitesse = cell2mat(data.getVariableValues('vitesse'));
heureGMT  = data.getVariableValues('heureGMT');

for i=1:length(namedebut)
    indexdebut =find(cellfun('length',strfind(comments,namedebut{i})));
    indexfin =find(cellfun('length',strfind(comments,namefin{i})));
    dureeSeq = timecode(indexfin) - timecode(indexdebut);
    if isempty(indexdebut) || isempty(indexfin) 
          fprintf(idfileres,'\t%f\t%f\t%f\t%f\t%f', -1, -1,-1,-1,-1);
           disp([' pb avec ' nametrip ' condition ' namedebut{i}]);
    else
        meanSpeed = mean(vitesse(indexdebut:indexfin));
        maxSpeed = max(vitesse(indexdebut:indexfin));
        minSpeed = min(vitesse(indexdebut:indexfin));
        stdSpeed = std(vitesse(indexdebut:indexfin));
        heureGMT0 = heureGMT{indexdebut};
        fprintf(idfileres,'\t%f\t%s\t%f\t%f\t%f\t%f', dureeSeq,heureGMT0, meanSpeed,maxSpeed,minSpeed,stdSpeed);
    end
    
end
fprintf(idfileres,'\n');

delete(trip);
%lengthcomments = cellfun('length',comments);
%indexComment = find(lengthcomments>1);
% commentslus = comments(indexComment)';

fprintf(idfileres,'\n');  


output_args = 1;
