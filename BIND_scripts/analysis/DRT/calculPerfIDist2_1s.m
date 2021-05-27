function [ output_args ] = calculPerfIDist2_1s(numsuj, track , typedrt, nametrip,idfileres, nametaches, namedebut , namefin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%fprintf(idfileres,'IdSujet\tTrack\tTypeDRT\tCondition\tVitesse\n');

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(nametrip, 0.04, true);


data = trip.getAllDataOccurences('localisation');
comments = data.getVariableValues('commentaires');
timecode  = cell2mat(data.getVariableValues('timecode'));
pk = cell2mat(data.getVariableValues('pk'));
ciblepk = cell2mat(data.getVariableValues('ciblepk'));

for i=1:length(namedebut)
    indexdebut =find(cellfun('length',strfind(comments,namedebut{i}))); %#ok<*EFIND>
    indexfin =find(cellfun('length',strfind(comments,namefin{i})));  
    if isempty(indexdebut) || isempty(indexfin) 
          fprintf(idfileres,'%f\t%s\t%s\t%s\t%f\n', -1, '-1','-1','-1',-1);
           disp([' pb avec ' nametrip ' condition ' namedebut{i}]);
    else
 %       dureeSeq = timecode(indexfin) - timecode(indexdebut);
        Pk1s = interp1(timecode(indexdebut:indexfin),pk(indexdebut:indexfin),timecode(indexdebut):1:timecode(indexfin),'linear');
        cPk1s = interp1(timecode(indexdebut:indexfin),ciblepk(indexdebut:indexfin),timecode(indexdebut):1:timecode(indexfin),'linear');    
        interdistance = cPk1s-Pk1s-4000; % 4000 correspond à la somme des demi-longueurs des deux véhicules car pk et c.pk 
                                   % mesurés aux centres de gravité des véhicules
       for j=1:length(Pk1s)
            fprintf(idfileres,'%f\t%s\t%s\t%s\t%f\t%f\t%f\n', numsuj, track , typedrt, nametaches{i}, Pk1s(j),cPk1s(j),interdistance(j));
       end;
    end
    
end


delete(trip);
%lengthcomments = cellfun('length',comments);
%indexComment = find(lengthcomments>1);
% commentslus = comments(indexComment)';




output_args = 1;
