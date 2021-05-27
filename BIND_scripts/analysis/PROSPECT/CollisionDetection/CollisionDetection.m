function [TTC,PET] = CollisionDetection(shape1,shape2,x_lim,y_lim,TTC_and_PET_needed)
    
    %initialise variables
    [timecodes,idx_1,idx_2] = intersect(shape1(:,1),shape2(:,1));
    Intersect = zeros(1,length(timecodes));
    delta_row = 0;
    TTC = Inf;
    PET = Inf;
    
    if and(max(diff(idx_1)) == 1, max(diff(idx_2)) == 1)
        
        while sum(Intersect) == 0 && delta_row < idx_1(end)
            
            for i_row = 1:length(timecodes)-1
                
                %% FIRST STEP : TEST COLLISION WITHOUT SLIDING FOR TTC
                if delta_row == 0
                    
                    rect1 = [shape1(idx_1(i_row),2) shape1(idx_1(i_row),3); ...
                        shape1(idx_1(i_row),4) shape1(idx_1(i_row),5); ...
                        shape1(idx_1(i_row),6) shape1(idx_1(i_row),7); ...
                        shape1(idx_1(i_row),8) shape1(idx_1(i_row),9)];
                    
                    rect2 = [shape2(idx_2(i_row),2) shape2(idx_2(i_row),3); ...
                        shape2(idx_2(i_row),4) shape2(idx_2(i_row),5); ...
                        shape2(idx_2(i_row),6) shape2(idx_2(i_row),7); ...
                        shape2(idx_2(i_row),8) shape2(idx_2(i_row),9)];
                    
                    [Intersect(i_row)] = RectIntersectUsingSATProspect(rect1,rect2,x_lim,y_lim);
                    
                    if Intersect(i_row) == 1
                        TTC = timecodes(i_row) - timecodes(1);
                        return
                    end
                    
                    %% SECOND STEP : TEST COLLISION WITH SLIDING TIME FOR PET
                elseif delta_row > 0 && TTC_and_PET_needed
                    
                    rect2 = [shape2(idx_2(i_row),2) shape2(idx_2(i_row),3); ...
                        shape2(idx_2(i_row),4) shape2(idx_2(i_row),5); ...
                        shape2(idx_2(i_row),6) shape2(idx_2(i_row),7); ...
                        shape2(idx_2(i_row),8) shape2(idx_2(i_row),9)];
                    
                    %% TEST COLLISION WITH SLIDE OF + DELTA_ROW
                    if idx_1(i_row) + delta_row <= idx_1(end)-1
                        
                        rect1Inc = [shape1(idx_1(i_row)+delta_row,2) shape1(idx_1(i_row)+delta_row,3); ...
                            shape1(idx_1(i_row)+delta_row,4) shape1(idx_1(i_row)+delta_row,5); ...
                            shape1(idx_1(i_row)+delta_row,6) shape1(idx_1(i_row)+delta_row,7); ...
                            shape1(idx_1(i_row)+delta_row,8) shape1(idx_1(i_row)+delta_row,9)];
                        
                        [Intersect(i_row)] = RectIntersectUsingSATProspect(rect1Inc,rect2,x_lim,y_lim);
                        
                        if Intersect(i_row) == 1
                            PET = shape1(idx_1(i_row)+delta_row,1) - shape1(idx_1(i_row),1);
                            return
                        end
                        
                    end
                    
                    %% TEST COLLISION WITH SLIDE OF - DELTA_ROW
                    if idx_1(i_row) - delta_row >= idx_1(1)
                        
                        rect1Dec = [shape1(idx_1(i_row)-delta_row,2) shape1(idx_1(i_row)-delta_row,3); ...
                            shape1(idx_1(i_row)-delta_row,4) shape1(idx_1(i_row)-delta_row,5); ...
                            shape1(idx_1(i_row)-delta_row,6) shape1(idx_1(i_row)-delta_row,7); ...
                            shape1(idx_1(i_row)-delta_row,8) shape1(idx_1(i_row)-delta_row,9)];
                        
                        [Intersect(i_row)] = RectIntersectUsingSATProspect(rect1Dec,rect2,x_lim,y_lim);
                        
                        if Intersect(i_row) == 1
                            PET = shape1(idx_1(i_row)-delta_row,1) - shape1(idx_1(i_row),1);
                            return
                        end
                        
                    end
                end
            end
            
            delta_row = delta_row + 1;
            
        end
    end
end