%{
Interface:
This interface describes a way to standardize computation of aggregated values on the duration of each occurence of a situation when using
the BIND framework.

A typical use case would be to calculate the mean value of a variable
during each occurence of a situation.

%}
classdef SituationAggregator < handle
    
    methods(Abstract, Static)
        %{
        Function:
        Apply some treatements to some datas within the boundaries of a
        situation
        
        Arguments:
        inputSituationTimecodes - A 2*n cell array. The first line contains the
        timecode of the beginning of each occurence, and the second line
        contains the matching end timecode in the same column.
        inputDataValues - A 2*n cell array with the timecode of the data in the
        first line, and the matching value in the second.
        parametersValues - A cell array of strings containing the values
        of the parameters, in the order described by <getParametersList()>.
        
        Returns:
        A 3*n processed cell array. The first line contains the timecodes of the
        beginning of the occurences, the second the matching end timecode,
        and the third one, the matching aggregated value. The length of
        the return should generally be the same that the length of
        the initial situations array.
        
        %}
        processedValues = process(this, inputSituationTimecodes, inputDataValues , parametersValues);
        
    end
    
end

