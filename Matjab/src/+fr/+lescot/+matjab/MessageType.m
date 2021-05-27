%Class: fr.lescot.matjab.MessageType
%This class represents the type of a Message.
%This class is only a stub of wrapper, and may not be fully functionnal.
classdef MessageType
    
    properties(Constant)
        %Constant: NORMAL
        %The normal message constant
        %
        %Value:
        %'normal'
        %
        %Modifiers:
        %- Public
        NORMAL = 'normal';
        %Constant: CHAT
        %The chat message constant
        %
        %Value:
        %'chat'
        %
        %Modifiers:
        %- Public
        CHAT = 'chat';
        %Constant: GROUPCHAT
        %The group chat message constant
        %
        %Value:
        %'groupchat'
        %
        %Modifiers:
        %- Public
        GROUPCHAT = 'groupchat';
        %Constant: HEADLINE
        %The headline message constant
        %
        %Value:
        %'headline'
        %
        %Modifiers:
        %- Public
        HEADLINE = 'headline';
        %Constant: ERROR
        %The error message constant
        %
        %Value:
        %'error'
        %
        %Modifiers:
        %- Public
        ERROR = 'error';
    end
    
    properties(Access = private)
        %Property: smackType
        %The embedded java message type.
        %
        %Modifiers:
        %- Private
        smackType;
    end
    
    methods
        
        %Function: MessageType()
        %Constructor of the MessageType.
        %
        %Arguments:
        %javaOrString - Either a string whose value is the same than one of
        %the type constants of the class or a
        %org.jivesoftware.smack.packet.Message$Type java object, to wrap in
        %a Matjab object.
        %
        %Throws:
        %MessageType:MessageType:JavaException - if the call to the
        %underlying java implementation throws an exception.
        %
        %Modifiers:
        %- Public
        function this = MessageType(javaOrString)
            if strcmp('org.jivesoftware.smack.packet.Message$Type', class(javaOrString))
                this.smackType = javaOrString;
            else
                %Complicated stuff to be able to load the inner class Message$Type from Java
                classLoader = org.jivesoftware.smackx.FormField().getClass().getClassLoader();
                typeClass = java.lang.Class.forName('org.jivesoftware.smack.packet.Message$Type', false, classLoader);
                argumentsList = javaArray('java.lang.Class', 1);
                argumentsList(1) = java.lang.Class.forName('java.lang.String', false, classLoader);
                valueOfMethod = typeClass.getMethod('valueOf', argumentsList);
                arguments = javaArray('java.lang.String', 1);
                arguments(1) = java.lang.String(javaOrString);
                try
                    this.smackType = valueOfMethod.invoke('', arguments);
                catch ME
                   throw(MException('MessageType:MessageType:JavaException', ['The underlying java object have thrown the following exception : ' ME.message])); 
                end
            end
        end
        
    end
    
    methods(Static)
        
        %Function: valueOf()
        %Returns the enum constant of this type with the specified name.
        %
        %Arguments:
        %string - A string representing a constant name.
        %
        %Returns: An other string object, with the value of the constant.
        %
        %Throws:
        %MessageType:valueOf:JavaException - if the call to the
        %underlying java implementation throws an exception.
        %
        %Modifiers:
        %- Public
        function out = valueOf(string)
            %Complicated stuff to be able to load the inner class Condition from Java
            classLoader = org.jivesoftware.smackx.FormField().getClass().getClassLoader();
            typeClass = java.lang.Class.forName('org.jivesoftware.smack.packet.Message$Type', false, classLoader);
            argumentsList = javaArray('java.lang.Class', 1);
            argumentsList(1) = java.lang.Class.forName('java.lang.String', false, classLoader);
            valueOfMethod = typeClass.getMethod('valueOf', argumentsList);
            arguments = javaArray('java.lang.String', 1);
            arguments(1) = java.lang.String(string);
            try
                out = XMPPErrorType(valueOfMethod.invoke('', arguments));
            catch ME
                throw(MException('MessageType:valueOf:JavaException', ['The underlying java object have thrown the following exception : ' ME.message]));
            end
        end
        
    end
    
end

