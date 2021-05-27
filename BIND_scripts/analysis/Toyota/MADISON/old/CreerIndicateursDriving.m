       
function [IndDriving] = CreerIndicateursDriving(CabValues_timecode,VoieValues_timecode,dtValues,tempsevent)

IndDriving = [];
Durees = [60 120]; % indiquer les tailles des fenêtres à utiliser
Debutfenetre = [30 60]; % indiquer le décalages des fenêtres par rapport à l'evenement
dtValues = dtValues';

for debut=1:length(Debutfenetre)
    tempsdebutfenetre = tempsevent + Debutfenetre(debut);
    
    for duree=1:length(Durees)
        Intervalle = find(CabValues_timecode(:,1)>tempsdebutfenetre & CabValues_timecode(:,1)<(tempsdebutfenetre+Durees(duree)));
        CabValues_timecode = CabValues_timecode(Intervalle,:);
        VoieValues_timecode = VoieValues_timecode(Intervalle,:);
        dtValues_timecode = dtValues(Intervalle,:);
        SDLP = std(abs(VoieValues_timecode(:,2)).*dtValues_timecode);
        SDWA = std(abs(CabValues_timecode(:,2)*360/7500).*dtValues_timecode);
        % SRR = 
        IndDriving = [IndDriving SDLP SDWA SRR];
    end
end

                    

    
    
