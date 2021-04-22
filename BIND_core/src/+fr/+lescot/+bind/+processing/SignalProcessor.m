%{
Interface:
This interface describes a way to standardize temporal data treatement ("Data") when using
the BIND framework. The goal is that the input and output format remains
identical, so that SignalProcessors can easily be chained. So output type is always "Data"

%}
classdef SignalProcessor < handle
    
    methods(Abstract, Static) 
        %{
        Function:
        Apply some treatements to a 2*n cell array. The first line of the array
        contains the timecodes, and the second line the values.
        
        Arguments:
        inputCellArray - A 2*n cell array of numerical values. 
        parametersValues - A cell array of strings containing the values
        of the parameters, in the order described by <getParametersList()>.
        
        Returns:
        A 2*n filtered cell array : pairs of timecode and associated value
        
        %}
        processedData = process(this, inputCellArray, parametersValues);
        
        %{
        Function:
        Returns the human-readable name of the filter.
        
        Returns:
        A String.
        
        %}
        out = getName(this);
        
        %{
        Function:
        Returns the list of the name of the parameters required.
        
        Returns:
        A cell array of Strings.
        
        %}
        out = getParametersList();
        
        %{
        Function:
        Returns the default values of the parameters, in the same order
        than the names returned by <getParametersList()>.
        
        Returns:
        A cell array of Strings.
        
        %}
        out = getParametersDefaultValues();
        
    end
    
end

