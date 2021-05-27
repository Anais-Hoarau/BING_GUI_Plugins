%Interface: fr.lescot.matjab.MessageListener
%This interface describes the methods that an object must implement to be
%used as a message Listener by a bot.
classdef MessageListener < handle
   
    methods(Abstract)
        %Function: processMessage
        %Process the received messages.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %bot - A reference to the bot that received the message. Useful if
        %some answer is to be sent in the message listener.
        %message - A <fr.lescot.matjab.Message> object.
        %
        %Modifiers:
        %- Public
        %- Abstract
        processMessage(this, bot, message);
    end
    
end

