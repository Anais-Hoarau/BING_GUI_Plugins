function [traj_extr] = ExtrTraj_ExtrTraj_WithAccel(data,i_row,threshold_speed)
    data_use = data(i_row:end,:);
    traj_extr = zeros(size(data_use));
    traj_extr(:,1) = data_use(:,1);
    traj_extr(1:2,:) = data_use(1:2,:);
    
    %% GET COORDONATES DATAS
    X1 = data_use(1,2);
    Y1 = data_use(1,3);
    X2 = data_use(2,2);
    Y2 = data_use(2,3);
    X3 = data_use(3,2);
    Y3 = data_use(3,3);
    
    dt1 = data_use(2,1) - data_use(1,1);
    dt2 = data_use(3,1) - data_use(2,1);
    
    v1 = [X2-X1,Y2-Y1]/dt1;
    v2 = [X3-X2,Y3-Y2]/dt2;
    
    a2 = (v2-v1)/dt2;
    if norm(v2) > threshold_speed
        %% EXTRAPOLATE TRAJECTORIES DATA FROM i_row
        for i_row_extr = 3:size(data_use,1)
            dt = data_use(i_row_extr,1) - data_use(i_row_extr-1,1);
            prev_pos = traj_extr(i_row_extr-1,2:3);
            X2 = traj_extr(i_row_extr-2,2);
            Y2 = traj_extr(i_row_extr-2,3);
            X3 = traj_extr(i_row_extr-1,2);
            Y3 = traj_extr(i_row_extr-1,3);
            v2 = [X3-X2,Y3-Y2]/dt;
            
            if norm(v2) < threshold_speed
                new_pos = prev_pos;
            elseif norm(v2) < norm(a2) %&& norm(v2) < 1.5
                v2_norm = v2 / norm(v2);
                new_pos = prev_pos + v2 * dt + dot(a2,v2_norm) * v2_norm * dt^2;
            else
                new_pos = prev_pos + v2 * dt + a2 * dt^2;
            end
            traj_extr(i_row_extr,2:3) = new_pos;
        end
    else
        traj_extr(3:size(data_use,1),2:3) = ones(size(data_use,1)-2,2).*traj_extr(2,2:3);
    end
end