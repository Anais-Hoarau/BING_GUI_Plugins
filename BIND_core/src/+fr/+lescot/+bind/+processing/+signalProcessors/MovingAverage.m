%{
Class:
This class applies a moving average to a signal on a window of N elements (N being an odd integer). 
It results in a smoothing of the signal. However, it also causes the loss
of (N-1)/2 values on each side of the signal. For example, with an _inputCellArray_ like
this
:timecodes [ 1 | 2 | 3 | 4 | 5]
:values    [ 0 | 6 | 4 | 5 | 3]
and a window width of 3, we would have the following output :
:timecodes [  2   | 3 | 4 ]
:values    [ 3.33 | 5 | 4 ]
%}

classdef MovingAverage < fr.lescot.bind.processing.SignalProcessor
    
        
    methods (Static)
        %{
        Function:
                
        Arguments:
        windowWidth - and odd integer value. The value will automatically
        be rounded to the nearest integer if it is not an integer value.
        
        Throws:
        ARGUMENT_EXCEPTION - if once rounded,
        windowWidth is not an odd value or if windowWidth is
        larger than the length of inputCellArray.
        %}
        function processedData = process(inputCellArray, windowWidth)
            import fr.lescot.bind.exceptions.ExceptionIds;
            windowWidth = round(windowWidth);
          
            if ~mod(windowWidth, 2)
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'windowWidth argument must be an odd value.'));
            end
            
            halfWindowWidth = (windowWidth-1)/2;
            if length(inputCellArray) >= windowWidth
                signal = cell2mat(inputCellArray(2,:));
                signalSize = length(signal);
                timecodes = inputCellArray(1, halfWindowWidth + 1:signalSize - halfWindowWidth);

                averagedSignal = cell(1, signalSize - (windowWidth - 1));
                for i = halfWindowWidth + 1:signalSize - halfWindowWidth
                    averagedSignal{i - halfWindowWidth} = mean(signal(i- halfWindowWidth :i + halfWindowWidth));
                end

                processedData = [timecodes; averagedSignal];
            else
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'windowWidth argument musn''t be smaller than the length of the inputCellArray.'));
            end
        end  
    end
end

