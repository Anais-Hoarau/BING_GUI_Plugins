%{
Class:
This class is the configurator of the <Magneto> plugin

%}
classdef MagnetoConfigurator < fr.lescot.bind.configurators.PluginConfigurator
    
    properties
        %{
        Property:
        The handler on the position chooser widget.
        %}
        positionChooser;
    end
    
    methods
        
        %{
        Function:
        The constructor of the MagnetoConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        tripInformation - a <data.MetaInformations> object that stores the
        available videos
        caller - handler to the interface that ask for a configuration, in
        order to be able to give back the configurator when closing.
        
        
        Returns:
        this - a new VideoPlayerConfigurator.
        %}
        function this = MagnetoConfigurator(pluginId, metaTrip, caller, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator(pluginId, metaTrip, caller);
            this.buildWindow();
            if length(varargin) == 1
                this.setUIState(varargin{1});
            end
        end
        
        
    end
    
    methods(Access = private)
        
        %{
        Function:
        Build the window
        
        Arguments:
        this - optional
        
        %}
        function buildWindow(this)
            set(this.getFigureHandler(), 'position', [0 0 200 150]);
            set(this.getFigureHandler(), 'Name', 'Magneto configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 60]);
            validateCallbackHandle = @this.validateCallback;
            uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [60 10 80 40], 'Callback', validateCallbackHandle);
            %Set the initial GUI position
            movegui(this.getFigureHandler(), 'center');
        end
        
        %{
        Function:
        Launched when the validate button is pressed. It launch the close
        callback.
        
        Arguments:
        this - optional
        source - for callback
        eventdata - for callback
        
        %}
        function validateCallback(this, src, eventdata)
            this.closeCallback(src, eventdata);
        end
        
        %{
        Function:
        Launched when the window have to be closed.
        
        Arguments:
        this - optional
        source - for callback
        eventData - for callback
        
        %}
        function closeCallback(this, src, ~)
            import fr.lescot.bind.configurators.*;
            if src ~= this.getFigureHandler()
                %GenerateConfiguration
                configuration = Configuration();
                arguments = {Argument('position', false, this.positionChooser.getSelectedPosition(),2)};
                configuration.setArguments(arguments);
                %Set configuration
                this.configuration = configuration;
                this.quitConfigurator();
            end
        end   
    end
    
    methods(Access = protected)
        %{
        Function:
        see <configurators.PluginConfigurator.setUIState()>
        %}
        function setUIState(this, configuration)
            position = configuration.findArgumentWithOrder(2).getValue();
            this.positionChooser.setSelectedPosition(position);
        end
    end
    
    methods(Static)
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip, configuration) %#ok<INUSL>
            args = configuration.getArguments();
            if length(args) == 1
                out = true;
            else
                out = false;
            end
        end
    end
    
end
