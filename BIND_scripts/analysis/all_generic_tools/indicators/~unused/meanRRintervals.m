% calculate mean RRintervals
function meanRRintervals(trip, startTime, endTime, cas_situation)

MP150_dataOccurences = trip.getDataOccurencesInTimeInterval('MP150_data', startTime, endTime);
RRintervals = cell2mat(MP150_dataOccurences.getVariableValues('RRintervals'));

meanRRintervals = mean(RRintervals);
disp(['[' num2str(startTime) ';' num2str(endTime) '] interval RR moyen = ' num2str(meanRRintervals) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'RRinter_moy', startTime, endTime, meanRRintervals);

end