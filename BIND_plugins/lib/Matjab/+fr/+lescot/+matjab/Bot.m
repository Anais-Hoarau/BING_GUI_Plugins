%Class: fr.lescot.matjab.Bot
%This class is the main class of the library, since it encapsulates the
%java bot on which the whole wrapper relies. The way it work is quite
%simple : the java bot (fr.lescot.matjab.BufferBot) receive all the
%messages, and store them. The matlab bot poll the java bot to pick-up the
%messages, anbd activates the messages handler. This process is not the
%best one, but it is the only one to worka around the fact we can't
%associate a matlab callbback handler to a java object.
%Message sending is more simple, since it is not asynchronous and there is
%no notion of handling events. To work properly, this bot needs
%BufferBot.jar in the path, with its dependencies.
classdef Bot < handle
    
    properties(Access = private)
        %Property: bot
        %The embedded java bot.
        %
        %Modifiers:
        %- Private
        bot;
        %Property: listeners
        %The cell array of function handlers that will be called when a
        %message is received.
        %
        %Modifiers:
        %- Private
        listeners = {};
        %Property: messagesRetrievalTimer
        %The timer that manages the polling of the java bot.
        %
        %Modifiers:
        %- Private
        messagesRetrievalTimer;
        %Property: isConnected
        %A boolean value that keep in memory whether the bot is connected
        %or not (used to avoid calling a disconnect method on an aloready disconnected java bot, causing an error).
        %
        %Modifiers:
        %- Private
        isConnected = false;
    end
    
    methods
        
        %Function: Bot()
        %Constructor of the bot. Do not support proxy configuration at the
        %moment.
        %
        %Arguments:
        %serverName - A string indicating the name of the server to connect
        %login - A string indicating the login of the user
        %password - A string representing the password of the user on the
        %server.
        %ressource - A string representing the ressource from which the user is connected.
        %treatMessagesStoredOnServer - If this boolean is true, the
        %messages sent to the server while offline will be processed. If it
        %is false, they will be deleted.
        %
        %Modifiers:
        %- Public
        function this = Bot(serverName, login, password, ressource, treatMessagesStoredOnServer)
            this.importSmackIntoJavaPath();
            this.bot = fr.lescot.matjab.BufferBot(java.lang.String(serverName), java.lang.String(login), java.lang.String(password), java.lang.String(ressource), java.lang.Boolean(treatMessagesStoredOnServer));
            this.messagesRetrievalTimer = timer('ExecutionMode', 'fixedDelay', 'Period', 0.02, 'TimerFcn', @this.checkAndProcessMessages);
        end
        
        %Function: addMessageListener()
        %
        %Add a new message listener to the bot. A message listener is an
        %object implementing the interface
        %<fr.lescot.matjab.MessageListener>. When a message is received by
        %the bot, the method processMessage of ALL the listeners will be
        %applied to the message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %messageListener - an object implementing the MessageListener interface.
        %
        %Throws:
        %Bot:addMessageListener:InvalidArgument - if messageListener is not
        %a MessageListener implementation.
        %
        %Modifiers:
        %- Public
        function addMessageListener(this, messageListener)
            if ~isa(messageListener, 'fr.lescot.matjab.MessageListener')
               throw(MException('Bot:addMessageListener:InvalidArgument', 'The argument messageListener must be an implementation of the interface fr.lescot.matjab.MessageListener'));
            end
            this.listeners = {this.listeners{:} messageListener};
        end
        
        %Function: connect()
        %
        %Connect the bot with the informations provided in the constructor.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Modifiers:
        %- Public
        function connect(this)
            if ~this.isConnected
                start(this.messagesRetrievalTimer);
                try
                    this.bot.connect();
                catch ME
                    splittedMessage = regexp(ME.message, '\r\n', 'split');
                    throw(MException('Bot:connect:ConnectionError', ['An exception occured while trying to connect to the server, with the following message : ' splittedMessage{1}]));
                end
                this.isConnected = true;
            end
        end
        
        %Function: disconnect()
        %
        %Disonnect the bot. It can be reconnected later with <connect()>.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Modifiers:
        %- Public
        function disconnect(this)
            if this.isConnected
                this.bot.disconnect();
                stop(this.messagesRetrievalTimer);
                this.isConnected = false;
            end
        end
        
        %Function: sendMessage()
        %
        %Send the message object passed in argument to the server.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %message - A <fr.lescot.matjab.Message> object.
        %
        %Modifiers:
        %- Public
        function sendMessage(this, message)
            this.bot.sendMessage(message.unwrap());
        end
        
        %Function: delete
        %Overwrite the standard delete method to ensure proper
        %disconnection and timer suppresion.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Modifiers:
        %- Public
        function delete(this)
            this.disconnect();
            delete(this.messagesRetrievalTimer);
        end
        
    end
    
    methods(Access = private)
        
        %Function: checkAndProcessMessages
        %The callback method called by the timer on each iteration, to
        %check for new messages from the java bot.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %src - The object who called the method. Optionnal.
        %eventData - Informations about the event that caused the call. Optionnal.
        %
        %Modifiers:
        %- Private
        function checkAndProcessMessages(this, src, eventData)
            smackMessages = this.bot.getBufferedMessages();
            if smackMessages.size() > 0
                %For each message ...
                for i = 1:1:length(smackMessages)
                    matlabMessage = fr.lescot.matjab.Message(smackMessages.elementAt(i-1));
                    % ... call each messageListener.
                    for j = 1:1:length(this.listeners)
                        this.listeners{j}.processMessage(this, matlabMessage);
                    end
                end
            end
        end
        
        %Function: importSmackIntoJavaPath
        %Add the java bot to the java path. The jar must already be in the
        %path.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Modifiers:
        %- Private
        function importSmackIntoJavaPath(this)
            if isempty(which('fr.lescot.matjab.BufferBot'))
                javaaddpath(which('BufferBot.jar'));
            end
        end
        
    end
    
end

