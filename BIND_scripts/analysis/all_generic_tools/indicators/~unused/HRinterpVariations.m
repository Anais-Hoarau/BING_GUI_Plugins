% calculate HRinterp variations
function HRinterpVariations(trip, startTime, endTime, cas_situation)

MP150_dataOccurences = trip.getDataOccurencesInTimeInterval('MP150_data', startTime, endTime);
HRinterp = cell2mat(MP150_dataOccurences.getVariableValues('HRinterp'));

HRinterpVar = std(HRinterp);
disp(['[' num2str(startTime) ';' num2str(endTime) '] Variations HRinterp = ' num2str(HRinterpVar) ' bpm']);
trip.setSituationVariableAtTime(cas_situation, 'HRinterp_var', startTime, endTime, HRinterpVar);

end