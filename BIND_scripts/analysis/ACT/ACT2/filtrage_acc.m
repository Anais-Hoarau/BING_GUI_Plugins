% Filtrage de la variable pedale d'accélérateur
% - on enlève les retour à zeros intenpestifs
% - on fait une moyenne glissante sur 

function [acc_filt] = filtrage_acc(acc,n_largeur,actif)
            if actif
                acc_filt = acc; 
                % Retour à zero intenpestif
                ind_acc_nz = find(acc~=0);
                for i=1:1:length(ind_acc_nz)-1
                    if ind_acc_nz(i+1) - ind_acc_nz(i) < 4
                        acc_filt(ind_acc_nz(i)+1 : ind_acc_nz(i+1)- 1) = (acc(ind_acc_nz(i+1)) + acc(ind_acc_nz(i)))/2;
                    end
                end
                ind_acc_z = find(acc==0);
                for i=1:1:length(ind_acc_z)-1
                    if ind_acc_z(i+1) - ind_acc_z(i) < 4
                        acc_filt(ind_acc_z(i)+1 : ind_acc_z(i+1)- 1) = 0;
                    end
                end

                %% Moyenne glissante
                % n_largeur = 4; %largeur de la moyenne glissant
                square = ones(n_largeur,1)/n_largeur;
                acc_filt = conv(acc_filt,square,'same');
                acc_filt(acc<2)=0;
            else
                acc_filt = acc;    
            end

end