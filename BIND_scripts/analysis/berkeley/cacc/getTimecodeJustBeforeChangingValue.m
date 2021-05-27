% This method do the same as the ChangingValueFinder EvendDiscoverer,
% except that it returns the last timecode before a change occurs instead
% of the timecode when the event occur.
function discoveredEvents = getTimecodeJustBeforeChangingValue(inputCellArray)

            timecode = cell2mat(inputCellArray(1,:));
            signal = cell2mat(inputCellArray(2,:));

            v_before = signal(1);
            v_after = signal(1);
            ind = 2;
            ind_fin = length(signal);
            ii = 1;
            while(ind < ind_fin)
                 if v_before ~= v_after
                    event_valueChange(ii) = timecode(ind-1); 
                    ii = ii + 1;
                end
                ind = ind + 1;
                v_before = v_after;
                v_after = signal(ind);
            end

            discoveredEvents = [num2cell(event_valueChange)];
end