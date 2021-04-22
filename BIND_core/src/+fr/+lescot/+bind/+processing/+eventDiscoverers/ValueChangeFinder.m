%{
Class:
This processor detects value changes in a signal. The timecode returned for
each event is the one just before the value changed. So for example 
if we have an _inputCellArray_ that looks like this :
:timecodes [10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20]
:signal    [0  | 0  | 1  | 1  | 1  | 1  | 0  | 0  | 0  | 0  | 1 ]
the time codes returned will be 11, 15 and 19.
%}

classdef ValueChangeFinder < fr.lescot.bind.processing.EventDiscoverer

    methods (Static)
            
        function out = extract(inputCellArray)   
            timecodes = inputCellArray(1,:);
            signal = inputCellArray(2,:);
            discoveredEvents = {};
            
            for i = 2:1:length(signal)
                if signal{i} ~= signal{i-1}
                    discoveredEvents{end+1} = timecodes{i-1};
                end
            end
            out = discoveredEvents;
        end
        
    end
end

