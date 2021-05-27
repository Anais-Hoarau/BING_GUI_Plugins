% calculate steering angle variations
function steeringAngleVar(trip, startTime, endTime, cas_situation)
    
    %get data
    trajectoireOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
    steeringAngle = cell2mat(trajectoireOccurences.getVariableValues('angle_volant'));
    
    %calculate indicator
    steeringAngle_var = std(steeringAngle/4000*360);
    
    % display indicator
    disp(['[' num2str(startTime) ';' num2str(endTime) '] variations d''angle au volant = ' num2str(steeringAngle_var) '°']);
    
    % save indicator
    trip.setSituationVariableAtTime(cas_situation, 'steeringAngles_var', startTime, endTime, steeringAngle_var)
    
end