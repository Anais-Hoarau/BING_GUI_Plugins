%Class: fr.lescot.matjab.error.XMPPError
classdef XMPPError
    
    properties(Access = private)
        smackError;
    end
    
    methods
        
        function this = XMPPError(varargin)
            argNumber = length(varargin);
            switch(argNumber)
                case 1
                    if strcmp('org.jivesoftware.smack.packet.XMPPError', class(varargin{1}))
                        this.smackError = varargin{1};
                    else
                        this.smackError = org.jivesoftware.smack.packet.XMPPError(varargin{1}.unwrap());
                    end
                case 2
                    this.smackError = org.jivesoftware.smack.packet.XMPPError(varargin{1}.unwrap(), java.lang.String(varargin{2}));
                case 5
                    arg1 = varargin{1};
                    arg2 = fr.lescot.matjab.error.XMPPErrorType.valueOf(java.lang.String(varargin{2}));
                    arg3 = java.lang.String(varargin{3});
                    arg4 = java.lang.String(varargin{4});
                    argCellArray5 = varargin{5};
                    arg5 = java.util.Vector;
                    for i = 1:1:length(argCellArray5)
                        arg5.add(fr.lescot.matjab.extension.Extension(argCellArray5{i}));
                    end
                    this.smackError = org.jivesoftware.smack.packet.XMPPError(arg1, arg2, arg3, arg4, arg5);
                otherwise
                    throw(MException('fr.lescot.matjab.error.XMPPError.XMPPError.IvalidArgumentException', 'The number of arguments for the constructor must be 1, 2 or 5'));
            end
        end
        
        function out = unwrap(this)
            out = this.smackError;
        end
        
        function addExtension(this, extension)
            this.smackError.addExtension(extension.unwrap());
        end
        
        function out = getCode(this)
            out = this.smackError.getCode();
        end
        
        function out = getCondition(this)
            out = this.smackError.getCondition();
        end
        
        function out = getExtension(elementName, nameSpace)
            out = fr.lescot.matjab.extension.Extension(this.getExtension(java.lang.String(elementName), java.lang.String(nameSpace)));
        end
        
        function out = getExtensions(this)
            out = {};
            vectorOfExtensions = this.smackError.getExtensions();
            while(vectorOfExtensions.hasNext())
                out = {out{:} vectorOfExtensions.next()};
            end
        end
        
        function out = getMessage(this)
            out = this.smackError.getMessage();
        end
        
        function out = getType(this)
            out = fr.lescot.matjab.error.XMPPErrorType(this.smackError.getType());
        end
        
        function setExtension(this, extensions)
            extensionsList = java.util.Vector;
            for i = 1:1:length(extensions)
                extensionsList.add(extensions{i}.unwrap());
            end
            this.smackError.setExtension(extensionsList);
        end
        
        function out = toString(this)
            out = this.smackError.toString();
        end
        
        function out = toXML(this)
            out = this.smackError.toXML();
        end
        
    end
    
end

