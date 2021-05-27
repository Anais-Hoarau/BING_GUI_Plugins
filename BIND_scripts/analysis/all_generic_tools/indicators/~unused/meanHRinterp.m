% calculate mean HRinterp
function meanHRinterp(trip, startTime, endTime, cas_situation)

MP150_dataOccurences = trip.getDataOccurencesInTimeInterval('MP150_data', startTime, endTime);
HRinterp = cell2mat(MP150_dataOccurences.getVariableValues('HRinterp'));

meanHRinterp = mean(HRinterp);
disp(['[' num2str(startTime) ';' num2str(endTime) '] HRinterp moyen = ' num2str(meanHRinterp) ' bpm']);
trip.setSituationVariableAtTime(cas_situation, 'HRinterp_moy', startTime, endTime, meanHRinterp);

end