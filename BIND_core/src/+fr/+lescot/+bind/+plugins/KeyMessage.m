%{
Class:
This class stores a message matching the following regular expression : ^(alt_)?(ctrl_)?(shift_)?.*_.?$
This expression describes the concatenation of the various informations we have on a keyboard event, so that 
they can be accurately identified.
%}
classdef KeyMessage < fr.lescot.bind.observation.RegexpMessage

    methods
 
        %{
        Function:
        Build a new KeyMessage object with an empty current message.
        
        Returns:
        this - a new instance of KeyMessage.
        %}
        function this = KeyMessage()
            this@fr.lescot.bind.observation.RegexpMessage('^(alt_)?(ctrl_)?(shift_)?.*_.?$');
        end
 
    end

end