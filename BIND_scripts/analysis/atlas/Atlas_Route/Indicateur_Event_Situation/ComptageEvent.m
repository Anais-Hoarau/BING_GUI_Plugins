% Cette fonction compte le notre d'évenments dans chaque situation. 


% Inputs :
%
% Events - cell array de N éléments : N étant le nombre
% de type d'évenement différent. Chaque élément de ce cell array est un
% array de timecode:
% situation_statTimecode - timecode du début de situation
% situation_endTimecode - timecode de fin de situation
% 
% Outputs :
% NbreEvent - array donnant le d'event contenu dans chaque situation
%

function NbreEvent = ComptageEvent(Events,situation_statTimecode,situation_endTimecode)
    
    N= length(Events);
    NbreEvent=zeros(1,N);
    
    for i=1:1:N
        
        for j=1:1:length(Events{i})
            
            if  (Events{i}(j)> situation_statTimecode) && (Events{i}(j) < situation_endTimecode)
                NbreEvent(i)=NbreEvent(i)+1;
            end
        end
    end
    
end