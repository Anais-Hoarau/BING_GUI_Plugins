%{
Class:
This class is the configurator of the <PARKSituationEnrichment> plugin

%}
classdef PARKSituationEnrichmentConfigurator < fr.lescot.bind.configurators.PluginConfigurator
    
    properties
        %{
        Property:
        The handler on the position chooser widget.
        %}
        positionChooser;
        
        coderButtonGroup;
        radioMaud;
        radioLaurence;
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
        function this = PARKSituationEnrichmentConfigurator(pluginId, metaTrip, caller, varargin)
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
            set(this.getFigureHandler(), 'position', [0 0 200 240]);
            set(this.getFigureHandler(), 'Name', 'Magneto configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            
            % une group de radio permettant de choisir si Maud ou Laurence
            % code!
            backgroundColor = get(this.getFigureHandler,'Color');
            this.coderButtonGroup = uibuttongroup(this.getFigureHandler(),'Title','Codeur','Units', 'pixels','Position',[10 160 180 75],'BackgroundColor', backgroundColor);
            this.radioMaud = uicontrol(this.coderButtonGroup,'Style','Radio','String','Maud','Position',[10 30 100 30],'Tag','Maud','BackgroundColor', backgroundColor);
            this.radioLaurence = uicontrol(this.coderButtonGroup,'Style','Radio','String','Laurence','Position',[10 5 100 30],'Tag','Laurence','BackgroundColor', backgroundColor);
            
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
                arguments = cell(1,2);
                arguments{1} = Argument('position', false, this.positionChooser.getSelectedPosition(),2);
                arguments{2} = Argument('coder', false, get(get(this.coderButtonGroup,'SelectedObject'),'Tag'),3);
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
            coder = configuration.findArgumentWithOrder(3).getValue();
            switch coder
                case 'Maud'
                    set(this.coderButtonGroup, 'SelectedObject', this.radioMaud);
                case 'Laurence'
                    set(this.coderButtonGroup, 'SelectedObject', this.radioLaurence);
            end
        end
    end
    
    methods(Static)
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip,configuration)
            arguments = configuration.getArguments();
            isCoderNameValid = any(strcmpi(configuration.findArgumentWithOrder(3).getValue(), {'Maud', 'Laurence'}));
            if length(arguments) == 2 && isCoderNameValid
                out = true;
            else
                out = false;
            end
        end
    end
    
end

