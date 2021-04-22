%{
Interface:
This class is the interface to implement to give Observers capabilities to
an object.

See also http://en.wikipedia.org/wiki/Observer_pattern for more details 
about the Observer design pattern.

%}
classdef Observer < handle
    
    methods (Abstract = true)
        %{
        Function:
        Performs update operations on notify.
        This is the unique method of the interface. It's implementation
        must perform all the necessaries operations when the observed
        object notifies a change.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        message - A <Message> object, containing a text value (or the
        default empty value).
        
        
        Throws:
        ARGUMENT_EXCEPTION - If the number of args is not
        1 (one).
        %}
        update(object, message)
    end
    
end

