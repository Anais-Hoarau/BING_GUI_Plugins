% calcul moyenne d'acc�l�ration/d�c�l�ration du VP et dur�es
function meanAccelDecel(trip, startTime, endTime, cas_situation)

vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
AccVP = cell2mat(vitesseVPOccurences.getVariableValues('acceleration'));

%calculs sur acc�l�ration
mask_Acc = AccVP>0;
meanAccVP = mean(AccVP(mask_Acc));
disp(['[' num2str(startTime) ';' num2str(endTime) '] Acc�l�ration moyenne = ' num2str(meanAccVP) ' m/s�']);
trip.setSituationVariableAtTime(cas_situation, 'accel_moy', startTime, endTime, meanAccVP);

mask_Dec = AccVP<0;
meanDecVP = mean(AccVP(mask_Dec));
disp(['[' num2str(startTime) ';' num2str(endTime) '] D�c�leration moyenne = ' num2str(meanDecVP) ' m/s�']);
trip.setSituationVariableAtTime(cas_situation, 'decel_moy', startTime, endTime, meanDecVP);
end