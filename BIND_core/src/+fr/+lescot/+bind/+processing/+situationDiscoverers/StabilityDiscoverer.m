%{
Class:
This extractor finds sequences of identical values. As such, it is mostly
intended to be run on a discrete signal that have been very well cleaned, or
even delibatery discretized.

With an example input shaped like this :
:timecode:  [1 | 2 | 3 | 4 | 5 | 6 | 7 | 8]
:values:    [1 | 1 | 1 | 3 | 2 | 5 | 5 | 5]
The return is :
:start timecodes :  [1 | 6]
:end timecodes :    [3 | 8]

It is to be noted that 1 element sequences will not be returned, since they
are not valid BIND sequences (they are closer of events).
%}

classdef StabilityDiscoverer < fr.lescot.bind.processing.SituationDiscoverer
    
    
    methods (Static)
        function out = extract(inputCellArray)
            timecodes = inputCellArray(1,:);
            signal = inputCellArray(2,:);
            discoveredSituations = {};
            isInSituation = false;
            for i = 2:1:length(signal)
                isEqualToPrevious = (signal{i} == signal{i-1});
                if  isEqualToPrevious && ~isInSituation
                    isInSituation = true;
                    discoveredSituations{1, end+1} = timecodes{i-1}; %#ok<AGROW>
                elseif ~isEqualToPrevious && isInSituation
                    isInSituation = false;
                    discoveredSituations{2, end} = timecodes{i-1};
                elseif isEqualToPrevious && isInSituation && i == length(signal)
                    %To close a situation that would be on the end of a signal
                    %and so would not be closed
                    isInSituation = false;
                    discoveredSituations{2, end} = timecodes{i};
                end
            end
            %We delete the one point situations, since they are not valid
            %situations for bind.            
            logicalIndicesToDelete = [];
            for i=1:1:size(discoveredSituations, 2)
               if  discoveredSituations{1, i} == discoveredSituations{2, i}
                   logicalIndicesToDelete(end + 1) = i; %#ok<AGROW>
               end
            end
            discoveredSituations(:,logicalIndicesToDelete) = [];
            
            out = discoveredSituations;
        end     
    end
end
    
