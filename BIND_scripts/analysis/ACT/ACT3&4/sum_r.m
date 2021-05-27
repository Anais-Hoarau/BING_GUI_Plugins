    function t = sum_r(d_x,id)
        if id > 1
            t(id-1) = sum_r(d_x,id-1);
            t(id) = t(id-1) + d_x(id);    
        else
            t(1) = d_x(1);
        end
    end