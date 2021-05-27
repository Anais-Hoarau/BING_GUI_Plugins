%% calcul du TIV minimum du VP
function minTIV(trip, startTime, endTime, cas_situation)

%Calculé par rapport au véhicule cible (-10)
PK_cibleOccurences = trip.getDataOccurencesInTimeInterval('cible', startTime, endTime);
PK_cible = cell2mat(PK_cibleOccurences.getVariableValues('pkCible'));
PK_cibleArret = PK_cible(find(diff(PK_cible)==0, 1));
PK_VPOccurences = trip.getDataOccurencesInTimeInterval('localisation', startTime, endTime);
PK_VP = cell2mat(PK_VPOccurences.getVariableValues('pk'));
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
vitessesVP = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));
TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));
TIV_arret = NaN;
i=1;
while PK_VP(i) < PK_cibleArret
    if vitessesVP(i) == 0
        TIV_arret = TIVs(i);
        break
    end
    i=i+1;
end
disp(['[' num2str(startTime) ';' num2str(endTime) '] TIV arret = ' num2str(TIV_arret) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'TIV_min', startTime, endTime, TIV_arret);

end