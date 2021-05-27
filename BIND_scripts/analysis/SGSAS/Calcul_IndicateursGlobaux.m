function Calcul_IndicateursGlobaux(chemin_trip)

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

%on recupère les record 'vitesse' et 'trajectoire'
record_vitesse = trip.getAllDataOccurences('vitesse');
record_trajectoire = trip.getAllDataOccurences('trajectoire');

%on récupère les data qui nous intéresse
try
data_vitesse = record_vitesse.buildCellArrayWithVariables({'timecode' 'vitesse' 'accelerateur' 'frein' 'embrayage'});
catch
data_vitesse = record_vitesse.buildCellArrayWithVariables({'timecode' 'vitesse' 'accélérateur' 'frein' 'embrayage'});
end

data_trajectoire = record_trajectoire.buildCellArrayWithVariables({'voie' 'angleVolant'});

%calcul de la vitesse moyenne pour les vitesses non nulles (v>2km/h)
mat_vitesse = 3.6 * cell2mat(data_vitesse(2,:));
mat_vitesse_nn = mat_vitesse(mat_vitesse>2);
vitesse_moyenne = mean(mat_vitesse_nn);

%calcul '%' d'enfoncement pedale
Acc = (100/255)*cell2mat(data_vitesse(3,:));
Frein = (100/255)*cell2mat(data_vitesse(4,:));
Embr = (100/255)*cell2mat(data_vitesse(5,:));
PedaleAcc = mean(Acc);
PedaleFrein = mean(Frein);
PedaleEmbr = mean(Embr);

%calcul SdtDev
PositionVoie=cell2mat(data_trajectoire(1,:));
PositionVoie_std = std(PositionVoie);

AngleVolant=cell2mat(data_trajectoire(2,:));
AngleVolant_std=std(AngleVolant);

trip.setAttribute('Vitesse_moy',num2str(vitesse_moyenne));

trip.setAttribute('%AppuiAcc_moy',num2str(PedaleAcc));
trip.setAttribute('%AppuiFrein_moy',num2str(PedaleFrein));
trip.setAttribute('%AppuiEmbr_moy',num2str(PedaleEmbr));

trip.setAttribute('PositionVoie_std',num2str(PositionVoie_std));
trip.setAttribute('AngleVolant_std',num2str(AngleVolant_std));

% On ferme le trip (penser à bien fermer le trip systématiquement !!! pour éviter des messages d'erreur après)
delete(trip);
end