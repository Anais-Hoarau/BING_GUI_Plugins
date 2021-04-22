classdef Analyzer_copie_dock < fr.lescot.bind.loading.Loader & fr.lescot.bind.plugins.TripPlugin
    properties(Access=private)
        
        %{
        Property:
        handler on button to add a plugin
        
        %}
        addPluginButton
        
        %{
        Property:
        handler on button to remove a plugin
        
        %}
        removePluginButton
        
        %{
        Property:
        handler on button to configure a plugin
        
        %}
        configurePluginButton
        
        %{
        Property:
        a cell array containing the pluginID of the selected plugins
        
        %}
        selectedPluginsIds;
        
        %{
        Property:
        handler on button to launch all plugins
        
        %}
        launchButton
        
        %{
        Property:
        handler on menu for new environment
        
        %}
        newEnvironmentMenu
        %{
        Property:
        handler on menu for loading all items from environment file
        
        %}
        loadEverythingFromEnvironmentMenu
        %{
        Property:
        handler on menu for loading plugins from environment file
        
        %}
        loadPluginsFromEnvironmentMenu
        %{
        Property:
        handler on menu for saving a new environment file
        
        %}
        saveEnvironmentMenu
        
        %{
        Property:
        handler on menu for loading recursively trips
        
        %}
        addAllTripsInSubFolder
        
        
        MagnetoUIPanel; %fenetre avec magneto
        MagnetoSousPanel;
        trip;
        window;
        
        %%propriété de magneto:
        %Simple commands panel controls
        
        %{
        Property:
        The handler of the first stop button (simple controls).
        
        %}
        stopButtonHandler;
        %{
        Property:
        The handler of the play button.
        
        %}
        playButtonHandler;
        %{
        Property:
        The handler of the play backward button.
        
        %}
        playBackwardButtonHandler;
        %{
        Property:
        The handler of the slider that indicates the current position in the file.
        
        %}
        sliderHandler;
        
        %Time panel elements
        
        %{
        Property:
        The text field that contains the current time.
        
        %}
        timeDisplayHandler;
        %{
        Property:
        The text field that contains the current remaining time before the end of the file.
        
        %}
        remainingTimeDisplayHandler;
        
        %Advanced command panel controls
        
        %{
        Property:
        The handler of the button that starts variable speed rewinding.
        
        %}
        rewindButtonHandler;
        %{
        Property:
        The handler of the button that moves one image backward.
        
        %}
        stepBackwardButtonHandler;
        %{
        Property:
        The handler of the second stop button (Advanced controls).
        
        %}
        stopButtonHandler2;
        %{
        Property:
        The handler of the button that moves one image forward.
        
        %}
        stepForwardButtonHandler;
        %{
        Property:
        The handler of the button that starts variable speed forwarding.
        
        %}
        forwardButtonHandler;
        
        %Backward speed block
        
        %{
        Property:
        The handler of the button that increase the speed of variable speed backward playing.
        
        %}
        increaseSpeedBackward;
        %{
        Property:
        The handler of the button that decrease the speed of variable speed backward playing.
        
        %}
        decreaseSpeedBackward;
        %{
        Property:
        The handler of the text field holding the value of the speed of variable speed backward playing.
        
        %}
        textSpeedBackward;
        
        %Forward speed block
		
        %{
        Property:
        The handler of the button that increase the speed of variable speed forward playing.
        
        %}
        increaseSpeedForward;
        %{
        Property:
        The handler of the button that decrease the speed of variable speed forward playing.
        
        %}
        decreaseSpeedForward;
        %{
        Property:
        The handler of the text field holding the value of the speed of variable speed forward playing.
        
        %}
        textSpeedForward;
        
        %{
        Property:
        The handler of the goto button (Advanced controls).
        
        %}
        gotoButton;
        
        %Utilities vars
        
        %{
        Property:
        A cell array that contains all the toggle buttons of the GUI that are (mostly) mutually exclusives.
        
        %}
        buttonsArray;
        
        %{
        Property:
        The color used by the buttons as BackgroundColor when they are instanciated.
        
        %}
        originalButtonsColor;
        
        %{
        Property:
        This handlers points to the 
        
        %}
        currentlyPlayingButton;
    end
    
    
    
    methods(Access=public)
        %{
        Function:
        Necessary for implementing interface ConfiguratorUser. Get return values from configurators and refresh the UI accordingly
        
        Arguments:
        this - The object on which the function is called, optional.
        pluginIndice - the indice of the plugin in the pluginSet being configured
        configuration - the value of returned the configuration
        
        %}
        function receiveConfiguration(this,pluginsId ,configuration)
            this.receiveConfiguration@fr.lescot.bind.loading.Loader(pluginsId ,configuration)
            this.refreshPluginUITable();
        end
        
        %{
        Function:
        Default constructor. Calls superclass and build UI
        
        Arguments:
        this - The object on which the function is called, optional.
        
        %}
        function this=Analyzer_copie_dock(trip)
            %%de magneto:
            this@fr.lescot.bind.plugins.TripPlugin(trip);
            
            %call the constructor of the inherited class
            this@fr.lescot.bind.loading.Loader()
            
            this.trip=trip;
            %Build the user interface (possibly ABSTRACT method in mother
            %class to force GUI creation)
            this.buildUI()
        end
    
    
    %%%%%%%%%DE magneto:
    function update(this, message)
            if isa(message, 'fr.lescot.bind.kernel.TimerMessage')
                import('fr.lescot.bind.utils.StringUtils');
                set(this.timeDisplayHandler, 'String', ['Temps : ' StringUtils.formatSecondsToString(this.trip.getTimer.getTime())]);
                set(this.remainingTimeDisplayHandler, 'String', ['Restant : ' StringUtils.formatSecondsToString(this.trip.getMaxTimeInDatas() - this.trip.getTimer.getTime())]);
                set(this.sliderHandler, 'Value', this.trip.getTimer.getTime());  
            end
            if isa(message, 'fr.lescot.bind.plugins.KeyMessage')
               %Do things :)
            end
        end
        
    end
    
    methods(Static)
        %{
        Function:
        Returns the human-readable name of the filter.
        
        Returns:
        A String.
        
        %}
        function out = getName()
            out = '[ALL] Magnétoscope';
        end
        
        %{
        Function:
        Overwrite <plugins.Plugin.isInstanciable()>.
        
        
        Returns:
        out - true
        %}
        function out = isInstanciable()
            out = true;
        end
        
        %{
        Function:
        Implements <fr.lescot.bind.plugins.Plugin.getConfiguratorClass()>.
        %}
        function out = getConfiguratorClass()
            out = 'fr.lescot.bind.configurators.MagnetoConfigurator';   
        end      
    end
    
    methods(Access=private)
        
       %création d'une grade fenetre avec le magnéto en haut à gauche
        function buildUI(this)
            % get system properties to build window accordingly
            screenResolution = get( 0, 'ScreenSize' );
            screenWidth = screenResolution(3);
            screenHeigt = screenResolution(4);
            
            % fouvre la fenetre Loader
            windowWidth = max(screenWidth)
            windowHeigth = max(screenHeigt)
            set(this.getFigureHandler(),'DefaultFigureWindowStyle', 'Docked');
            movegui(this.getFigureHandler());
            set(this.getFigureHandler(),'Visible','on');
            
            %creation d'une zone magneto:
            zoneForPluginHeigth = 500;
            zoneForPluginWidth = 500;
            
            %disposer une fenetre
            MagnetoFigure=figure(1);
            MagnetoFigure.set('Name','magnetoFigure');
            %{
            grid = uigridlayout(MagnetoFigure,[3 9]);
            
            p = uipanel(grid);
            p.Scrollable = 'off';
            p.Layout.Row = [3,5];
            p.Layout.Column = 1;
            %}
            h2 = figure(2); 
            plot(rand(1, 10)); 
            % Make figure fit in upper right quadrant..
            
            h3 = figure(3); 
            plot(rand(1, 10)); 
           
            
            %affiche les fenetres
             Figures=figure;
             Figures.set('WindowStyle', 'normal');
             
             Figure= ([figure(1), figure(2), figure(3)]);
             Figure.set('Parent', Figures);
             Figure.set( 'WindowStyle', 'Docked');
             Figure.set('Position', [0 0 windowWidth windowHeigth]);
             
           %disposer le magneto
            MagnetoPanel=uipanel(this.getFigureHandler(),'position', [0 .50 .50 350], 'Title','Magneto','FontSize',12, 'BackgroundColor','red');
            
            
            %Loading images
            stepBackwardImg = imread(which('step_backward.jpg'));
            rewindImg = imread(which('rewind.jpg'));
            stopImg = imread(which('stop.jpg'));
            playBackwardImg = imread(which('play_backward.jpg'));
            playImg = imread(which('play.jpg'));
            fastForwardImg = imread(which('fast_forward.jpg'));
            stepForwardImg = imread(which('step_forward.jpg'));
            %Adding ui elements
            %Simple commands panel
            simplePanel = uipanel(this.getFigureHandler(), 'Parent', MagnetoPanel, 'BackgroundColor', 'blue', 'Title', 'Commandes basiques', 'Units', 'pixel', 'Position', [20 220 310 100]);
            this.playBackwardButtonHandler = uicontrol(simplePanel, 'Style','togglebutton','CData', playBackwardImg, 'Position',[70 30 50 50]);
            this.stopButtonHandler = uicontrol(simplePanel, 'Style','togglebutton','CData', stopImg, 'Position',[130 30 50 50]);
            this.playButtonHandler = uicontrol(simplePanel, 'Style','togglebutton','CData', playImg, 'Position',[190 30 50 50]);
            this.sliderHandler = uicontrol(simplePanel, 'Style','Slider', 'Position',[10 10 290 10]) %, 'Max', this.trip.getMaxTimeInDatas());
            
            %The display panel
            displayPanel = uipanel(this.getFigureHandler(),'Parent', MagnetoPanel, 'BackgroundColor', 'blue', 'Title', 'Temps', 'Units', 'pixel', 'Position', [20 160 310 40]);
            this.timeDisplayHandler = uicontrol(displayPanel ,'Style','text','String','Temps : 00:00:00:0000', 'Position',[10 3 120 20],'BackgroundColor', 'blue', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
            this.remainingTimeDisplayHandler = uicontrol(displayPanel ,'Style','text','String','Restant : 00:00:00:0000', 'Position',[150 3 120 20],'BackgroundColor', 'blue', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
            %Advanced commands panel
            advancedPanel = uipanel(this.getFigureHandler(), 'Parent',MagnetoPanel, 'BackgroundColor', 'blue', 'Title', 'Commandes avancées', 'Units', 'pixel', 'Position', [20 20 310 120]); % position relative à celle du panel 'Magnetoscope'
            this.rewindButtonHandler = uicontrol(advancedPanel, 'Style','togglebutton','CData', rewindImg, 'Position',[10 50 50 50]);
            this.stepBackwardButtonHandler = uicontrol(advancedPanel, 'Style','pushbutton','CData', stepBackwardImg, 'Position',[70 50 50 50]);
            this.stopButtonHandler2 = uicontrol(advancedPanel ,'Style','togglebutton','CData', stopImg, 'Position',[130 50 50 50]);
            this.stepForwardButtonHandler = uicontrol(advancedPanel, 'Style','pushbutton','CData', stepForwardImg, 'Position',[190 50 50 50]);
            this.forwardButtonHandler = uicontrol(advancedPanel,'Style','togglebutton','CData', fastForwardImg, 'Position',[250 50 50 50]);
            %The two spinners for the speed
            this.increaseSpeedBackward = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', '+', 'Position', [10 36 50 15]);
            this.decreaseSpeedBackward = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', '-', 'Position', [10 8 50 15]);
            this.textSpeedBackward = uicontrol(advancedPanel,'Style','text','String','1x', 'Position',[10 23 50 13]);
            
            this.increaseSpeedForward = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', '+', 'Position', [250 36 50 15]);
            this.decreaseSpeedForward = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', '-', 'Position', [250 8 50 15]);
            this.textSpeedForward = uicontrol(advancedPanel,'Style','text','String','1x', 'Position',[250 23 50 13]);
            
            %The goto button
            this.gotoButton = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', 'Aller à ...', 'Position', [115 8 80 35]);
            
            %Initialisation of the utility vars
            this.buttonsArray = {this.rewindButtonHandler this.stopButtonHandler this.playButtonHandler this.stopButtonHandler2 this.playBackwardButtonHandler this.forwardButtonHandler};
            this.originalButtonsColor = get(this.rewindButtonHandler, 'BackgroundColor');
            %}
            
             % ouvrir la fenetre crée :
            movegui(this.getFigureHandler);
            set(this.getFigureHandler(),'Visible','on');
        end
        
      
            
        
        function massiveAddSqliteTripCallback(this, source, eventdata)
            directory = uigetdir('c:\','Select root dir for massive plugin add');
            if ~isempty(directory)
                sqliteTripsInSubFolder = fr.lescot.bind.utils.TripSetUtils.loadAllSQLiteTripsInSubdirectory(directory);
                % display modal window : this may take a while
                
                % load trips
                foundTrips = sqliteTripsInSubFolder.getTrips();
                
                for i=1:length(foundTrips)
                    this.addTrip(foundTrips{i});
                end
                this.refreshUI();
            end
        end
        
        %{
        Function:
        Callback called when user click on a button for trip control

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function tripControlCallback(this, source, eventdata)
            switch source
                case this.addTripButton
                    % Potentially select trip implementation then
                    % switch on correct opening method
                    selectedImplementation = 'SQLiteTrip';
                    switch selectedImplementation
                        case 'SQLiteTrip'
                            this.addSQLiteTrip();
                    end
                case this.removeTripButton
                    this.removeSelectedTrips();
            end
            % after any press on trip buttons, refresh the UI
            this.refreshTripUITable();
            this.setTripsButtonsStatus();
            this.setPluginsButtonsStatus(); % for configuration plugin button
            this.refreshPluginUITable(); % check if config are still valid
            this.refreshLaunchButtonStatus();
        end
        
        %{
        Function:
        Callback called when user click on a button for plugin control

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function pluginControlCallback(this, source, eventdata)
            switch source
                case this.addPluginButton
                    %potentially ask the user to select mono or multi
                    % then act accordingly
                    pluginType = 'MonoTrip';
                    switch pluginType
                        case 'MonoTrip'
                            this.addMonoTripPlugin();
                        case 'MultiTrip'
                    end
                case this.removePluginButton
                    this.removeSelectedPlugins();
                case this.configurePluginButton
                    this.configureSelectedPlugins();
            end
            % after any press on plugins buttons, refresh the UI
            this.refreshPluginUITable();
            this.setPluginsButtonsStatus();
            this.refreshLaunchButtonStatus();
            % this.refreshLaunchButtonStatus();
        end
        
        %{
        Function:
        Callback called when user click on a cell of the trip Uitable. It keeps informations on selectedTrips

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function tripUITable_CellSelectionCallback(this, source, eventdata)
            if numel(eventdata.Indices)==0
                %nothing selected!
                this.selectedTrips = {};
            else
                % get the lines that are selected and the associated trip
                % handlers
                rowsSelected = unique(eventdata.Indices(:,1));
                userDataMatrix = get(source, 'UserData');
                this.selectedTrips = userDataMatrix(rowsSelected);
            end
            this.setTripsButtonsStatus();
            this.refreshLaunchButtonStatus();
        end
        
        %{
        Function:
        Callback called when user click on a cell of the plugin Uitable. It keeps informations on selectedPluginsIds

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function pluginsUITable_CellSelectionCallback(this, source, eventdata)
            if numel(eventdata.Indices)==0
                %nothing selected!
                this.selectedPluginsIds = [];
            else
                % get the lines that are selected and the associated trip
                % handlers
                rowsSelected = unique(eventdata.Indices(:,1));
                userDataMatrix = get(source, 'UserData');
                this.selectedPluginsIds = userDataMatrix(rowsSelected);
            end
            this.setPluginsButtonsStatus();
        end
        
        %{
        Function:
        Update the uitable concerning plugins information with configurations related to the trip metainformations

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function refreshPluginUITable(this)
            loadedPluginsClassName = this.getLoadedPluginsName('ClassName');
            loadedPluginsName = this.getLoadedPluginsName('HumanReadableName');
            pluginNumber = length(loadedPluginsClassName);
            % we are only interested in plugin name and validity of the
            % plugin configuration : 2 columns to display
            pluginPropertiesNumber = 2;
            % prepare uitable properties
            data = cell(pluginNumber,pluginPropertiesNumber);
            userData = cell(pluginNumber, 1);
            for i=1:pluginNumber
                % pluginIds match the indices of the plugin UITable
                data{i, 1} = char(loadedPluginsName{i});
                if this.isPluginConfigurationPresent(i)
                    mode = this.getMode();
                    switch mode
                        case 'intersection'
                            pluginConfigurationValidity = this.isPluginConfigurationValid(i,this.getTripsCommonMetaInformations());
                        case 'union'
                            % TODO : implement selected trip metadatas collection
                            % and call to
                            % this.isPluginConfigurationValid(i,metas)
                            %metaInformations = this.get
                            pluginConfigurationValidity = true;
                    end
                else
                    pluginConfigurationValidity = false;
                end
                switch pluginConfigurationValidity
                    case true
                        data{i, 2} = 'Oui';
                    case false
                        data{i, 2} = 'Non';
                end
                % expected pluginID after plugin is launched
                userData{i} = i;
            end
            % set the properties to the UItable
            set(this.pluginsUITable, 'Data', data);
            set(this.pluginsUITable, 'UserData', userData);
            set(this.pluginsUITable, 'ColumnName', {'Nom' 'config. valide'});
            set(this.pluginsUITable, 'RowName', []);
            set(this.pluginsUITable,'ColumnWidth', {150 100});
        end
        
        %{
        Function:
        Update the uitable concerning trip information with datas from the trips

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function refreshTripUITable(this)
            loadedTrips = this.getTripSet().getTrips();
            if ~isempty(loadedTrips)
                commonAttributesList = this.getTripsCommonMetaInformations().getTripAttributesList();
                commonAttributesNumber = length(commonAttributesList);
                tripNumber = length(loadedTrips);
                % prepare uitable properties
                data = cell(tripNumber,commonAttributesNumber);
                userData = cell(tripNumber, 1);
                for i=1:tripNumber
                    trip = loadedTrips{i};
                    for k = 1:commonAttributesNumber
                        attributeValue = trip.getAttribute(commonAttributesList{k});
                        data{i, k} = attributeValue;
                    end
                    userData{i} = trip;
                end
            else
                data = {};
                userData = {};
                commonAttributesList = {};
            end
            % set the properties to the UItable
            set(this.tripUITable, 'Data', data);
            set(this.tripUITable, 'UserData', userData);
            set(this.tripUITable, 'ColumnName', commonAttributesList);
            set(this.tripUITable, 'RowName', []);
            set(this.tripUITable,'ColumnWidth', {50});
        end
        
        %{
        Function:
        Enable or disable removeTripButton, if no trips are present in the tripSet or if no trips are selected

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function setTripsButtonsStatus(this)
            if isempty(this.getTripSet().getTrips()) || isempty(this.selectedTrips)
                set(this.removeTripButton, 'Enable', 'off');
            else
                set(this.removeTripButton, 'Enable', 'on');
            end
        end
        
        %{
        Function:
        Modify button status (enable/disable) linked to plugins according to UI state

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function setPluginsButtonsStatus(this)
            if isempty(this.getLoadedPluginsName('ClassName')) || isempty(this.selectedPluginsIds)
                set(this.removePluginButton, 'Enable', 'off');
                set(this.configurePluginButton, 'Enable', 'off');
            else
                set(this.removePluginButton, 'Enable', 'on');
                if isempty(this.getTripSet().getTrips())
                    set(this.configurePluginButton, 'Enable', 'off');
                else
                    set(this.configurePluginButton, 'Enable', 'on');
                end
            end
        end
        
        
        %{
        Function:
        Propose a file chooser so that the user can select a trip file, then open it and add it to the tripset

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function addSQLiteTrip(this)
            [FileName,PathName] = uigetfile('*.trip','Select the trip file');
            if ~isequal(FileName,0)
                
                tripFileName = fullfile(PathName,FileName);
                trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFileName,0.04,false);
                this.addTrip(trip);
            end
        end
        
        %{
        Function:
        Remove from the tripSet all plugins whose ID are currently selected. The selected IDs are updated by the
        tripsUITable_CellSelectionCallback method.

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function removeSelectedTrips(this)
            for i=1:length(this.selectedTrips)
                this.removeTrip(this.selectedTrips{i});
            end
        end
        
        %{
        Function:
        Propose a list chooser to the user in order to choose a mono trip plugin to add to the pluginset

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function addMonoTripPlugin(this)
            availablePluginClassNameList = this.getAvailablePlugins('ClassName');
            availablePluginNameList = this.getAvailablePlugins('HumanReadableName');
            % prepare data for sort on human readable name
            for i=1:length(availablePluginClassNameList)
                A{i,1} = availablePluginClassNameList{i};
                A{i,2} = availablePluginNameList{i};
            end
            sortedPluginList = sortrows(A,2);
            % List box for user input
            pluginList = sortedPluginList(:,1);
            pluginListToDisplay = sortedPluginList(:,2);
            promptCaption = 'Selectionnez les plugins à ajouter';
            [selection, ok] = listdlg('SelectionMode','multiple','ListSize',[300 400],'PromptString',promptCaption,'ListString',pluginListToDisplay);
            if ok
                for i = 1:1:length(selection)
                    this.addPluginWithConfiguration(pluginList(selection(i)),'');
                end
            end
        end
        
        %{
        Function:
        Remove from the pluginSet all plugins whose ID are currently selected. The selected IDs are updated by the
        pluginsUITable_CellSelectionCallback method.

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function removeSelectedPlugins(this)
            pluginIDArray = [];
            for i = 1:length(this.selectedPluginsIds)
                pluginIDArray = [pluginIDArray this.selectedPluginsIds{i}];
            end
            this.removePluginsAndConfigs(pluginIDArray);
        end
        
        %{
        Function:
        Configure the plugins whose ID is currently selected. The selected IDs are updated by the
        pluginsUITable_CellSelectionCallback method. This method only work if 1 plugin is selected

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function configureSelectedPlugins(this)
            loaderMode = this.getMode();
            if length(this.selectedPluginsIds) > 1
                msgbox('Vous ne pouvez configurer qu''un seul plugin à la fois');
            else
                switch loaderMode
                    case 'intersection'
                        metaInformations = this.getTripsCommonMetaInformations();
                    case 'union'
                        % TODO : implement get metas from selected trip
                        %metaInformations =
                end
                pluginId = this.selectedPluginsIds{1};
                if this.isPluginConfigurationPresent(pluginId)
                    if  this.isPluginConfigurationValid(pluginId,metaInformations)
                        % open existing configuration
                        this.launchPluginConfiguratorWithMetaInformations(pluginId,metaInformations,false);
                    else
                        % si pas une conf invalide existe, on demande
                        % avant de l'écraser
                        overwrite = questdlg('Une configuration existe pour ce plugin, mais n''est pas valide. Voulez vous écraser cette configuration?','Overwrite?','Continuer','Annuler','Annuler');
                        if strcmp(overwrite,'Continuer')
                            % new configuration wished
                            this.launchPluginConfiguratorWithMetaInformations(pluginId,metaInformations,true);
                        end
                    end
                else
                    % new configuration required
                    this.launchPluginConfiguratorWithMetaInformations(pluginId,metaInformations,true);
                end
            end
        end
        
        %{
        Function:
        Launch the plugins with there configuration on the selected trips.  The selected IDs are updated by the
        pluginsUITable_CellSelectionCallback method. This method only work for the moment if 1 trip is selected.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function launchCallback(this, source, eventdata)
            if length(this.selectedTrips) == 1
                analysisType = 'MonoTrip';
            else
                analysisType = 'MultiTrip';
            end
            switch analysisType
                case 'MonoTrip'
                    try
                        this.launchPluginsWithTrip(this.selectedTrips);
                    catch ME
                        if isa(ME, 'fr.lescot.bind.exceptions.PluginException')
                            msgbox('Impossible de lancer le dépouillement si tout les plugins ne sont pas configurés', 'Attention','warn', 'modal')
                        else
                            rethrow(ME);
                        end
                    end
                case 'MultiTrip'
                    msgbox('Select 1 trip only : multitrip plugins are not supported yet...');
            end
        end
        
        %{
        Function:
        enable or disable the launch button according to UI
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function refreshLaunchButtonStatus(this)
            loadedPlugins = this.getLoadedPluginsName('ClassName');
            pluginNumber = length(loadedPlugins);
            
            if isempty(this.selectedTrips) || pluginNumber==0
                set(this.launchButton,'Enable', 'off');
            else
                set(this.launchButton,'Enable', 'on');
            end
        end
        
        %{
        Function:
        Call all required sub methods for UI refresh
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function refreshUI(this)
            this.refreshTripUITable();
            this.setTripsButtonsStatus();
            this.setPluginsButtonsStatus(); % for configuration plugin button
            this.refreshPluginUITable(); % check if config are still valid
            this.refreshLaunchButtonStatus();
        end
        
        %{
        Function:
        Callback called whenever the user click on any of the Environment menu
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - The source that launched the callback (the menu : load/save...)
        %}
        function environnementManagmentCallback(this, source, eventdata)
            switch source
                case this.newEnvironmentMenu
                    % delete plugins, configs and trip set
                    answer = questdlg('Vous êtes sur le point de tout remettre à zéro','Reset','Continuer','Annuler','Annuler');
                    if strcmp(answer,'Continuer')
                        this.resetTrips();
                        this.resetPlugins();
                        this.refreshUI();
                    end
                case this.loadEverythingFromEnvironmentMenu
                    % first reset all trips and plugins : ask before doing
                    % so
                    answer = questdlg('Vous êtes sur le point de tout recharger un nouvel environnement. L''environnement courant ne sera pas sauvegardé','Reset','Continuer','Annuler','Annuler');
                    % if user is ok, go!
                    if strcmp(answer,'Continuer')
                        this.resetTrips();
                        this.resetPlugins();
                        
                        % ask the user for an environment file and load trips + plugins
                        [FileName,PathName,FilterIndex] = uigetfile('*.env','Pick environment file');
                        envFile = fullfile(PathName,FileName);
                        if (exist(envFile,'file')==2)
                            try
                                this.loadTripsFromEnvironmentFile(envFile);
                                this.loadPluginsAndConfigurationsFromEnvironmentFile(envFile);
                            catch ME
                                if strcmp(ME.identifier,'Environnement:loadFromFile:InvalidPath')
                                    msgbox('Wrong file type : need a *.env file');
                                else
                                    msgbox('Error while loading environment file');
                                end
                                return;
                            end
                        end
                        this.refreshUI();
                    end
                case this.loadPluginsFromEnvironmentMenu
                    % ask the user for an environment file and load plugins
                    [FileName,PathName,FilterIndex] = uigetfile('*.env','Pick environment file');
                    envFile = fullfile(PathName,FileName);
                    if (exist(envFile,'file')==2)
                        try
                            this.loadPluginsAndConfigurationsFromEnvironmentFile(envFile);
                        catch ME
                            if strcmp(ME.identifier,'Environnement:loadFromFile:InvalidPath')
                                msgbox('Wrong file type : need *.env file');
                            else
                                msgbox('Error while loading environment file');
                            end
                            return;
                        end
                    end
                    this.refreshUI();
                case this.saveEnvironmentMenu
                    % ask the user for a path file where to save trips +
                    % plugins
                    [FileName,PathName,FilterIndex] = uiputfile('*.env','Save environment to file');
                    environmentFileName = fullfile(PathName,FileName);
                    this.saveEverythingToEnvironmentFile(environmentFileName);
            end
        end
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function dynamizeUI(this)
            %Adding callbacks on buttons
            %Simple commands
            playBackwardButtonCallback = @this.playBackwardCallback;
            set(this.playBackwardButtonHandler, 'Callback', playBackwardButtonCallback);
            stopButtonCallback = @this.stopCallback;
            set(this.stopButtonHandler, 'Callback', stopButtonCallback);
            playButtonCallback = @this.playCallback;
            set(this.playButtonHandler, 'Callback', playButtonCallback);


            %Advanced commands
            set(this.stopButtonHandler2, 'Callback', stopButtonCallback);
            
            decreaseSpeedCallbackHandler = @this.decreaseSpeedBackwardCallback;
            set(this.decreaseSpeedBackward, 'Callback',decreaseSpeedCallbackHandler); 
            increaseSpeedBackwardCallbackHandler = @this.increaseSpeedBackwardCallback;
            set(this.increaseSpeedBackward, 'Callback',increaseSpeedBackwardCallbackHandler);
            rewindButtonCallback = @this.rewindCallback;
            set(this.rewindButtonHandler, 'Callback',rewindButtonCallback);

            stepForwardButtonCallback = @this.stepForwardCallback;
            set(this.stepForwardButtonHandler, 'Callback', stepForwardButtonCallback);
            stepBackwardButtonCallback = @this.stepBackwardCallback;
            set(this.stepBackwardButtonHandler, 'Callback', stepBackwardButtonCallback);
            
            decreaseSpeedCallbackHandler = @this.decreaseSpeedForwardCallback;
            set(this.decreaseSpeedForward, 'Callback',decreaseSpeedCallbackHandler); 
            increaseSpeedForwardCallbackHandler = @this.increaseSpeedForwardCallback;
            set(this.increaseSpeedForward, 'Callback',increaseSpeedForwardCallbackHandler);
            forwardButtonCallback = @this.forwardCallback;
            set(this.forwardButtonHandler, 'Callback',forwardButtonCallback);
            
            sliderCallbackHandler = @this.sliderCallback;
            addlistener(this.sliderHandler, 'Action', sliderCallbackHandler);
            
            gotoButtonCallbackHandler = @this.gotoButtonCallback;
            set(this.gotoButton, 'Callback', gotoButtonCallbackHandler);
        end
        
        %{
        Function:
        Unpush the non selected buttons if they are in <buttonsArray>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        selectedButtonsArray - A cell array of button handlers.
        
        %}
        function setButtonsState(this, selectedButtonsArray)
            for i = 1:1:length(this.buttonsArray)
               isInSelectedArray = false;
               for j = 1:1:length(selectedButtonsArray)
                   isInSelectedArray = isInSelectedArray || ( selectedButtonsArray{j} ==  this.buttonsArray{i});
               end
               set(this.buttonsArray{i}, 'Value', isInSelectedArray);
            end
        end
        
        %{
        Function:
        The callback of the goto button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function gotoButtonCallback(this, ~, ~)
            timeElements = {'00' '00' '00' '000'};
            valid = false;
            while ~valid
                timeElements = inputdlg({'Heures', 'Minutes', 'Secondes', 'Millisecondes'}, 'Aller à', 1, timeElements);
                if ~isempty(timeElements)
                    timeElementsNum = cell(1, length(timeElements));
                    valid = true;
                    for i = 1:1:length(timeElements)
                        timeElementsNum{i} = str2double(timeElements{i});
                        valid = valid && ~isnan(timeElementsNum{i}) && (timeElementsNum{i} >= 0);
                    end
                else
                    valid = true;
                end
            end
            if ~isempty(timeElements)
                hours = timeElementsNum{1};
                minutes = timeElementsNum{2};
                seconds = timeElementsNum{3};
                millis = timeElementsNum{4};
                newTime = min(3600 * hours + 60 * minutes + seconds + millis / 1000, this.trip.getMaxTimeInDatas()); 
                this.trip.getTimer().setTime(newTime);
            end
        end
        
        %{
        Function:
        The callback of the "-" button related to forward speed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function decreaseSpeedForwardCallback(this, ~, ~)
           this.lesserSpeed(this.textSpeedForward);
           if this.currentlyPlayingButton == this.forwardButtonHandler
               this.forwardCallback(this.forwardButtonHandler);
           end
        end
        
        %{
        Function:
        The callback of the "+" button related to forward speed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function increaseSpeedForwardCallback(this, ~, ~)
           this.raiseSpeed(this.textSpeedForward);
           if this.currentlyPlayingButton == this.forwardButtonHandler
               this.forwardCallback(this.forwardButtonHandler);
           end
        end
        
        %{
        Function:
        The callback of the "-" button related to backward speed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function decreaseSpeedBackwardCallback(this, ~, ~)
           this.lesserSpeed(this.textSpeedBackward);
           if this.currentlyPlayingButton == this.rewindButtonHandler
               this.rewindCallback(this.rewindButtonHandler);
           end
        end
        
        %{
        Function:
        The callback of the "+" button related to backward speed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function increaseSpeedBackwardCallback(this, ~, ~)
           this.raiseSpeed(this.textSpeedBackward);
           if this.currentlyPlayingButton == this.rewindButtonHandler
               this.rewindCallback(this.rewindButtonHandler);
           end
        end
        
        %{
        Function:
        Parses the current content of a speed text field and divide it by
        two.
        
        Arguments:
        textField - The handler of a textfield containing a speed.
        
        %}
        function lesserSpeed(~, textField)
            currentString = get(textField, 'String');
            currentString = currentString(1:length(currentString)-1);
            newValue = str2double(currentString)/2;
            set(textField, 'String', [sprintf('%.4g', newValue) 'x']);
        end
        
        %{
        Function:
        Parses the current content of a speed text field and multiplies it by
        two.
        
        Arguments:
        textField - The handler of a textfield containing a speed.
        
        %}
        function raiseSpeed(~, textField)
            currentString = get(textField, 'String');
            currentString = currentString(1:length(currentString)-1);
            newValue = str2double(currentString)*2;
            set(textField, 'String', [sprintf('%.4g', newValue) 'x']);
        end
        
        %{
        Function:
        The callback of the time slider.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function sliderCallback(this, ~, ~)
            this.stopCallback(this.stopButtonHandler);
            newTime = get(this.sliderHandler, 'Value');
            this.trip.getTimer().setTime(newTime);
        end
        
        %{
        Function:
        The callback of the forward play button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function forwardCallback(this, source, ~)
            if(this.trip.getTimer.getTime() < this.trip().getMaxTimeInDatas())
                currentString = get(this.textSpeedForward, 'String');
                currentString = currentString(1:length(currentString)-1);
                this.trip.getTimer.setMultiplier(str2double(currentString));
                this.trip.getTimer.startTimer();
            end
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the rewind play button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function rewindCallback(this, source, ~)
            if(this.trip.getTimer.getTime() > 0)
                currentString = get(this.textSpeedBackward, 'String');
                currentString = currentString(1:length(currentString)-1);
                this.trip.getTimer.setMultiplier(-1*str2double(currentString));
                this.trip.getTimer.startTimer();
            end
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the step one image backward button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function stepBackwardCallback(this, source, ~)
            this.trip.getTimer.stopTimer();
            this.trip.getTimer.setMultiplier(1);
            newTime = this.trip().getTimer().getTime() - this.trip().getTimer().getDefaultPeriod();
            this.trip.getTimer.setTime(max(0, newTime));
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the step one image forward button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function stepForwardCallback(this, source, ~)
            this.trip.getTimer.stopTimer();
            this.trip.getTimer.setMultiplier(1);
            newTime = this.trip().getTimer().getTime() + this.trip().getTimer().getDefaultPeriod();
            this.trip.getTimer.setTime(min(newTime, this.trip().getMaxTimeInDatas()));
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the play button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function playCallback(this, source, ~)
            this.trip.getTimer.setMultiplier(1);
            this.trip.getTimer.startTimer();
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the play backward button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function playBackwardCallback(this, source, ~)
            this.trip.getTimer.setMultiplier(-1);
            this.trip.getTimer.startTimer();
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the stop button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function stopCallback(this, source, ~)
            this.trip.getTimer.stopTimer();
            this.setButtonsState({this.stopButtonHandler this.stopButtonHandler2});
            this.currentlyPlayingButton = source;
        end
        
    
end


end

