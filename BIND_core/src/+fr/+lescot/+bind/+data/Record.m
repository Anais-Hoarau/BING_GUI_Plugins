%{
Class:
This class represents a result from a database request. It is
implemented as a struct array, to avoid costly operations when converting from
sqlite4m output. Efficient, but hard to manipulate, because some syntaxes
aren't very well documented in Matlab.

%}
classdef Record < handle
    
    properties (Access = private)
        %{
        Property:
        A struct array with fields representing the Variables
        
        %}
        data;
        
        %{
        Property:
        A logical marking wether the Record is empty or not
        
        %}
        isEmptyProperty;
    end
    
    methods
        
        %{
        Function:
        Constructor of Record. This method takes struct array as
        argument. This array will be used as a dataholder.
        Developpers should not create a Record object themselves using the constructor, but
        should instanciante it with the return of a "trip.get____" method.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        structure - The structure to embed, or an empty matrix.
        
        Returns:
        A new Record object.
        
        Throws:
        ARGUMENT_EXCEPTION - If the argument is not
        an empty matrix or a struct array.
        %}
        function this = Record(structure)
            import fr.lescot.bind.exceptions.ExceptionIds;
            this.isEmptyProperty = false;
            if ~isstruct(structure)
                if isnumeric(structure) && isempty(structure)
                    %In this case, it's very probable
                    %that it is an empty result returned by sqlite4m. In
                    %this case, we don't throw an exception but we mark the
                    %Record as empty (returning no data is not an
                    %exception, it is a normal use case for a database
                    %request).
                    this.isEmptyProperty = true;
                else
                    throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The expected argument is a struct array or an empty matrix.'))
                end
            else
                this.data = structure;
            end
        end
        
        %{
        Function:
        Retrieves the values stored in record for the given variable
        name (case insensitive search). If the Record is an empty one, an empty cell array is
        returned wathever the value of "variableName" is.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        variableName - A string giving the name of the variable to retrieve.
        
        Returns:
        A cell array
        
        Throws:
        UNCLASSIFIED_EXCEPTION - If the string passed as variableName is
        not a valid key.
        %}
        function out = getVariableValues(obj, variableName)
            import fr.lescot.bind.exceptions.ExceptionIds;
            try
                if(~obj.isEmpty )
                    variableNamesList = fieldnames(obj.data);
                    variableIndexes = find(strcmpi(variableName, variableNamesList));
                    value = {obj.data.(variableNamesList{variableIndexes(1)})};
                else
                    value = {};
                end
            catch ME
                if any(strcmpi(ME.identifier, {'MATLAB:nonExistentField' 'MATLAB:noSuchMethodOrField' 'MATLAB:badsubscript'}))
                    throw(MException(ExceptionIds.UNCLASSIFIED_EXCEPTION.getId(), 'The requested variable is not present in this Record.'));
                else
                    rethrow(ME);
                end
            end
            out = value;
        end
        
        %{
        Function:
        Returns a cell array of strings containing the names of the
        variables available in this Record.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of strings.
        %}
        function out = getVariableNames(obj)
            if ~obj.isEmpty
                out = fieldnames(obj.data);
            else
                out = {};
            end
        end
        
        %{
        Function:
        Returns a logical that reprensents the fact that the number of elements in the Record is 0 or not..
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A logical.
        %}
        function out = isEmpty(this)
           out = this.isEmptyProperty; 
        end
        
        %{
        Function:
        Builds a x by n cell array, where x id the number of elements
        passed un variablesList. It is basically a concatenation of
        various variables values in a single vector.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        variablesList - a cell array of Strings
        
        Returns:
        A cell array of values.
        %}
        function out = buildCellArrayWithVariables(this, variablesList)
           out = {};
           if ~this.isEmpty
               for i = 1:1:length(variablesList)
                   values = this.getVariableValues(variablesList{i});
                   out(i, 1:length(values)) = values; %#ok<AGROW>
               end
           end
        end
        
    end
    
end

