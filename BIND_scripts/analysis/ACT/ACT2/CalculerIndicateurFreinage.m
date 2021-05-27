function [deceleration,vitesse_deb,vitesse_ini,distance_freinage,duree_freinage,TIV_frein,TTC_frein]=CalculerIndicateurFreinage(timecode,Essai,ReactionTime_frein,pk,vitesse,TIV,TTC)

N = size(ReactionTime_frein,1);

TIV_frein = NaN(N,1);
TTC_frein = NaN(N,1);
duree_freinage = NaN(N,1);

deceleration = NaN(N,2);
vitesse_deb = NaN(N,1);
vitesse_ini = NaN(N,1);
distance_freinage = NaN(N,1);

for i=1:1:N
    indice_Essai_deb =  Essai(i,4);
    indice_Essai_fin =  Essai(i,5);
    indice_TR_frein = ReactionTime_frein(i,1);
    indice_Relachement_frein = ReactionTime_frein(i,4)-1;
    
   vitesse_deb(i) = vitesse(indice_Essai_deb-1);% le -1 a été ajouté par faire correspondre les résultats à la feuille excel... il n'est pas vraiment justifié
    
    if ~isnan(indice_TR_frein)       
        TIV_frein(i) = TIV(indice_TR_frein);
        TTC_frein(i) = TTC(indice_TR_frein);
        vitesse_ini(i) = vitesse(indice_TR_frein);
    else
        TIV_frein(i) = nan;
        TTC_frein(i) = nan;
        vitesse_ini(i) = nan;
    end
    
    if ~isnan(indice_TR_frein) && ~isnan(indice_Relachement_frein)
        duree_freinage(i) =  timecode(indice_Relachement_frein) - timecode(indice_TR_frein);
        distance_freinage(i) = abs((pk(indice_Relachement_frein) - pk(indice_TR_frein)))/1000;
        deceleration(i,1) = vitesse_ini(i)^2/(2* distance_freinage(i));
        deceleration(i,2) = ( vitesse_ini(i)^2 - vitesse(indice_Relachement_frein)^2 )/(2* distance_freinage(i));
    else
        duree_freinage(i) = nan;
        distance_freinage(i) = nan;
        deceleration(i,1) = nan;
        deceleration(i,2) = nan;
    end   
    
    
    
end

end