% fonction qui extrait les seuils de frein qui nous vont bien
% tc: liste de time codes
% value: liste de valeurs associées
% window_tc: durée maximale (exprimée dans l'unité des tc) entre le début
% du premier top et la fin du troisième top. 5 secondes ou 5000 ms semble
% correct.
function tops = extract_seuils_frein_intelligent(tc,value,maximum_window_tc)
    % calcule les zones où l'on a franchi la valeur 0.5
    appuis = cherche_tc_franchissement_seuil(tc,value,0.5);
    
    % cherche les indices correspondants à une succession de trois appuis
    % dont la durée totale est inférieure à maximum_window_tc
    % (fin de l'appui 3 - début de l'appui 1 < maximum_window_tc)
    indices = find(appuis(3:end,2) - appuis(1:end-2,1) < maximum_window_tc);
    
    % Pour chacun de ces indices (normalement un au début de la manip, un à
    % la fin)...
    len_tops = length(indices);
    for i = 1:len_tops
        % enrichit la structure tops pour ajouter les infos des timecodes
        % de début et de fin de ces trois appuis.
        tops(i).appuis = appuis(indices(i):indices(i)+2,:);
    end
    
end
