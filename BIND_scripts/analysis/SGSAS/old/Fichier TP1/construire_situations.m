function construire_situations(chemin_trip)
    % on ouvre un fichier trip
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

    % A FAIRE...
    %% R�cup�rer les commentaires
    
    %% filtrer les commentaires et les apparier 2 par 2
    
    %% r�cup�rer les timecodes de d�but et de fin
    
    %% cr�er les situations correspondantes
    
    % cr�er les m�ta situations
    % cr�er les instances (remplir les lignes)
    
    
    % On ferme le trip (penser � bien fermer le trip syst�matiquement !!! pour
    % �viter des messages d'erreur apr�s)
    delete(trip);
end