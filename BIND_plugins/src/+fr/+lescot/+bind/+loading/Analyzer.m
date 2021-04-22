classdef Analyzer < fr.lescot.bind.loading.Loader
    properties(Access=private)
        %{
        Property:
        a uitable that keeps informations on loaded trips. uitable property 'Data' contains common trip attributes.
        uitable property 'UserData' contains trip handlers
        
        %}
        tripUITable;
        
        %{
        Property:
        handler on button to add a trip
        
        %}
        addTripButton;
        %{
        Property:
        handler on button to remove a trip
        
        %}
        removeTripButton;
        %{
        Property:
        a cell array containing the trip handlers of the selected trips
        
        %}
        selectedTrips;
        
        %{
        Property:
        handler on uitable to display plugins infos
        
        %}
        pluginsUITable;
        
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
        function this=Analyzer()
            %call the constructor of the inherited class
            this@fr.lescot.bind.loading.Loader()
            %Build the user interface (possibly ABSTRACT method in mother
            %class to force GUI creation)
            this.buildUI()
        end
    end
    
    methods(Access=private)
        
        %{
        Function:
        Build all windows elements and dynamise. The created window is half the dimension of the screen resolution, but
        minimum size is 800x400

        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function buildUI(this)
            % get system properties to build window accordingly
            screenResolution = get( 0, 'ScreenSize' );
            screenWidth = screenResolution(3);
            screenHeigth = screenResolution(4);
            % figure size is half screen heigth or width, but cannot go
            % under 800x400
            windowWidth = max(800,screenWidth/2);
            windowHeigth = max(400, screenHeigth/2);
            set(this.getFigureHandler(),'Position', [0 0 windowWidth windowHeigth])
            
            % define general constant for figure
            buttonWidth = 100;
            
            % uitable for all the trips of the tripSet
            zoneForTripControlsHeigth = 100;
            zoneForTripWidth = 250;
            this.tripUITable = uitable(this.getFigureHandler(),'Position',[20 (zoneForTripControlsHeigth+5) zoneForTripWidth (windowHeigth-130)]);
            callbackHandler = @this.tripUITable_CellSelectionCallback;
            set(this.tripUITable, 'CellSelectionCallback', callbackHandler);
            
            %The controls associated with TRIPS : Trip panel for trip buttons
            panelTrips = uipanel(this.getFigureHandler(), 'Units', 'pixels', 'Position', [20 5 zoneForTripWidth zoneForTripControlsHeigth], 'BackgroundColor', get(this.getFigureHandler(), 'Color'), 'Title', 'Trips');
            buttonCaption = 'Ajouter un trip';
            this.addTripButton = uicontrol(panelTrips, 'Style', 'pushbutton', 'String', buttonCaption, 'Position', [(zoneForTripWidth/2-buttonWidth/2) (zoneForTripControlsHeigth/2) buttonWidth 30]);
            callbackHandler = @this.tripControlCallback;
            set(this.addTripButton, 'Callback', callbackHandler);
            buttonCaption = 'Enlever ces trips';
            this.removeTripButton = uicontrol(panelTrips, 'Style', 'pushbutton', 'String', buttonCaption, 'Position', [(zoneForTripWidth/2-buttonWidth/2) (zoneForTripControlsHeigth/6) buttonWidth 30]);
            callbackHandler = @this.tripControlCallback;
            set(this.removeTripButton, 'Callback', callbackHandler);
            
            %The plugins uitable
            zoneForPluginControlsHeigth = 100;
            zoneForPluginWidth = 250;
            this.pluginsUITable = uitable(this.getFigureHandler(),'Position',[(windowWidth-zoneForPluginWidth)-20 (zoneForPluginControlsHeigth+5) zoneForPluginWidth (windowHeigth-130)]);
            callbackHandler = @this.pluginsUITable_CellSelectionCallback;
            set(this.pluginsUITable, 'CellSelectionCallback', callbackHandler);
            
            % The controls associated with PLUGINS : Plugins panel for plugions buttons
            panelPlugins = uipanel(this.getFigureHandler(), 'Units', 'pixels', 'Position', [(windowWidth-zoneForPluginWidth)-20 5 zoneForPluginWidth zoneForPluginControlsHeigth], 'BackgroundColor', get(this.getFigureHandler(), 'Color'), 'Title', 'Plugins');
            buttonCaption = 'Ajouter des plugins';
            this.addPluginButton = uicontrol(panelPlugins, 'Style', 'pushbutton', 'String',buttonCaption , 'Position', [(zoneForPluginWidth/4-buttonWidth/2) (zoneForPluginControlsHeigth/2) buttonWidth 30]);
            callbackHandler = @this.pluginControlCallback;
            set(this.addPluginButton, 'Callback', callbackHandler);
            buttonCaption = 'Configurer le plugin';
            this.configurePluginButton = uicontrol(panelPlugins, 'Style', 'pushbutton', 'String', buttonCaption, 'Position', [(3*zoneForPluginWidth/4-buttonWidth/2)  (zoneForPluginControlsHeigth/2) buttonWidth 30]);
            callbackHandler = @this.pluginControlCallback;
            set(this.configurePluginButton, 'Callback', callbackHandler);
            buttonCaption = 'Enlever ce plugin';
            this.removePluginButton = uicontrol(panelPlugins, 'Style', 'pushbutton', 'String',buttonCaption , 'Position', [(zoneForPluginWidth/4-buttonWidth/2) (zoneForTripControlsHeigth/6) buttonWidth 30]);
            callbackHandler = @this.pluginControlCallback;
            set(this.removePluginButton, 'Callback', callbackHandler);
            
            %Launch button
            buttonCaption = 'Démarrer l''analyse';
            this.launchButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String',buttonCaption , 'Position', [(windowWidth/2-buttonWidth/2) windowHeigth/2  buttonWidth buttonWidth]);
            callbackHandler = @this.launchCallback;
            set(this.launchButton, 'Callback', callbackHandler);
            
            % Menus
            menu = uimenu(this.getFigureHandler(), 'Label', 'Environnement');
            
            this.newEnvironmentMenu = uimenu(menu, 'Label', 'Nouveau');
            callbackHandler = @this.environnementManagmentCallback;
            set(this.newEnvironmentMenu, 'Callback', callbackHandler);
            
            this.loadEverythingFromEnvironmentMenu = uimenu(menu, 'Label', 'Charger Trips+Plugins depuis fichier');
            callbackHandler = @this.environnementManagmentCallback;
            set(this.loadEverythingFromEnvironmentMenu, 'Callback', callbackHandler);
            
            this.loadPluginsFromEnvironmentMenu = uimenu(menu, 'Label', 'Charger Plugins depuis fichier');
            callbackHandler = @this.environnementManagmentCallback;
            set(this.loadPluginsFromEnvironmentMenu, 'Callback', callbackHandler);
            
            this.saveEnvironmentMenu = uimenu(menu, 'Label', 'Sauvegarder Trips+Plugins vers fichier');
            callbackHandler = @this.environnementManagmentCallback;
            set(this.saveEnvironmentMenu, 'Callback', callbackHandler);
            
            % menu for trip mass loading
            menu2 = uimenu(this.getFigureHandler(), 'Label', 'Trips');
            this.addAllTripsInSubFolder = uimenu(menu2, 'Label', 'Ajouter tous les trips SQLite des sous dossiers');
            callbackHandler = @this.massiveAddSqliteTripCallback;
            set(this.addAllTripsInSubFolder, 'Callback', callbackHandler);
            
            % set the good status for all UI elements
            this.refreshUI();
            % at least we can show the figure
            movegui(this.getFigureHandler,'center');
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
    end
end

