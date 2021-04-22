%{
Class:
This class represents an attribute of a <MetaDataBase>.

%}
classdef MetaVariableBase < handle
    
    properties(Access = protected);
        %{
        Property:
        The holder variable for the name of the variable.
        
        %}
        name;
        
        %{
        Property:
        The holder variable for the type of the variable.
        
        %}
        type = fr.lescot.bind.data.MetaVariableBase.TYPE_REAL;
        
                
        %{
        Property:
        The holder variablfor the unit of the data.
        %}
        unit;
        
        %{
        Property:
        The holder variable for the comments about the data.
        %}
        comments;
        
    end
    
    properties(Constant)
        %{
        Constant:
        The constant to describe a numeric value
        
        %}
        TYPE_REAL = 'REAL';
        %{
        Constant:
        The constant to describe a textual value.
        
        %}
        TYPE_TEXT = 'TEXT';
    end
    
    methods
        
        %{
        Function:
        Getter for the name attribute.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        The name of the variable as a String.
        %}
        function out = getName(obj)
            out = obj.name;
        end
        
        %{
        Function:
        Setter for the name attribute.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        name - The new String value for the name attribute.
        %}
        function setName(obj, name)
            obj.name = name;
        end
        
        %{
        Function:
        Getter for the type attribute.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        The type of the MetaAttribute as a String.
        %}
        function out = getType(obj)
            out = obj.type;
        end
        
        %{
        Function:
        Setter for the type attribute. This type describes the type of data
        that will be stored in the variable, and must be one of the type
        constants of the class.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        type - The new String value for the type attribute.
        
        Throws:
        ARGUMENT_EXCEPTION - if the value of type is not
        one of the type constant of the class.
        %}
        function setType(this, type)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~any(strcmpi(type, {this.TYPE_REAL, this.TYPE_TEXT}))
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The value given for type is not a valid type. Please check valid types in documentation'));
            end
            this.type = type;
        end

        
        %{
        Function:
        Getter for the unit of the datas.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        Returns:
        The unit of the datas.
        %}
        function out = getUnit(this)
            out = this.unit;
        end
        
        %{
        Function:
        Setter for the unit of the datas.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        unit - A string containing the new unit to set.
        %}
        function setUnit(this, unit)
            this.unit = unit;
        end
        
         %{
        Function:
        Getter for the comments about the datas.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        Returns:
        The comments of the datas.
        %}
        function out = getComments(this)
            out = this.comments;
        end
        
        %{
        Function:
        Setter for the comments about the datas.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        comments - A string containing the new comments to set.
        %}
        function setComments(this, comments)
            this.comments = comments;
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
           out = [this.name '|' this.type '|' this.unit '|' this.comments];
        end
        
    end
    
end