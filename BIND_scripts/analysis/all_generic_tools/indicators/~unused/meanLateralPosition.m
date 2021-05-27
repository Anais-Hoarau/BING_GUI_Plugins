% calcul de la moyenne des positions lat�rales du VP par c�t�
function meanLateralPosition(trip, startTime, endTime, cas_situation)
    
    trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
    PositionLateraleVP = cell2mat(trajectoireVPOccurences.getVariableValues('voie'))'-1750; % -1750 sur route et -2500 sur autoroute
    
    MeanDepLat = mean(PositionLateraleVP)/1000;
    disp(['[' num2str(startTime) ';' num2str(endTime) '] moyenne de position lat�rale = ' num2str(MeanDepLat) ' m']);
    trip.setSituationVariableAtTime(cas_situation, 'posLat_moy', startTime, endTime, MeanDepLat);
    
    MeanDepLatNeg = mean(PositionLateraleVP<0)/1000;
    disp(['[' num2str(startTime) ';' num2str(endTime) '] moyenne de position lat�rale gauche = ' num2str(MeanDepLatNeg) ' m']);
    trip.setSituationVariableAtTime(cas_situation, 'posLatG_moy', startTime, endTime, MeanDepLatNeg);
    
    MeanDepLatPos = mean(PositionLateraleVP>0)/1000;
    disp(['[' num2str(startTime) ';' num2str(endTime) '] moyenne de position lat�rale droite = ' num2str(MeanDepLatPos) ' m']);
    trip.setSituationVariableAtTime(cas_situation, 'posLatD_moy', startTime, endTime, MeanDepLatPos);
    
end