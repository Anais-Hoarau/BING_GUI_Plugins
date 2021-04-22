%{
Class:
This class is the base class for the plugin configurators. A plugin
configurator is most of the time a GUI that allow the user to select some
parameters for a given class of plugin. As a plugin is able to return the
class of its configurator, it allows a launcher to instanciante the right
class of configurator. The launcher have to implement the interface
<ConfiguratorUser> to be able to use the plugin configurator. This
interface provides a method that is used when the user validates the
configurations and closes the window. It's a form of callback. The
configuration passed to the launcher is the one stored in the property
<configuration>.

%}
classdef PluginConfigurator < handle

    properties(Access = private)
        %{
        Property:
        The handler on the window.
        
        %}
        figureHandler;
        
        %{
        Property:
        The reference to the software object that launched the plugin
        configurator and needs the configuration.
        
        %}
        caller;
        
        %{
        Property:
        The identifier of the plugin instance that is configured. Used to
        be passed to the caller during the callback so that it is able to
        link the configuratio returned to the instance.
        
        %}
        pluginId;
        
    end
    
    properties(Access = protected)
        %{
        Property:
        The object that contains the <Configuration> returned when the
        window is closed.
        
        %}
        configuration;
        
        %{
        Property:
        The <MetaInformations> object that contains all the data and
        variables the plugin should be able to propose.
        
        %}
        metaTrip;
    end
    
    methods(Access = public)
        
        %{
        Function:
        
        Build a configurator window. By default, the WindowStyle property
        is "modal", wich means that when the configurator is open, it is
        impossible to access other matlab windows.
        
        Arguments:
        metaTrip - A <data.MetaInformation> object that contains all the
        data that the loader determined as being usable by the
        configurator.
        pluginId - A unique value referencinf the plugin instance that
        will be configured. This value is passed back to the
        <ConfiguratorUser> object. The structure and value of the id does
        not matter, as long as the <ConfiguratorUser> is able to
        understand it.
        caller - A reference to the object that instanciated the
        configurator, and that implements the <ConfiguratorUser>
        interface.
        configuration - An optionnal argument containing a configuration
        to restore.
        
        Throws:
        ARGUMENT_EXCEPTION - if "caller" does not implement <ConfiguratorUser>
        
        %}
        function this = PluginConfigurator(pluginId, metaTrip, caller, varargin)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~isa(caller, 'fr.lescot.bind.configurators.ConfiguratorUser')
                 throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The argument "caller" must implement the interface fr.lescot.bind.configurators.ConfiguratorUser'));
            end
            this.metaTrip = metaTrip;
            this.caller = caller;
            this.pluginId = pluginId;
            this.figureHandler = figure('MenuBar', 'none', 'Name', 'Plugin', 'NumberTitle', 'off', 'Resize', 'off', 'Toolbar', 'none', 'Visible', 'on', 'Position', [0 0 100 100]);
            set(this.figureHandler,'WindowStyle','modal');
        end
        
        %{
        Function:
        
        Returns the handler to manipulate the window of the configurator.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A figure handler.
        
        %}
        function out = getFigureHandler(this)
            out = this.figureHandler;
        end
        
        %{
        Function:
        
        Returns the reference of the list of trips.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A <plugins.Plugin> reference.
        
        %}
        function out = getTripsList(this)
            out = this.tripsList;
        end
        
        %{
        Function:
        
        Stores the configuration that will be returned when quitting the plugin.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        config - the <Configuration> object representing the new
        configuration to set.
        
        %}
        function setConfiguration(this, config)
           this.configuration = config; 
        end
    end
    
    methods(Access = protected)
        
        %{
        Function:
        
        Closes the plugin, and send the configuration (stored in the
        attribute <PluginConfigurator.configuration>) to the object that
        instanciated the configurator. This method is mostly intended to
        be called by something like a "Validate configuration" button,
        that closes the configurator and returns to the launcher.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        config - the <Configuration> object that is finally returned by the
        plugin.
        
        %}
        function quitConfigurator(this)
            this.caller.receiveConfiguration(this.pluginId, this.configuration);
            delete(this.figureHandler);
            delete(this);
        end
        
    end
    
    methods(Abstract, Static)
        %{
        Function:
        Validates a configuration in regard of the referenceTrip passed as
        an argument. Used to check if the configuration is still valid for
        a new set of Trip for example.
        
        Arguments:
        referenceTrip - a <kernel.Trip> object.
        configuration - a <plugins.configurators.Configuration> object.
        
        %}
        out = validateConfiguration(referenceTrip, configuration);
    end
    
    methods(Abstract, Access = protected)
        %{
        Function:
        Restore a configuration, so that if the plugin is validated
        immediately after, the same configuration will be generated.
        
        Arguments:
        this - optional
        configuration - The configuration to restore
        
        %}
        setUIState(this, configuration);
    end
    
end