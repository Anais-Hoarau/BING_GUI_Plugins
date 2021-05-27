%Class: fr.lescot.matjab.extension.dataForm.DataForm
%The implementation of the XMPP DataForm extension
%(<http://xmpp.org/extensions/xep-0004.html>).
%
%Extends:
%- <fr.lescot.matjab.extension.Extension>
classdef DataForm < fr.lescot.matjab.extension.Extension
    
    methods
        
        %Function: DataForm()
        %The constructor of the DataForm.
        %
        %Arguments:
        %varargin - Either a smack dataForm to encapsulate, or a String
        %with the type of the form (form/submit/cancel/result).
        %
        %Modifiers:
        %- Public
        function this = DataForm(varargin)
            arg = varargin{1};
            if any(strcmpi({'fr.lescot.matjab.extension.Extension', 'fr.lescot.matjab.extension.dataForm.DataForm'}, class(arg)))
                %add check dans le cas d'une extension !!!
                this.smackExtension = arg.unwrap();
            else
                this.smackExtension = org.jivesoftware.smackx.packet.DataForm(java.lang.String(arg));
            end
        end
        
        %Function: addField()
        %Add a field to the DataForm.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %formField - A <FormField> object.
        %
        %Modifiers:
        %- Public
        function addField(this, formField)
            this.smackExtension.addField(formField.unwrap());
        end
        
        %Function: addInstruction()
        %Add some instructions to the DataForm.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %instruction - A String.
        %
        %Modifiers:
        %- Public
        function addInstruction(this, instruction)
            this.smackExtension.addInstruction(java.lang.String(instruction));
        end
        
        %Function: addItem()
        %Add an item to the DataForm.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %dataFormItem - A <DataFormItem> object.
        %
        %Modifiers:
        %- Public
        function addItem(this, dataFormItem)
            this.smackExtension.addItem(dataFormItem.unwrap());
        end
        
        %Function: getFields()
        %Returns a cell array of fields.
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
            iteratorOfJavaFields = this.smackExtension.getFields();
            out = {};
            while(iteratorOfJavaFields.hasNext())
                out = {out{:} FormField(iteratorOfJavaFields.next())};
            end
        end
        
        %Function: getInstructions()
        %Returns a cell array of fields.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A cell array of Strings.
        %
        %Modifiers:
        %- Public
        function out = getInstructions(this)
            iteratorOfStrings = this.smackExtension.getFields();
            out = {};
            while(iteratorOfStrings.hasNext())
                out = {out{:} iteratorOfStrings.next()};
            end
        end
        
        
        %Function: getItems()
        %Returns a cell array of items.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A cell array of <DataFormItem>.
        %
        %Modifiers:
        %- Public
        function out = getItems(this)
            import fr.lescot.matjab.extension.dataForm.*;
            iteratorOfJavaItems = this.smackExtension.getFields();
            out = {};
            while(iteratorOfJavaItems.hasNext())
                out = {out{:} DataFormItem(iteratorOfJavaItems.next())};
            end
        end
        
        %Function: getReportedData()
        %Returns the fields that will be returned from a search.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A cell array of <DataFormReportedData>.
        %
        %Modifiers:
        %- Public
        function out = getReportedData(this)
            import fr.lescot.matjab.extension.dataForm.*;
            out = DataFormReportedData(this.smackExtension.getReportedData());
        end
        
        %Function: getTitle()
        %Returns the title of the DataForm.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %
        %Returns: 
        %- A String.
        %
        %Modifiers:
        %- Public
        function out = getTitle(this)
            out = this.smackExtension.getTitle();
        end
        
        %Function: getType()
        %Returns the type of the DataForm.
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
            out = this.smackExtension.getType();
        end
        
        %Function: setInstructions()
        %Add a list of instructions to the DataForm.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %instructionsCellArray - A cell array of Strings.
        %
        %Modifiers:
        %- Public
        function setInstructions(this, instructionsCellArray)
            instructions = java.lang.Vector();
            for i = 1:1:length(instructionsCellArray)
                instructions.add(instructionsCellArray{i});
            end
            this.smackExtension.setInstructions(instructions);
        end
        
        %Function: setReportedData()
        %Sets the fields that will be returned from a search.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %dataFormReportedData - A <DataFormReportedData> object.
        %
        %Modifiers:
        %- Public
        function setReportedData(this, dataFormReportedData)
            this.smackExtension.setReportedData(dataFormReportedData.unwrap());
        end
        
        %Function: setTitle()
        %Sets the title of the form.
        %
        %Arguments:
        %this - The object on which the method is called. Optionnal.
        %title - A String.
        %
        %Modifiers:
        %- Public
        function setTitle(this, title)
            this.smackExtension.setTitle(java.lang.String(title));
        end
        
    end
    
end

