%Class: fr.lescot.matjab.extension.dataForm.FormField
classdef FormField < handle

    properties(Access = private)
        smackFormField;
    end
    
    methods
        
        function this = FormField(varargin)
            if size(varargin,2) == 1
                if strcmpi('org.jivesoftware.smackx.FormField', class(varargin{1}))
                    this.smackFormField = varargin{1};
                else
                    this.smackFormField = org.jivesoftware.smackx.FormField(java.lang.String(varargin{1}));
                end
            else
                this.smackFormField = org.jivesoftware.smackx.FormField();
            end
        end
        
        function out = unwrap(this)
            out = this.smackFormField();
        end
        
        function addOption(this, formFieldOption)
            this.smackFormField.addOption(formFieldOption.unwrap());
        end
        
        function addValue(this, value)
            this.smackFormField.addValue(java.lang.String(value));
        end
        
        function addValues(this, valuesCellArray)
            vectorList = java.util.Vector();
            for i = 1:1:length(valuesCellArray)
                vectorList.add(java.lang.String(valuesCellArray));
            end
            this.smackFormField.addValues(vectorList);
        end
        
        function out = getDescription(this)
            out = this.getDescription();
        end
        
        function out = getLabel(this)
            out = this.getLabel();
        end

        function out = getOptions(this)
           iterator = this.smackFormField.getOptions(); 
           out = {};
           while(iterator.hasNext())
               out = {out{:} fr.lescot.matajab.extension.dataForm.FormFieldOption(iterator.next())};
           end
        end

        function out = getType(this)
            out = this.smackFormField.getType();
        end

        function out = getValues(this)
            iterator = this.smackFormField.getValues();
            out = {};
            while(iterator.hasNext())
                out = {out{:} iterator.next()};
            end
        end
               
        function out = getVariable(this)
            out = this.smackFormField.getVariable();
        end
        
        
        function out = isRequired(this)
            out = this.smackFormField;
        end
        
        function setDescription(this, description)
            this.smackFormField.setDescription(java.lang.String(description));
        end
        
        function setLabel(this, label)
            this.smackFormField.setLabel(java.lang.String(label));
        end
        
        function setRequired(this, required)
            this.smackFormField.setRequired(required);
        end
        
        function setType(this, type)
            this.smackFormField.setType(java.lang.String(type));
        end
        
        function out = toXML(this)
            out = this.smackFormField.toXML();
        end
                                
    end
end
