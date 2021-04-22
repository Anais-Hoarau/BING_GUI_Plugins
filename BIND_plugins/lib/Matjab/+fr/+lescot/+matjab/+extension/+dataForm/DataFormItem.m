%Class: fr.lescot.matjab.extension.dataForm.DataFormItem
%This class represents an Item of a DataForm.
%
%Extends:
%- handle
classdef DataFormItem < handle
    
    %Property: smackDataFormItem
    %The java encapsulated item.
    %
    %Modifiers:
    %- Private
    properties(Access = private)
        smackDataFormItem;
    end
    
    methods
        
        %Function: DataFormItem()
        %The constructor of the DataFormItem.
        %
        %Arguments:
        %varargin - Either a smack DataForm$Item to encapsulate, or a cell array of <FormFields>.
        %
        %Modifiers:
        %- Public
        function this = DataFormItem(varargin)
            %Appy the correct constructor according to varargin
            if strcmpi('org.jivesoftware.smackx.DataForm$Item', class(varargin{1}))
                this.smackDataFormItem = varargin{1};
            else
                %Complicated stuff to be able to load the inner class Item from Java
                classLoader = org.jivesoftware.smackx.FormField().getClass().getClassLoader();
                optionClass = java.lang.Class.forName('org.jivesoftware.smackx.packet.DataForm$Item', false, classLoader);
                constructors = optionClass.getConstructors();
                constructor = constructors(1);
                %Transform the cell array into a Vector
                vector = java.util.Vector;
                cellArray = varargin{1};
                for i = 1:1:length(cellArray)
                    vector.add(cellArray{i});
                end
                this.smackDataFormItem = constructor.newInstance(vector);
            end
        end
        
        %Function: getFields()
        %Returns the fields of the item.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A cell array of <FormFields>.
        %
        %Modifiers:
        %- Public
        function out = getFields(this)
            import fr.lescot.matjab.extension.dataForm.*;
            iterator = this.smackDataFormItem.getFields();
            out = {};
            while(iterator.hasNext())
                out = {out{:} FormField(iterator.next())};
            end
        end
        
                
        %Function: toXML()
        %Return the XML version of the DataForm Item, ie. the xml fragment that
        %will be added to the DataForm.
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
           out = this.smackDataFormItem.toXML(); 
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
            out = this.smackDataFormItem;
        end
    end
    
end

