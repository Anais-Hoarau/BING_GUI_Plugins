%{
Class:
The stateVariable class is an instance of the abstract Variable class
 <fr.lescot.bind.coding.Variable>
%}
classdef stateVariable < fr.lescot.bind.coding.Variable
    properties
    end
    
    methods
        %constructor
        function this = stateVariable(name)
            this@fr.lescot.bind.coding.Variable(name);
        end
    end
end