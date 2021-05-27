%cette fonction calcule la sinuosit� d'une route � partir d'un relev� de
%coordonn�es GPS

% inputs : latitude , longitude [1xN](en degr� d�cimaux) et l'ordre (nombre
% de points avant et apr�s utilis�s pour calculer la sinuosit�). On pourra
% par la suite calculer un indicateur de sinuosit� moyenne sur plusieur
% ordre

%fonction utilis�e : vdist (calcul de distance entre de points GPS dans le
%syst�me de coordonn�es WS84...

function [sinuosity]=calculer_sinuosite(latitude,longitude,ordre)
        
        %calcul de la distance entre chaque point : array de dimension [1xN-1]
        % remarque si la distance est trop grande entre de point (perte du
        % signal GPS, la valeur pr�c�dente est conserv�e.
        
        distance=zeros(1,length(latitude)-1);
        for i=1:1:(length(latitude)-1)
        distance(i)=vdist(latitude(i),longitude(i),latitude(i+1),longitude(i+1));
        end
        

        %calcul de la sinuosit� : array de dimension [1 x N-2*ordre]
        sinuosity=zeros(1,(length(latitude)));
        for i=(ordre+1):1:(length(latitude)-ordre) 
            sinuosity(i)= calculer_distance_curviligne(i,distance,ordre)/(vdist(latitude(i-ordre),longitude(i-ordre),latitude(i+ordre),longitude(i+ordre)));
        end
end




% 
% function distance_curv = calculer_distance_curviligne(indice,distance,ordre)
%     distance_curv=0;
%     for i=1:1:ordre
%     distance_curv = distance_curv + distance(indice-i)+distance(indice+(i-1));
%     end
% end




