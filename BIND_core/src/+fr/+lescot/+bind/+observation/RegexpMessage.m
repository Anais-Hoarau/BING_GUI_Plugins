%{
Class:

An implementation of <Message> that bases message validation on a regular expression. Not intended to be used itself,
it would be semantically incorrect. Instead, subclass it with a class whose constructor takes no arguments but
calls Message constructor a regexp as argument.
%}
classdef RegexpMessage < fr.lescot.bind.observation.Message
    
    methods
        
        %{
        Function:
        This contructor builds a new Message object with the regexp matching allowed values.
        
        Arguments:
        allowedValues - A string regexp.
        
        Returns:
        A RegexpMessage object.
        
        Throws:
        ARGUMENT_EXCEPTION - if allowedValues is not a string.
        %}
        function this = RegexpMessage(allowedValues)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~ischar(allowedValues)
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'allowedValues should be a string.'));
            end
            this@fr.lescot.bind.observation.Message(allowedValues);
        end
        
        %{
        Function:
        Setter for the current message.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        currentMessage - The new string value for the message.

        Throws:
        ARGUMENT_EXCEPTION - If the currentMessage
        arg do not match the validation regexp.
        %}
        function setCurrentMessage(obj, currentMessage)
            import fr.lescot.bind.exceptions.ExceptionIds;
            regexpAllowed = obj.getAllowedValues();
            match = regexp(currentMessage, regexpAllowed, 'once');
            if isempty(match)
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), '"currentMessage" must match the defined regexp'));
            else
                obj.setCurrentMessage@fr.lescot.bind.observation.Message(currentMessage);
            end
        end
        
    end
end
