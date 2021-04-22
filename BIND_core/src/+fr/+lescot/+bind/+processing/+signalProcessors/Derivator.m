%{
Class:
This processor calculates the approximate first order derivative of a signal with
respect to time. The value of the derivative is calculated as 
:diff(y) ./diff(t).
To decide to which timecode the derivative value will be affected, you have
three options :
- LEFT : the derivative is affected to the left point (default option if
not specified)
- RIGHT : the derivative is affected to the right point
- MIDDLE : the derivative is affected between the two points, at equal
distance of the left and right point.
To take an example input,
:timecodes [ 1 | 2 | 3 | 4 | 5 | 6]
:values    [ 0 | 2 | 3 | 3 | 2 | 1]
with timecodeSide = MIDDLE would return
:timecodes [ 1.5 | 2.5 | 3.5 | 4.5 | 5.5]
:values    [ 1   |  1  |  0  |  -1 | -1 ]
while witch timecodeSide = LEFT, it would return :
:timecodes [ 1 | 2 | 3 | 4  | 5  ]
:values    [ 1 | 1 | 0 | -1 | -1 ]
%}
classdef Derivator < fr.lescot.bind.processing.SignalProcessor
    
    properties(Constant)
        LEFT = 0;
        RIGHT = 1;
        MIDDLE = 2;
    end
    
    methods (Static)
        function out = process(inputCellArray, timecodeSide)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~exist('timecodeSide', 'var')
                timecodeSide = fr.lescot.bind.processing.signalProcessors.Derivator.LEFT;
            end
            timecodes = cell2mat(inputCellArray(1,:));
            signal = cell2mat(inputCellArray(2,:));
            
            dy = diff(signal);
            dt = diff(timecodes);
            derivative = dy ./ dt;
            switch(timecodeSide)
                case fr.lescot.bind.processing.signalProcessors.Derivator.LEFT
                    derivativeTimecodes = timecodes(1:end-1);
                case fr.lescot.bind.processing.signalProcessors.Derivator.RIGHT
                    derivativeTimecodes = timecodes(2:end);
                case fr.lescot.bind.processing.signalProcessors.Derivator.MIDDLE
                    derivativeTimecodes =  timecodes(2:end) - dt/2;
                otherwise
                    throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'timecodeSide must be one of the constant defined in the class'));
            end
            
            out = [num2cell(derivativeTimecodes); num2cell(derivative)];
        end        
    end
end

