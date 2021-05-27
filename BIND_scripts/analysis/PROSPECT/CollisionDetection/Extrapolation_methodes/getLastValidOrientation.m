function [v] = getLastValidOrientation(traj,i_row,threshold_speed)

valid_row = i_row;
while valid_row > 0
    
    dt = traj(valid_row+1,1) - traj(valid_row,1);
    
    %% GET COORDONATES DATAS
    X1 = traj(valid_row,2);
    Y1 = traj(valid_row,3);
    X2 = traj(valid_row+1,2);
    Y2 = traj(valid_row+1,3);
    
    v = [X2-X1,Y2-Y1];
    
    if norm(v)/dt > threshold_speed
        v = v/norm(v);
        return
    end
    
    valid_row = valid_row - 1;
    
end

warning('Impossible de trouver une orientation valide de l''objet')

end