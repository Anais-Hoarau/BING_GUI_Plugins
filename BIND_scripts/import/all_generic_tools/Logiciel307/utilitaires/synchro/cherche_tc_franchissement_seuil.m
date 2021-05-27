function tc_seuils = cherche_tc_franchissement_seuil(tc,valeur,seuil)

    indices_seuil = find(valeur>seuil);
    indices_indices_franchissement_seuil = find(indices_seuil(2:end) ~= indices_seuil(1:end-1) +1);
    
    tc_seuils = zeros(length(indices_indices_franchissement_seuil)+1,2);
    tc_seuils(1,1) = tc(indices_seuil(1));
    for i = 1:length(indices_indices_franchissement_seuil)
        %disp 'valeur avant fin seuil';
        %valeur(indices_seuil(indices_indices_franchissement_seuil(i)))
        %disp 'valeur de fin seuil';
        %valeur(1+indices_seuil(indices_indices_franchissement_seuil(i)))
        tc_seuils(i,2) = tc(1+indices_seuil(indices_indices_franchissement_seuil(i)));
        %disp 'valeur avant début seuil';
        %valeur(indices_seuil(1+indices_indices_franchissement_seuil(i))-1)
        %disp 'valeur de début seuil';
        %valeur(indices_seuil(1+indices_indices_franchissement_seuil(i)))
        tc_seuils(i+1,1) = tc(indices_seuil(1+indices_indices_franchissement_seuil(i)));
    end
    tc_seuils(end,2) = tc(indices_seuil(end));
    
end