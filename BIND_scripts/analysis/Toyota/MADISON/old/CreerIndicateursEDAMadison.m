function [INDDermale] = CreerIndicateursEDAMadison(tempsevent,temps_DEBUT,i)

Durees = [60 120]; % indiquer les tailles des fenêtres à utiliser
Debutfenetre = [30 60]; % indiquer le décalages des fenêtres par rapport à l'evenement
tempseventrefEDA = tempsevent-temps_DEBUT;
INDDermale =[];

%changer nom dossier en fonction de ce qu'on veut changer
nom=['D:\hidalgo\Desktop\MADISON 2\EDA_Ptest' '_scrlist.xls']
[data, text]=xlsread(nom,2);
        
for debut=1:length(Debutfenetre)
    tempsdebutfenetre = tempseventrefEDA + Debutfenetre(debut);
    
    for duree=1:length(Durees)
        fintempsevent = tempsdebutfenetre + Durees(duree);
        scrs = find(data(:,1)>tempsdebutfenetre & data(:,1)<fintempsevent);
        nombre_scrs = numel(scrs);
        amplitude_moy = mean (data(scrs,2));
        ecart_type_amp = std(data(scrs,2));
        index_pic_max = find(max(data(scrs,2)));
        latence_pic_max=data(scrs(index_pic_max,1));
        latence_premier = data(scrs(1),1);
        latence_moy = mean(diff(data(scrs,1)));
        INDDermale =[INDDermale nombre_scrs amplitude_moy ecart_type_amp latence_premier latence_moy ];  
        
    end
end