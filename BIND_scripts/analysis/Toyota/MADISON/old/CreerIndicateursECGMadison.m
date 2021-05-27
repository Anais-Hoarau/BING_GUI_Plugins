function [INDCardiaque] = CreerIndicateursECGMadison(tempsevent,timecodePic,valRR,RR2,DRR2)

Durees = [30 60]; % indiquer les tailles des fenêtres à utiliser
Debutfenetre = [0 30]; % indiquer le décalages des fenêtres par rapport à l'evenement
INDCardiaque =[];

for debut=1:length(Debutfenetre)
    
    tempsdebutfenetre = tempsevent + Debutfenetre(debut);
    
    for duree=1:length(Durees)
        
        fintempsevent = tempsdebutfenetre + Durees(duree);
        
        % Calcul des indicateurs cardiaques
        
        indexValor = find(timecodePic>=tempsdebutfenetre & timecodePic<fintempsevent);
        
        RRMoy = mean(valRR(indexValor));
        RRMax = max(valRR(indexValor));
        RRMin = min(valRR(indexValor));
        SDNN = sqrt((sum(RR2(indexValor))) - length(indexValor)*RRMoy^2)/(length(indexValor)-1);
        % Pas besoin de vérifier si valRR est > 0, car cette verification
        % est déjà faite dans extractRR
        
        indexValor2 = find(timecodePic>=tempsdebutfenetre & timecodePic<fintempsevent);
        DRR2valides = DRR2(indexValor2);
        index_DRR2_positives = find(DRR2valides>0);
        DRR2valides_positives = DRR2valides(index_DRR2_positives);
        sumDDR2 = sum(DRR2valides_positives);
        RMSSD = sqrt(sumDDR2/(length(index_DRR2_positives)-1));
        
        indexValor = [];
        indexValor2 = [];
        
        INDCardiaque =[INDCardiaque 60/RRMoy SDNN RMSSD];  
        
    end
end
