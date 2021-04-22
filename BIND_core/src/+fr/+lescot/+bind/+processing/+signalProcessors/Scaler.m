%{
Class:
This processor multiplies all the values of a signal by a fixed value,
thereby scaling the signal. For instance, with an _inputCellArray_ like
this
:timecodes [ 1 | 2 | 3 | 4 | 5]
:values    [ 0 | 6 | 4 | 5 | 3]
and a factor of 0.5, we would have the following output :
:timecodes [ 1  | 2  | 3  | 4   | 5  ]
:values    [ 0  | 3  | 2  | 2.5 | 1.5]
%}

classdef Scaler < fr.lescot.bind.processing.SignalProcessor
        
    methods (Static)
        
        %{
        Function:
        
        Arguments:
        scaleFactor - a numeric value.
        
        %}
        function processedData = process(inputCellArray, scaleFactor)

            timecodes = inputCellArray(1,:);
            signal = cell2mat(inputCellArray(2,:));
            
            signal = scaleFactor * signal;
    
            processedData = [timecodes; num2cell(signal)];
        end

    end
end

