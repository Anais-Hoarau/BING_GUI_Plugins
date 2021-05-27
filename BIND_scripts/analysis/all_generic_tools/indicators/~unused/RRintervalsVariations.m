% calculate RRintervals Variations
function RRintervalsVariations(trip, startTime, endTime, cas_situation)

MP150_dataOccurences = trip.getDataOccurencesInTimeInterval('MP150_data', startTime, endTime);
RRintervals = cell2mat(MP150_dataOccurences.getVariableValues('RRintervals'));

varRRintervals = std(RRintervals);
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations des intervals RR = ' num2str(varRRintervals) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'RRinter_var', startTime, endTime, varRRintervals);

end