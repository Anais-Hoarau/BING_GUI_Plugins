%Class: fr.lescot.matjab.extension.Extension
%This class is the root class for any implementation of an XMPP extension.
%It have little sense by itself, and have to be extended before use.
%
%Subclasses:
%- <dataForm.DataForm>
classdef Extension < handle
    
    properties(Access = protected)
        %Property: smackExtension
        %The java encapsulated extension.
        %
        %Modifiers:
        %- Protected
        smackExtension;
    end
    
    methods
        
        %Function: Extension()
        %The constructor of the extension.
        %
        %Arguments:
        %varargin - Either a smack extension to encapsulate, or nothing.
        %
        %Modifiers:
        %- Public
        function this = Extension(varargin)
            if length(varargin) == 1
                this.smackExtension = varargin{1};
            end
        end
        
        %Function: getElementName()
        %Returns the name of the element.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getElementName(this)
            out = this.smackExtension.getElementName();
        end
        
        %Function: getNamespace()
        %Returns the name of the element.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getNamespace(this)
            out = this.smackExtension.getNamespace();
        end
        
        %Function: toXML()
        %Return the XML version of the extension, ie. the xml fragment that
        %will be added to the message.
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
            out = this.smackExtension.toXML();
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
            out = this.smackExtension;
        end
    end
    
end

