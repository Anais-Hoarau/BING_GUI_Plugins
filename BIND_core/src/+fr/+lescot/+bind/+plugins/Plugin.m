%{
Class:
A merely semantic abstract class that is the root of all the plugins
classes. This class shouldn't be derived directly by concrete plugins
class, but by abstract "templates" for plugins instead.

%}
classdef Plugin < handle
    
    methods(Abstract, Static)
        %{
        Function:
        Returns the human-readable name of the plugin.
        
        Returns:
        A String.
        
        %}
        out = getName(this);
        
        %{
        Function:
        This method returns a boolean value that indicates if the plugin
        is deigned to treat a single trip (false) or multiple trips (true).
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A boolean value that indicates if the plugin
        is deigned to treat a single trip (false) or multiple trips
        (true).
        
        %}
        out = isMultiTrip(this);
        
        %{
        Function:
        This method returns the class of the configurator linked to this plugin.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A string representing the fully qualified name of the plugin
        configurator class, or an empty string if the plugin does not have
        a configurator.
        
        %}
        out = getConfiguratorClass(this);
        
    end
    
    methods(Static)
       
               
        %{
        Function:
        This method returns a boolean value that indicates if the plugin
        is instanciable or not. This methods purpose is to facilitate
        research of plugins within the path. The default value is false,
        and have to be overwritten in "real plugins", i.e. plugins that
        can be used directly, and not only via an heritage.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        false 
        %}
        function out = isInstanciable()
            out = false;
        end
        
    end
end