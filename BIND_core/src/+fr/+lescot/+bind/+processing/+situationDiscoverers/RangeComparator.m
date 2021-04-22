
%{
Class:
This discoverer find situations where the value of the signal is either
inside a range, or outside of this range. It is also possible to use non
absolute relational operators (see <extract()>).
For example, running this extractor on this set of data :
:[1 | 2 | 3 | 4 | 5 | 6 | 7 | 8]
:[4 | 1 | 2 | 3 | 4 | 5 | 5 | 5]
with inRange = false and absolute = true will return :
:[2 | 6]
:[3 | 8]
(see <SituationDiscoverer.extract()> for an explanation of the output format).

It is to be noted that 1 element sequences will not be returned, since they
are not valid BIND sequences (they are closer of events).
%}

classdef RangeComparator < fr.lescot.bind.processing.SituationDiscoverer
    
    
    methods (Static)
        
        %{
        Function:
        
        Arguments:
        lowerThreshold - A numerical value
        upperThreshold - A numerical value
        inRange - A logical value. If true the situations will be found when the value is in
        the range. If false when outside.
        absolute - Optionnal. A logical value. If true (the default value)
        the search will be performed with absolute relational operators (<,
        >). If false, <= and >= will be used.
        %}
        function out = extract(inputCellArray, lowerThreshold, upperThreshold, inRange, absolute)
            if ~exist('absolute', 'var')
                absolute = true;
            end
            lowerThreshold = num2str(lowerThreshold);
            upperThreshold = num2str(upperThreshold);
            if inRange
                if absolute
                    logicalFunction = @(value)eval([lowerThreshold '<' num2str(value) '&&' num2str(value) '<' upperThreshold]);
                else
                    logicalFunction = @(value)eval([lowerThreshold '<=' num2str(value) '&&' num2str(value) '<=' upperThreshold]);
                end
            else
                if absolute
                    logicalFunction = @(value)eval([lowerThreshold '>' num2str(value) '||' num2str(value) '>' upperThreshold]);
                else
                    logicalFunction = @(value)eval([lowerThreshold '>=' num2str(value) '||' num2str(value) '>=' upperThreshold]);
                end
            end
            out = fr.lescot.bind.processing.situationDiscoverers.SimpleLogicalFunctionDiscoverer.extract(inputCellArray, logicalFunction); 
        end
        
    end
end

