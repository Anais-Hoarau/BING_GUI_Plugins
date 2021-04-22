classdef CellArrayUtilsTest < TestCase

    methods
        
        function this = CellArrayUtilsTest(name)
            this = this@TestCase(name);
        end
        
        function testSwapLines(~)
            cellArray = {1 2 3;4 5 6};
            cellArraySwaped = fr.lescot.bind.utils.CellArrayUtils.swapLines(cellArray, 1, 2);
            assertTrue(all(all(cell2mat({4 5 6; 1 2 3}) == cell2mat(cellArraySwaped))));
            
            cellArraySwaped = fr.lescot.bind.utils.CellArrayUtils.swapLines(cellArray, 1, 1);
            assertTrue(all(all(cell2mat(cellArray) == cell2mat(cellArraySwaped))));
        end
    end
    
end

