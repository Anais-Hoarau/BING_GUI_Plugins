%{
Class:
This class is the configurator of the <EventSituationBrowser> plugin

%}
classdef EventCoding_Configurator < fr.lescot.bind.configurators.PluginConfigurator
    
    properties        
        %{
        Property:
        The handler on the position chooser widget.
        %}
        positionChooser;

        %{
        Property:
        The path to the file used for configuration
        %}
        configFile

        %{
        Property:
        The handler to the label that remind the selection
        %}
        configFileLabel 
    end
    
    methods
        %{
        Function:
        The constructor of the EventSituationBrowserConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        tripInformation - a <data.MetaInformations> object that stores the
        available videos
        caller - handler to the interface that ask for a configuration, in
        order to be able to give back the configurator when closing.
        
        Returns:
        this - a new EventSituationBrowserConfigurator.
        %}
        function this = EventCoding_Configurator(pluginId, metaTrip, caller, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator(pluginId, metaTrip, caller);
            
            this.buildWindow();
            
            % reload the previous config if it exist
            if length(varargin) == 1
                this.setUIState(varargin{1});
            end
        end
    end
    
    methods(Access = private)
        %{
        Function:
        Build the window and instanciate the Event Situation selector widget
        
        Arguments:
        this - optional
        
        %}
        function buildWindow(this)
            set(this.getFigureHandler(), 'position', [0 0 270 200]);
            set(this.getFigureHandler(), 'Name', 'Event Coding configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            
            % the label that remind the path to the config file
            this.configFileLabel = uicontrol(this.getFigureHandler(),'Style','text', 'String', 'No config',...
                'Position', [10 150 170 50]); 

            % the button to select the config file
            configFileSelectionCallbackHandle = @this.selectConfigFileCallback;
            uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Config File', 'Position', [190 170 80 30], 'Callback', configFileSelectionCallbackHandle);
            % widget to select position of the plugin
            this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 60]);
            % quit button
            validateCallbackHandle = @this.validateCallback;
            uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [60 10 80 40], 'Callback', validateCallbackHandle);
            %Set the initial GUI position
            movegui(this.getFigureHandler(), 'center');
        end
        
       %{
        Function:
        Launched when the config file selection button is pressed. It
        launch a ui get file.
        
        Arguments:
        this - optional
        source - for callback
        eventdata - for callback
        
        %}
        function selectConfigFileCallback(this, src, eventdata)
            if ~isempty(this.configFile)
                [pathstr, name, ext] = fileparts(this.configFile);
                [FileName,PathName] = uigetfile(['*' ext],'Select the config file',pathstr);
            else
                [FileName,PathName] = uigetfile('*.txt','Select the config file');
            end
            
            if ~isequal(FileName,0)
                this.configFile = fullfile(PathName, FileName);
                set(this.configFileLabel,'String',this.configFile);
            end
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
            configuration = fr.lescot.bind.configurators.Configuration();
            this.configuration = configuration;
            firstArgument = fr.lescot.bind.configurators.Argument('configFile', false, this.configFile,2);
            secondArgument = fr.lescot.bind.configurators.Argument('positionAtStart', false, this.positionChooser.getSelectedPosition(),3);
            arguments = {firstArgument secondArgument};
            configuration.setArguments(arguments);
            this.quitConfigurator();
            
        end
    end
    
    methods(Access = protected)
        %{
        Function:
        see <configurators.PluginConfigurator.setUIState()>
        %}
        function setUIState(this, configuration)
            configFilePath =  configuration.findArgumentWithOrder(2).getValue();
            this.configFile = configFilePath;
            set(this.configFileLabel,'String',this.configFile);
            
            position = configuration.findArgumentWithOrder(3).getValue();
            this.positionChooser.setSelectedPosition(position);
        end
    end
    
    methods(Static)
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        
        This method will verify that the linked file exists
        
        %}
        function out = validateConfiguration(referenceTrip, configuration)
            arguments = configuration.getArguments();
            if length(arguments) == 2
                if strcmp(arguments{1}.getName,'configFile')
                   if exist(arguments{1}.getValue,'file')
                        out = true; 
                   else
                       out = false; 
                   end
                else
                    out = false;
                end
            else
                out = false;
            end
        end
    end
    
end

