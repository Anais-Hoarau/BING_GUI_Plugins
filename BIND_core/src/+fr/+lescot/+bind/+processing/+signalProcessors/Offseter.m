%{
Class:
This processor adds a fixed value to all the values of the signal. For instance, with an _inputCellArray_ like
this
:timecodes [ 1 | 2 | 3 | 4 | 5]
:values    [ 0 | 6 | 4 | 5 | 3]
and a factor of 3.2, we would have the following output :
:timecodes [ 1  | 2  | 3  | 4   | 5  ]
:values    [ 3.2  | 9.2  | 7.2  | 8.2 | 6.2]
%}

classdef Offseter < fr.lescot.bind.processing.SignalProcessor
        
    methods (Static)
        
        %{
        Function:
        
        Arguments:
        scaleFactor - a numeric value.
        
        %}
        function processedData = process(inputCellArray, offset)

            timecodes = inputCellArray(1,:);
            signal = cell2mat(inputCellArray(2,:));
            
            signal = offset + signal;
    
            processedData = [timecodes; num2cell(signal)];
        end

    end
end

