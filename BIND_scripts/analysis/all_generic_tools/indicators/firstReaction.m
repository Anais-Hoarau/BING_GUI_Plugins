%% find first reaction of the driver
function firstReaction(trip, startTime, endTime, cas_situation)
    trajectoireOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
    steeringAngle = cell2mat(trajectoireOccurences.getVariableValues('angle_volant'));
    vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    breakPourcentage = cell2mat(vitesseOccurences.getVariableValues('frein'));
    Timecodes = cell2mat(vitesseOccurences.getVariableValues('timecode'));
    maskSteeringAngleTimecodes = Timecodes(diff(steeringAngle) > 5);
    maskBreakPourcentageTimecodes = Timecodes(breakPourcentage > 15);
    if isempty(maskSteeringAngleTimecodes) || ~isempty(maskBreakPourcentageTimecodes) && maskBreakPourcentageTimecodes(1) < maskSteeringAngleTimecodes(1)
        firstReac = 'break';
        TCFirstReac = maskBreakPourcentageTimecodes(1);
        TRFirstReac = maskBreakPourcentageTimecodes(1) - startTime;
    elseif isempty(maskBreakPourcentageTimecodes) || ~isempty(maskSteeringAngleTimecodes) && maskSteeringAngleTimecodes(1) < maskBreakPourcentageTimecodes(1)
        firstReac = 'steeringWheel';
        TCFirstReac = maskSteeringAngleTimecodes(1);
        TRFirstReac = maskSteeringAngleTimecodes(1) - startTime;
    end
    TIV1stReac = cell2mat(trip.getDataOccurenceAtTime('vitesse', TCFirstReac).getVariableValues('TIV'));
    disp(['[' num2str(startTime) ';' num2str(endTime) '] 1ère réaction = ' firstReac]);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] temps de réaction = ' num2str(TRFirstReac)]);
    trip.setSituationVariableAtTime(cas_situation, '1stReac', startTime, endTime, firstReac)
    trip.setSituationVariableAtTime(cas_situation, 'TC1stReac', startTime, endTime, TCFirstReac)
    trip.setSituationVariableAtTime(cas_situation, 'TR1stReac', startTime, endTime, TRFirstReac)
    trip.setSituationVariableAtTime(cas_situation, 'TIV1stReac', startTime, endTime, TIV1stReac)
end