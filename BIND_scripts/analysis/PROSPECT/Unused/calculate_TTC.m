function calculate_TTC(trip)
dataNames = {'CAR_trajectories', 'VRU_trajectories'};
% variablesNames = {'TTC'};

for i_data = 1:length(dataNames)
    
    % get trajectories data from trip
    trajectories_occurences = trip.getAllDataOccurences(dataName);
    timecodes = trajectories_occurences.getVariableValues('timecode')';
    traject_distance = cell2mat(trajectories_occurences.getVariableValues('distance'));
    traject_vitesse = cell2mat(trajectories_occurences.getVariableValues('vitesse'))/3.6;
    
    
end

end

% % delta_i = 0;
% i_impact.CAR_trajectories = 66;
% i_impact.VRU_trajectories = i_impact.CAR_trajectories+35; %+7;
% % i_infini.CAR_trajectories = 92-delta_i;
% % i_infini.VRU_trajectories = i_infini.CAR_trajectories+7;
% % i_recul_VRU = 76; %(changement de sens du piéton)
% for i_data = 1:length(dataNames)
%     dataName = dataNames{i_data};
%     addDataVariable2Trip(trip,dataName,variablesNames{1},'REAL','unit','s')
%
%     % get trajectories data from trip
%     trajectories_occurences = trip.getAllDataOccurences(dataName);
%     timecodes = trajectories_occurences.getVariableValues('timecode')';
%     traject_distance = cell2mat(trajectories_occurences.getVariableValues('distance'));
%     traject_vitesse = cell2mat(trajectories_occurences.getVariableValues('vitesse'))/3.6;
%
%     % calculate TTC
%     i_PIP = i_impact.(dataName);
%     %     i_infini = i_infini_(dataNames{i_data});
%     TTPIP.(dataName) = zeros(length(traject_distance),1);
%     for i_occurence = 1:length(traject_distance)
%         %         if strcmp(dataName,'VRU_trajectories') %&& i_occurence > i_recul_VRU
%         %             TTPIP.(dataName)(i_occurence) = 0;
%         %         else
%         mask_trajectoire_utile = zeros(length(traject_distance),1);
%         mask_trajectoire_utile(i_occurence:i_PIP) = 1;
%         TTPIP.(dataName)(i_occurence) = sum(traject_distance(find(mask_trajectoire_utile)))/traject_vitesse(i_occurence);
%         %         end
%     end
%     trip.setBatchOfTimeDataVariablePairs(dataName, variablesNames{1}, [timecodes, num2cell(TTPIP.(dataName))]');
% end
% TDTC = TTPIP.CAR_trajectories - TTPIP.VRU_trajectories; %(8:209);
% GTTPIP = TTPIP.CAR_trajectories + TTPIP.VRU_trajectories; %(8:209);
% addDataVariable2Trip(trip,'CAR_trajectories','TDTC','REAL','unit','s')
% addDataVariable2Trip(trip,'CAR_trajectories','GTTPIP','REAL','unit','s')
% timecodes = trip.getAllDataOccurences('CAR_trajectories').getVariableValues('timecode')';
% trip.setBatchOfTimeDataVariablePairs('CAR_trajectories', 'TDTC', [timecodes, num2cell(TDTC)]');
% trip.setBatchOfTimeDataVariablePairs('CAR_trajectories', 'GTTPIP', [timecodes, num2cell(GTTPIP)]');
