function [ output_args ] = calculPerfIDist( nametrip, idfileres, namedebut , namefin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%namevar = { 'DureeSeq' ; 'sortieGap'};

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(nametrip, 0.04, true);


data = trip.getAllDataOccurences('localisation');

timecode  = cell2mat(data.getVariableValues('timecode'));
comments = data.getVariableValues('commentaires');

pk = cell2mat(data.getVariableValues('pk'));
cPk = cell2mat(data.getVariableValues('ciblepk'));
interdistance = cPk-pk-4000; % 4000 correspond à la somme des demi-longueurs des deux véhicules car pk et c.pk 
                                   % mesurés aux centres de gravité des véhicules

heureGMT  = data.getVariableValues('heureGMT');

for i=1:length(namedebut)
    indexdebut =find(cellfun('length',strfind(comments,namedebut{i})));
    indexfin =find(cellfun('length',strfind(comments,namefin{i})));
    dureeSeq = timecode(indexfin) - timecode(indexdebut);
    if isempty(indexdebut) || isempty(indexfin) 
          fprintf(idfileres,'\t%f\t%f\t%f\t%f\t%f', -1, -1,-1,-1,-1);
           disp([' pb avec ' nametrip ' condition ' namedebut{i}]);
    else
        meanIDist = mean(interdistance(indexdebut:indexfin));
        maxIDist = max(interdistance(indexdebut:indexfin));
        minIDist= min(interdistance(indexdebut:indexfin));
        stdIDist= std(interdistance(indexdebut:indexfin));
        heureGMT0 = heureGMT{indexdebut};
        fprintf(idfileres,'\t%f\t%s\t%f\t%f\t%f\t%f', dureeSeq,heureGMT0, meanIDist,maxIDist,minIDist,stdIDist);
    end
    
end
fprintf(idfileres,'\n');

delete(trip);
%lengthcomments = cellfun('length',comments);
%indexComment = find(lengthcomments>1);
% commentslus = comments(indexComment)';

fprintf(idfileres,'\n');  


output_args = 1;
