%{
Class:
This class represents an argument of a <Configuration>. This argument can
be an optionnal argument or not. If it is an optionnal argument, it name
will be used in the invocation of the plugin, in order to respect the key
/ value syntax used by Matlab for such args. The value can be a single
string (under the form of a 1x1 cell array) or a cell array of strings.

%}
classdef Argument < handle
    
    properties(Access = private)
        %{
        Property:
        The name of the argument.
        
        %}
        name;
        
        %{
        Property:
        The variable that tells wether the argument is optionnal or not.
        
        %}
        isOptionnalProperty;
        
        %{
        Property:
        The value of the argument.
        
        %}
        value;
        
        %{
        Property:
        The order of the argument in the call.
        
        %}
        order;
    end
    
    methods
        
        %{
        Function:
        
        The constructor sets all the fields of the object.
        
        Arguments:
        name - A string representing the name of the argument.
        isOptionnal - A boolean (aka logical) value.
        value - the value for the argument.
        order - the order that will indicate the relative position of the
        argument in the call of the command. The value 1 is not allowed,
        since for most plugins it will be occupied by the plugin, or the
        plugins cell array.
        
        %}
        function this = Argument(name, isOptionnal, value, order)
            this.setOrder(order);
            this.name = name;
            this.isOptionnalProperty = isOptionnal;
            this.value = value;
        end
        
        %{
        Function:
        
        Setter for the name attribute.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newName - A string containing the name to set.
        
        %}
        function setName(this, newName)
            this.name = newName;
        end
        
        %{
        Function:
        
        Getter for the name attribute
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A string.
        
        %}
        function out = getName(this)
            out = this.name;
        end
        
        %{
        Function:
        
        Setter for the isOptionnal attribute.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        value - A logical value.
        
        %}
        function setIsOptionnal(this, value)
            this.isOptionnalProperty = value;
        end
        
        %{
        Function:
        
        Getter for the isOptionnal attribute.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A logical.
        
        %}
        function out = isOptionnal(this)
            out = this.isOptionnalProperty;
        end
        
        %{
        Function:
        
        Setter for the value of the Argument.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newValue - A value
        
        %}
        function setValue(this, newValue)
            this.value = newValue;
        end
        
        %{
        Function:
        
        Getter for the value.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A value.
        
        %}
        function out = getValue(this)
            out = this.value;
        end
        
        %{
        Function:
        
        Getter for the order.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A double
        
        %}
        function out = getOrder(this)
           out = this.order; 
        end
        
        %{
        Function:
        
        Setter for the order of the Argument.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        order - A double
        
        Throws:
        ARGUMENT_EXCEPTION : setOrder:invalidOrderValue - If order <= 1
        
        %}
        function setOrder(this, order)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if order <= 1
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The value of "order" should be > 1.'));
            else
                this.order = order;
            end
        end
    end
    
end

