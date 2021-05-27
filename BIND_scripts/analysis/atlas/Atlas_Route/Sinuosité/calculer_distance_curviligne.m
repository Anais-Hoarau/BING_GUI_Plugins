% Cette sous function permet de calculer la distance curviligne entre deux
% points. Cette dernière va etre obtenue en sommant les distance de i-ordre
% à i+ordre autour de point i
function distance_curv = calculer_distance_curviligne(indice,distance,ordre)
    distance_curv=0;
    for i=1:1:ordre
    distance_curv = distance_curv + distance(indice-i)+distance(indice+(i-1));
    end
end