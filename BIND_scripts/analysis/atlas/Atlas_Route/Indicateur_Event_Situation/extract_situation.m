%Cette fonction traite le signal TopConsigne pour en extraire uniquement le top
% des situations à la valeur de tension souhiatée



% Inputs : array 'timecode', array 'TopConsigne', valeur de la tension
% correspondant à la situation à traiter, un seuil de temps minimun pour la
% durée d'une situation (seconde)

% Output : array contenant uniquement le situation définit pour la tension
% définit en entrée

function Top_situation =extract_situation(timecode , TopConsigne, situation_value , seuil_temps)
    N=length(TopConsigne);
    index= 1:1:N;
    Top_situation =zeros(N,1);
    
    
    %la valeur du seuil de tension pour la détection de la situation
    %pourrait éventuellement être passée en argument d'entrée
    index_situation = index(TopConsigne>(situation_value -0.2) & TopConsigne<(situation_value +0.2));
    Top_situation(TopConsigne>(situation_value -0.2) & TopConsigne<(situation_value +0.2)) = situation_value;
    
    seuil_indice = 50*seuil_temps;
    
    indice_deb_fin(1,1) = index_situation(1);
    j=1;
    for i=1:1:length(index_situation)-1
              
        if index_situation(i+1)- index_situation(i)>seuil_indice
            indice_deb_fin(j,2) = index_situation(i);
            indice_deb_fin(j+1,1) = index_situation(i+1);
            j=j+1;
        end
        
    end
    indice_deb_fin(j,2) = index_situation(end);
    
    
    
    for ii=1:1:size(indice_deb_fin,1)
        Top_situation(indice_deb_fin(ii,1):indice_deb_fin(ii,2))=situation_value;
    end
   
    
%     index_dernierchangement=1;
%     changement=1;
%     
%     for i=1:1:(N-1)
%         
%         if Top_situation(i+1)~=Top_situation(i)
%             
%             if (timecode(i)-timecode(index_dernierchangement))<seuil_temps
%                 switch changement
%                     case 1
%                         Top_situation (index_dernierchangement:i)=0;
%                     case -1
%                         Top_situation (index_dernierchangement:i)=situation_value;
%                 end
%             end
%             
%             
%             if Top_situation(i+1)>Top_situation(i)
%                 changement=1;
%             else
%                 changement=-1;
%             end
%             
%             index_dernierchangement=i;
%         end
%     end
    
end