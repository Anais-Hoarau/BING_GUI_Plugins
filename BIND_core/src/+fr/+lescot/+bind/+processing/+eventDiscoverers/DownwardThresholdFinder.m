%{
Class:
This class extract an event each time the signal crosses a defined
threshold downward.  The timecode returned is the one between the one on the left the threshold crossing. For example if we have an _inputCellArray_ that looks like this :
:timecodes [10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20]
:signal    [20 | 19 | 18 | 16 | 16 | 15 | 15 | 16 | 17 | 18 | 19]
and a threshold of 16, the only timecode returned will be 14.
%}

classdef DownwardThresholdFinder < fr.lescot.bind.processing.EventDiscoverer

    methods (Static)

        %{
        Function:
        
        Arguments: 
        threshold - a numeric value
        %}
        function out = extract(inputCellArray, threshold)
            
            timecodes = inputCellArray(1,:);
            signal = inputCellArray(2,:);
            discoveredEvents = {};
           
            for i = 2:1:length(signal)
               if signal{i} < threshold && signal{i-1} >= threshold
                   discoveredEvents{end+1} = timecodes{i-1};
               end
            end
            
            out = discoveredEvents;
        end
        
    end
end

