%{
Class:
This discoverer is not really intended to be used by end users, as it
serves mainly as a technical foundation for some classes like
<ThresholdComparator>. However, as Matlab technical limitations prevents
from making it hidden in any clean way, it is documented here if you really wish
to use it. This discoverer finds contiguous sequences of values matching a
certain criteria. The trick is that this criteria is validated by a
function passed in argument as a function handler. This function must take
one value in argument, and output a logical value. It will then be applied
to all the values of the signal, and according to the result, situations
will be extracted.

If you want an example of how to use this class, you can check
<ThresholdComparator> as a reference.

It is to be noted that 1 element sequences will not be returned, since they
are not valid BIND sequences (they are closer of events).
%}

classdef SimpleLogicalFunctionDiscoverer < fr.lescot.bind.processing.SituationDiscoverer
    
    
    methods (Static)
        
         %{
        Function:

        Arguments:
        logicalFunctionHandler - a handler to a function that take one
        numerical value as argument and outputs a logical value.
        %}
        function out = extract(inputCellArray, logicalFunctionHandler)
            timecodes = inputCellArray(1,:);
            signal = inputCellArray(2,:);
            discoveredSituations = {};
            isInSituation = false;
            for i = 1:1:length(signal)
                if logicalFunctionHandler(signal{i}) && ~isInSituation
                    isInSituation = true;
                    discoveredSituations{1, end+1} = timecodes{i}; %#ok<AGROW>
                elseif ~logicalFunctionHandler(signal{i}) && isInSituation
                    isInSituation = false;
                    discoveredSituations{2, end} = timecodes{i-1};
                elseif logicalFunctionHandler(signal{i}) && isInSituation && i == length(signal)
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