%{
Interface:
This interface describes a way to standardize Situations extraction from temporal data (known as Data within
BIND). The input format is identical to the output format of <SignalProcessor> so the two can be chained
easily.

%}
classdef SituationDiscoverer < handle
    
    methods(Abstract, Static) 
        %{
        Function:
        Apply an extraction algorithm to a 2*n cell array. The first line of the array
        contains the timecodes, and the second line the values.
        
        Arguments:
        inputCellArray - A 2*n cell array of numerical values. 
        parametersValues - A cell array of strings containing the values
        of the parameters, in the order described by <getParametersList()>.
        
        Returns:
        A 2*n cell array, containing the start timecodes of the extracted situations on the first line
        and the matching end timecodes on the second line.
        
        %}
        discoveredSituations = extract(this, inputCellArray, parametersValues);
        
    end
    
end

