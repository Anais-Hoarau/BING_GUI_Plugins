%{
Interface:
This interface describes a way to standardize Events extraction from temporal data (known as Data within
BIND), with a specialization toward extracting events from geographic coordinates.

%}
classdef GeographicEventDiscoverer < handle
    
    methods(Abstract, Static) 
        %{
        Function:
        Apply an extraction algorithm to a 3*n cell array. The first line of the cell array
        contains the timecodes, and the second line the latitudes, and the thir line longitudes.
        %inputCellArray :
        %[time1 | time2 | time... ]
        %[lat1  | lat2  | latn... ]
        %[long1 | long2 | longn...]
        Arguments:
        inputCellArray - A 3*n cell array of numerical values. 
        varargin - The additional arguments of the discovrer.
        
        Returns:
        A cell array, containing the timecodes of the extracted events.
        
        %}
        discoveredEvents = extract(this, inputCellArray, varargin);
        
    end
    
end

