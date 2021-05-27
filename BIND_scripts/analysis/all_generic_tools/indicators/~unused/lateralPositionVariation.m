% calcul des variations de positions latérales du VP (standard déviation)
function lateralPositionVariation(trip, startTime, endTime, cas_situation)

trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
PositionLateraleVP = cell2mat(trajectoireVPOccurences.getVariableValues('voie'))'-1750; % -1750 sur route et -2500 sur autoroute

varDepLat = std(PositionLateraleVP);
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations de position latérale = ' num2str(varDepLat/1000) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'posLat_var', startTime, endTime, varDepLat/1000);

end