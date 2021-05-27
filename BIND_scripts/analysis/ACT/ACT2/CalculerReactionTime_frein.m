function [reactionTime_frein] = CalculerReactionTime_frein(timecode,frein,Essai)
N=size(Essai,1);
reactionTime_frein = NaN(N,6); 
% la premi�re colonne correspond � l'indice appui frein
% la deuxi�me au temps de r�action (ms) de l'appui frein
% la troisi�me colonne correspond au timecode globlable de l'appui frein
% la premi�re colonne correspond � l'indice du relachement frein
% la deuxi�me au temps de r�action (ms) du relachement frein
% la troisi�me colonne correspond au timecode globlable du relachement frein

for i_essai=1:1:N
    freinage_found=0;
    arret_found=0;
%    if Essai(i_essai,3)==2 ||  Essai(i_essai,3)==8 
        %% Recup�ration de la variable acc�l�rateur sur la plage de l'essai
        mask_id = timecode>Essai(i_essai,1) & timecode<Essai(i_essai,2)+5; % on cherche le relachement du frein jusqu'� 5s apr�s l'essai
        timecode_essai = timecode(mask_id);
        frein_essai = frein(mask_id);
        

        %% Calcul du temps de r�action
        for ii =2:1:length(frein_essai)-4                      
            % d�tection frein
            if (frein_essai(ii)>0)&&(frein_essai(ii-1)==0)&&(frein_essai(ii+4)>1) && freinage_found==0
                id_freinage =ii;
                freinage_found=1;
            end
            %arret freinage
            if (frein_essai(ii+3)==0)&&(frein_essai(ii+2)>0)&&(frein_essai(ii-1)>=1) && arret_found==0
                id_arret =ii+4;
                arret_found=1;
            end
            %d�c�leration

            
        end
        
        if freinage_found==0
            reactionTime_frein(i_essai,1) = nan;
            reactionTime_frein(i_essai,2) = nan;
            reactionTime_frein(i_essai,3) = nan;
        else
            reactionTime_frein(i_essai,1) = (id_freinage+1) + Essai(i_essai,4);
            reactionTime_frein(i_essai,2) = timecode_essai(id_freinage);
            reactionTime_frein(i_essai,3) = 1000*(timecode_essai(id_freinage+1)-Essai(i_essai,1)); % le temps de reaction est donn� es ms
        end
        
        if arret_found==0
            reactionTime_frein(i_essai,4) = nan;
            reactionTime_frein(i_essai,5) = nan;
            reactionTime_frein(i_essai,6) = nan;
        else
            reactionTime_frein(i_essai,4) = id_arret + Essai(i_essai,4);
            reactionTime_frein(i_essai,5) = timecode_essai(id_arret);
            reactionTime_frein(i_essai,6) = 1000*(timecode_essai(id_arret)-Essai(i_essai,1)); % le temps de reaction est donn� es ms
        end

%     else
%         reactionTime_frein(i_essai,1) = nan;
%         reactionTime_frein(i_essai,2) = nan;
%         reactionTime_frein(i_essai,3) = nan;
%         reactionTime_frein(i_essai,4) = nan;
%         reactionTime_frein(i_essai,5) = nan;
%         reactionTime_frein(i_essai,6) = nan;
%     end
end

end