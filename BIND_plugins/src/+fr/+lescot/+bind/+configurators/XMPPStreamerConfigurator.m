%{
Class:
%}
classdef XMPPStreamerConfigurator < fr.lescot.bind.configurators.PluginConfigurator

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
        The handler on the login text field.
        
        %}
        loginField;
        
        %{
        Property:
        The handler on the password text field.
        
        %}
        passwordField;
        
        %{
        Property:
        The handler on the ressource name text field.
        
        %}
        ressourceField;
        
        %{
        Property:
        The handler on the server name text field.
        
        %}
        serverField;
        
        %{
        Property:
        The handler on the recipient JID text field.
        
        %}
        recipientField;
        
        %{
        Property:
        The handler on the variable selection widget.
        
        %}
        variableSelector;
    end
    
    methods
        
        %{
        Function:
        The constructor of the XMPPStreamerConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        metaTrip - a trip object that stores all the informations that are
        shared by the trips availaible.
        caller - handler to the interface that ask for a configuration, in
        order to be able to return the configurator when closing.
        
        
        Returns:
        this - a new XMPPStreamerConfigurator.
        %}
        function this = XMPPStreamerConfigurator(pluginId, metaTrip, caller, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator(pluginId, metaTrip, caller);
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
        this - The object on which the function is called, optionnal.
        
        %}
        function buildWindow(this)
            windowBackgroundColor = get(this.getFigureHandler(), 'Color');
            
            set(this.getFigureHandler(), 'position', [0 0 800 470]);
            set(this.getFigureHandler(), 'Name', 'Configurateur de XMPPStreamer');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
           
            this.variableSelector = fr.lescot.bind.widgets.VariablesSelector(this.getFigureHandler(), this.metaTrip, 'DATA', 'Position', [10 105]);
            
            %The positions chooser plus the validation button + The XMPP
            %fields
            this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 10]);
            
            %Login
            uicontrol(this.getFigureHandler(), 'Style', 'Text', 'String', 'Login', 'BackgroundColor', windowBackgroundColor,'Position', [190 73 60 15], 'HorizontalAlignment', 'right');
            this.loginField = uicontrol(this.getFigureHandler(), 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [255 70 130 20], 'HorizontalAlignment', 'left');
            
            %Password
            uicontrol(this.getFigureHandler(), 'Style', 'Text', 'String', 'Passe', 'BackgroundColor', windowBackgroundColor,'Position', [190 43 60 15], 'HorizontalAlignment', 'right');
            this.passwordField = uicontrol(this.getFigureHandler(), 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [255 40 130 20], 'HorizontalAlignment', 'left');
            
            %Ressource
            uicontrol(this.getFigureHandler(), 'Style', 'Text', 'String', 'Ressource', 'BackgroundColor', windowBackgroundColor,'Position', [190 13 60 15], 'HorizontalAlignment', 'right');
            this.ressourceField = uicontrol(this.getFigureHandler(), 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [255 10 130 20], 'HorizontalAlignment', 'left');
            
            %Server
            uicontrol(this.getFigureHandler(), 'Style', 'Text', 'String', 'Serveur', 'BackgroundColor', windowBackgroundColor,'Position', [400 60 80 15], 'HorizontalAlignment', 'right');
            this.serverField = uicontrol(this.getFigureHandler(), 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [485 57 200 20], 'HorizontalAlignment', 'left');
            
            %Recipient
            uicontrol(this.getFigureHandler(), 'Style', 'Text', 'String', 'JID destinataire', 'BackgroundColor', windowBackgroundColor,'Position', [400 30 80 15], 'HorizontalAlignment', 'right');
            this.recipientField = uicontrol(this.getFigureHandler(), 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [485 27 200 20], 'HorizontalAlignment', 'left');
            
            this.validateButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [710 10 80 40]);
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
                %Put all the errors in a cell array of strings
                errors = {};
                errorsIndex = 1;
                if ~isempty(this.variableSelector.getSelectedVariables())
                    if isempty(get(this.loginField, 'String'))
                        errors{errorsIndex} = 'Le login ne peut pas être vide.';
                        errorsIndex = errorsIndex + 1;
                    end
                    if isempty(get(this.passwordField, 'String'))
                        errors{errorsIndex} = 'Le mot de passe ne peut pas être vide.';
                        errorsIndex = errorsIndex + 1;
                    end
                    if isempty(get(this.serverField, 'String'))
                        errors{errorsIndex} = 'Le nom du serveur ne peut pas être vide.';
                        errorsIndex = errorsIndex + 1;
                    end
                    if length(regexp(get(this.recipientField, 'String'), '^\S+@\S+(/\S*)?$', 'match')) ~= 1
                        errors{errorsIndex} = 'Le JID du destinataire doit être de la forme " login@serveur[/ressource] ".';
                    end
                    %If there are some errors, display them, else, validate the
                    %config
                    if ~isempty(errors)
                        warndlg(errors, 'Configuration invalide')
                    else
                        %GenerateConfiguration
                        configuration = Configuration();
                        arguments = {};
                        arguments{1} = Argument('dataIdentifiers', false, sort(this.variableSelector.getSelectedVariables()), 2);
                        arguments{2} = Argument('position', false, this.positionChooser.getSelectedPosition(), 3);
                        arguments{3} = Argument('server', false, get(this.serverField, 'String'), 4);
                        arguments{4} = Argument('username', false, get(this.loginField, 'String'), 5);
                        arguments{5} = Argument('password', false, get(this.passwordField, 'String'), 6);
                        arguments{6} = Argument('ressource', false, get(this.ressourceField, 'String'), 7);
                        arguments{7} = Argument('recipient', false, get(this.recipientField, 'String'), 8);
                        configuration.setArguments(arguments);
                        %Set configuration
                        this.configuration = configuration;
                        this.quitConfigurator();
                    end
                else
                    this.configuration = {};
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
            set(this.serverField, 'String', configuration.findArgumentWithOrder(4).getValue());
            set(this.loginField, 'String', configuration.findArgumentWithOrder(5).getValue());
            set(this.passwordField, 'String', configuration.findArgumentWithOrder(6).getValue());
            set(this.ressourceField, 'String', configuration.findArgumentWithOrder(7).getValue());
            set(this.recipientField, 'String', configuration.findArgumentWithOrder(8).getValue());
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
            
            %Check that the data to stream are all available in the datas
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

