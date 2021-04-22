%{
Interface:
This interface describes a way to standardize Events extraction from temporal data (known as Data within
BIND). The input format is identical to the output format of <SignalProcessor> so the two can be chained
easily.

%}
classdef EventDiscoverer < handle
    
    methods(Abstract, Static) 
        %{
        Function:
        Apply an extraction algorithm to a 2*n cell array. The first line of the cell array
        contains the timecodes, and the second line the values.
        
        Arguments:
        inputCellArray - A 2*n cell array of numerical values. 
        varargin - The parameters of the extractor, in the order described by <getParametersList()>.
        
        Returns:
        A cell array, containing the timecodes of the extracted events.
        
        %}
        discoveredEvents = extract(this, inputCellArray, varargin);
        
    end
    
end

