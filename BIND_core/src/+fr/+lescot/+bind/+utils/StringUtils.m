%{
Class:
This class contains some static methods concerning strings.
%}
classdef StringUtils

    methods(Static = true, Sealed = true)
       
        %{
        Function:
        Returns true if the string is in the celle array of strings.
        
        Arguments:
        array - the cell array of strings to be searched.
        string - the string to look for.
        
        Returns:
        true if the string is in the array.
        
        %}
        function out = checkIfStringIsInArray(array, string)
           out = false;
           for i=1:1:length(array)
               if(strcmp(array{i}, string))
                   out = true;
               end
           end
        end
        
        %{
        Function:
        Takes an integer value resprenting the time in seconds, and
        return it as a String formated as hh:mm:ss:MMM
        
        Arguments:
        secondsToFormat - The integer to format
        
        Returns:
        true if the string is in the array.
        
        %}
        function out = formatSecondsToString(secondsToFormat)
            import fr.lescot.bind.utils.StringUtils;
            millis = round(secondsToFormat * 1000);
            hours = sprintf('%02d', (millis - rem(millis, 3600000)) /3600000);
            millis = rem(millis, 3600000);
            minutes = sprintf('%02d', (millis - rem(millis, 60000)) / 60000);
            millis = rem(millis, 60000);
            seconds = sprintf('%02d', (millis - rem(millis, 1000))  / 1000);
            millis = sprintf('%03i', mod(millis, 1000));
            out = [hours ':' minutes ':' seconds ':' millis];
        end
        
    end
    
end

