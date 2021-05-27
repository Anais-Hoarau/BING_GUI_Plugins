function calculate_indicators_withoutConflicts(trip, full_directory)
    trip_id = trip.getAttribute('TRIP_NAME'); 
    trip_id = trip_id(1:end-5); 
    regexp_trip_id = strfind(trip_id, '_');
    trip_num = trip_id(1:regexp_trip_id(1)-1);
    
    dataName = 'VRU_trajectories2';
    dataName_reduced = dataName(1:3);
    data_variables = {'speed_mean','speed_std','speed_max','speed_min','accel_mean','accel_std','accel_max','decel_max'};
    data_variables_units = {'km/h','km/h','km/h','km/h','m/s2','m/s2','m/s2','m/s2'};
    speed_ratio = 3.6; % to convert speed in m/s to km/h

    % remove situation if necessary
    removeSituationsTables(trip,{'Indicators'});
    
    % get data
    timecodes_video = cell2mat(trip.getAllDataOccurences('timecode_data').getVariableValues('timecode'));
    timecodes = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('timecode'));
    trajX = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('VRU_trajectories2_1'));
    trajY = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('VRU_trajectories2_2'));
    speeds = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('speed'))*speed_ratio;
    accels = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('accel'));
    VRU_type = cell2mat(trip.getAllSituationOccurences('VRU_characteristics').getVariableValues('VRU_type'));
    
    %% CALCULATE INDICATORS

    % calculate speeds
    if strcmp(VRU_type, 'P1')
        idx_start = find(trajY > -13, 1);
        idx_end = find(trajY > -2, 1);
    elseif strcmp(VRU_type, 'P3')
        idx_start = find(trajY < -2, 1);
        idx_end = find(trajY < -13, 1);
    elseif strcmp(VRU_type, 'P2')
        idx_start = find(trajX > 20, 1);
        idx_end = find(trajX > 27, 1);
    elseif strcmp(VRU_type, 'P4')
        idx_start = find(trajX < 27, 1);
        idx_end = find(trajX < 20, 1);
    end
    if contains(VRU_type, 'P')
        speeds = speeds(idx_start:idx_end);
        accels = accels(idx_start:idx_end);
        timecodes = timecodes(idx_start:idx_end);
    end
    
    data_out.speed_mean = mean(speeds);
    data_out.speed_std = std(speeds);
    data_out.speed_max = max(speeds);
    data_out.speed_min = min(speeds);
    
    % disp speed values
    disp(['speed_mean = ' num2str(data_out.speed_mean) ' km/h'])
    disp(['speed_std = ' num2str(data_out.speed_std) ' km/h'])
    disp(['speed_max = ' num2str(data_out.speed_max) ' km/h'])
    disp(['speed_min = ' num2str(data_out.speed_min) ' km/h'])
    
%     % plot speed
%     plot(timecodes,speeds); title([trip_id '__Speed__' VRU_type]); xlabel('Time (s)'); ylabel('Speed (km/h)');
%     xlim([0,timecodes_video(end)]);
%     
%     if contains(VRU_type, 'P')
%         ylim([0,12]);
%         savefig([full_directory filesep 'Figures' filesep trip_id '_Speed_' dataName_reduced '_crosswalk.fig'])
%         saveas(gcf,[full_directory filesep 'Figures' filesep trip_id '_Speed_' dataName_reduced '_crosswalk.png']);
%     else
%         ylim([0,52]);
%         savefig([full_directory filesep 'Figures' filesep trip_id '_Speed_' dataName_reduced '.fig'])
%         saveas(gcf,[full_directory filesep 'Figures' filesep trip_id '_Speed_' dataName_reduced '.png']);
%     end
    
    % calculate accels
    data_out.accel_mean = mean(abs(accels));
    data_out.accel_std = std(accels);
    data_out.accel_max = max(accels);
    data_out.decel_max = min(accels);
%     [~,idx_min] = min(abs(accels));
%     data_out.accel_min = accels(idx_min);
%     [~,idx_max] = max(abs(accels));
%     data_out.accel_max = accels(idx_max);
    
    % disp accel values
    disp(['accel_mean = ' num2str(data_out.accel_mean) ' m/s2'])
    disp(['accel_std = ' num2str(data_out.accel_std) ' m/s2'])
    disp(['accel_max = ' num2str(data_out.accel_max) ' m/s2'])
    disp(['decel_max = ' num2str(data_out.decel_max) ' m/s2'])
    
%     % plot accel
%     plot(timecodes,accels); title([trip_id '__Accel__' VRU_type]); xlabel('Time (s)'); ylabel('Accel (m/s²)');
%     xlim([0,timecodes_video(end)]);
%     
%     if contains(VRU_type, 'P')
%         ylim([-3,3]);
%         savefig([full_directory filesep 'Figures' filesep trip_id '_Accel_' dataName_reduced '_crosswalk.fig'])
%         saveas(gcf,[full_directory filesep 'Figures' filesep trip_id '_Accel_' dataName_reduced '_crosswalk.png']);
%     else
%         ylim([-4,4]);
%         savefig([full_directory filesep 'Figures' filesep trip_id '_Accel_' dataName_reduced '.fig'])
%         saveas(gcf,[full_directory filesep 'Figures' filesep trip_id '_Accel_' dataName_reduced '.png']);
%     end
    
    %% add indicators table, variables and values to the trip
    addSituationTable2Trip(trip,'Indicators');
    trip.setBatchOfTimeSituationVariableTriplets('Indicators','name',[num2cell(timecodes(1)),num2cell(timecodes(end)),{'Indicators'}]')
    for i_variable = 1:length(data_variables)
        addSituationVariable2Trip(trip,'Indicators',[data_variables{i_variable}],'REAL','unit',data_variables_units{i_variable})
        trip.setBatchOfTimeSituationVariableTriplets('Indicators',[data_variables{i_variable}],[num2cell(timecodes(1)),num2cell(timecodes(end)),num2cell(data_out.(data_variables{i_variable}))]')
    end
    
end