%% calculate number of self-report used and self-report filtered by "scenario" situation
function numberOfSelfReportsByScenario(trip, startTime, endTime, cas_situation)
    nbSR_byCL = trip.getSituationOccurencesInTimeInterval('conduite_libre', startTime, endTime).getVariableValues('nbSR');
    nbSRFiltr_byCL = trip.getSituationOccurencesInTimeInterval('conduite_libre', startTime, endTime).getVariableValues('nbSRFiltr');
    nbSR_tot = sum(cell2mat(nbSR_byCL));
    nbSRFiltr_tot = sum(cell2mat(nbSRFiltr_byCL));
    trip.setSituationVariableAtTime(cas_situation, 'nbSR', startTime, endTime, nbSR_tot)
    trip.setSituationVariableAtTime(cas_situation, 'nbSRFiltr', startTime, endTime, nbSRFiltr_tot)
end