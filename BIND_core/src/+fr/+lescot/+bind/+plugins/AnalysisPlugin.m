%{
Class:
This abstract class is the template for all the plugins that focus on
statistical analysis, data filtering or any operation that relies on
asynchronous treatement of several <kernel.Trips> at a time.

%}
classdef AnalysisPlugin < fr.lescot.bind.plugins.Plugin

    properties
        %{
        Property:
        The <kernel.Experimentation> object.
        
        %}
        experimentation;
    end
    
    methods
        
        %{
        Function:
        Getter for the <kernel.Experimentation>.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        out - A <kernel.Experimentation> object
        %}
        function out = getExperimentation(obj)
            out = obj.experimentation;
        end
        
        %{
        Function:
        Setter for the <kernel.Experimentation> object.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        model - The new <kernel.Experimentation> object.
        %}
        function setExperimentation(obj, experimentation)
            obj.experimentation = experimentation;
        end
        
    end
    
end
