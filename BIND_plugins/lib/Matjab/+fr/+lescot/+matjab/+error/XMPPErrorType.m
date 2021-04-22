%Class: fr.lescot.matjab.error.XMPPErrorType
classdef XMPPErrorType
    
    properties(Constant)
        WAIT = 'WAIT';
        CANCEL = 'CANCEL';
        MODIFY = 'MODIFY';
        AUTH = 'AUTH';
        CONTINUE = 'CONTINUE';
    end
    
    properties(Access = private)
        smackType;
    end
    
    methods
        
        function this = XMPPErrorType(javaOrString)
            if strcmp('org.jivesoftware.smack.packet.XMPPError$Type', class(javaOrString))
                this.smackType = javaOrString;
            else
                %Complicated stuff to be able to load the inner class Condition from Java
                classLoader = org.jivesoftware.smackx.FormField().getClass().getClassLoader();
                typeClass = java.lang.Class.forName('org.jivesoftware.smack.packet.XMPPError$Type', false, classLoader);
                argumentsList = javaArray('java.lang.Class', 1);
                argumentsList(1) = java.lang.Class.forName('java.lang.String', false, classLoader);
                valueOfMethod = typeClass.getMethod('valueOf', argumentsList);
                arguments = javaArray('java.lang.String', 1);
                arguments(1) = java.lang.String(javaOrString);
                %TODO : chopper l'exception java en cas d'argument illégal et la
                %transformer en exception matlab
                this.smackType = valueOfMethod.invoke('', arguments);
            end
        end
        
    end
    
    methods(Static)
        
        function out = valueOf(string)
            %Complicated stuff to be able to load the inner class Condition from Java
            classLoader = org.jivesoftware.smackx.FormField().getClass().getClassLoader();
            typeClass = java.lang.Class.forName('org.jivesoftware.smack.packet.XMPPError$Type', false, classLoader);
            argumentsList = javaArray('java.lang.Class', 1);
            argumentsList(1) = java.lang.Class.forName('java.lang.String', false, classLoader);
            valueOfMethod = typeClass.getMethod('valueOf', argumentsList);
            arguments = javaArray('java.lang.String', 1);
            arguments(1) = java.lang.String(string);
            %TODO : chopper l'exception java en cas d'argument illégal et la
            %transformer en exception matlab
            out = XMPPErrorType(valueOfMethod.invoke('', arguments));
        end
        
        
    end
    
end

