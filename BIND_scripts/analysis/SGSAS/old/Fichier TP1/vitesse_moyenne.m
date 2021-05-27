function vitesse_moyenne (chemin_trip)

    % on ouvre un fichier trip
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);
    % on charge la table 'vitesse'
    record = trip.getAllDataOccurences('vitesse');
    % dans la table vitesse, on récupère les valeurs de la colonne/variable
    % 'vitesse'
    cell_vitesse = record.getVariableValues('vitesse');
    % on convertit en matrice pour utiliser les fonctions matlab
    mat_vitesse = cell2mat(cell_vitesse);
    % on trouve les indices où la vitesse est non nulle
    ind_vitesse = find(mat_vitesse ~= 0);
    % on construit une matrice avec ces indices
    mat_vitesse_non_nulle = mat_vitesse(ind_vitesse);
    % on calcule la moyenne sur la mat_vitesse_non_nulle
    vitesse_moyenne = mean(mat_vitesse_non_nulle);
    % On affiche la vitesse moyenne dans la console
    disp(['Vitesse moyenne = ' num2str(vitesse_moyenne) 'm/s']);
    disp(['Vitesse moyenne = ' num2str(vitesse_moyenne*3.6) 'km/h']);
    % On enregistre la valeur de la vitesse en m/s dans une variable globale du
    % trip
    trip.setAttribute('VitesseMoyenne',num2str(vitesse_moyenne));
    % On ferme le trip (penser à bien fermer le trip systématiquement !!! pour
    % éviter des messages d'erreur après)
    delete(trip);


end