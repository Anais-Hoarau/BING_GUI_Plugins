function [ output_args ] = calculPerfVIT2(numsuj, track , typedrt, nametrip,idfileres, nametaches, namedebut , namefin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%fprintf(idfileres,'IdSujet\tTrack\tTypeDRT\tCondition\tVitesse\n');

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(nametrip, 0.04, true);


data = trip.getAllDataOccurences('localisation');
comments = data.getVariableValues('commentaires');
timecode  = cell2mat(data.getVariableValues('timecode'));
vitesse = cell2mat(data.getVariableValues('vitesse'));


for i=1:length(namedebut)
    indexdebut =find(cellfun('length',strfind(comments,namedebut{i}))); %#ok<*EFIND>
    indexfin =find(cellfun('length',strfind(comments,namefin{i})));  
    if isempty(indexdebut) || isempty(indexfin) 
          fprintf(idfileres,'%f\t%s\t%s\t%s\t%f\n', -1, '-1','-1','-1',-1);
           disp([' pb avec ' nametrip ' condition ' namedebut{i}]);
    else
 %       dureeSeq = timecode(indexfin) - timecode(indexdebut);
         for j=(indexdebut:indexfin)
            fprintf(idfileres,'%f\t%s\t%s\t%s\t%f\n', numsuj, track , typedrt, nametaches{i}, vitesse1s(j));
         end;
    end
    
end


delete(trip);
%lengthcomments = cellfun('length',comments);
%indexComment = find(lengthcomments>1);
% commentslus = comments(indexComment)';




output_args = 1;
