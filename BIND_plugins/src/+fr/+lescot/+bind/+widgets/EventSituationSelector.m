%{
Class:

This widget display a window that allows the selection of a specific event or situation.
It can return a string giving the nature of the selection and its name, formed like 'event.eventName' or 'situation.situationName'.

%}

classdef EventSituationSelector < handle
    
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
        A string describing if the widget is operating on which events or situations.
        String should be formed as 'situation.situationName' or 'event.eventName'.
        %}
        markerIdentifier;
        
        %{
        Property:
        In this widget, items is a placeholder of data or event or situation. So this is the handler
        to the list that displays them (the leftmost list).
        %}
        itemsList;
        
        %{
        Property:
        This is the handler on the main uipanel that contains all the components.
        %}
        mainPanel;
        
        %{
        Property:
        This is the handler on the radio button group.
        %}
        modeSelectionGroup
        
        %{
        Property:
        This is the handler on the radio button used for event selection.
        %}
        eventRadioButton
        
        %{
        Property:
        This is the handler on the radio button used for situation selection.
        %}
        situationRadioButton
        
    end
    
    
    methods
        
        %{
        Function:
        This function is called to retrieve the current value of the selection of the widget.
        
        Returns :
        out - A string formed like 'event.eventName' or 'situation.situationName'
        %}
        function out = getSelectedIdentifier(this)
            selectedIndice = get(this.itemsList,'Value');
            if selectedIndice == 0
                out = '';
            else
                items = get(this.itemsList,'String');
                
                splittedDataName = regexp(this.markerIdentifier, '\.', 'split');
                mode = splittedDataName{1};
                
                out = [mode '.' items{selectedIndice}];
            end
        end
        
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
        markerIdentifier - A string containing "event" or "situation". Indicates on which type of items the
        widget will operate.
        *Position - a 2x1 array of double that gives the position in
        pixels relatively to the parent component. Defaulted to [0 0].
        *BackgroundColor - The color of the background of the widget.
        Defaulted to the color of the parent component.
        *Height - The desired height of the widget in pixels. Defaulted to 360 px.
        Returns:
        The figureHandler, thus allowing the use of the handle to modify
        the window or as a parent for other graphical components.
        %}
        function this = EventSituationSelector(parentHandler, metaInformations, markerIdentifier, varargin)
            %Add an argument parser for the optional args
            parser = inputParser;
            parser.addRequired('parentHandler');
            parser.addRequired('metaInformations');
            parser.addRequired('markerIdentifier');%Todo : add auto validator
            parser.addOptional('Position', [0 0]);
            parser.addOptional('BackgroundColor', get(parentHandler, 'Color'));
            parser.addOptional('Height', 200);
            parser.parse(parentHandler, metaInformations, markerIdentifier, varargin{:});
            
            this.parentHandler = parser.Results.parentHandler;
            this.metaInformations = parser.Results.metaInformations;
            this.markerIdentifier = parser.Results.markerIdentifier;
            
            %Once all the parameters are here, let's build the widget
            this.buildWidget(parser.Results.Position,...
                parser.Results.BackgroundColor, ...
                parser.Results.Height...
                );
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
        height - the original height of the widget, in pixels.
        %}
        function buildWidget(this, position, backgroundColor, height)
            
            this.mainPanel = uipanel(this.parentHandler, 'Title', 'Select your situation / event', 'BackgroundColor', backgroundColor,'Units', 'pixel', 'Position', [position(1) position(2) 300 height]);
            
            modeChangeCallbackHandle = @this.modeSelectionChange_CallbackHandle;
            this.modeSelectionGroup = uibuttongroup(this.mainPanel(), 'Units', 'pixels', 'Position', [10 height-50 140 35],'BackgroundColor', backgroundColor,'Title', 'Marker type','BorderType', 'none', 'SelectionChangeFcn', modeChangeCallbackHandle);
            %radio bouton
            this.eventRadioButton = uicontrol(this.modeSelectionGroup, 'Style', 'radio', 'BackgroundColor', backgroundColor, 'String', 'Event', 'Tag', 'Events', 'Position', [10 0 60 20]);
            this.situationRadioButton = uicontrol(this.modeSelectionGroup, 'Style', 'radio', 'BackgroundColor', backgroundColor, 'String', 'Situation', 'Tag', 'Situations', 'Position', [70 0 60 20]);
            
            this.itemsList = uicontrol(this.mainPanel, 'Style', 'listbox', 'Position', [10 5 280 height-70],'Min', 0, 'Max', 0);
            set(this.itemsList,'BackgroundColor','White');
            this.refreshUI()
            
        end

        %{
        Function:
        Callback activated when user click on the radio boxes, thus changing the type to display in the list
        %}
        function modeSelectionChange_CallbackHandle(this,source,eventdata)
            selectedItem = get(this.modeSelectionGroup, 'SelectedObject');
            modeTag = get(selectedItem, 'Tag');
            switch modeTag
                case 'Situations'
                    this.markerIdentifier = 'situation.';
                case 'Events'
                    this.markerIdentifier = 'event.';
            end
            
            this.refreshUI();
        end

        %{
        Function:
        Fill in the widget list with the adequate value and set the selection indice in the list
        %}
        function refreshUI(this)
            splittedDataName = regexp(this.markerIdentifier, '\.', 'split');
            mode = splittedDataName{1};
            itemName = splittedDataName{2};
            
            % refresh radio buttons and get data
            switch mode
                case 'event'
                    set(this.modeSelectionGroup, 'SelectedObject', this.eventRadioButton);
                    itemsNames = this.metaInformations.getEventsNamesList();
                case 'situation'
                    set(this.modeSelectionGroup, 'SelectedObject', this.situationRadioButton);
                    itemsNames = this.metaInformations.getSituationsNamesList();
            end
            
            %refresh item list
            set(this.itemsList, 'String', itemsNames);
            if isempty(itemsNames)
                set(this.itemsList, 'Value',0);
            else
                itemFound = false;
                for i=1:length(itemsNames)
                    if strcmp(itemsNames{i},itemName)
                        set(this.itemsList,'Value',i);
                        itemFound = true;
                    end
                    if ~itemFound
                        set(this.itemsList,'Value',1);
                    end
                end
            end
        end
    end
end



