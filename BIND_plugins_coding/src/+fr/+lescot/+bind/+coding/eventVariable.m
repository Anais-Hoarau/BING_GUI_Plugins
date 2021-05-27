%{
Class:
The eventVariable class is an instance of the abstract Variable class
 <fr.lescot.bind.coding.Variable>
%}
classdef eventVariable < fr.lescot.bind.coding.Variable
    properties
        defaultModality = {}
    end
    
    methods
        function this = eventVariable(name)
            this@fr.lescot.bind.coding.Variable(name);
        end
        % There is no default modality for a situationVariable. 
        % defaultModality uis always empty.
        function out = getDefaultModality(this)
            out = this.defaultModality;
        end
        
        function setDefaultModality(this,~)
            this.defaultModality = {};
        end
    end
end