%cellArrayOfInformations :
%Line 1 : timecodes
%Line 2 : voie (mm)
%Line 3 : cap degres
%Line 4 : Sens
function out = findLaneExcursions(cellArrayOfInformations)
    laneExcursion =  cell(1, size(cellArrayOfInformations, 2));
    for i = 1:1:size(cellArrayOfInformations, 2)
        %%% Code snippet given by Daniel Ndiaye %%%
        number = (26.06 + abs(cellArrayOfInformations{3, i})) * (pi / 180);
        valDelta = (1.818 * sin(number));
        leftWheelPositionValue = cellArrayOfInformations{2, i} - valDelta;
        rightWheelPositionValue = cellArrayOfInformations{2, i} + valDelta;
        %%% end snippet %%%
        sens = cellArrayOfInformations{4, i};
        if strcmp('Direct', sens)
            if  leftWheelPositionValue < 0 || rightWheelPositionValue > 7000
                laneExcursion{i} = true;
            else
                laneExcursion{i} = false;
            end
        else
            if  leftWheelPositionValue > 0 || rightWheelPositionValue < 7000
                laneExcursion{i} = true;
            else
                laneExcursion{i} = false;
            end
        end
    end
    out = laneExcursion;
end

