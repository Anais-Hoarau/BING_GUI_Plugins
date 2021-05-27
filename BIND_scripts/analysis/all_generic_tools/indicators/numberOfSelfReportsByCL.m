%% calculate number of self-report used and self-report filtered by "conduite_libre" situation
function numberOfSelfReportsByCL(trip, startTime, endTime, cas_situation)
    SR_timecodes = trip.getEventOccurencesInTimeInterval('self_report', startTime, endTime).getVariableValues('name');
    SR_filtres_timecodes = trip.getEventOccurencesInTimeInterval('self_report_filtre', startTime, endTime).getVariableValues('name');
    nbSR = length(SR_timecodes);
    nbSRFiltr = length(SR_filtres_timecodes);
    trip.setSituationVariableAtTime(cas_situation, 'nbSR', startTime, endTime, nbSR)
    trip.setSituationVariableAtTime(cas_situation, 'nbSRFiltr', startTime, endTime, nbSRFiltr)
end