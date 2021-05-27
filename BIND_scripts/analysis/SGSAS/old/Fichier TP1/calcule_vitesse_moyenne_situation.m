function calcule_vitesse_moyenne_situation(chemin_trip)
    % on ouvre un fichier trip
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

    % A FAIRE...
    
    % récupérer la liste des situations
    % pour chaque situation : calculer la vitesse moyenne sur cette
    % situation
    % récupérer la valeur de la vitesse entre les deux timecodes de début
    % et de fin de la situation.
    
    
    % On ferme le trip (penser à bien fermer le trip systématiquement !!! pour
    % éviter des messages d'erreur après)
    delete(trip);
end