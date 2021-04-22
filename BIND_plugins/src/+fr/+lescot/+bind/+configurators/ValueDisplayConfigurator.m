%{
Class:
This class is the configurator of the <ValueDisplay> plugin

%}
classdef ValueDisplayConfigurator < fr.lescot.bind.configurators.PluginConfigurator_simplif
    
    properties
        %{
        Property:
        The handler on the position chooser widget.
        %}
        positionChooser;
        
        %{
        Property:
        The handler on the configuration validation button.
        
        %}
        validateButton
        
        %{
        Property:
        The handler on the variable selection widget.
        
        %}
        variableSelector;
    end
    
    methods
        
        %{
        Function:
        The constructor of the ValueDisplayConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        metaTrip - a trip object that stores all the informations that are
        shared by the trips availaible.
        caller - handler to the interface that ask for a configuration, in
        order to be able to return the configurator when closing.
        
        
        Returns:
        this - a new VideoPlayerConfigurator.
        %}
        function this = ValueDisplayConfigurator(pluginName, trip, metaTrip, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator_simplif(pluginName, trip, metaTrip, varargin);
            this.buildWindow();
            if length(varargin) == 1
                this.setUIState(varargin{1});
            end
            this.dynamizeUI();
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
            
            set(this.getFigureHandler(), 'position', [0 0 800 470]);
            set(this.getFigureHandler(), 'Name', 'ValueDisplay configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
           
            this.variableSelector = fr.lescot.bind.widgets.VariablesSelector(this.getFigureHandler(), this.metaTrip, 'DATA', 'Position', [10 105]);
            
            %The positions chooser plus the validation button
            this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 10]);
            
            this.validateButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [360 35 80 40]);
            %Set the initial GUI position
            movegui(this.getFigureHandler(), 'center');
        end
        
        %{
        Function:
        Adds all the callbacks to the GUI.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function dynamizeUI(this) 
            %The validateButton
            validateCallbackHandle = @this.validateCallback;
            set(this.validateButton, 'Callback', validateCallbackHandle);
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
            %%%%%
            uiresume(this.getFigureHandler);
            %%%%%

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
                if isempty(this.variableSelector.getSelectedVariables())
                    this.configuration = {};
                    this.quitConfigurator();
                else
                    %GenerateConfiguration
                    configuration = Configuration();
                    arguments = {};
                    arguments{1} = Argument('dataIdentifiers', false, sort(this.variableSelector.getSelectedVariables()), 2);
                    arguments{2} = Argument('position', false, this.positionChooser.getSelectedPosition(), 3);
                    configuration.setArguments(arguments);
                    %Set configuration
                    this.configuration = configuration;
                    this.quitConfigurator();
                end
            end
        end
        
    end
    
    methods(Access = protected)
        %{
        Function:
        see <configurators.PluginConfigurator.setUIState()>
        %}
        function setUIState(this, configuration)
            position = configuration.findArgumentWithOrder(3).getValue();
            this.positionChooser.setSelectedPosition(position);

            dataList = configuration.findArgumentWithOrder(2);
            this.variableSelector.setSelectedVariables(dataList.getValue());
        end
    end
    
    methods(Static)
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip, configuration)
            valid = true;
            %Check if the object is a configuration
            if ~isa(configuration, 'fr.lescot.bind.configurators.Configuration')
                valid = false;
            end
            
            %Check that the data to display are all available in the datas
            datasConfigured = configuration.findArgumentWithOrder(2).getValue();
            
            datasVarsAvailable = {};  
            datasAvailable = referenceTrip.getDatasList();
            for i = 1:1:length(datasAvailable)
                data = datasAvailable{i};
                variables = data.getVariables();
                for j = 1:1:length(variables)
                   variable = variables{j};
                   datasVarsAvailable = {datasVarsAvailable{:} [data.getName() '.' variable.getName()]};
                end
            end
            
            for i = 1:1:length(datasConfigured)
                if ~any(strcmpi(datasConfigured{i}, datasVarsAvailable))
                    valid = false;
                    break;
                end
            end
            out = valid;
        end
    end
    
end

