%{
Class:
Describes a structure to create a string message whose value can be
changed only among selected values.
This class is not intended to be used by herself, it would not be
semanticaly correct.
Instead, subclass it with a class whose constructor takes no arguments but
calls FixedValuesMessage constructor with a list of values.

%}
classdef FixedValuesMessage < fr.lescot.bind.observation.Message
     
    methods
        
        %{
        Function:
        This contructor builds a new Message object with the list of
        allowed values.
        
        Arguments:
        allowedValues - A cell array of strings representing all the
        values allowed for currentMessage.
        
        Returns:
        A Message object
        
        Throws:
        ARGUMENT_EXCEPTION - If the allowedValues argument is not
        a cell array of strings.
        %}
        function out = FixedValuesMessage(allowedValues)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~iscellstr(allowedValues)
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'allowedValues should be a cell array of strings'));
            end
            out = out@fr.lescot.bind.observation.Message(allowedValues);
        end

        %{
        Function:
        Setter for the current message.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        currentMessage - The new string value for the message.
        
        Throws:
        ARGUMENT_EXCEPTION - If the currentMessage
        arg is not an element of allowedValues.
        %}
        function setCurrentMessage(obj, currentMessage)
            import fr.lescot.bind.exceptions.ExceptionIds;
            valuesAllowed = obj.getAllowedValues();
            isCorrect = fr.lescot.bind.utils.StringUtils.checkIfStringIsInArray(valuesAllowed, currentMessage);
            if ~isCorrect
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), '"currentMessage" must be one of the values in allowedValues'));
            else
                obj.setCurrentMessage@fr.lescot.bind.observation.Message(currentMessage);
            end
        end
        
    end

end

