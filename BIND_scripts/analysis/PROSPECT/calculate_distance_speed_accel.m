function calculate_distance_speed_accel(trip)
dataNames = {'CAR_trajectories2','VRU_trajectories2'}; %,'CAR_trajectories_interp','VRU_trajectories_interp'};
variablesNames = {'dist_x','dist_y','dist','speed_x','speed_y','speed','accel_x','accel_y','accel'}; %,'speed_smooth','accel_smooth'
units = {'m','m','m','m/s','m/s','m/s','m/s2','m/s2','m/s2'};
period = 0.04;
% span_speed = 30;
% span_accel = 30;

for i_data = 2:length(dataNames)
    dataName = dataNames{i_data};
    
    % add trajectories data tables
    for i_variable = 1:length(variablesNames)
        addDataVariable2Trip(trip,dataName,variablesNames{i_variable},'REAL','unit',units{i_variable})
    end
    
    % get trajectories data from trip
    trajectories_occurences = trip.getAllDataOccurences(dataName);
    timecodes = cell2mat(trajectories_occurences.getVariableValues('timecode'));
    traj_x = cell2mat(trajectories_occurences.getVariableValues([dataName '_1'])); % coordonnées en x (m)
    traj_y = cell2mat(trajectories_occurences.getVariableValues([dataName '_2'])); % coordonnées en y (m)
    
    % calculate distances
    data_out.dist_x = interp1(timecodes(2:end),diff(traj_x),timecodes,'spline','extrap'); % distance en x (m)
    data_out.dist_y = interp1(timecodes(2:end),diff(traj_y),timecodes,'spline','extrap'); % distance en y (m)
    data_out.dist = sqrt(data_out.dist_x.^2+data_out.dist_y.^2); % distance (m)
    
    % calculate speeds
    data_out.speed_x = data_out.dist_x/period; % speed en x (m/s)
    data_out.speed_y = data_out.dist_y/period; % speed en y (m/s)
    data_out.speed = data_out.dist/period; % speed (m/s)
%     data_out.speed_smooth = smooth(medfilt1(data_out.speed,25),span_speed)'; % speed lissée (m/s)
    
    % calculate accels
    data_out.accel_x = smooth(interp1(timecodes(2:end),diff(data_out.speed_x),timecodes,'spline','extrap')/period)'; % accélération en x lissée (m/s²)
    data_out.accel_y = smooth(interp1(timecodes(2:end),diff(data_out.speed_y),timecodes,'spline','extrap')/period)'; % accélération en y lissée (m/s²)
    data_out.accel = smooth(interp1(timecodes(2:end),diff(data_out.speed),timecodes,'spline','extrap')/period)'; % accélération lissée (m/s²)
%     data_out.accel_smooth = smooth(data_out.accel,span_accel)'; % accélération lissée (m/s²)
    
    % write trajectories data in tables
    for i_variable = 1:length(variablesNames)
        trip.setBatchOfTimeDataVariablePairs(dataName, variablesNames{i_variable}, [num2cell(timecodes)', num2cell(data_out.(variablesNames{i_variable})')]');
    end
    
end
end