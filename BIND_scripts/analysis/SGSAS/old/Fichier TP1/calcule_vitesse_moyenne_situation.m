function calcule_vitesse_moyenne_situation(chemin_trip)
    % on ouvre un fichier trip
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

    % A FAIRE...
    
    % r�cup�rer la liste des situations
    % pour chaque situation : calculer la vitesse moyenne sur cette
    % situation
    % r�cup�rer la valeur de la vitesse entre les deux timecodes de d�but
    % et de fin de la situation.
    
    
    % On ferme le trip (penser � bien fermer le trip syst�matiquement !!! pour
    % �viter des messages d'erreur apr�s)
    delete(trip);
end