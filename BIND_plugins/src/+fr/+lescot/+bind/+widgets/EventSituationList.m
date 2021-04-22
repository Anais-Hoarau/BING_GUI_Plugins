%{
Class:

 This class allow the creation of a widget presenting a list of markers :
 events or situations. The widget must be invoked with a markerIdentifier
 formed as a string 'situation.SituationName' or 'event.eventName'.
 
 WARNING : This widget is not capable of refreshing automatically, however, it has an 'update' method
 that must be explicitely called in the update method of the plugin that instanciate the widget.

 The size of the plugins can be defined, but the width must be > 350
 pixels.

%}
classdef EventSituationList < handle
    
    properties(Access = private)
        parentHandler
        %{
        Property:
        The handler to the panel that hosts the uitable and the control buttons.
        
        %}
        EventSituationListPanel;
        
        %{
        Property:
        Name of the situation or event that is currently displayed by the widget
        %}
        markerName
        
        %{
        Property:
        Type displayed by the widget. Can be 'event' or 'situation'
        %}
        markerType
        
        %{
        Property:
        Cell Array containing the data extracted from the marker table in the trip.
        
        %}
        markerDatas
        
        %{
        Property:
        Handler on the uitable used for marker selection
        
        %}
        tableHandler
        
        %{
        Property:
        Cell Array of string containing the names of the variables
        
        %}
        variablesName
        
        %{
        Property:
        Handler on the current Trip
        
        %}
        theTrip
        
        %{
        Property:
        Value of the current page of marker to display
        
        %}
        currentPage
        
        %{
        Property:
        General setting to define the number of markers to display per
        page
        
        %}
        markersOnPage
        
        %{
        Property:
        Value of the maximum number of pages that can be displayed
        
        %}
        maxAvailablePages
        
        %{
        Property:
        Value of the number of markers that are available in the trip
        
        %}
        markerNumber
        
        %{
        Property:
        Value of the number of markers that are available in the trip
        
        %}
        statusLabel
        
        %{
        Property:
        Handler on the button that bring to the first page
        
        %}
        firstButton
        
        %{
        Property:
        Handler on the button that bring to the previous page
        
        %}
        previousButton
        
        %{
        Property:
        Handler on the button that bring to the next page
        
        %}
        nextButton
        
        %{
        Property:
        Handler on the button that bring to the last page
        
        %}
        lastButton
        
        %{
        Property:
        Size of the uitable that display the event/situations occurences
        
        %}
        tableSize
        
        %{
        Property:
        Cell array containing the different filters. Filters are cells of {variableName,mode,value}
        where mode can be "equal" or "different"
        
        %}
        filterList
        
        %{
        Property:
        Cell array containing the different translater. Filters are cells of {variableName,valueToReplace,targetValue}
        
        %}
        translaterList
        
        %{
        Property:
        value of the line that is currently selected on the uitable of the widget
        
        %}        
        selectedUITableLine
        
        availableMetaInfos
    end
    
    methods(Access = public)
        
        %{
        Function:
        The constructor of the class. Build a new widget and link it in
        the parent component. The selected value is "center" by default.
        Some options can be customized to improve integration. The starred
        (*) arguments have to be passed under the form 'argName',
        argValue.
        
        Arguments:
        parentHandler - The handler of the parent component
         trip - The trip containing the data to display
         markerIdentifier - The situation/event identifier
        *Position - a 2x1 array of double that gives the position in
        pixels relatively to the parent component. Defaulted to [0 0].
        *Size - a 2x1 array of double that gives the size in pixel, heigth and width. Defaulted to [0 0].
        *BackgroundColor - The color of the background of the widget.
        Defaulted to the color of the parent component.
        *SelectionChangeFcn - The callback handler to execute when the
        selected item changes.
        *Title - The title of the window. Defaulted to "Position"
        *Filters - a cell array of filter descriptions :  {variableName, mode, value} with variableName - A string of a variable that exists in the marker, mode - the string 'equal' or 'different'. If mode is 'equal', only the marker occurence whose variable match the value parameter are loaded in the markerData buffer. If the mode is 'different', only the marker occurences whose variable are different from the value parameter are loaded in the markerData buffer... and value - a string
        *Translaters - a cell array of translaters descriptions : {variableName,valueToReplace, targetValue) with variableName - A string of a variable that exists in the marker, valueToReplace - the string that is in the data and that must be converted and targetValue - the string that will be displayed instead
        
        Returns:
        The figureHandler, thus allowing the use of the handle to modify
        the window or as a parent for other graphical components.
        %}
        function this = EventSituationList(parentHandler,  trip, markerIdentifier, varargin)
            %Add an argument parser for the optional args
            parser = inputParser;
            parser.addRequired('parentHandler');
            parser.addRequired('trip');
            parser.addRequired('markerIdentifier');
            parser.addOptional('Position', [0 0]);
            parser.addOptional('Size', [350 350])
            parser.addOptional('BackgroundColor', get(parentHandler, 'Color'));
            parser.addOptional('Filters', {});
            parser.addOptional('Translaters', {});
            % parse with basis input data...
            parser.parse(parentHandler,trip,markerIdentifier, varargin{:});
            
            this.theTrip = trip;
            this.availableMetaInfos = this.theTrip.getMetaInformations();
            
            % configuration of the UI
            
            this.connectMarkerIdentifier(markerIdentifier);
            
            if parser.Results.Size(1)>= 350
                dimension = [parser.Results.Position(1) parser.Results.Position(2) parser.Results.Size(1) parser.Results.Size(2)];
            else
                dimension = [parser.Results.Position(1) parser.Results.Position(2) 350 parser.Results.Size(2)];
            end
            
            % create the primary panel
            this.EventSituationListPanel = uipanel(parentHandler, 'Units', 'pixels', 'Position', dimension, 'BackgroundColor', parser.Results.BackgroundColor);
            
            % add all components inside the panel
            this.buildUI(parser.Results.BackgroundColor);
            this.setSize(dimension(3:4));
                        
            % display correct title on the panel
            this.setTitle(['Showing ' this.markerType 's : ' this.markerName]);
            
            % load filters before loading data
            this.filterList = parser.Results.Filters;
            
            % initiate ton blank the translaters at widget creation
            this.translaterList = {};
            
            
            % load UI with correct data
            this.currentPage = 0;
            this.refreshWidgetView();
        end
        
        %{
        Function:
        
        This method is required if the widget needs to refresh when trip evolve.
        It must be explicitely called from the figure using the widget.
        %}
        function update(this, message)
            if any(strcmp(message.getCurrentMessage(),{'EVENT_ADDED' 'EVENT_REMOVED' 'EVENT_VARIABLE_ADDED''EVENT_VARIABLE_REMOVED''EVENT_CONTENT_CHANGED''SITUATION_ADDED''SITUATION_REMOVED''SITUATION_VARIABLE_ADDED''SITUATION_VARIABLE_REMOVED''SITUATION_CONTENT_CHANGED'}))
                this.availableMetaInfos = this.theTrip.getMetaInformations();
            end
            
            if any(strcmp(message.getCurrentMessage(),{'EVENT_CONTENT_CHANGED' 'SITUATION_CONTENT_CHANGED'}))
                % refreshMarkerData, selectRelevantPage, refreshMarkerList
                this.refreshWidgetView();
            end
            if any(strcmp(message.getCurrentMessage(),{'STEP' 'GOTO' }))
                % for performance, no refresh of markerData at each step,
                % and refresh list only when page change
                oldPage = this.currentPage;
                this.selectCurrentPage();
                newPage = this.currentPage;
                if oldPage~=newPage
                    this.refreshMarkerList();
                end
            end
        end
        
        %{
        Function:
        Getter for the background color of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        The background color
        %}
        function out = getBackgroundColor(this)
            out = get(this.EventSituationListPanel, 'BackgroundColor');
        end
        
        %{
        Function:
        Setter for the background color of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newBackgroundColor - The new color of the background.
        %}
        function setBackgroundColor(this, newBackgroundColor)
            set(this.EventSituationListPanel, 'BackgroundColor', newBackgroundColor);
        end
        
        function setMarkerIdentifier(this,newMarkerIdentifier)
            if this.connectMarkerIdentifier(newMarkerIdentifier);
                this.refreshWidgetView();
                % display correct title on the panel
                this.setTitle(['Showing ' this.markerType 's : ' this.markerName]);
            else
                msgbox('Wrong marker type or wrong marker name');
            end
        end
        
        function out = getMarkerIdentifier(this)
            out =   [ this.markerType '.' this.markerName ];
        end
        
        %{
        Function:
        Getter for the position of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A 2x1 double array
        %}
        function out = getPosition(this)
            position = get(this.EventSituationListPanel, 'Position');
            out = position(1:2);
        end
        
        %{
        Function:
        Getter for the size of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A 2x1 double array
        %}
        function out = getSize(this)
            size = get(this.EventSituationListPanel, 'Position');
            out = size(3:4);
        end
        
        %{
        Function:
        Setter for the new position of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newPosition - A 2 elements double vector, expressing the new position in pixels.
        %}
        function setPosition(this, newPosition)
            set(this.EventSituationListPanel, 'Position', [newPosition(1) newPosition(2) this.getSize()]);
        end
        
        %{
        Function:
        Setter for the new size of the widget. Modify the size of the panel, and of the subsequent components
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newSize - A 2 elements double vector, expressing the new size in pixels [width heigth].
        %}
        function setSize(this, newSize)
            targetWidth = max(350,newSize(1));
            targetHeigth = max(38+65,newSize(2));
            set(this.EventSituationListPanel, 'Position', [this.getPosition() targetWidth targetHeigth]);
            size = this.getSize();
            this.tableSize = [size(1)-15 size(2)-65];
            set(this.tableHandler , 'Position', [5 45 this.tableSize]);
            middlePosition = size(1) / 2;
            set(this.statusLabel, 'Position', [middlePosition-60 10 150 20]);
            set(this.firstButton , 'Position', [middlePosition-145 10 40 30]);
            set(this.previousButton , 'Position', [middlePosition-105 10 40 30]);
            set(this.nextButton , 'Position', [middlePosition+80 10 40 30]);
            set(this.lastButton , 'Position', [middlePosition+120 10 40 30]);
            
            set(this.tableHandler, 'FontUnits', 'pixels');
            tableLineHeigth = get(this.tableHandler, 'FontSize') * 2;
            possibleNumberOfLinesInTable = floor(targetHeigth/tableLineHeigth);
            this.markersOnPage = possibleNumberOfLinesInTable;
            % when all components have the good position, refresh is
            % possible
            this.refreshWidgetView();
        end
        
        %{
        Function:
        Getter for the title of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A string
        %}
        function out = getTitle(this)
            out = get(this.EventSituationListPanel , 'Title');
        end
        
        %{
        Function:
        Setter for the title of the widget frame.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newTitle - A string.
        %}
        function setTitle(this, newTitle)
            set(this.EventSituationListPanel , 'Title', newTitle);
        end
        
        %{
        Function:
        This function add a filter that can custom the data list view.
        It tests if the parameteres have correct values (especially variablename and mode)
        The title of the widget is modified with the name of the filter
        
        Arguments:
        this - The object on which the function is called, optionnal.
        variableName - A string of a variable that exists in the marker
        mode - the string 'equal' or 'different'. If mode is 'equal', only the marker occurence whose variable match the value parameter are loaded in the markerData buffer.
        If the mode is 'different', only the marker occurences whose variable are different from the value parameter are loaded in the markerData buffer.
        value - a string
        
        Return:
        filterId - the id of the added filter
        
        Throws:
        xxxxxx - Exception thrown when the parameters are not correct
        %}
        function filterId = addFilter(this,variableName,mode,value)
            variableNameIsValid = 0;
            for i = 1:length(this.variablesName)
                if strcmp(variableName,this.variablesName{i})
                    variableNameIsValid = 1;
                end
            end
            
            modeIsValid = 0;
            if ( strcmp(mode,'equal') || strcmp(mode,'different') )
                modeIsValid = 1;
            end
            
            if modeIsValid && variableNameIsValid
                % on ajoute le filtre
                this.filterList = {this.filterList{:} {variableName,mode,value} };
            else
                % TODO : exception
                msgbox('wrong filter');
                return;
            end
            
            % refresh view
            this.setTitle(['Showing ' this.markerType 's : ' this.markerName ' (filtered)']);
            this.refreshWidgetView();
            filterId = length(this.filterList);
        end
        
        %{
        Function:
        This function remove a filter that can custom the data list view.
        It tests if the parameteres have correct values
        The title of the widget is modified
        
        Arguments:
        this - The object on which the function is called, optionnal.
        filterId - the id of the filter to delete. If 0 is used, remove all filter at once.
     
        Throw:
        ME - wrong filterId
        %}
        function deleteFilter(this,filterId)
            if filterId == 0
                this.filterList = {};
            else
                this.filterList(filterId) = [];
            end
            % refresh view
            if isempty(this.filterList)
                % display correct title on the panel
                this.setTitle(['Showing ' this.markerType ' : ' this.markerName]);
            end
            this.refreshWidgetView();
        end
        
        %{
        Function:
        This function add a translater that can custom the data list view by replacing a specific variable value by another one : i.e. a translation
        It tests if the parameteres have correct values (especially variablename )
        
        Arguments:
        this - The object on which the function is called, optionnal.
        variableName - A string of a variable that exists in the marker
        valueToReplace - the string that is in the data and that must be converted
        targetValue - the string that will be displayed instead
        
        Return:
        translaterId - the id of the added converter
        
        Throws:
        xxxxxx - Exception thrown when the parameters are not correct
        %}
        function translaterId = addTranslater(this,variableName,valueToReplace,targetValue)
            variableNameIsValid = 0;
            for i = 1:length(this.variablesName)
                if strcmp(variableName,this.variablesName{i})
                    variableNameIsValid = 1;
                end
            end
            if variableNameIsValid
                % we can add the converter
                this.translaterList = {this.translaterList{:} {variableName,valueToReplace,targetValue} };
            else
                % TODO : exception
                msgbox('wrong translater');
                return;
            end
            
            % refresh view
            this.refreshWidgetView();
            translaterId = length(this.translaterList);
        end
        
        %{
        Function:
        This function delete a translater that can custom the data list view.
        It tests if the parameteres have correct values
        Arguments:
        this - The object on which the function is called, optionnal.
        translaterId - the id of the translater to delete. If 0 is used, remove all translater at once.
     
        Throw:
        ME - wrong translaterId
        %}
        function deleteTranslater(this,translaterId)
            if translaterId == 0
                this.translaterList = {};
            else
                this.translaterList(translaterId) = [];
            end
            % refresh view
            this.refreshWidgetView();
        end
    end
    
    methods (Access = private)
        %{
        Function:
        This function connect the widget to a new situation or event table
        
        Arguments:
        this - The object on which the function is called, optionnal.
        markerIdentifier - A string form as 'event.eventName' or 'situation.situationName'
        %}
        function connectMarkerIdentifier(this,markerIdentifier)
            % check if markerIdentifier is of the correct form
            if strmatch('situation.',char(markerIdentifier))
                marker = 'situation';
            else
                if strmatch('event.',char(markerIdentifier))
                    marker = 'event';
                end
            end
            
            availableInfos = this.theTrip.getMetaInformations();
            
            switch marker
                case ('situation')
                    markerNamesList = availableInfos.getSituationsNamesList();
                case ('event')
                    markerNamesList = availableInfos.getEventsNamesList();
            end
            
            for i=1:length(markerNamesList)
                markerId = [ marker '.' char(markerNamesList(i))];
                if strcmp(markerId,markerIdentifier);
                    this.markerName = char(markerNamesList(i));
                    this.markerType = marker;
                end
            end
        end
        
        %{
        Function:
        This function build the widget user interface
        
        Arguments:
        this - The object on which the function is called, optionnal.
        backgroundColor - A color.
        %}
        function buildUI(this,backgroundColor)
            
            % buildMarkerList
            this.tableHandler = uitable('Parent',this.EventSituationListPanel);
            size = this.getSize();
            this.tableSize = [size(1)-15 size(2)-65];
            set(this.tableHandler , 'Position', [5 45 this.tableSize]);
            callbackHandler = @this.availableMarkers_CellSelectionCallback;
            set(this.tableHandler, 'CellSelectionCallback', callbackHandler);
            
            callbackHandler = @this.markerList_KeyPressFcnCallback;
            set(this.tableHandler, 'KeyPressFcn', callbackHandler);

            set(this.tableHandler, 'BackgroundColor',[0.95 0.95 0.95]);
            
            % buildMarkerControls
            middlePosition = size(1) / 2;
            this.statusLabel = uicontrol(this.EventSituationListPanel, 'Style', 'text', 'String', 'xx to xx of xx', 'Position', [middlePosition-60 10 150 20]);
            set(this.statusLabel, 'BackgroundColor',backgroundColor);
            
            this.firstButton = uicontrol(this.EventSituationListPanel, 'Style', 'pushbutton', 'String', '<<', 'Position', [middlePosition-145 10 40 30]);
            callbackHandler = @this.markerButtonsCallback;
            set(this.firstButton, 'Callback', callbackHandler);
            
            this.previousButton = uicontrol(this.EventSituationListPanel, 'Style', 'pushbutton', 'String', '<', 'Position', [middlePosition-105 10 40 30]);
            callbackHandler = @this.markerButtonsCallback;
            set(this.previousButton, 'Callback', callbackHandler);
            
            
            this.nextButton = uicontrol(this.EventSituationListPanel, 'Style', 'pushbutton', 'String', '>', 'Position', [middlePosition+80 10 40 30]);
            callbackHandler = @this.markerButtonsCallback;
            set(this.nextButton, 'Callback', callbackHandler);
            
            this.lastButton = uicontrol(this.EventSituationListPanel, 'Style', 'pushbutton', 'String', '>>', 'Position', [middlePosition+120 10 40 30]);
            callbackHandler = @this.markerButtonsCallback;
            set(this.lastButton, 'Callback', callbackHandler);
        end
        
        %{
        Function:
        This function is the callback that catch button press on the uitable
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - handler on the components from which the call back comes
        eventdata - associated data on the callback, i.e. name of key pressed
        %}
        function markerList_KeyPressFcnCallback(this,source, eventdata)
            markerTotalNumber = size(this.markerDatas,1);
            firstMarkerOnTable = (this.currentPage * this.markersOnPage) + 1;
            lastMarkerOnTable = firstMarkerOnTable + this.markersOnPage;
            
            mustMove = false;
            
            if this.selectedUITableLine ~= 0
                if strcmp(eventdata.Key,'uparrow') && this.selectedUITableLine == 1
                    %when user press up arrow on the uitable, he migth want to go to previous page
                    % if he is at the top
                    % what is the previous marker? it can't be 0!
                    targetMarker = max(1,firstMarkerOnTable-1);
                    if targetMarker ~= 1
                        mustMove = true;
                    end
                end
                if strcmp(eventdata.Key,'downarrow') && this.selectedUITableLine == this.markersOnPage
                    %when user press down arrow on the uitable, he migth want to go to next page
                    % if he is at the bottom
                    % what is the next marker? it can't be more than the total marker number!
                    targetMarker = min(markerTotalNumber,lastMarkerOnTable+1);
                    if targetMarker ~= markerTotalNumber
                        mustMove = true;
                    end
                end
                
                if mustMove
                    timecodes = this.markerDatas(:,1); % 1st columen is for timecode
                    timecodeDestination = timecodes{targetMarker};
                    this.theTrip.getTimer().stopTimer();
                    pause(0.02);
                    this.theTrip.getTimer().setTime(timecodeDestination);
                    this.selectedUITableLine = 0;
                end
            end
        end
        
        %{
        Function:
        This function is the general callback for all widget buttons
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function markerButtonsCallback(this,source, eventdata)
            switch source
                case this.previousButton
                    if (this.currentPage - 1 >= 0)
                        this.currentPage = this.currentPage - 1;
                        this.refreshMarkerList();
                    end
                case this.firstButton
                    this.currentPage = 0;
                    this.refreshMarkerList();
                    
                case this.nextButton
                    if (this.currentPage +1 < this.maxAvailablePages )
                        this.currentPage = this.currentPage + 1;
                        this.refreshMarkerList();
                    end
                case this.lastButton
                    this.currentPage = this.maxAvailablePages - 1;
                    this.refreshMarkerList();
            end
        end
        
        %{
        Function:
        This function refresh the widget view, performing data refresh,
        current page identification, refreshMarkerList
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function refreshWidgetView(this)
            % update widget properties with trip data
            this.refreshMarkerData();
            
            % find out the relevant page to display according to current
            % timecode
            
            this.selectCurrentPage();
            
            % update the widget view with widget properties
            this.refreshMarkerList();
        end
        
        
        %{
        Function:
        Extract from the all the markers in the markerData buffer the ones that can be
        displayed in the current table.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function refreshMarkerList(this)
            % set lines
            nbMarkerOnPage = this.markersOnPage;
            nbLignesTotal = size(this.markerDatas,1);
            firstMarker = (this.currentPage * nbMarkerOnPage) + 1;
            lastMarker = firstMarker + nbMarkerOnPage - 1;
            lastMarker = min(lastMarker,nbLignesTotal);
            if ~isempty(this.markerDatas)
                nbColonnes = size(this.markerDatas(1,:),2);
            else
                nbColonnes = 0;
            end
            nbMarkerToDisplay = max(1,lastMarker-firstMarker+1);
            
            % TODO : gestion du problème de comptage des pages lors du
            % redimensionnement du widget
            if firstMarker <= lastMarker
            
                tableData = cell(nbMarkerToDisplay,nbColonnes+1);
                % for all the possible markers on the page
                a = this.markerDatas;
                tableData(1:nbMarkerToDisplay,1) = num2cell(firstMarker:lastMarker);
                tableData(1:nbMarkerToDisplay,2:nbColonnes+1) = a(firstMarker:lastMarker,:);

                width = this.tableSize(1);
                columnsWidth = {25 50}; % Id and timecode have fixed size
                columnWidth = (width-75) / (nbColonnes-1);
                columnMinSize = 50; % other column are never below 50
                if columnWidth < columnMinSize
                    columnWidth = columnMinSize;
                end
                for i=1:nbColonnes-1
                    columnsWidth = {columnsWidth{:} columnWidth-2};
                end

                set(this.tableHandler, 'ColumnName', {'#' this.variablesName{:} });
                set(this.tableHandler, 'RowName', []);
                set(this.tableHandler, 'ColumnWidth', columnsWidth);         
            end
                
            % if data exist for this marker
            if exist('tableData','var')
                set(this.tableHandler, 'Data', tableData);
                markerIDs = tableData(:,1);
                N = length(markerIDs);
                firstMarkerOnScreen = tableData{1,1};
                lastMarkerOnScreen = firstMarkerOnScreen + N - 1;
                status = [ num2str(firstMarkerOnScreen) '   to   ' num2str(lastMarkerOnScreen) '        of ' num2str(this.markerNumber) ];
                set(this.statusLabel,'String',status);
            else
                % display blank table
                set(this.tableHandler, 'Data', {});
                set(this.statusLabel,'String','No markers');
            end
            this.setButtonStatus();
        end
        
        %{
        Function:
        Called when user click in the marker table. Move the trip timer to
        the timecode of the marker.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        src - the source from where the callback was triggered
        eventdata - additional parameters
        %}
        function availableMarkers_CellSelectionCallback(this, source, eventdata)
            if numel(eventdata.Indices)~=0
                % get the information on the selected line of the uitable
                rowSelected = eventdata.Indices(1);
                this.selectedUITableLine = rowSelected;
                dataMatrix = get(source, 'Data');
                marker = dataMatrix(rowSelected,:);
                timecodeDestination = marker{2}; %str2num(marker{2}); % 1 is for marker ID, so timecode is in column 2
                this.theTrip.getTimer().stopTimer();
                pause(0.02);
                this.theTrip.getTimer().setTime(timecodeDestination);
            end
        end
        
        %{
        Function:
        this function enable or disable the different buttons according to
        the page of the marker list that is displayed
        
        Arguments:
        This - optionnal, the object on which the method is called
        %}
        function setButtonStatus(this)
            if (this.currentPage == 0)
                set(this.firstButton,'Enable','off');
                set(this.previousButton,'Enable','off');
            else
                set(this.firstButton,'Enable','on');
                set(this.previousButton,'Enable','on');
            end
            
            if (this.currentPage == this.maxAvailablePages - 1)
                set(this.nextButton,'Enable','off');
                set(this.lastButton,'Enable','off');
            else
                set(this.nextButton,'Enable','on');
                set(this.lastButton,'Enable','on');
            end
        end
        
        
        %{
        Function:
        this method watch the current trip timer and according to its
        value, it select from the markers the page that contains the
        occurence which timecode is the closest to the trip current
        timecode
        
        Arguments:
        this - optionnal, the object on which the method is called
        %}
        function selectCurrentPage(this)
            timecode = this.theTrip.getTimer().getTime();
            nbMarkerOnPage = this.markersOnPage;
            nbLignesTotal = this.markerNumber;
            
            for i = 0:(this.maxAvailablePages-1)
                firstMarker = (i * nbMarkerOnPage) + 1;
                lastMarker = firstMarker + nbMarkerOnPage - 1;
                lastMarker = min(lastMarker,nbLignesTotal);
                %   markerDatas(1) always contains event timecode or start
                %   timecode for situations
                timeCodeFirstMarker = this.markerDatas{firstMarker,1}; % cell2mat(this.markerDatas{1}(firstMarker));
                timeCodeLastMarker = this.markerDatas{lastMarker,1}; %cell2mat(this.markerDatas{1}(lastMarker));
                % need sprintf to fix comparison between doubles
                timecode = str2num(sprintf('%.12f',timecode));
                timeCodeFirstMarker = str2num(sprintf('%.12f',timeCodeFirstMarker));
                timeCodeLastMarker =  str2num(sprintf('%.12f',timeCodeLastMarker));
                if (timecode >= timeCodeFirstMarker && timecode < timeCodeLastMarker)
                    this.currentPage = i;
                    return;
                else
                    if (i == this.maxAvailablePages-1 && timecode > timeCodeLastMarker )
                        % si on est a la derniere page et que le timecode
                        % est quand meme supérieur, on rafiche une de moins
                        this.currentPage = i;
                        return;
                    end
                end
            end
            
        end
        
        %{
        Function:
        Connect to the trip metaInformations and trip data and refill the
        buffer that contain the marker data
        Load the markers occurence of the trip by taking into account the filters
        
        Arguments:
        this - optionnal, the object on which the method is called
        %}
        function refreshMarkerData(this)
            
            availableInfos = this.availableMetaInfos;
                         
            this.variablesName = {};
            
            switch this.markerType
                case ('situation')
                    variablesNames =  availableInfos.getSituationVariablesNamesList(this.markerName);
                    this.variablesName{1} = 'startTimecode';
                    this.variablesName{2} = 'EndTimecode';
                    indexvariablesName = 3;
                case('event')
                    variablesNames =  availableInfos.getEventVariablesNamesList(this.markerName);
                    this.variablesName{1} = 'timecode';
                    indexvariablesName = 2;
            end
            
            for k = 1:length(variablesNames)
                if ~strcmpi(variablesNames{k},'startTimecode') && ~strcmpi(variablesNames{k},'endTimecode') && ~strcmpi(variablesNames{k},'timecode')
                    this.variablesName{indexvariablesName} = variablesNames{k};
                    indexvariablesName = indexvariablesName+1;
                end
            end
            
            switch this.markerType
                case('situation')
                    record = this.theTrip.getAllSituationOccurences(this.markerName);
                case('event')
                    record = this.theTrip.getAllEventOccurences(this.markerName);
            end
            
            
            % first blank variable, then reload
            this.markerDatas = {};
            
            lines = length(record.getVariableValues(this.variablesName{1}));
            columns = k;
            
            datasCell = cell(lines,columns);
            for k=1:length(this.variablesName)
                datas = record.getVariableValues(this.variablesName{k}); 
                if ~isempty(datas)
                    datasCell(:,k) = datas;
                end
            end
            this.markerDatas = datasCell;
            
            % Apply filters : select all indices that validate all filters
            % and at the end, select the subset of this.markerDatas with
            % these indices
            filterNumber = length(this.filterList);
            
            if filterNumber~=0
                indicesToKeep = [];
                occurenceNumber = lines; %length(this.markerDatas{:,1});
                % we run each filter on all data occurences
                for k = 1:filterNumber
                    theFilter = this.filterList{k};
                    variableName = theFilter{1};
                    mode = theFilter{2};
                    value = theFilter{3};
                    for i=1:length(this.variablesName)
                        if strcmp(this.variablesName{i},variableName)
                            columnToFilter = i;
                        end
                    end
                    
                    switch mode
                        case 'equal'
                            for i=1:occurenceNumber
                                if strcmp(num2str(this.markerDatas{i,columnToFilter}),value)
                                    indicesToKeep = union(indicesToKeep,i);
                                end
                            end
                        case 'different'
                            for i=1:occurenceNumber
                                if ~strcmp(num2str(this.markerDatas{i,columnToFilter}),value)
                                    indicesToKeep = union(indicesToKeep,i);
                                end
                            end
                    end
                end
                
                % when all filters are applied, get adequate data
                indicesToKeep = sort(indicesToKeep);
                markersToKeep = this.markerDatas(indicesToKeep,:);
                this.markerDatas = markersToKeep;
                %for i=1:length(this.variablesName)
                %                    this.markerDatas{i} = this.markerDatas{i}(indicesToKeep);
                %end
            end
            
            % Apply translaters : find out all items that must be
            % translated
            translaterNumber = length(this.translaterList);
            
            
            if translaterNumber ~=0
                
                indicesToTranslate = [];
                if ~isempty(this.markerDatas)
                    occurenceNumber = size(this.markerDatas,1);
                else
                    occurenceNumber = 0;
                end
                for k = 1:translaterNumber
                    theTranslater = this.translaterList{k};
                    variableName = theTranslater{1};
                    valueToReplace = theTranslater{2};
                    targetValue = theTranslater{3};
                    for i=1:length(this.variablesName)
                        if strcmp(this.variablesName{i},variableName)
                            columnToTranslate = i;
                        end
                    end
                    
                    % find out occurences to translate, and translate
                    % markerData immediatly
                    for i=1:occurenceNumber
                        if strcmp(num2str(this.markerDatas{i,columnToTranslate}),valueToReplace)
                            this.markerDatas{i,columnToTranslate} = targetValue;
                        end
                    end
                end
            end
            
            % refresh properties, like page number...
            occurenceNumber = size(this.markerDatas,1);
            this.markerNumber = occurenceNumber;
            remaining = rem(occurenceNumber,this.markersOnPage);
            nombreDivisible = (occurenceNumber - remaining);
            this.maxAvailablePages = nombreDivisible /  this.markersOnPage ;
            if remaining ~= 0
                this.maxAvailablePages = this.maxAvailablePages + 1;
            end
        end
        
    end
    
end

