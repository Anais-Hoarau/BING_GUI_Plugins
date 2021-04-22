%{
Class:
This processor allows to calculate the value of points at a time not
recorded in the signal, using a linear interpolation. So, using an input
signal shaped like this
:timecodes [ 1 | 2 | 3 | 4 | 5]
:values    [ 0 | 6 | 4 | 5 | 3]
asking for the values at times 1.5, 2 and 2.5 would return :
:timecodes [ 1.5 | 2 | 2.5 ]
:values    [ 3   | 6 | 5   ]
%}
classdef LinearInterpoler < fr.lescot.bind.processing.SignalProcessor
    methods (Static)

        %{
        Function:
                
        Arguments:
        targetTimecodes - a cell array of numeric values.

        %}
        function processedData = process(inputCellArray, targetTimecodes)
            timecode = cell2mat(inputCellArray(1,:));
            signal = cell2mat(inputCellArray(2,:));  
            targetTimecodes = cell2mat(targetTimecodes);
            result = interp1(timecode,signal,targetTimecodes); 
            processedData = [num2cell(targetTimecodes); num2cell(result)];
        end
        
    end
end

