%{
Class:
This class is the base class used for various implementations of observer / observable messages.

%}
classdef Message < handle
    
    properties (Access = private)
        %{
        Property:
        Stores the current value of message.
        
        %}
        currentMessage = '';
        
        %{
        Property:
        Stores the allowed values.
        
        %}
        allowedValues;
    end
    
    methods
        
        %{
        Function:
        Constructor for the Message.
        
        Arguments:
        allowedValues - An object that will be used by implementations to 
        check the validity of the message value.
        %}
        function this = Message(allowedValues)
            this.allowedValues = allowedValues;
        end
        
        %{
        Function:
        Getter for allowed values.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        out - An object representing the values allowed for currentMessage.
        %}
        function out = getAllowedValues(obj)
            out = obj.allowedValues;
        end
        
        %{
        Function:
        Getter for the current message.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        out - A string representing the current message.
        %}
        function out = getCurrentMessage(obj)
           out =  obj.currentMessage;
        end
        
        %{
        Function:
        Set the value of the current message. This method is intended to be re-implemented in implementations.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        messageValue - the string value of the message.
        %}
        function setCurrentMessage(this, messageValue)
           this.currentMessage = messageValue; 
        end
        
    end
    

end

