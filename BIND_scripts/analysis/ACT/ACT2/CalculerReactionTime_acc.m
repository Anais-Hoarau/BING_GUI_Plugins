function [reactionTime_acc] = CalculerReactionTime_acc(timecode,acc,acc_filt,Essai)
denominateur_seuil = 2.5;
taille_fg = 4;
N=size(Essai,1);
reactionTime_acc = NaN(N,3); 
% la première colonne correspond à l'indice appui frein
% la deuxième au temps de réaction (ms) de l'appui frein
% la troisième colonne correspond au timecode globlable de l'appui frein
% la quatrième correspond à la valeur de l'accélérateur en début d'essai

d_acc = diff(acc);
d_acc_filt = diff(acc_filt);

d_acc(d_acc>0)=0;
d_acc_filt(d_acc_filt>0)=0;

d_acc = abs(d_acc);
d_acc_filt = abs(d_acc_filt);

moyenne_gene = mean(d_acc_filt(d_acc_filt~=0));


for i_essai=1:1:N
%   if Essai(i_essai,3)==2 ||  Essai(i_essai,3)==8
        %% Recupération de la variable accélérateur sur la plage de l'essai
        mask_id = timecode>Essai(i_essai,1) & timecode<Essai(i_essai,2);
        timecode_essai = timecode(mask_id);
        
        acc_essai = acc(mask_id);
        acc_filt_essai = acc_filt(mask_id);
        
        d_acc_essai = diff(acc_essai);
        d_acc_filt_essai = diff(acc_filt_essai);
        
        d_acc_essai(d_acc_essai>=0) = nan;
        d_acc_filt_essai(d_acc_filt_essai>=0)=nan;
        
        d_acc_essai = abs(d_acc_essai);
        d_acc_filt_essai = abs(d_acc_filt_essai);
        
        Seuil = max(d_acc_filt_essai)/denominateur_seuil;
        
        TR_found=0;
        %% Calcul du temps de réaction
        for ii =1:1:length(d_acc_filt_essai)-taille_fg
            % moyenne sur 5 points
            d_acc_filt_essai_plage=d_acc_filt_essai(ii:ii+taille_fg);
            d_acc_filt_essai_moy5 = sum(d_acc_filt_essai_plage(~isnan(d_acc_filt_essai_plage)))/length(d_acc_filt_essai_plage(~isnan(d_acc_filt_essai_plage)));
            
            % détection temps de réaction
            if  (Seuil > moyenne_gene) && (d_acc_filt_essai_moy5 > Seuil) && (TR_found==0)
                
                if ii+6 > size(timecode_essai,1)
                    id_TR = size(timecode_essai,1); 
                else
                    id_TR =ii+6;
                end
                TR_found=1;
            end 

        end
        
        if TR_found==0
            reactionTime_acc(i_essai,1) = nan;
            reactionTime_acc(i_essai,2) = nan;
            reactionTime_acc(i_essai,3) = nan;
            reactionTime_acc(i_essai,4) = acc_essai(1);
        else
            reactionTime_acc(i_essai,1) = id_TR + Essai(i_essai,4);
            reactionTime_acc(i_essai,2) = timecode_essai(id_TR);
            reactionTime_acc(i_essai,3) = 1000*(timecode_essai(id_TR)-Essai(i_essai,1)); % le temps de reaction est donné es ms   
            reactionTime_acc(i_essai,4) = 100*acc_essai(1)/255;
        end
%     else
%         reactionTime_acc(i_essai,1) = nan;
%         reactionTime_acc(i_essai,2) = nan;
%         reactionTime_acc(i_essai,3) = nan;
%     end
end

end