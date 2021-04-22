%{
Class:
This class is the configurator of the <SituationDisplay> plugin.

%}
classdef SituationDisplayConfigurator < fr.lescot.bind.configurators.PluginConfigurator
    
    properties(Access = private)
        %{
        Property:
        The handler on the text field for the customization of the width.
        of the time window.
        %}
        timeWindowTextField;
        %{
        Property:
        The handler on the position chooser widget.
        %}
        positionChooser;
        %{
        Property:
        The handler on the validation button.
        %}
        validateButton;
        
        %{
        Property:
        The handler on the variable selection widget.
        %}
        variableSelector;
    end
    
    methods
        
        %{
        Function:
        The constructor of the SituationDisplayConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        metaTrip - a <data.MetaInformations> object that stores the
        available videos.
        caller - handler to the interface that ask for a configuration, in
        order to be able to give back the configurator when closing.
        configuration - An optionnal <configurators.Configuration>
        object, containing a configuration to restore.
        
        Returns:
        out - a new DataPlotterConfigurator.
        %}
        function this = SituationDisplayConfigurator(pluginId, metaTrip, caller, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator(pluginId, metaTrip, caller, varargin);
            this.buildWindow();
            if length(varargin) == 1
                this.setUIState(varargin{1});
            end
        end
        
    end
    
    methods(Access = protected)
        %{
        Function:
        see <configurators.PluginConfigurator.setUIState()>
        %}
        function setUIState(this, configuration)
            import fr.lescot.bind.utils.StringUtils;
            import fr.lescot.bind.configurators.*;
            dataList = configuration.findArgumentWithOrder(2);
            if ~isempty(dataList)
                this.variableSelector.setSelectedVariables(dataList.getValue);
            end
            
            position = configuration.findArgumentWithOrder(3);
            if ~isempty(position)
                this.positionChooser.setSelectedPosition(position.getValue());
            end
            
            timeWindow = configuration.findArgumentWithOrder(4);
            if ~isempty(timeWindow)
                set(this.timeWindowTextField, 'String', timeWindow.getValue());
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
            set(this.getFigureHandler(), 'position', [0 0 800 525]);
            set(this.getFigureHandler(), 'Name', 'SituationDisplay configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            
            windowBackgroundColor = get(this.getFigureHandler(), 'Color');
            
            %The time scale panel
            timeScalePanel = uipanel(this.getFigureHandler, 'BackgroundColor', windowBackgroundColor, 'Title', 'Largeur de la fenêtre temporelle', 'Units', 'pixel', 'Position', [10 105 180 50]);
            uicontrol(timeScalePanel, 'Style', 'Text', 'String', 'Fenêtre (en s)', 'BackgroundColor', windowBackgroundColor, 'Position', [10 5 70 20]);
            this.timeWindowTextField = uicontrol(timeScalePanel, 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [90 9 45 20], 'String', '60');
            
            %The position panel
            this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 10], 'BackgroundColor', windowBackgroundColor);
            
            %The variable selector panel
            this.variableSelector = fr.lescot.bind.widgets.VariablesSelector(this.getFigureHandler, this.metaTrip, 'SITUATION', 'Position', [10 160], 'Height', 360);
            
            %The validate button
            this.validateButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [365 10 80 40]);
            
            %Create and link the callbacks
            validateCallbackHandle = @this.validateCallback;
            set(this.validateButton, 'Callback', validateCallbackHandle);
            %Let's move the GUI
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
        function closeCallback(this, source, ~)
            if source ~= this.getFigureHandler()
                import fr.lescot.bind.configurators.*;
                if isempty(this.variableSelector.getSelectedVariables())
                    this.configuration = {};
                    this.quitConfigurator();
                else
                    %GenerateConfiguration
                    configuration = Configuration();
                    arguments = {};
                    %The three compulsory arguments
                    arguments{1} = Argument('situationIdentifiers', false, sort(this.variableSelector.getSelectedVariables()), 2);
                    arguments{2} = Argument('position', false, this.positionChooser.getSelectedPosition(), 3);
                    arguments{3} = Argument('xMax', false, str2double(get(this.timeWindowTextField, 'String')), 4);
                    configuration.setArguments(arguments);
                    %Set configuration
                    this.configuration = configuration;
                    this.quitConfigurator();
                 end
            end
        end
    end
    
    methods(Static)
        
        %{
        Function:
        See <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip, configuration)
            valid = true;
            %Check if the object is a configuration
            if ~isa(configuration, 'fr.lescot.bind.configurators.Configuration')
                valid = false;
            end
            
            %Check that the situations to plots are all available in the
            %trip
            situationsConfigured = configuration.findArgumentWithOrder(2).getValue();
            
            situationsVarsAvailable = {};  
            situationsAvailable = referenceTrip.getSituationsList();
            for i = 1:1:length(situationsAvailable)
                situation = situationsAvailable{i};
                variables = situation.getVariables();
                for j = 1:1:length(variables)
                   variable = variables{j};
                   situationsVarsAvailable = {situationsVarsAvailable{:} [situation.getName() '.' variable.getName()]};
                end
            end
            
            for i = 1:1:length(situationsConfigured)
                if ~any(strcmpi(situationsConfigured{i}, situationsVarsAvailable))
                    valid = false;
                    break;
                end
            end
            out = valid;
        end
        
    end
    
end
