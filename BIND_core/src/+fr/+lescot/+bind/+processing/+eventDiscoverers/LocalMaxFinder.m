%{
Class:
This extractor finds local maximas by first calculating the approximate
derivative of the signal (left derivatvie), then looking positive to negative sign change.
For example
:timecodes [1 | 2 | 3 | 4 | 5 | 6]
:values    [1 | 2 | 3 | 3 | 2 | 1]
returns
:[3]
%}

classdef LocalMaxFinder < fr.lescot.bind.processing.EventDiscoverer
    
    
    methods (Static)
        
        function out = extract(inputCellArray)
            import fr.lescot.bind.processing.signalProcessors.*;
            import fr.lescot.bind.processing.eventDiscoverers.*;
            derivatedSignal = Derivator.process(inputCellArray, Derivator.LEFT);
            out = DownwardThresholdFinder.extract(derivatedSignal, 0);

        end
        
    end
end

