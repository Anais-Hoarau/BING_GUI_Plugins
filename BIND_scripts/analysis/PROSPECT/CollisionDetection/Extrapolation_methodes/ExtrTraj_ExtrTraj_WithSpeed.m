function [traj_extr] = ExtrTraj_ExtrTraj_WithSpeed(data,i_row,threshold_speed)
data_use = data(i_row:end,:);
traj_extr = zeros(size(data_use));
traj_extr(:,1) = data_use(:,1);
traj_extr(1,:) = data_use(1,:);

%% GET COORDONATES DATAS
dt = data_use(2,1) - data_use(1,1);
X1 = data_use(1,2);
Y1 = data_use(1,3);
X2 = data_use(2,2);
Y2 = data_use(2,3);

v1 = [X2-X1,Y2-Y1];
speed = norm(v1)/dt;
v1_norm = v1/norm(v1);

%% EXTRAPOLATE TRAJECTORIES DATA FROM i_row
for i_row_extr = 2:size(data_use,1)
    if speed > threshold_speed
        dt = data_use(i_row_extr,1) - data_use(i_row_extr-1,1);
        dist = speed*dt;
        prev_pos = traj_extr(i_row_extr-1,2:3);
        new_pos = prev_pos + v1_norm*dist;
        traj_extr(i_row_extr,2:3) = new_pos;
    else
        traj_extr(i_row_extr,2:3) = traj_extr(i_row_extr-1,2:3);
    end
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