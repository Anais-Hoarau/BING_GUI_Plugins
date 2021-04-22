%{
Class:
This class represents all the datas concerning an instance of a data type.
It is a base class, and is extended by the Meta classes corresponding to
several other types of data.

%}
classdef MetaBase < handle
    
    
    properties (Access = private)
        %{
        Property:
        the name of the data.
        
        %}
        name;        
        
        %{
        Property:
        the comments about the datas.
        
        %}
        comments;
        
        %{
        Property:
        Is the data a base data or not ? If it is, it will be read only.
        
        %}
        isBaseAttr;
        
        %{
        Property:
        the user variables list of the table.
        
        %}
        userVariables = {};
        
        %{
        Property:
        the framework variables for this item. Includes the key variables, such as timecode.
        
        %}
        frameworkVariables = {};
    end
    
    methods
        
        %{
        Function:
        Instanciates a new MetaBase object.
        
        Returns:
        A MetaBase instance
        %}
        function this = MetaBase()
            this.isBaseAttr = false;
        end
        
        %{
        Function:
        Getter for the isBase attribute. If the data is a base data, it is
        forbidden to modify it. The default value is false.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        the boolean isBase attribute.
        %}
        function out = isBase(obj)
            out = obj.isBaseAttr;
        end
        
        %{
        Function:
        Setter for the isBase attribute.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        isBase - the boolean value indicating if the item is a base one.
        %}
        function setIsBase(obj, isBase)
            obj.isBaseAttr = isBase;
        end
        
        %{
        Function:
        Getter for the name of the data.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        The name of the data, as a String.
        %}
        function out = getName(obj)
            out = obj.name;
        end
        
        %{
        Function:
        Setter for the name of the data.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        name - the new name to set, as a String.
        %}
        function setName(obj, name)
            obj.name = name;
        end    
        
        %{
        Function:
        Getter for the comments about the data.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        A string containing the comment about the data. May be an empty
        String.
        %}
        function out = getComments(obj)
            out = obj.comments;
        end
        
        %{
        Function:
        Setter for the comments of the data.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        comments - the new comment String to set.
        %}
        function setComments(obj, comments)
            obj.comments = comments;
        end
       
        %{
        Function:
        Getter for the variables of the datas (only the ones added by the user via <setVariables>.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of <MetaVariableBase>.
                
        %}
        function out = getVariables(obj)
            out = obj.userVariables;
        end
        
        %{
        Function:
        Setter for the <MetaVariableBase> of the datas. Any variable which name is in 
        <kernel.Trip.RESERVED_VARIABLE_NAMES> will be ignored, and won't be added to the MetaBase object.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        variables - the new cell array of <MetaVariableBase> extension to set.
        %}
        function setVariables(this, variables)
            cleanedVariable = {};
            for i = 1:1:length(variables)
                variableName = variables{i}.getName();
                if ~any(strcmpi(variableName, fr.lescot.bind.kernel.Trip.RESERVED_VARIABLE_NAMES))
                    cleanedVariable{end + 1} = variables{i}; %#ok<AGROW>
                end
            end
            this.userVariables = cleanedVariable;
        end
        
        %{
        Function:
        Getter for the framework variables of the MetaBase. Either timecode or startTimecode and endTimecode
        , depending on the extension of MetaBase instanciated.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of one of the inherited class of <MetaVariableBase>, depending on the extension of MetaBase instanciated.
                
        %}
        function out = getFrameworkVariables(this)
            out = this.frameworkVariables;
        end
        
        %{
        Function:
        Returns the concatenated results of both <getFrameworkVariables()> and <getVariables()>
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of <MetaVariableBase>.      
        %}
        function out = getVariablesAndFrameworkVariables(this)
            out = [this.getFrameworkVariables() this.getVariables()];
        end
        
        %{
        Function:
        Returns a hash of the object, which is an identifier string which
        is equal between two objects only if the two objects are equal
        (equality being here an esuality of value, not of reference).
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A string   
        %}        
        function out = hash(this)
           out = [this.name '|' this.comments '|' this.isBaseAttr];
        end
        
    end

    methods(Access = protected)
       %{
        Function:
        Setter for the <MetaVariableBase> representing the keys of the data.
        Arguments:
        this - The object on which the function is called, optionnal.
        variables - the new cell array of <MetaVariableBase> extension to set in <frameworkVariables>.
        %}
        function setFrameworkVariables(this, variables)
            this.frameworkVariables = variables;
        end
    end
    
end

