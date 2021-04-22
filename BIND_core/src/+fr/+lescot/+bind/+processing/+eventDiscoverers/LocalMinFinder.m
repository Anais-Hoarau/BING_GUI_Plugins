%{
Class:
This extractor finds local minimas by first calculating the approximate
derivative of the signal (left derivative), then looking negative to positive sign change.
For example
:timecodes [1 | 2 | 3 | 4 | 5 | 6]
:values    [3 | 2 | 1 | 1 | 2 | 3]
returns
:[3]
%}

classdef LocalMinFinder < fr.lescot.bind.processing.EventDiscoverer
    
    
    methods (Static)
        
        function out = extract(inputCellArray)
            import fr.lescot.bind.processing.signalProcessors.*;
            import fr.lescot.bind.processing.eventDiscoverers.*;
            derivatedSignal = Derivator.process(inputCellArray, Derivator.LEFT);
            out = UpwardThresholdFinder.extract(derivatedSignal, 0);

        end
        
    end
end

