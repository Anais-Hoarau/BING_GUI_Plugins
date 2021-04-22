%{
Interface:
This interface provides the methods necessary for the objects of class
PluginConfigurator to be able to pass the configuration upon completion.
%}
classdef ConfiguratorUser < handle

    methods(Abstract)
        
        %{
        Function:
        
        Arguments:
        this - The object on which the function is called, optionnal.
        pluginId - The unique id of the configured plugin, as passed to
        the <PluginConfigurator> constructor.
        configuration - The object containing all the informations about
        the configuration.
        
        %}
        receiveConfiguration(this, pluginId, configuration);
        
    end
    
end

