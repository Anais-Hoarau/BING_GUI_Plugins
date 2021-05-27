%Class: fr.lescot.matjab.Message
%This class represents a message as sent or received by the <Bot>. It's an
%abstract layer over the xml structure of a message.
classdef Message < handle
    
    properties(Access = private)
        %Property: smackMessage
        %The java smack message wrapped in the object.
        %
        %Modifiers:
        %- Private
        smackMessage;
    end
    
    methods
        
        %TODO: Implement Body class to be able to implement this one
        %         function out = getBodies(this)
        %             out = this.smackMessage.getBodies().toArray();
        %         end
        %Todo : See how to implement :
        %boolean removeBody(Message.Body body)
        
        %Function: Message()
        %The constructor of the message.
        %
        %Arguments:
        %varargin - Either nothing (to build an empty message), or a smack
        %Message to wrap.
        %
        %Modifiers:
        %- Public
        function this = Message(varargin)
            if size(varargin,2) == 1
                this.smackMessage = varargin{1};
            else
                this.smackMessage = org.jivesoftware.smack.packet.Message();
            end
        end
        
        %Function: addBody()
        %Add a body to the message for a specified language.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %language - A string representing the language of the body added.
        %body - The string containing the content of the body.
        %
        %Modifiers:
        %- Public
        function addBody(this, language, body)
            this.smackMessage.addBody(java.lang.String(language), java.lang.String(body));
        end
        
        %Function: getBody()
        %Returns the default body of the message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- a String.
        %
        %
        %Modifiers:
        %- Public
        function out = getBody(this)
            out = this.smackMessage.getBody();
        end
        
        %Function: getBody()
        %Returns the default body of the message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %language - A string that indicated the language of the body to
        %retrieve.
        %
        %Returns: 
        %- a String.
        %
        %
        %Modifiers:
        %- Public
        function out = getBodyWithLanguage(this, language)
            out = this.smackMessage.getBody(java.lang.String(language));
        end
        
        %Function: getBodyLanguages()
        %Returns list of languages for which a body exist.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A cell array of Strings.
        %
        %Modifiers:
        %- Public
        function out = getBodyLanguages(this)
            out = cell(this.smackMessage.getBodyLanguages().toArray());
        end
        
        %Function: getSubject()
        %Returns the subject of the message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getSubject(this)
            out = this.smackMessage.getSubject();
        end
        
        %Function: getThread()
        %Returns the thread id of a message. A thread is a sequence of chat
        %messages.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getThread(this)
            out = this.smackMessage.getThread();
        end
        
        %Function: getType()
        %Returns the type of the message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getType(this)
            out = this.smackMessage.getType().toString();
        end
        
        %Function: removeBody()
        %Removes the body of the message with the matching language.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %language - A string.
        %
        %Modifiers:
        %- Public
        function removeBody(this, language)
            this.smackMessage.removeBody(java.lang.String(language));
        end
        
        %Function: setBody()
        %Set the default body of the message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %body - The string containing the content of the body.
        %
        %Modifiers:
        %- Public
        function setBody(this, body)
            this.smackMessage.setBody(java.lang.String(body));
        end
        
        %Function: setLanguage()
        %Sets the xml:lang of this Message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %language - The string containing the language.
        %
        %Modifiers:
        %- Public
        function setLanguage(this, language)
            this.smackMessage.setLanguage(java.lang.String(language));
        end
        
        %Function: setSubject()
        %Sets the subject of this Message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %subject - The string containing the subject.
        %
        %Modifiers:
        %- Public
        function setSubject(this, subject)
            this.smackMessage.setSubject(java.lang.String(subject));
        end
        
        %Function: setThread()
        %Sets the thread id of this Message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %thread - The string containing the thread id.
        %
        %Modifiers:
        %- Public
        function setThread(this, thread)
            this.smackMessage.setThread(java.lang.String(thread));
        end
        
        %Function: setType()
        %Sets the type of this Message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %type - The string containing the type id.
        %
        %Modifiers:
        %- Public
        function setType(this, type)
            %Todo: add exception management if the string is not a correct
            %value for the enum
            this.smackMessage.setType(org.jivesoftware.smack.packet.Message.Type.fromString(java.lang.String(type)));
        end
        
        %Function: toXML()
        %Returns the complete XML version of the message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns:
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = toXML(this)
            out = this.smackMessage.toXML();
        end
        
        %Function: getFrom()
        %Returns the JID of the message sender.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getFrom(this)
            out = this.smackMessage.getFrom();
        end
        
        %Function: setFrom()
        %Set the JID of the message emitter.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %from - The string containing the JID.
        %
        %Modifiers:
        %- Public
        function setFrom(this, from)
            this.smackMessage.setFrom(java.lang.String(from));
        end
        
        %Function: getTo()
        %Returns the JID of the message recipient.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getTo(this)
            out = this.smackMessage.getTo();
        end
        
        %Function: setTo()
        %Set the JID of the message recipient.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %from - The string containing the JID.
        %
        %Modifiers:
        %- Public
        function setTo(this, to)
            this.smackMessage.setTo(java.lang.String(to));
        end
        
        %Function: getPacketId()
        %Return the id of the packet
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getPacketId(this)
            out = this.smackMessage.getPacketId();
        end
        
        %Function: setPacketId()
        %Set the ID of the packet
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %packetId - The string containing the ID.
        %
        %Modifiers:
        %- Public
        function setPacketID(this, packetId)
            this.smackMessage.setPacketID(java.lang.String(packetId));
        end
          
        %Function: getXmlns()
        %Returns the extension sub-packets (including properties data) as
        %an XML String
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getXmlns(this)
            out = this.smackMessage.getXmlns();
        end
        
        %Function: getError()
        %Returns the error associated with this packet, or an empty cell array if there
        %are no errors. 
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getError(this)
            %A dirty trick to make up for the fact that instead of a null
            %value, we have no assignement at all when there are no errors
            %... wich cause an exception to be thrown when you try to
            %affect the non-result or use it as a function argument...
            try
                smackError = this.smackMessage.getError();
            catch ME
                if strcmp(ME.identifier, 'MATLAB:unassignedOutputs')
                    out = {};
                else
                    throw(ME);
                end
            end
            out = fr.lescot.matjab.error.XMPPError(smackError);
        end
        
        %Function: setError()
        %Sets the error for this message. 
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %error - An <error.XMPPError> object.
        %
        %Modifiers:
        %- Public
        function setError(this, error)
            this.smackMessage.setError(error.unwrap());
        end
        
        %Function: addExtension()
        %Add an extension to the message.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %extension - An <extension.Extension> object.
        %
        %Modifiers:
        %- Public
        function addExtension(this, extension)
            this.smackMessage.addExtension(extension.unwrap());
        end
        
        %Function: getExtension()
        %Returns the first packet extension that matches the specified
        %element name and namespace. If If the provided elementName is null
        %then only the provided namespace is attempted to be matched.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %elementName - A String.
        %namespace - A String.
        %
        %Returns: 
        %- An <extension.Extension> object.
        %
        %Modifiers:
        %- Public
        function out = getExtension(this, elementName, namespace)
            if(isempty(elementName)) 
                smackExtension = this.smackMessage.getExtension(elementName), java.lang.String(namespace)
            else
                smackExtension = this.smackMessage.getExtension(java.lang.String(elementName), java.lang.String(namespace));
            end
            if ~isempty(smackExtension)
                out = fr.lescot.matjab.extension.Extension(smackExtension);
            else
                out = {};
            end
        end
        
        %Function: getExtensions()
        %Returns a cell array of all the extensions of the packet.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- An <extension.Extension> cell array.
        %
        %Modifiers:
        %- Public
        function out = getExtensions(this)
            out = {};
            extensionsCollection = this.smackMessage.getExtensions();
            iterator = extensionsCollection.iterator();
            while(iterator.hasNext())
                nextExtension = fr.lescot.matjab.extension.Extension(iterator.next());
                out{1, length(out) + 1} = nextExtension;
            end
        end
        
        %Function: removeExtension()
        %Remove the extension argument from the packet.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %extension - An <extension.Extension> object.
        %
        %Modifiers:
        %- Public 
        function removeExtension(this, extension)
            this.smackMessage.removeExtension(extension.unwrap());
        end
        
        %Function: unwrap()
        %*DO NOT USE THIS METHOD UNLESS WORKING ON IMPROVING THE
        %IMPLEMENTATION OF THE WRAPPER. NEVER. EVER. It would make your code dependant of the underlying java implementation !!!*.
        %
        %Returns the embedded java object.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A org.jivesoftware.smack.packet.Message object.
        %
        %Modifiers:
        %- Public 
        function out = unwrap(this)
            out = this.smackMessage();
        end
        
    end
    
    methods(Static)
        
        %Function: nextID()
        %Returns the next unique id. Each id made up of a short
        %alphanumeric prefix along with a unique numeric value.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        %- Static
        function out = nextID()
            out =  org.jivesoftware.smack.Message.nextID();
        end
        
    end
    
end

