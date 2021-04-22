%{
Class:
This utility class provides methods for working with cell arrays.
%}
classdef CellArrayUtils

    methods(Static)
               
        %{
        Function:
        This function allow to swap 2 lines of a cell array.
        
        Arguments:
        this - optional
        firstLineIndex - the index of the first of the two lines to swap.
        secondLineIndex - the index of the second of the two lines to swap.
        
        %}
        function out = swapLines(array, firstLineIndex, secondLineIndex)
            firstLine = array(firstLineIndex, :);
            secondLine = array(secondLineIndex, :);
            array(firstLineIndex, :) = secondLine;
            array(secondLineIndex, :) = firstLine;
            out = array;
        end
        
    end
    
end

