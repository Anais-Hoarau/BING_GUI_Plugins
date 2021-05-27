function [traj_extr] = ExtrTraj_ExtrTraj_WithKalman(data,i_row)
data_use = data(i_row:end,:);
traj_extr = zeros(size(data_use));
traj_extr(:,1) = data_use(:,1);
traj_extr(1,:) = data_use(1,:);

traj_extr = StandardKalmanFilter(data_use(:,2:9)',5,2);




%% GET COORDONATES DATAS
dt = data_use(2,1) - data_use(1,1);
for i_column = 2:2:8

    X1 = data_use(1,i_column);
    Y1 = data_use(1,i_column+1);
    X2 = data_use(2,i_column);
    Y2 = data_use(2,i_column+1);
    X3 = data_use(3,i_column);
    Y3 = data_use(3,i_column+1);
    
    v1 = [X2-X1,Y2-Y1];
    v2 = [X3-X2,Y3-Y2];
    speed1 = norm(v1)/dt;
    speed2 = norm(v2)/dt;
    accel = (speed2-speed1)/dt;
    v1_norm = v1/norm(v1);
    v2_norm = v2/norm(v2);
    
    %% EXTRAPOLATE TRAJECTORIES DATA FROM i_row
    for i_row_extr = 2:size(data_use,1)
        dt = data_use(i_row_extr,1) - data_use(i_row_extr-1,1);
        dist = accel*dt^2;
        prev_pos = traj_extr(i_row_extr-1,i_column:i_column+1);
        new_pos = prev_pos + v1_norm*dist;
        traj_extr(i_row_extr,i_column:i_column+1) = new_pos;
    end
end

% temp
% data_dist = diff(data_use); % distance en x (m)
% for i = 1:length(data_dist)
%     speed(i) = sqrt(data_dist(i,2)^2+data_dist(i,3)^2)/data_dist(i,1);
% end
% speed = speed';
% plot(speed)
% speed_smooth = smooth(medfilt1(speed,25))'; % speed lissée (m/s)