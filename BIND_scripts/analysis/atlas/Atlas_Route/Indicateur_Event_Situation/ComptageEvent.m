% Cette fonction compte le notre d'�venments dans chaque situation. 


% Inputs :
%
% Events - cell array de N �l�ments : N �tant le nombre
% de type d'�venement diff�rent. Chaque �l�ment de ce cell array est un
% array de timecode:
% situation_statTimecode - timecode du d�but de situation
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