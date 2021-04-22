%{
Class:
This class represents the configuration of a plugin, under the form a
collection of <Arguments>.
%}
classdef Configuration < handle
    
    %{
    Property:
    The variable that stores the cell array of arguments.
    
    %}
    properties(Access = private)
        arguments;
    end
    
    methods
        %{
        Function:
        Default constructor
        
        Arguments:
        none
        
        %}
        function this = Configuration()
            this.arguments = {};
        end
        
        %{
        Function:
        
        Setter for the argument list.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        argsCellArray - a cell array of <Arguments>.
        
        Throws:
        ARGUMENT_EXCEPTION - If the order values of the arguments are not uniques.
        
        %}
        function setArguments(this, argsCellArray)
            import fr.lescot.bind.exceptions.ExceptionIds;
            ordersArray = [];
            for i = 1:1:length(argsCellArray)
               if isempty(find(ordersArray == argsCellArray{i}.getOrder(), 1))
                   ordersArray(i) = argsCellArray{i}.getOrder();
               else
                   throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Some redundancies have been detected in the arguments order values. Order should be unique for each argument'));
               end
            end
            this.arguments = argsCellArray;
        end
        
        function addArgumentInConfig (this, argument)%rajout
            o=this.getArgumentsMaxOrder()
            oa=argument.getOrder()
            this.arguments{oa} = argument;
            
        end
        
        %{
        Function:
        
        Getter for the list of arguments.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of <Arguments>
        
        %}
        function out = getArguments(this)
            out = this.arguments;
        end
        
        %{
        Function:
        
        Return the highest value of the order property of the <Arguments>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        An integer value
        
        %}
        function out = getArgumentsMaxOrder(this)
            maxArg = 1;
            for i = 1:1:length(this.arguments)
                if this.arguments{i}.getOrder() > maxArg
                    maxArg = this.arguments{i}.getOrder();
                end
            end
            out = maxArg;
        end
        
        %{
        Function:
        
        Return the argument with the correspoding order value, if it
        exist, and an empty cell array if it doesn't.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        order - An integer value
        
        Returns:
        An <Argument> or {};
        
        %}
        function out = findArgumentWithOrder(this, order)
            out = {};
            for i = 1:1:length(this.arguments)
                if(this.arguments{i}.getOrder == order)
                    out = this.arguments{i};
                    break;
                end
            end
        end
        
    end
    
end

