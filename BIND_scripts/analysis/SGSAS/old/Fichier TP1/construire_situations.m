function construire_situations(chemin_trip)
    % on ouvre un fichier trip
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

    % A FAIRE...
    %% Récupérer les commentaires
    
    %% filtrer les commentaires et les apparier 2 par 2
    
    %% récupérer les timecodes de début et de fin
    
    %% créer les situations correspondantes
    
    % créer les méta situations
    % créer les instances (remplir les lignes)
    
    
    % On ferme le trip (penser à bien fermer le trip systématiquement !!! pour
    % éviter des messages d'erreur après)
    delete(trip);
end