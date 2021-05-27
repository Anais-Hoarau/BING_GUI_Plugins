function cap_filtre = filtrer_donnees_cap(cap)
N=length(cap);
index_list=(1:1:N);
cap_filtre=cap;

    %interpollation linear des zones cap==0 -> perte de siganl gps
    index_zero = index_list(cap==0);
    index_zero_debut_fin=filtrer_index(index_zero);
    for i=1:1:1%length(index_zero_debut_fin)
        index_debut=index_zero_debut_fin(i,1);
        index_fin=index_zero_debut_fin(i,2);
        pas= (cap(index_fin+1)-cap(index_debut-1))/(index_fin - index_debut+2);
        
        cap_filtre(index_debut:index_fin) = (cap(index_debut-1)+pas : pas : cap(index_fin+1)-pas);     
    end
    
%     index_dis=index_list(abs(diff(cap_filtre))>100)
%     N_dis=length(index_dis);
%     if mod(N,2)==0
%         for ii=1:1:floor(N_dis/2)
%             cap(index_dis(2*i-1)-1)
%             if cap(index_dis(2*i-1)-1)>350
%             cap_filtre(index_dis(2*i-1):index_dis(2*i)) = cap_filtre(index_dis(2*i-1):index_dis(2*i)) +360;
%             else
%             cap_filtre(index_dis(2*i-1):index_dis(2*i)) = cap_filtre(index_dis(2*i-1):index_dis(2*i)) -360;    
%             end
%         end
%     else
%         disp('erreur dans le filtrage des discontinuité du cap');
%     end    
        


end
