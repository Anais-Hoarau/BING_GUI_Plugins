function Remplir_Situation(chemin_trip,NomSituation)

% on ouvre un fichier trip
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

%Recupère les occurences de la situation 'NomStiuation'
NomSituation_liste=trip.getAllSituationOccurences(NomSituation);
%Extrait les time de début et de fin
startTimecode_situation_liste=NomSituation_liste.getVariableValues('startTimecode');
endTimecode_situation_liste=NomSituation_liste.getVariableValues('endTimecode');

%initialisation des cell arrays
vitesse_moyenne_Situation_NomSituation=cell(1,length(startTimecode_situation_liste));
PedaleAcc_Situation_NomSituation=cell(1,length(startTimecode_situation_liste));
PedaleFrein_Situation_NomSituation=cell(1,length(startTimecode_situation_liste));



for i=1:length(startTimecode_situation_liste)


vitesse_Situation_Nomsituation = trip.getDataOccurencesInTimeInterval('vitesse',startTimecode_situation_liste{i},endTimecode_situation_liste{i});
trajectoire_Situation_Nomsituation = trip.getDataOccurencesInTimeInterval('trajectoire',startTimecode_situation_liste{i},endTimecode_situation_liste{i});

%'timecode', 'vitesse', 'Acc' , 'Frein', 'voie'
cell_timecode_Situation_NomSituation = vitesse_Situation_Nomsituation.getVariableValues('timecode');
cell_vitesse_Situation_NomSituation = vitesse_Situation_Nomsituation.getVariableValues('vitesse');
cell_PedaleAcc_Situation_NomSituation = vitesse_Situation_Nomsituation.getVariableValues('accélérateur');
cell_PedaleFrein_Situation_NomSituation = vitesse_Situation_Nomsituation.getVariableValues('frein');
cell_voie_Situation_NomSituation = trajectoire_Situation_Nomsituation.getVariableValues('voie');

% on convertit en matrice pour utiliser les fonctions matlab
mat_vitesse_Situation_NomSituation = cell2mat(cell_vitesse_Situation_NomSituation);
mat_PedaleAcc_Situation_NomSituation = cell2mat(cell_PedaleAcc_Situation_NomSituation);
mat_PedaleFrein_Situation_NomSituation = cell2mat(cell_PedaleFrein_Situation_NomSituation);
mat_voie_Situation_NomSituation = cell2mat(cell_voie_Situation_NomSituation);
mat_timecode_Situation_NomSituation = cell2mat(cell_timecode_Situation_NomSituation);

% on calcule la moyenne sur la mat_vitesse_non_nulle
vitesse_moyenne_Situation_NomSituation{i} = 3.6* mean(mat_vitesse_Situation_NomSituation);
PedaleAcc_Situation_NomSituation{i} = mean(mat_PedaleAcc_Situation_NomSituation);    
PedaleFrein_Situation_NomSituation{i} = mean(mat_PedaleFrein_Situation_NomSituation);    

Derive_voie_Situation = diff(mat_voie_Situation_NomSituation) ./ diff(mat_timecode_Situation_NomSituation);
Derive_voie_Situation = [Derive_voie_Situation 0];

        if (max(abs(Derive_voie_Situation))> 2e4)
            StdVoie_Situation_NomSituation{i} = -1;% changement de voie
        else
            StdVoie_Situation_NomSituation{i} = std(mat_voie_Situation_NomSituation); % ecart type voie
        end



    
end

if isempty(startTimecode_situation_liste)
else
%Peuple les instance de situations avec le vitesse moyenne calculée
trip.setBatchOfTimeSituationVariableTriplets(NomSituation,'vitesse_moy',[startTimecode_situation_liste ; endTimecode_situation_liste ; vitesse_moyenne_Situation_NomSituation])
trip.setBatchOfTimeSituationVariableTriplets(NomSituation, '%PedaleAcc',[startTimecode_situation_liste ; endTimecode_situation_liste ; PedaleAcc_Situation_NomSituation])
trip.setBatchOfTimeSituationVariableTriplets(NomSituation, '%PedaleFrein',[startTimecode_situation_liste ; endTimecode_situation_liste ; PedaleFrein_Situation_NomSituation])
trip.setBatchOfTimeSituationVariableTriplets(NomSituation, 'VarVoie',[startTimecode_situation_liste ; endTimecode_situation_liste ; StdVoie_Situation_NomSituation])
end
% On ferme le trip (penser à bien fermer le trip systématiquement !!! pour
    % éviter des messages d'erreur après)
    
 %setTimeSituationTriplets (pour insérer situation non batch)
delete(trip);







end