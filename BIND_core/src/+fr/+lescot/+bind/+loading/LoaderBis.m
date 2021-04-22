  %{
Class:
This class creates an object that is useful for

%}

classdef LoaderBis < fr.lescot.bind.configurators.ConfiguratorUser
    
    properties(Access = private)
        %{
        Property:
        a <fr.lescot.bind.kernel.TripSet> object that contains the trips used by the loader
        
        %}
        tripSet;
        
        %{
        Property:
        The cell array of plugin className
        
        %}
        pluginSelect;
        
        %{
        Property:
        The cell array of <fr.lescot.bind.configurators.Configuration>
        
        %}
        pluginConfigurationSet;
        
        
        pluginConfigurationSelect; %ajout pour plugin unique
        
        %{
        Property:
        The handle on the loader window.
        
        %}
        figureHandler;
        
        %{
        Property:
        handler to the figure of the launch window
        
        %}
        launchFigureHandler;

        %{
        Property:
        handler to the button of the launch window to go back to launcher
        
        %}
        returnToLoaderButton
        
        %{
        Property:
        handler to the label of the launch window
        
        %}
        launchWindowLabel;
        
        %{
        Property:
        When plugins are launched, this variable contains a cell array of instanciated trips connected to the plugins
        
        %}
        launchedTrips;
        
        %{
        Property:
        When plugins are launched, this variable keep a cell array of instanciated plugins
        
        %}
        launchedPlugins;
        
        %{
        Property:
        Indicate whether plugins work on union mode or in intersection mode. default mode is intersection
        %}
        mode;
        
        %{
        Property:
        Indicate in which package of the path the available plugins will be
        looked for.
        %}
        pluginsPackage;
    end
    
    methods(Access=protected)
        %{
        Function:
        Getter for the plugins packages in which to look for the available
        plugins.
        
        Arguments:
        none.
        
        Returns:
        out - a String
        
        %}
        function out = getPluginsPackage(this)
            out = this.pluginsPackage;
        end
        
         function out = getPluginConfigurationSelect(this)
            out = this.pluginConfigurationSelect;
        end
        
        %{
        Function:
        Getter for the figure handler of the loader
        
        Arguments:
        none.
        
        Returns:
        out - a figure hangler
        
        %}
        function out = getFigureHandler(this)
            out = this.figureHandler;
        end
        
        
        %{
        Function:
        Getter for the tripSet
        
        Arguments:
        this - The object on which the function is called, optional.
        
        Returns:
        out - a <fr.lescot.bind.kernel.TripSet> object that contains all the trips
        %}
        function out=getTripSet(this)
            out = this.tripSet;
        end
        
        function out=getMode(this)
            out = this.mode;
        end
        
        function setMode(this,mode)
            if any(strcmp(mode,{'union' 'intersection'}))
                this.mode = mode;
            else
                %ME
            end
        end
        
        %{
        Function:
        This method re-initialise the trips to reset the program
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function resetTrips(this)
            this.getTripSet().setTrips({});
        end    
        
        %{
        Function:
        This method re-initialise the plugins to reset the program
        
        Arguments:
        this - The object on which the function is called, optional.
        %}
       
        function resetPlugins(this)%enelever à verifier l'utilité
            this.setPluginSelect();
            this.setPluginConfigurationSelect();
        end
         
        %{
        Function:
        This method is called to save tripset, pluginset and configuration set to a enviroment file
        
        Arguments:
        this - The object on which the function is called, optional.
        filename - The path to the file where to save the environment
        %}
        function saveEverythingToEnvironmentFile(this,filename)
            % build an environment object and add trips and plugins
            environmentToSave = fr.lescot.bind.loading.Environnement();
            tripsToSave = this.getTripSet().getTrips();
            if ~isempty(tripsToSave)
                environmentToSave.setTrips(tripsToSave);
            end
            
            pluginsToSave = this.getPluginSelect();
            configurationsToSave = this.getPluginConfigurationSet();
            environmentToSave.setpluginClassesAndConfigurations(pluginsToSave,configurationsToSave);
            environmentToSave.saveToFile(filename);
        end
        
        %{
        Function:
        This method is called to load tripset from a enviroment file
        
        Arguments:
        this - The object on which the function is called, optional.
        filename - The path to the file containing the environment to load
        %}
        function loadPluginsAndConfigurationsFromEnvironmentFile(this,filename) %suprimmer ?
            loadedEnvironment = fr.lescot.bind.loading.Environnement.loadPluginsAndConfigsFromFile(filename);
            [pluginClasses pluginConfigurations] = loadedEnvironment.getpluginClassesAndConfigurations();
            numberOfPluginsToLoad = length(pluginClasses);
            for i=1:numberOfPluginsToLoad
                this.addPluginWithConfiguration(pluginClasses{i},pluginConfigurations{i});
            end
        end
        
        %{
        Function:
        This method is called to load tripset from a enviroment file
        
        Arguments:
        this - The object on which the function is called, optional.
        filename - The path of the file containing the environment to load
        
        Throws:
        The exception of environment
        'Environnement:loadFromFile:InvalidPath' - If the file is not .env
        %}
        function loadTripsFromEnvironmentFile(this,filename) %suprimmer ?
            loadedEnvironment = fr.lescot.bind.loading.Environnement.loadFromFile(filename);
            tripsToLoad = loadedEnvironment.getTrips();
            numberOfTripsToLoad = length(tripsToLoad);
            for i=1:numberOfTripsToLoad
                this.addTrip(tripsToLoad{i});
            end
        end
    end
    
    methods(Access=public)
        
        %{
        Function:
        Default constructor.
        
        Arguments:
        pluginsPackage - A string indicating in which package of the path the loader
        will look for some suitable plugins. If the package is not defined,
        it is defaulted to 'fr.lescot.bind.plugins'. So, yes, if you use
        the Loader class as a base for your loaders, you have to put your
        plugins in some packages. It is mainly caused by technical reasons,
        but it is a good thing the the structure of your application anyway
        !
        %}
        function this =  LoaderBis(varargin)
            
            if nargin == 1
                this.pluginsPackage = varargin{1};
            else
                this.pluginsPackage = 'fr.lescot.bind.plugins';
            end
            %this.initialize(); % car fonction commentée
            closeWindowCallback = @this.closeWindow;
            this.figureHandler = figure('MenuBar', 'none', 'Name', 'Loader', 'DockControls', 'off', 'NumberTitle', 'off', 'Resize', 'off', 'Toolbar', 'none', 'Visible', 'off', 'Position', [0 0 100 100], 'CloseRequestFcn',closeWindowCallback, 'PaperPositionMode', 'auto');
        end
        
        
        
        %{
        Function:
        Necessary for implementing interface ConfiguratorUser. Get return values from configurators
        
        Arguments:
        this - The object on which the function is called, optional.
        pluginIndice - the indice of the plugin in the pluginSet being configured
        configuration - the value of returned the configuration
        
        %}
        function receiveConfiguration(this,pluginsId ,configuration) %faire sortir la configuartion avec cette fonction
            pluginConfigurationSelect = this.getPluginConfigurationSelect();
            pluginConfigurationSelect(pluginId)=configuration;
            this.setPluginConfigurationSelect(configuration);
        end
        
        %{
        Function:
        start the configurator of a plugin
        
        Arguments:
        this - The object on which the function is called, optional.
        pluginIndice - the indice of the plugin in the pluginSet that must be configured
        metaInformations - the value of the metainformation that describe what is available in the tripSet
        blank - a boolean to indicate that the configurator have to be launched with a blank configuration
        
        %}
        function launchPluginConfiguratorWithMetaInformations(this,pluginIndice,metaInformations,blank)
            %pluginSet = this.getPluginSet();
            pluginId = this.selectedPluginsIds(pluginIndice);
            pluginConfigurationSet = this.getPluginConfigurationSet();
            
            pluginToConfigure = pluginSet(pluginId);
            existingConfiguration = this.pluginConfigurationSet(pluginIndice);
            
            configurator = [pluginToConfigure '.getConfiguratorClass()'];
            pluginConfigurator = eval(configurator);
            if ~isempty(pluginConfigurator)
                if isempty(existingConfiguration) || blank
                    expression = [ pluginConfigurator '(pluginIndice,metaInformations,this)'];
                else
                    expression = [ pluginConfigurator '(pluginIndice,metaInformations,this,existingConfiguration)'];
                end
                eval(expression);
            else
                % ME
            end
        end
        
        %{
        Function:
        launch all loaded plugins connected to a trip
        
        Arguments:
        this - The object on which the function is called, optional.
        tripSelection - a cell array of trips on which plugins must be
        connected. If the length is higher than 1, the plugins have to be
        MultiTrip plugins.
        %}
        function launchPluginsWithTrip(this,tripSelection,pluginSelect)
            import fr.lescot.bind.exceptions.ExceptionIds;
            %first check if all plugins have valid configuration
           
            allPluginsAreValid = true;
            if length(tripSelection) == 1
                analysisType = 'MonoTrip';
            else
                analysisType = 'MultiTrip';
            end
            
            loaderMode = this.getMode();
            switch loaderMode
                case 'union'
                        if ~this.isPluginConfigurationValid(pluginSelect,trip.getMetaInformations())
                            allPluginsAreValid = false;
                        end
                   
                    
                case 'intersection'
                    allPluginsAreValid= this.isPluginConfigurationValidWithTripSet();
                    
            end
            
            if ~allPluginsAreValid
                errordlg('Veuillez vérifier la configuration des plugins chargés.')
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'It''s impossible to start the plugins if they are not all properly configured.'));
            else
                
                pluginsConfiguration = this.getPluginConfigurationSet();
                
                % create window to display loading information
                this.createLaunchWindow();
                message = ['Please wait during initialization!'];
                this.updateLaunchWindowLabel(message);
                
                
                    configurator = [pluginSelect '.getConfiguratorClass()'];
                    pluginConfigurator = eval(configurator);
                    if ~isempty(pluginConfigurator)
                        pluginConfiguration = pluginsConfigurationSelect;
                        
                        expression = '';
                        expression = [expression 'this.launchedPlugins{' sprintf('%d', i) '} = '];
                        expression = [expression char(loadedPlugins{i})];
                        switch analysisType
                            case 'MonoTrip'
                                expression = [expression '(tripSelection{1}'];
                            case 'MultiTrip'
                                expression = [expression '(tripSelection{1}']; % DOESN'T WORK!!! TO IMPLEMENT CORRECTLY.
                        end
                        for j = 1:1:pluginConfiguration.getArgumentsMaxOrder()
                            argument = pluginConfiguration.findArgumentWithOrder(j);
                            if ~isempty(argument)
                                expression = [expression ',']; % the , is necessary for separating each argument.
                                if argument.isOptionnal()
                                    expression = [expression '''' argument.getName() '''' ','];
                                end
                                expression = [expression 'pluginConfiguration.findArgumentWithOrder(' sprintf('%d', j) ').getValue()'];
                            end
                        end
                        expression = [expression ');'];
                    end
                    message = ['Launching plugin ' pluginSelect];
                    this.updateLaunchWindowLabel(message);
                    try
                        eval(expression);
                        this.launchedTrips = tripSelection;
                    catch ME
                        % first generate error log
                        errorMessage{1} = 'Problem while ';
                        errorMessage{2} = message;
                        errorMessage{3} = 'Exception caugth with message';
                        errorMessage{4} = ME.message;
                        msgbox(errorMessage,'Error while launching plugins','error');
                        exportErrorMessage = getReport(ME, 'extended');
                        disp(exportErrorMessage);
                    end
                end
                % at this stage, all plugins are ready (or have failed, but it doesn't matter ^^)
                % The label on the stop window can indicate trip
                % properties, and the button to go back to loader can be
                % activated
                switch analysisType
                    case 'MonoTrip'
                        % on est en mono trip
                        metas = tripSelection{1}.getMetaInformations();
                        attributesList = metas.getTripAttributesList();
                        
                        % blank message variable
                        message = {};
                        message{1} = 'Trip info :';
                        message{2} = ' ';
                        try 
                            message{3} = tripSelection{1}.getMetaInformations().getParticipant().getAttribute('name');
                        catch
                            N = min(length(attributesList),3);
                            for i=1:1:N
                                attributeName = attributesList{i};
                                attributeValue = tripSelection{1}.getAttribute(attributesList{i});
                                message{i+2} = [ attributeName ' = ' attributeValue];
                            end
                        end
                    case 'MultiTrip'
                        message = 'Analyse multitrip';
                end
            this.updateLaunchWindowLabel(message);
            set(this.returnToLoaderButton, 'Enable', 'on');
            end
        

        %{
        Function:
        kill all the launched the plugins : remove observers, close windows and delete plugins and reset all trips timers
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function closePlugins(this)
            if ~isempty(this.launchedTrips) && ~isempty(this.launchedPlugins)
                
                % stop timers of all launched trips
                for i = 1:1:length(this.launchedTrips)
                    this.launchedTrips{i}.getTimer.stopTimer();
                    for j = 1:1:length(this.launchedPlugins)
                        if isa(this.launchedPlugins{j},'fr.lescot.bind.plugins.GraphicalPlugin')
                            handle = findobj(this.launchedPlugins{j});
                            if handle.isvalid()
                                this.launchedPlugins{j}.closeWindow();
                            end
                        elseif isa(this.launchedPlugins{j},'fr.lescot.bind.plugins.MultiGraphicalPlugin')
                            handle = findobj(this.launchedPlugins{j});
                            if handle.isvalid()
                                this.launchedPlugins{j}.closeWindow();
                            end
                        end
                        this.launchedTrips{i}.removeObserver(this.launchedPlugins{j});
                    end
                    
                    % when all plugins are closed, reset timer
                    
                    this.launchedTrips{i}.getTimer.resetTimer();
                end
                % and go back to full loader  reset timers of all launched
                % trips
                this.launchedTrips ();
                this.launchedPlugins();
            else
                %ME
            end
        end
        
        %{
        Function:
        Bring back all plugin to front windows
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function bringPluginsWindowsToFront(this)
            if ~isempty(this.launchedTrips) && ~isempty(this.launchedPlugins)
                for i = 1:1:length(this.launchedPlugins)
                    if isa(this.launchedPlugins{i},'fr.lescot.bind.plugins.GraphicalPlugin')
                        handle = findobj(this.launchedPlugins{i});
                        if handle.isvalid()
                            set(this.launchedPlugins{i}.getFigureHandler(),'Visible','on');
                        end
                    else
                        if libisloaded('videoDllAlias')
                            % If there are loaded video
                            if ~calllib('videoDllAlias', 'NoMoreVideo')
                                % put all video windows to foreground
                                calllib('videoDllAlias','SetForeground',0);
                            end
                        end
                    end
                end
            end
            
        end
        
        %{
        Function:
        Get the list of installed plugin, by class or by human readable name
        
        Arguments:
        this - The object on which the function is called, optional.
        mode - a string : 'ClassName' or 'HumanReadableName' to choose the output
        
        Returns:
        A cell array of string
        
        %}
        function out = getAvailablePlugins(this,mode)
            if ~any(strcmp(mode,{'ClassName' 'HumanReadableName'}))
                mode = 'ClassName';
            end
            
            pluginList = fr.lescot.bind.utils.PluginUtils.getAllAvailablePlugins(this.pluginsPackage);
            switch mode
                case 'ClassName'
                    out = pluginList;
                case 'HumanReadableName'
                    pluginListWithHumanReadableName = cell(1,length(pluginList));
                    for i=1:length(pluginList)
                        expression = [ pluginList{i} '.getName()' ];
                        pluginListWithHumanReadableName{i} = eval(expression);
                    end
                    out = pluginListWithHumanReadableName;
            end
        end
        
        %{
        Function:
        Add a plugin and a configuration. If configuration is empty ( [] for example), add an empty configuration.
        
        Arguments:
        this - The object on which the function is called, optional.
        pluginClassName - className of the plugin to add
        configuration - if isempty(configuration) returns "true", add plugins with blank config
        
        Returns:
        out - The pluginID of the added plugin
        %}
        function out = addPluginWithConfiguration(this,pluginSelect, pluginClassName,configuration)
            availablePlugins = this.getAvailablePlugins('ClassName');
            if any(strcmp(pluginClassName,availablePlugins(:)))
                % this plugins is ok for add as it exists in the available
                % plugins
         
                this.setPluginSet({pluginSelect pluginClassName});
                out = 1;
                % add configuration
                loadedConfigurations = this.getPluginConfigurationSelect();
                if isempty(configuration)
                    this.setPluginConfigurationSet({loadedConfigurations '' });
                else
                    this.setPluginConfigurationSet({loadedConfigurations configuration });
                end
            else
                out = [];
            end
        end
        
        %{
        Function:
        Give the names of the loaded plugins
        
        Arguments:
        this - The object on which the function is called, optional.
        mode - a string : 'ClassName' or 'HumanReadableName' to choose the output
        
        Returns:
        A cell array of strings according to 'mode' parameter
        
        %}
        function out = getLoadedPluginsName(this,mode)
            if ~any(strcmp(mode,{'ClassName' 'HumanReadableName'}))
                mode = 'ClassName';
            end
            
            loadedPlugins = this.getPluginSelect;
            loadedConfigurations = this.getPluginConfigurationSelect;
            if isnotempty (loadedPlugins)
                loadedPluginsName = loadedPlugins.getName();
                    switch mode
                        case 'ClassName'
                            loadedPluginsName =loadedPlugins;
                        case 'HumanReadableName'
                            expression = [ char(loadedPlugins) '.getName()' ];
                            pluginName = eval(expression);
                            loadedPluginsName = pluginName;
                    end
               
                out = loadedPluginsName;
            else
                % in this case, no plugins are loader
                out = {};
            end
        end
        
        %{
        Function:
        Give information if the configuration of a given plugin is present. It test if there are some
        <fr.lescot.bind.configurators.Argument> in the configuration.
        
        Arguments:
        this - The object on which the function is called, optional.
        
        Returns:
        A boolean that tells if a configuration object is present
        
        %}
        function out = isPluginConfigurationPresent(this,pluginId)
            loadedConfigurations = this.getPluginConfigurationSet();
            % check is configuration are available
            configurationAvailable = true;
            pluginConfiguration = loadedConfigurations{pluginId};
            try
                arguments = pluginConfiguration.getArguments();
            catch ME
                configurationAvailable = false;
            end
            out = configurationAvailable;
        end
        
        %{
        Function:
        Give information if the configuration of a given plugin is valid according to a specific metaInformation given in parameter.
        
        Arguments:
        this - The object on which the function is called, optional.
        pluginId - the ID of the plugin which configuration has to be validated
        metaInformations - a referenceTrip for metadata verification
        
        Returns:
        A boolean that tells if a configuration is ok with the meta from parameters
        
        %}
        function out = isPluginConfigurationValid(this,pluginId,metaInformations)
            % check is configuration are available
            configurationValid = true;
            
            if ~this.isPluginConfigurationPresent(pluginId)
                configurationValid = false;
            else
                loadedPlugins = this.getPluginSelect;
                loadedPluginsName = loadedPlugins;
                expression = [ char(loadedPluginsName) '.getConfiguratorClass()' ];
                pluginConfigurator = eval(expression);
                
               
                pluginConfiguration = this.getPluginConfigurationSelect;
                
                expression = [ pluginConfigurator '.validateConfiguration(metaInformations, pluginConfiguration)' ];
                configurationValid=eval(expression);
            end
            out = configurationValid;
        end
        
        %{
        Function:
        Give information if the configuration of a given plugin is valid with respect to the common properties
        of the tripSet
        
        Arguments:
        this - The object on which the function is called, optional.
        
        Returns:
        A boolean that tells if the configuration of all the plugins are ok with the metaInfo of the tripSet
        
        %}
        function out = isPluginConfigurationValidWithTripSet(this)
            loadedPlugins = this.getPluginSelect();
            out = true;
            
                
            if ~this.isPluginConfigurationPresent()
                out = false;
            else
                loadedPluginsName = loadedPlugins;
                expression = [ char(loadedPluginsName) '.getConfiguratorClass()' ];
                pluginConfigurator = eval(expression);

                
                pluginConfiguration = this.getPluginConfigurationSelect();

                tripMetaInformations = this.getTripsCommonMetaInformations();

                expression = [ pluginConfigurator '.validateConfiguration(tripMetaInformations, pluginConfiguration)'];
                configurationValid=eval(expression);
                out = out && configurationValid;
            end
            end
            
    
        
        %{
        Function:
        Remove plugin and its configuration at a given indice from the pluginSet and pluginConfigurationSet
        
        Arguments:
        this - The object on which the function is called, optional.
        pluginIdsToDelete - an array of indice in the pluginSet
        
        %}
        function removePluginsAndConfigs(this,pluginSelect)
            loadedPlugins = this.getPluginSelect();
            loadedConfigurations = this.getPluginConfigurationSelect();
            loadedPlugins(pluginSelect) = [];
            loadedConfigurations(pluginSelect) = [];
            this.setPluginSet(loadedPlugins);
            this.setPluginConfigurationSet(loadedConfigurations);
        end
        
        %{
        Function:
        add a trip to the tripSet
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function addTrip(this,trip)
            this.getTripSet().addTrip(trip);
        end
        
        %{
        Function:
        Remove a trip from the tripSet
        
        Arguments:
        this - The object on which the function is called, optional.
        tripToDelete - a reference on the trip to remove
        
        %}
        function removeTrip(this,tripToDelete)
            this.getTripSet().removeTrip(tripToDelete);
        end
        
        %{
        Function:
        Get MetaInformations from tripSet
        
        Arguments:
        this - The object on which the function is called, optional.
        
        Returns:
        out - a <fr.lescot.bind.data.MetaInformation> objet describing what is in the trip
        
        %}
        function out=getTripsCommonMetaInformations(this)
            out = this.getTripSet().getTripsCommonProperties();
        end
        
        %NOK
        function out=getTripsCommonAttributesValues(this)
            %out = this.getTripSet().getTripsCommonProperties();
        end
    end
    
    methods(Access=private)
        %{
        Function:
        The callback called when the window is closed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function closeWindow(this, ~, ~)
            %TODO : delete all instanciated objects before quiting the
            %application
            delete(this.figureHandler);
            delete(this);
        end
        
        
        %{
        Function:
        Getter for the pluginSet
        
        Arguments:
        this - The object on which the function is called, optional.
        
        Returns:
        out - a cell array of plugin ClassName
        %}
        function out=getPluginSelect(this)
            out = this.pluginSelect;
        end
        
        %{
        Function:
        Setter for the pluginSet
        
        Arguments:
        this - The object on which the function is called, optional.
        newPluginSet - a cell array of plugin ClassName
        
        %}
        function setPluginSet(this,newPluginSet)
            this.pluginSet = newPluginSet;
        end
        
        %{
        Function:
        Getter for the pluginConfigurationSet
        
        Arguments:
        this - The object on which the function is called, optional.
        
        Returns:
        out - a cell array of <fr.lescot.bind.configurator.configuration>
        %}
        function out = getPluginConfigurationSet(this)
            out = this.pluginConfigurationSet;
        end
        
        %{
        Function:
        Setter for the pluginSet
        
        Arguments:
        this - The object on which the function is called, optional.
        newPluginConfigurationSet - a cell array of <fr.lescot.bind.configurator.configuration>
        
        %}
        function setPluginConfigurationSet(this,newPluginConfigurationSet)
            this.pluginConfigurationSet = newPluginConfigurationSet;
        end
        
        
        %{
        Function:
        This method initialise the necessary attribute for the program
        to run
        
        Arguments:
        this - The object on which the function is called, optional.
        
       
        function initialize(this)
            this.tripSet = fr.lescot.bind.kernel.TripSet();
            this.setPluginSelect();
            this.setPluginConfigurationSelect();
            this.setMode('intersection');
            
            this.launchedTrips = {};
            this.launchedPlugins = {};
        end
         %}
        %{
        Function:
        This method hide the main launcher window and replace it with a launch window that display
        useful information and controls for the launcher
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function createLaunchWindow(this)
            % first hide the main window
            set(this.figureHandler,'Visible','off');
            % then draw the stop figure
            windowTitle = 'Plugin Manager';
            this.launchFigureHandler = figure('MenuBar', 'none', 'Name', windowTitle, 'NumberTitle', 'off', 'Resize', 'off', 'Toolbar', 'none', 'Visible', 'off', 'Position', [0 0 300 150]);
            movegui(this.launchFigureHandler , 'center');
            
            this.launchWindowLabel = uicontrol(this.launchFigureHandler, 'Style', 'text', 'String', '', 'Position', [5 50 295 100], 'BackgroundColor', get(this.figureHandler, 'Color'));
            
            buttonCaption = 'Plugins';
            putPluginsToFrontButton = uicontrol(this.launchFigureHandler, 'Style', 'pushbutton', 'String', buttonCaption, 'Position', [30 10 120 40]);
            callbackHandler = @this.bringPluginsWindowsToFrontButtonCallback;
            set(putPluginsToFrontButton, 'Callback', callbackHandler);
            
            buttonCaption = 'Retour / Back';
            this.returnToLoaderButton = uicontrol(this.launchFigureHandler, 'Style', 'pushbutton', 'String', buttonCaption, 'Position', [170 10 120 40 ]);
            callbackHandler = @this.returnToLoaderButtonCallback;
            set(this.returnToLoaderButton, 'Callback', callbackHandler);
            set(this.launchFigureHandler,'CloseRequestFcn', callbackHandler);
            % by default, disable the button : it should not be pressed
            % before all plugins are launched
            set(this.returnToLoaderButton, 'Enable', 'off');
            
            set(this.launchFigureHandler, 'Visible', 'on');
        end
        
        %{
        Function:
        This method is useful to modify the text of the label of the launch window
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function updateLaunchWindowLabel(this,message)
            set(this.launchWindowLabel, 'String', message);
            set(this.launchFigureHandler,'Visible','on');
        end
        
        %{
        Function:
        This method stop the execution of the plugins, destroy the launch window and bring back the main loader window
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function returnToLoaderButtonCallback(this, source, eventdata)
            this.closePlugins();
            delete(this.launchFigureHandler);
            set(this.figureHandler,'Visible','on');
        end
        
        %{
        Function:
        This method is called when pressing the 'recall plugins' and call the bringPluginsWindowsToFront method
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function bringPluginsWindowsToFrontButtonCallback(this, source, eventdata)
            this.bringPluginsWindowsToFront();
        end
        
    end
end
