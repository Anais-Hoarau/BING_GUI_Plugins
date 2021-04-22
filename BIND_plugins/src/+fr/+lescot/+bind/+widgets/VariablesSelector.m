%{
Class:

This widget allows the selection of some variables inside the datas of a trip (or inside the events, or the
situations, depending on the "mode" parameter. The values are picked up via the <getSelectedVariables> method,
which return some strings in a cell array, with the form dataName.variableName (or eventName.variableName, or situationName.variableName).
The default size of the widget is 785 pixels wide by 360 pixels high, but height can be customized (width is fixed).
%}
classdef VariablesSelector < handle
    
    properties(Access = private)
        %{
        Property:
        The handler on the component on which the widget is pinned.
        %}
        parentHandler
        %{
        Property:
        A <data.MetaInformations> object that contains the description of the trip on which the data selection
        is performed.
        %}
        metaInformations;
        %{
        Property:
        A string describing if the widget is operating on datas, events or situations.
        %}
        mode;
        %{
        Property:
        A user defined callback executed when the add button is pressed.
        %}
        variablesAddedToSelectionCallback;
        %{
        Property:
        A user defined callback executed when the remove button is pressed.
        %}
        variablesRemovedFromSelectionCallback;
        %{
        Property:
        In this widget, items is a placeholder of data, event, situation or event&situation. So this is the handler
        to the list that displays them (the leftmost list).
        %}
        itemsList;
        %{
        Property:
        This is the handler on the list that displays the variables of the selected items (the second list).
        %}
        variablesList;
        %{
        Property:
        The handler on the add button.
        %}
        addButton;
        %{
        Property:
        The handler on the remove button.
        %}
        removeButton;
        %{
        Property:
        This is the handler on the list that displays the selected variables (the rightmost list).
        %}
        toPlotList;
        %{
        Property:
        This is the handler on the main uipanel that contains all the components.
        %}
        mainPanel;
        %{
        Property:
        This is the handler on the uipanel that contains the items list and the data list.
        %}
        datasPanel;
        %{
        Property:
        This is the handler on the uipanel that contains the add and remove buttons.
        %}
        buttonPanel;
        %{
        Property:
        This is the handler on the uipanel that contains the selected variables.
        %}
        toPlotPanel;
    end
    
    methods
        
        %{
        Function:
        The constructor of the class. Build a new widget and pin it in
        the parent component. Some options can be customized to improve
        integration. The starred (*) arguments have to be passed under the
        form 'argName', argValue.
        
        Arguments:
        parentHandler - The handler of the parent component
        metaInformations - A <data.MetaInformations> object containing the description of the
        trip on which to select the variables. Note that this object is static, so if the trip
        mode - A string containing "DATA" or "EVENT" or "SITUATION". Indicates on which type of items the
        widget will operate.
        *Position - a 2x1 array of double that gives the position in
        pixels relatively to the parent component. Defaulted to [0 0].
        *BackgroundColor - The color of the background of the widget.
        Defaulted to the color of the parent component.
        *VariablesAddedToSelectionCallback - A function handler that will be executed each time the
        add button is pressed. The function will receive one argument : a cell array of strings (same format
        as the <getSelectedVariables> output) that contains the list of elements added.
        *VariablesRemovedFromSelectionCallback - A function handler that will be executed each time the
        add button is pressed. The function will receive one argument : a cell array of strings (same format
        as the <getSelectedVariables> output) that contains the list of elements removed.
        *LeftPanelTitle - The title of the left panel (with the two lists). Defaulted to "Données & Variables".
        *RightPanelTitle - The title of the right panel (with the list of selected items). Defaulted to "A tracer".
        *Height - The desired height of the widget in pixels. Defaulted to 360 px.
        Returns:
        The figureHandler, thus allowing the use of the handle to modify
        the window or as a parent for other graphical components.
        %}
        function this = VariablesSelector(parentHandler, metaInformations, mode, varargin)
            %Add an argument parser for the optional args
            parser = inputParser;
            parser.addRequired('parentHandler');
            parser.addRequired('metaInformations');
            parser.addRequired('mode');%Todo : add auto validator
            parser.addOptional('Position', [0 0]);
            parser.addOptional('BackgroundColor', get(parentHandler, 'Color'));
            parser.addOptional('VariablesAddedToSelectionCallback', '');
            parser.addOptional('VariablesRemovedFromSelectionCallback', '');
            parser.addOptional('LeftPanelTitle', 'Données & Variables');
            parser.addOptional('RightPanelTitle', 'A tracer');
            parser.addOptional('Height', 360);
            parser.parse(parentHandler, metaInformations, mode, varargin{:});
            
            this.parentHandler = parser.Results.parentHandler;
            this.metaInformations = parser.Results.metaInformations;
            this.mode = parser.Results.mode;
            this.variablesAddedToSelectionCallback = parser.Results.VariablesAddedToSelectionCallback;
            this.variablesRemovedFromSelectionCallback = parser.Results.VariablesRemovedFromSelectionCallback;
            this.variablesAddedToSelectionCallback = parser.Results.VariablesAddedToSelectionCallback;
            
            %Once all the parameters are here, let's build the widget
            this.buildWidget(parser.Results.Position,...
                parser.Results.BackgroundColor, ...
                parser.Results.LeftPanelTitle, ...
                parser.Results.RightPanelTitle, ...
                parser.Results.Height...
                );
        end
        
        %{
        Function:
        Returns the list of selected variables.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        
        Returns:
        A cell array of strings (dataName.variableName form).
        %}
        function out = getSelectedVariables(this)
            out = sort(get(this.toPlotList, 'UserData'));
            return;
        end
        
        %{
        Function:
        Initialize the selected list with the provided variables. They have to be under
        the same form than the output of <getSelectedVariables>.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        
        Returns:
        A cell array of strings (dataName.variableName form).
        
        TODO:
        Check that the variables in the array are coherent with the <data.MetaInformations> object.
        %}
        function setSelectedVariables(this, selectedVariablesArray)
            set(this.toPlotList, 'String', selectedVariablesArray);
            set(this.toPlotList, 'UserData', selectedVariablesArray);
            this.updateItemsListCallback();
            this.updateVariablesListCallback();
        end
        
        %{
        Function:
        Adds a user defined callback that will be executed each time the add button is pressed.
        The function to execute will receive one argument : a cell array of strings (same format
        as the <getSelectedVariables> output) that contains the list of elements added.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        callback - A function handler
        %}
        function setAddVariableButtonCallback(this, callback)
            this.variablesAddedToSelectionCallback = callback;
        end
        
        %{
        Function:
        Adds a user defined callback that will be executed each time the removed button is pressed.
        The function to execute will receive one argument : a cell array of strings (same format
        as the <getSelectedVariables> output) that contains the list of elements removed.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        callback - A function handler
        %}
        function setRemoveVariableButtonCallback(this, callback)
            this.variablesRemovedFromSelectionCallback = callback;
        end
        
        %{
        Function:
        Changes the background color of all the panels, allowing to blend on any color.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        color - A matlab color (either letter format or array format).
        %}
        function setBackgroundColor(this, color)
            set(this.mainPanel, 'BackgroundColor', color);
            set(this.datasPanel, 'BackgroundColor', color);
            set(this.buttonPanel, 'BackgroundColor', color);
            set(this.toPlotPanel, 'BackgroundColor', color);
        end
        
        %{
        Function:
        Changes the position of the widget.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        position - A 2*1 matrix with the X and Y positions in pixels.
        %}
        function setPosition(this, position)
            currentPosition = get(this.mainPanel, 'Position');
            set(this.mainPanel, 'Position', [position(1) position(2) currentPosition(3) currentPosition(4)]);
        end
        
        %{
        Function:
        Vertically resizes the widget.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        height - The new vertical size in pixels.
        %}
        function setHeight(this, height)
            currentPosition = get(this.mainPanel, 'Position');
            set(this.mainPanel, 'Position', [currentPosition(1) currentPosition(2) 785 height]);
            set(this.datasPanel, 'Position', [1 1 335 height]);
            set(this.itemsList, 'Position', [10 10 155 height - 30]);
            set(this.variablesList, 'Position', [165 10 155 height - 30]);
            set(this.buttonPanel, 'Position', [350 0 80 height]);
            set(this.removeButton, 'Position', [0 ((height - 110 + 10)/2) 80 30]);
            set(this.addButton, 'Position', [0 ((height - 110 + 10)/2 + 50) 80 30]);
            set(this.toPlotPanel, 'Position', [445 1 335 height]);
            set(this.toPlotList, 'Position', [10 10 315 height - 30]);
        end
        
        %{
        Function:
        Changes the metainformations on which the selection is based. The selected variable panel will
        be reset by the operation.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        metaInfos - The new <data.MetaInformations> object.
        %}
        function setMetaInformations(this, metaInfos)
            set(this.toPlotList, 'String', {});
            set(this.toPlotList, 'UserData', {});
            this.metaInformations = metaInfos;
            this.updateItemsListCallback();
            this.updateVariablesListCallback();
        end
    end
    
    methods(Access = private)
        
        %{
        Function:
        Build the graphical elements of the widget.
        
        Arguments:
        this - The object on which the funtion is called. Optionnal.
        position - the 2*1 vector with the initial position in pixels.
        backgroundColor - The initial color of the elements.
        leftPanelTitle - The title of the left panel.
        rightPanelTitle - The title of the right panel.
        height - the original height of the widget, in pixels.
        %}
        function buildWidget(this, position, backgroundColor, leftPanelTitle, rightPanelTitle, height)
            
            this.mainPanel = uipanel(this.parentHandler, 'BorderType', 'none', 'BackgroundColor', backgroundColor,'Units', 'pixel', 'Position', [position(1) position(2) 785 height]);
            %The panel with the data.variable elements
            this.datasPanel = uipanel(this.mainPanel ,'BackgroundColor', backgroundColor, 'Title', leftPanelTitle, 'Units', 'pixel');
            this.itemsList = uicontrol(this.datasPanel, 'Style', 'listbox');
            this.variablesList = uicontrol(this.datasPanel, 'Style', 'listbox', 'Min', 0, 'Max', 1024);
            
            %The panel with the add and remove buttons
            this.buttonPanel = uipanel(this.mainPanel ,'BackgroundColor', backgroundColor, 'BorderType', 'none', 'Units', 'pixel');
            this.addButton = uicontrol(this.buttonPanel, 'Style', 'pushbutton', 'String', '>>');
            this.removeButton = uicontrol(this.buttonPanel, 'Style', 'pushbutton', 'String', '<<');
            
            %The panel with the elements selected
            this.toPlotPanel = uipanel(this.mainPanel ,'BackgroundColor', backgroundColor, 'Title', rightPanelTitle, 'Units', 'pixel');
            this.toPlotList = uicontrol(this.toPlotPanel, 'Style', 'listbox', 'Min', 0, 'Max', 1024);
            
            %Position and size the elements
            this.setHeight(height);
            
            this.updateItemsListCallback();
            this.updateVariablesListCallback();
            
            itemsListcallbackHandler = @this.updateVariablesListCallback;
            set(this.itemsList, 'Callback', itemsListcallbackHandler);
            addButtonCallbackHandler = @this.addButtonCallback;
            set(this.addButton, 'Callback', addButtonCallbackHandler);
            removeButtonCallbackHandler = @this.removeButtonCallback;
            set(this.removeButton, 'Callback', removeButtonCallbackHandler);
        end
        
        %{
        Function:
        Update the list of available datas.
        
        Arguments:
        this - optional
        source - for callback
        eventDatas - for callback
        
        %}
        function updateItemsListCallback(this, ~, ~)
            switch(this.mode)
                case('DATA')
                    items = this.metaInformations.getDatasList();
                case('EVENT')
                    items = this.metaInformations.getEventsList();
                case('SITUATION')
                    items = this.metaInformations.getSituationsList();
                case('EVENT&SITUATION')
                    items = this.metaInformations.getEventsList();
                    items = [items,this.metaInformations.getSituationsList()];
            end
            itemsNames = cell(1, length(items));
            for i = 1:1:length(items)
                itemsNames{i} = items{i}.getName();
            end
            set(this.itemsList, 'String', sort(itemsNames));
        end
        
        %{
        Function:
        Update the list of available variables without
        the already selected ones.
        
        Arguments:
        this - optional
        source - for callback
        eventDatas - for callback
        
        %}
        function updateVariablesListCallback(this, ~, ~)
            if ~isempty(get(this.itemsList, 'String'))
                selectedItemIndex = get(this.itemsList, 'Value');
                itemsStringList = get(this.itemsList, 'String');
                selectedItem = itemsStringList{selectedItemIndex};
                toPlotVars = get(this.toPlotList , 'UserData');
                if(length(toPlotVars) == 1)
                    toPlotVars = toPlotVars{1};
                end
                switch(this.mode)
                    case('DATA')
                        items = this.metaInformations.getDatasList();
                    case('EVENT')
                        items = this.metaInformations.getEventsList();
                    case('SITUATION')
                        items = this.metaInformations.getSituationsList();
                    case('EVENT&SITUATION')
                        items = this.metaInformations.getEventsList();
                        items = [items,this.metaInformations.getSituationsList()];
                end
                for i = 1:1:length(items)
                    if strcmp(items{i}.getName(), selectedItem)
                        variables = items{i}.getVariables();
                        variablesNames = {};
                        variablesDisplayNames = {};
                        for j = 1:1:length(variables)
                            if ~any(strcmpi([selectedItem '.' variables{j}.getName()], toPlotVars))
                                variablesNames{end + 1} = variables{j}.getName(); %#ok<AGROW>
                                variableUnit = variables{j}.getUnit();
                                if ~isempty(variableUnit)
                                    variablesDisplayNames{end + 1} = [variables{j}.getName() ' [' variableUnit ']']; %#ok<AGROW>
                                else
                                    variablesDisplayNames{end + 1} = variables{j}.getName(); %#ok<AGROW>
                                end
                            end
                        end
                    end
                end
                set(this.variablesList, 'UserData', sort(variablesNames));
                set(this.variablesList, 'String', sort(variablesDisplayNames));
                set(this.variablesList, 'Value', 1);
            end
        end
        
        %{
        Function:
        Move a variable from the available list to the toPlotList.
        
        Arguments:
        this - optional
        source - for callback
        eventDatas - for callback
        
        %}
        function addButtonCallback(this, ~, ~)
            if ~isempty(get(this.itemsList, 'String'))
                selectedDataIndex = get(this.itemsList, 'Value');
                datasStringList = get(this.itemsList, 'String');
                variablesDisplayStringsList = get(this.variablesList, 'String');
                variablesStringsList = get(this.variablesList, 'UserData');
                selectedData = datasStringList{selectedDataIndex};
                
                selectedVarsIndexes = get(this.variablesList, 'Value');
                if ~isempty(variablesDisplayStringsList)
                    
                    if length(selectedVarsIndexes) == 1
                        selectedVarsIndexes = [selectedVarsIndexes];
                    end
                    
                    newEntries = cell(1, length(selectedVarsIndexes));
                    newDisplayEntry = cell(1, length(selectedVarsIndexes));
                    for i = 1:1:length(selectedVarsIndexes)
                        newEntries{i} = [selectedData '.' variablesStringsList{selectedVarsIndexes(i)}];
                        newDisplayEntry{i} = [selectedData '.' variablesDisplayStringsList{selectedVarsIndexes(i)}];
                    end
                    %Update the toPlotList
                    currentPlottingList = get(this.toPlotList, 'UserData');
                    %if(length(currentPlottingList) == 1)
                    %    currentPlottingList = currentPlottingList{1};
                    %end
                    currentDisplayPlottingList =  get(this.toPlotList, 'String');
                    if ~iscell(currentDisplayPlottingList)
                        currentDisplayPlottingList = {currentDisplayPlottingList};
                    end
                    if isempty(currentPlottingList)
                        set(this.toPlotList, 'String',sort(newDisplayEntry));
                        set(this.toPlotList, 'UserData',sort(newEntries));
                    else
                        set(this.toPlotList, 'String', sort([currentDisplayPlottingList(:); newDisplayEntry(:)]));
                        set(this.toPlotList, 'UserData', sort([currentPlottingList(:); newEntries(:)]));
                    end
                    this.updateVariablesListCallback();
                end
                %Execute the optional user callback
                if ~isempty(this.variablesAddedToSelectionCallback) && ~isempty(variablesDisplayStringsList)
                    this.variablesAddedToSelectionCallback(newEntries);
                end
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
        function removeButtonCallback(this, ~, ~)
            currentStringList = get(this.toPlotList, 'UserData');
            if ~iscell(currentStringList)
                currentStringList = {currentStringList};
            end
            currentDisplayStringList = get(this.toPlotList, 'String');
            toRemoveFromPlotListIndexes = get(this.toPlotList, 'Value');
            
            %To be sure to get a cell array
            if length(toRemoveFromPlotListIndexes) == 1
                toRemoveFromPlotListIndexes = [toRemoveFromPlotListIndexes];
            end
            
            %Preallocate the new cell arrays
            newToPlotList = cell(1, length(currentStringList) - length(toRemoveFromPlotListIndexes));
            newToPlotDisplayList =  cell(1, length(currentStringList) - length(toRemoveFromPlotListIndexes));
            %The conditionnal switch is here to manage the empty cell array
            %case, which doesn't work in the list, and has to be replaced
            %by an empty string ... Viva matlab !
            if ~isempty(currentStringList)
                removedEntries = currentStringList(toRemoveFromPlotListIndexes);
            else
                removedEntries = {};
            end
            if ~isempty(newToPlotList)
                newIndex = 1;
                for i = 1:1:length(currentStringList)
                    %If the current index is not in the removal list, we
                    %copy it in the new array.
                    if isempty(find(toRemoveFromPlotListIndexes == i, 1))
                        newToPlotList{newIndex} = currentStringList{i};
                        newToPlotDisplayList{newIndex} = currentDisplayStringList{i};
                        newIndex = newIndex + 1;
                    end
                end
                set(this.toPlotList, 'String', sort(newToPlotDisplayList));
                set(this.toPlotList, 'UserData', sort(newToPlotList));
            else
                set(this.toPlotList, 'String', '');
                set(this.toPlotList, 'UserData', {});
            end
            set(this.toPlotList, 'Value', 1);
            
            %Update the available variable list
            this.updateVariablesListCallback();
            
            %Execute the optional user callback
            if ~isempty(this.variablesRemovedFromSelectionCallback)
                this.variablesRemovedFromSelectionCallback(removedEntries);
            end
        end
        
    end
end

