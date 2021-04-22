%{
Class:
This class is the configurator of the <DataPlotter> plugin.

%}
classdef DataPlotterConfigurator < fr.lescot.bind.configurators.PluginConfigurator_simplif
    
    properties(Access = private)
        %{
        Property:
        The handler on the text field that can be used to configure
        manually the min of the y scale.
        %}
        minTextField;
        %{
        Property:
        The handler on the text field that can be used to configure
        manually the max of the y scale.
        %}
        maxTextField;
        %{
        Property:
        The handler on the radio button that allow to configure automatic
        formatting.
        %}
        autoFormatRadioButton;
        %{
        Property:
        The handler on the radio button that allow to configure manually
        each formatting.
        %}
        manualFormatRadioButton;
        %{
        Property:
        The handler on the radio button group containing the two previous
        elements.
        %}
        formatGroup;
        %{
        Property:
        The handler on the table element allowing the customization of
        plotting for each variable selected.
        %}
        parametersTable;
        %{
        Property:
        The handler on the text field for the customization of the width
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
        The handler on the radio button used to choose an y scale based on
        the min and max value of the selected variables in the whole file.
        %}
        minMaxFileRadio;
        %{
        Property:
        The handler on the radio button used to choose an y scale based on
        the min and max value of the selected variables in the display window.
        %}
        minMaxWindowRadio;
        %{
        Property:
        The handler on the radio button used to choose an y scale based on the two text fields.
        %}
        manualRadio;
        %{
        Property:
        The handler on the button group containing the three previous elements.
        %}
        scaleModeGroup;
        %{
        Property:
        The handler group containing the three previous elements.
        %}
        validateButton;
        
        variableSelector;
    end
    
    methods
        
        %{
        Function:
        The constructor of the DataPlotterConfigurator plugin. When instanciated, a
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
        function this = DataPlotterConfigurator(pluginName, trip, metaTrip, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator_simplif(pluginName, trip, metaTrip, varargin);

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
            set(this.getFigureHandler(), 'visible', 'off');
            set(this.getFigureHandler(), 'WindowStyle', 'normal');
            set(this.getFigureHandler(), 'position', [0 0 800 700]);
            set(this.getFigureHandler(), 'Name', 'DataPlotter configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            
            windowBackgroundColor = get(this.getFigureHandler(), 'Color');
            
            this.variableSelector = fr.lescot.bind.widgets.VariablesSelector(this.getFigureHandler, this.metaTrip, 'DATA', 'Position', [10 340], 'Height', 360);
            %The data scale mode panel
            scalePanel = uipanel(this.getFigureHandler(), 'Units', 'pixels', 'Position', [10 210 180 120], 'Title', 'Echelle des données', 'BackgroundColor', windowBackgroundColor);
            this.scaleModeGroup = uibuttongroup(scalePanel, 'Units', 'pixels', 'Position', [5 30 170 80], 'BackgroundColor', windowBackgroundColor, 'BorderType', 'none');
            this.minMaxFileRadio = uicontrol(this.scaleModeGroup, 'Style', 'radio', 'Tag', 'file', 'String', 'Minimum - Maximum fichier', 'Position', [5 50 160 20], 'BackgroundColor', windowBackgroundColor, 'Min', 0, 'Max', 1);
            this.minMaxWindowRadio = uicontrol(this.scaleModeGroup, 'Style', 'radio', 'Tag', 'window', 'String', 'Minimum - Maximum fenêtre', 'Position', [5 30 160 20], 'BackgroundColor', windowBackgroundColor, 'Min', 0, 'Max', 1);
            this.manualRadio = uicontrol(this.scaleModeGroup, 'Style', 'radio', 'Tag', 'manual', 'String', 'Manuelle', 'Position', [5 10 160 20], 'BackgroundColor', windowBackgroundColor, 'Min', 0, 'Max', 1);
            
            uicontrol(scalePanel, 'Style', 'text', 'String', 'yMin', 'BackgroundColor', windowBackgroundColor, 'Position', [15 12 30 20]);
            this.minTextField = uicontrol(scalePanel, 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [45 15 45 20], 'Enable', 'off', 'String', '-100');
            
            uicontrol(scalePanel, 'Style', 'text', 'String', 'yMax', 'BackgroundColor', windowBackgroundColor, 'Position', [95 12 30 20]);
            this.maxTextField = uicontrol(scalePanel, 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [125 15 45 20], 'Enable', 'off', 'String', '100');
            
            %The time scale panel
            timeScalePanel = uipanel(this.getFigureHandler, 'BackgroundColor', windowBackgroundColor, 'Title', 'Largeur de la fenêtre temporelle', 'Units', 'pixel', 'Position', [10 155 180 50]);
            uicontrol(timeScalePanel, 'Style', 'Text', 'String', 'Fenêtre (en s)', 'BackgroundColor', windowBackgroundColor, 'Position', [10 5 70 20]);
            this.timeWindowTextField = uicontrol(timeScalePanel, 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [90 9 45 20], 'String', '60');
            
            %The position panel
            this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 60], 'BackgroundColor', windowBackgroundColor);
            %The plot format panel
            formatPanel = uipanel(this.getFigureHandler() ,'BackgroundColor', windowBackgroundColor, 'Title', 'Format', 'Units', 'pixel', 'Position', [200 60 590 270]);
            this.formatGroup = uibuttongroup(formatPanel, 'Units', 'pixels', 'BackgroundColor', windowBackgroundColor, 'BorderType', 'none', 'Position', [10 225 570 30]);
            this.autoFormatRadioButton = uicontrol(this.formatGroup, 'Style', 'radio', 'Tag', 'auto', 'String', 'Style automatique', 'Position', [10 5 160 20], 'BackgroundColor', windowBackgroundColor, 'Min', 0, 'Max', 1);
            this.manualFormatRadioButton = uicontrol(this.formatGroup, 'Style', 'radio', 'Tag', 'manual', 'String', 'Style manuel', 'Position', [180 5 160 20], 'BackgroundColor', windowBackgroundColor, 'Min', 0, 'Max', 1);
            
            columnFormat = {'char' {'Jaune' 'Magenta' 'Cyan' 'Rouge' 'Vert' 'Bleu' 'Noir'} {'Ligne' 'Tirets' 'Pointillés' 'Mixte'} {'Aucun' 'Plus' 'Cercle' 'Asterisque' 'Point' 'Croix' 'Carré' 'Diamant' 'Triangle haut' 'Triangle bas' 'Triangle gauche' 'Triangle droite' 'Pentagramme' 'Hexagramme'}};
            this.parametersTable = uitable(formatPanel, 'Position', [10 10 570 210], 'ColumnName', {'Donnée.Variable' 'Couleur' 'Ligne' 'Marqueur'}, 'ColumnWidth', {315 65 65 105}, 'RowName', [], 'Enable', 'off', 'ColumnFormat', columnFormat, 'ColumnEditable', [false true true true]);
            
            %The validate button
            this.validateButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [365 10 80 40]);
            
            %Create and link the callbacks
            this.variableSelector.setAddVariableButtonCallback(@this.addButtonCallback);
            this.variableSelector.setRemoveVariableButtonCallback(@this.removeButtonCallback);
            scaleModeCallbackHandler = @this.scaleModeCallback;
            set(this.scaleModeGroup, 'SelectionChangeFcn', scaleModeCallbackHandler);
            formatCallbackHandler = @this.formatCallback;
            set(this.formatGroup, 'SelectionChangeFcn', formatCallbackHandler);
            validateCallbackHandle = @this.validateCallback;
            set(this.validateButton, 'Callback', validateCallbackHandle);
            %Let's move the GUI
            movegui(this.getFigureHandler(), 'center');
            set(this.getFigureHandler(), 'visible', 'on'); %Give back the window visible
            set(this.getFigureHandler(), 'WindowStyle', 'modal'); %place the window in the foreground
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
        Move a variable from the available list to the toPlotList.
        
        Arguments:
        this - optional
        source - for callback
        eventDatas - for callback
        
        %}
        function addButtonCallback(this, newEntries)
            for i = 1:1:length(newEntries)
                newEntry = newEntries{i};
                %Update the format list
                currentFormatTable = get(this.parametersTable, 'Data');
                if isempty(currentFormatTable)
                    newFormatTable = {newEntry 'Noir' 'Ligne' 'Aucun'};
                else
                    newFormatTable = [currentFormatTable; {newEntry 'Noir' 'Ligne' 'Aucun'}];
                end
                set(this.parametersTable, 'Data', sortrows(newFormatTable));
            end
        end
        
        %{
        Function:
        Move a variable from the toPlotList to the available list.
        
        Arguments:
        this - optional
        source - for callback
        eventDatas - for callback
        
        %}
        function removeButtonCallback(this, removedEntries)
            currentFormatList = get(this.parametersTable, 'Data');
            for i = 1:1:length(removedEntries)
                logicalIndicesToRemove = strcmpi(currentFormatList(:, 1), removedEntries{i});
                if any(logicalIndicesToRemove)
                    currentFormatList(logicalIndicesToRemove, :) = [];
                end
            end
            set(this.parametersTable, 'Data', currentFormatList);
        end
        
        %{
        Function:
        Call <setScaleTextFieldsEditability()> according to the context.
        
        Arguments:
        this - optional
        source - for callback
        eventData - for callback
        
        %}
        function scaleModeCallback(this, ~, eventData)
            selectedObject = eventData.NewValue;
            tag = get(selectedObject, 'Tag');
            if strcmp(tag, 'file') ||strcmp(tag, 'window')
                this.setScaleTextFieldsEditability(false);
            else
                this.setScaleTextFieldsEditability(true);
            end
        end
        
        %{
        Function:
        Enables or disables the custom scale field according to the radio
        button selected.
        
        Arguments:
        this - optional
        editable - Wether the components have to be activated or
        desactivated.
        
        %}
        function setScaleTextFieldsEditability(this, editable)
            if(editable)
                set(this.minTextField, 'Enable', 'on');
                set(this.maxTextField, 'Enable', 'on');
            else
                set(this.minTextField, 'Enable', 'off');
                set(this.maxTextField, 'Enable', 'off');
            end
        end
        
        %{
        Function:
        Enables or disables the display parameter table according to the
        state of the radio button group.
        
        Arguments:
        this - optional
        source - for callback
        eventData - for callback
        
        %}
        function formatCallback(this, ~, eventData)
            selectedObject = eventData.NewValue;
            tag = get(selectedObject, 'Tag');
            if strcmp(tag, 'auto')
                set(this.parametersTable, 'Enable', 'off');
            else
                set(this.parametersTable, 'Enable', 'on');
            end
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
                    argIndex = 1;
                    %The three compulsory arguments
                    arguments{argIndex} = Argument('dataIdentifiers', false, sort(this.variableSelector.getSelectedVariables()), 2);
                    argIndex = argIndex + 1;
                    arguments{argIndex} = Argument('position', false, this.positionChooser.getSelectedPosition(), 3);
                    argIndex = argIndex + 1;
                    arguments{argIndex} = Argument('timeWindow', false, str2double(get(this.timeWindowTextField, 'String')), 4);
                    argIndex = argIndex + 1;
                    %The scale mode option and the scale options
                    selectedButton = get(this.scaleModeGroup, 'SelectedObject');
                    tagOfSelectedButton = get(selectedButton, 'tag');
                    if strcmp(tagOfSelectedButton, 'file')
                        arguments{argIndex} = Argument('scaleMode', true, 'MinMaxFile', 5);
                        argIndex = argIndex + 1;
                    else
                        if strcmp(tagOfSelectedButton, 'window')
                            arguments{argIndex} = Argument('scaleMode', true, 'MinMaxWindow', 5);
                            argIndex = argIndex + 1;
                        else
                            arguments{argIndex} = Argument('scaleMode', true, 'Manual', 5);
                            argIndex = argIndex + 1;
                            min = str2double(get(this.minTextField, 'String'));
                            max = str2double(get(this.maxTextField, 'String'));
                            arguments{argIndex} = Argument('scale', true, [min max], 6);
                            argIndex = argIndex + 1;
                        end
                    end
                    %The line type, colors and markers options
                    if get(this.manualFormatRadioButton, 'Value')
                        dataMatrix = get(this.parametersTable, 'Data');
                        colors = dataMatrix(:, 2);
                        %Convert to color codes
                        colors = DataPlotterConfigurator.colorStringsToCodes(colors);
                        arguments{argIndex} = Argument('colors', true, colors, 7);
                        argIndex = argIndex + 1;
                        
                        lines = dataMatrix(:, 3);
                        %Convert to line codes
                        lines = DataPlotterConfigurator.lineStringsToCodes(lines);
                        arguments{argIndex} = Argument('lineTypes', true, lines, 8);
                        argIndex = argIndex + 1;
                        
                        markers = dataMatrix(:, 4);
                        %Convert to marker codes
                        markers  = DataPlotterConfigurator.markerStringsToCodes(markers);
                        arguments{argIndex} = Argument('markers', true, markers, 9);
                    end
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
            %Check if referenceTrip is a trip (if plugins are opened before
            %a trip is loader, data should not be extracted from the trip)
            if ~isa(referenceTrip, 'fr.lescot.bind.data.MetaInformations')
                out = false;
                return;
            end
            
            %Check that the data to plots are all available in the datas
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
    
    methods(Access = private, Static)
        
        %{
        Function:
        Translate matlab colors code into human-readable string.
        
        Arguments:
        codesArray - A cell array of strings
        
        %}
        function out = colorsCodesToString(codesArray)
            for i = 1:1:length(codesArray)
                if strcmp(codesArray(i) ,'k')
                    codesArray{i} = 'Noir';
                    continue;
                end
                if strcmp(codesArray(i) ,'m')
                    codesArray{i} = 'Magenta';
                    continue;
                end
                if strcmp(codesArray(i) ,'y')
                    codesArray{i} = 'Jaune';
                    continue;
                end
                if strcmp(codesArray(i) ,'c')
                    codesArray{i} = 'Cyan';
                    continue;
                end
                if strcmp(codesArray(i) ,'r')
                    codesArray{i} = 'Rouge';
                    continue;
                end
                if strcmp(codesArray(i) ,'g')
                    codesArray{i} = 'Vert';
                    continue;
                end
                if strcmp(codesArray(i) ,'b')
                    codesArray{i} = 'Bleu';
                    continue;
                end
            end
            out = codesArray;
        end
        
        %{
        Function:
        Translate human-readable labels into matlab color codes..
        
        Arguments:
        colorsArray - A cell array of strings
        
        %}
        function out = colorStringsToCodes(colorsArray)
            for i = 1:1:length(colorsArray)
                if strcmp(colorsArray(i) ,'Noir')
                    colorsArray{i} = 'k';
                    continue;
                end
                if strcmp(colorsArray(i) ,'Magenta')
                    colorsArray{i} = 'm';
                    continue;
                end
                if strcmp(colorsArray(i) ,'Jaune')
                    colorsArray{i} = 'y';
                    continue;
                end
                if strcmp(colorsArray(i) ,'Cyan')
                    colorsArray{i} = 'c';
                    continue;
                end
                if strcmp(colorsArray(i) ,'Rouge')
                    colorsArray{i} = 'r';
                    continue;
                end
                if strcmp(colorsArray(i) ,'Vert')
                    colorsArray{i} = 'g';
                    continue;
                end
                if strcmp(colorsArray(i) ,'Bleu')
                    colorsArray{i} = 'b';
                    continue;
                end
            end
            out = colorsArray;
        end
        
        %{
        Function:
        Translate matlab line codes into human readble labels.
        
        Arguments:
        linesArray - A cell array of strings
        
        %}
        function out = linesCodesToString(linesArray)
            for i = 1:1:length(linesArray)
                if strcmp(linesArray(i) ,'-')
                    linesArray{i} = 'Ligne';
                    continue;
                end
                if strcmp(linesArray(i) ,'--')
                    linesArray{i} = 'Tirets';
                    continue;
                end
                if strcmp(linesArray(i) ,':')
                    linesArray{i} = 'Pointillés';
                    continue;
                end
                if strcmp(linesArray(i) ,'-.')
                    linesArray{i} = 'Mixte';
                    continue;
                end
            end
            out = linesArray;
        end
        
        %{
        Function:
        Translate human-readable labels into matlab line codes.
        
        Arguments:
        linesArray - A cell array of strings
        
        %}
        function out = lineStringsToCodes(linesArray)
            for i = 1:1:length(linesArray)
                if strcmp(linesArray(i) ,'Ligne')
                    linesArray{i} = '-';
                    continue;
                end
                if strcmp(linesArray(i) ,'Tirets')
                    linesArray{i} = '--';
                    continue;
                end
                if strcmp(linesArray(i) ,'Pointillés')
                    linesArray{i} = ':';
                    continue;
                end
                if strcmp(linesArray(i) ,'Mixte')
                    linesArray{i} = '-.';
                    continue;
                end
            end
            out = linesArray;
        end
        
        %{
        Function:
        Translate matlab marker codes to human readable label.
        
        Arguments:
        markersArray - A cell array of strings
        
        %}
        function out = markerStringsToCodes(markersArray)
            for i = 1:1:length(markersArray)
                if strcmp(markersArray(i) ,'Aucun')
                    markersArray{i} = '';
                    continue;
                end
                if strcmp(markersArray(i) ,'Plus')
                    markersArray{i} = '+';
                    continue;
                end
                if strcmp(markersArray(i) ,'Cercle')
                    markersArray{i} = 'o';
                    continue;
                end
                if strcmp(markersArray(i) ,'Asterisque')
                    markersArray{i} = '*';
                    continue;
                end
                if strcmp(markersArray(i) ,'Point')
                    markersArray{i} = '.';
                    continue;
                end
                if strcmp(markersArray(i) ,'Croix')
                    markersArray{i} = 'x';
                    continue;
                end
                if strcmp(markersArray(i) ,'Carré')
                    markersArray{i} = 's';
                    continue;
                end
                if strcmp(markersArray(i) ,'Diamant')
                    markersArray{i} = 'd';
                    continue;
                end
                if strcmp(markersArray(i) ,'Triangle haut')
                    markersArray{i} = '^';
                    continue;
                end
                if strcmp(markersArray(i) ,'Triangle bas')
                    markersArray{i} = 'v';
                    continue;
                end
                if strcmp(markersArray(i) ,'Triangle gauche')
                    markersArray{i} = '<';
                    continue;
                end
                if strcmp(markersArray(i) ,'Triangle droite')
                    markersArray{i} = '>';
                    continue;
                end
                if strcmp(markersArray(i) ,'Pentagramme')
                    markersArray{i} = 'p';
                    continue;
                end
                if strcmp(markersArray(i) ,'Hexagramme')
                    markersArray{i} = 'h';
                    continue;
                end
            end
            out = markersArray;
        end
        
        %{
        Function:
        Translate human readable label to matlab marker codes.
        
        Arguments:
        markersArray - A cell array of strings
        
        %}
        function out = markersCodesToString(markersArray)
            for i = 1:1:length(markersArray)
                if strcmp(markersArray(i) ,'')
                    markersArray{i} = 'Aucun';
                    continue;
                end
                if strcmp(markersArray(i) ,'+')
                    markersArray{i} = 'Plus';
                    continue;
                end
                if strcmp(markersArray(i) ,'o')
                    markersArray{i} = 'Cercle';
                    continue;
                end
                if strcmp(markersArray(i) ,'*')
                    markersArray{i} = 'Asterisque';
                    continue;
                end
                if strcmp(markersArray(i) ,'.')
                    markersArray{i} = 'Point';
                    continue;
                end
                if strcmp(markersArray(i) ,'x')
                    markersArray{i} = 'Croix';
                    continue;
                end
                if strcmp(markersArray(i) ,'s')
                    markersArray{i} = 'Carré';
                    continue;
                end
                if strcmp(markersArray(i) ,'d')
                    markersArray{i} = 'Diamant';
                    continue;
                end
                if strcmp(markersArray(i) ,'^')
                    markersArray{i} = 'Triangle haut';
                    continue;
                end
                if strcmp(markersArray(i) ,'v')
                    markersArray{i} = 'Triangle bas';
                    continue;
                end
                if strcmp(markersArray(i) ,'<')
                    markersArray{i} = 'Triangle gauche';
                    continue;
                end
                if strcmp(markersArray(i) ,'>')
                    markersArray{i} = 'Triangle droite';
                    continue;
                end
                if strcmp(markersArray(i) ,'p')
                    markersArray{i} = 'Pentagramme';
                    continue;
                end
                if strcmp(markersArray(i) ,'h')
                    markersArray{i} = 'Hexagramme';
                    continue;
                end
            end
            out = markersArray;
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
            
            %scaleMode and scale
            scaleMode = configuration.findArgumentWithOrder(5).getValue();
            if ~isempty(scaleMode)
                if strcmp(scaleMode, 'MinMaxWindow')
                    set(this.scaleModeGroup, 'SelectedObject', this.minMaxWindowRadio);
                    this.setScaleTextFieldsEditability(false);
                else
                    if strcmp(scaleMode, 'MinMaxFile')
                        set(this.scaleModeGroup, 'SelectedObject', this.minMaxFileRadio);
                        this.setScaleTextFieldsEditability(false);
                    else
                        set(this.scaleModeGroup, 'SelectedObject', this.manualRadio);
                        this.setScaleTextFieldsEditability(true);
                    end
                end
            end
            scale = configuration.findArgumentWithOrder(6);
            if ~isempty(scale)
                scale = scale.getValue();
                set(this.minTextField, 'String', sprintf('%.2f', scale(1)));
                set(this.maxTextField, 'String', sprintf('%.2f', scale(2)));
            end
            %The automatic / manual format and the array
            colors = configuration.findArgumentWithOrder(7);
            lines = configuration.findArgumentWithOrder(8);
            markers = configuration.findArgumentWithOrder(9);
            %Set properly the radio button
            if ~isempty(colors) || ~isempty(lines) || ~isempty(markers)
                set(this.formatGroup, 'SelectedObject', this.manualFormatRadioButton);
                set(this.parametersTable, 'Enable', 'on');
            else
                set(this.formatGroup, 'SelectedObject', this.autoFormatRadioButton);
                set(this.parametersTable, 'Enable', 'off');
            end
            %Generate the matrix to push in the table
            if ~isempty(dataList)
                datas = dataList.getValue();
                dataNumer = length(datas);
                array = cell(dataNumer, 4);
                array(:, 1) = datas;
                if ~isempty(colors)
                    array(:, 2) = DataPlotterConfigurator.colorsCodesToString(colors.getValue());
                else
                    array(:, 2) = {'Noir'};
                end
                if ~isempty(lines)
                    array(:, 3) = DataPlotterConfigurator.linesCodesToString(lines.getValue());
                else
                    array(:, 3) = {'Ligne'};
                end
                if ~isempty(markers)
                    array(:, 4) = DataPlotterConfigurator.markersCodesToString(markers.getValue());
                else
                    array(:, 4) = {'Aucun'};
                end
                set(this.parametersTable, 'Data', array);
            end
            
            
        end
    end
    
end
