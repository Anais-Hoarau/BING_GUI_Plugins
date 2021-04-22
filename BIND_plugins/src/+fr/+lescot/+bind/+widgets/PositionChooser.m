%{
Class:

This class allow the cration of a 180x90 pixels widget allowing to choose
between nine pre-created position, from "center", to the 4 cardinal points
and the 4 intermediates.
%}
classdef PositionChooser < handle
    
    properties(Access = private)
        parentHandler  
        %{
        Property:
        The handler to the button group that hosts the radio buttons.
        
        %}
        positionModeGroup;
        %{
        Property:
        The handler on the "center" radio button.
        
        %}
        cButton;
        %{
        Property:
        The handler on the "north" radio button.
        
        %}
        nButton;
        %{
        Property:
        The handler on the "south" radio button.
        
        %}
        sButton;
        %{
        Property:
        The handler on the "west" radio button.
        
        %}
        wButton;
        %{
        Property:
        The handler on the "north-west" radio button.
        
        %}
        nwButton;
        %{
        Property:
        The handler on the "south-west" radio button.
        
        %}
        swButton;
        %{
        Property:
        The handler on the "east" radio button.
        
        %}
        eButton;
        %{
        Property:
        The handler on the "north-east" radio button.
        
        %}
        neButton;
        %{
        Property:
        The handler on the "south-east" radio button.
        
        %}
        seButton;
        
    end
    
    methods
        
        %{
        Function:
        The constructor of the class. Build a new widget and link it in
        the parent component. The selected value is "center" by default.
        Some options can be customized to improve integration. The starred
        (*) arguments have to be passed under the form 'argName',
        argValue.
        
        Arguments:
        parentHandler - The handler of the parent component
        *Position - a 2x1 array of double that gives the position in
        pixels relatively to the parent component. Defaulted to [0 0].
        *BackgroundColor - The color of the background of the widget.
        Defaulted to the color of the parent component.
        *SelectionChangeFcn - The callback handler to execute when the
        selected item changes.
        *Title - The title of the window. Defaulted to "Position"
        
        Returns:
        The figureHandler, thus allowing the use of the handle to modify
        the window or as a parent for other graphical components.
        %}
        function this = PositionChooser(parentHandler, varargin)
            %Add an argument parser for the optional args
            parser = inputParser;
            parser.addRequired('parentHandler');
            parser.addOptional('Position', [0 0]);
            parser.addOptional('BackgroundColor', get(parentHandler, 'Color'));
            parser.addOptional('SelectionChangeFcn', '');
            parser.addOptional('Title', 'Position');
            parser.parse(parentHandler, varargin{:});
            
            this.positionModeGroup = uibuttongroup(parentHandler, 'Units', 'pixels', 'Position', [parser.Results.Position(1) parser.Results.Position(2) 180 90], 'Title', parser.Results.Title, 'BackgroundColor', parser.Results.BackgroundColor, 'SelectionChangeFcn', parser.Results.SelectionChangeFcn);
            %Center column
            this.cButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'Centre', 'Tag', 'center', 'Position', [70 30 60 20], 'BackgroundColor', parser.Results.BackgroundColor);
            this.nButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'N', 'Tag', 'north', 'Position', [70 55 30 20], 'BackgroundColor', parser.Results.BackgroundColor);
            this.sButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'S', 'Tag', 'south', 'Position', [70 5 30 20], 'BackgroundColor', parser.Results.BackgroundColor);
            
            %Left column
            this.wButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'O', 'Tag', 'west', 'Position', [10 30 30 20], 'BackgroundColor', parser.Results.BackgroundColor);
            this.nwButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'NO', 'Tag', 'northwest', 'Position', [10 55 35 20], 'BackgroundColor', parser.Results.BackgroundColor);
            this.swButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'SO', 'Tag', 'southwest', 'Position', [10 5 35 20], 'BackgroundColor', parser.Results.BackgroundColor);
            
            %Right column
            this.eButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'E', 'Tag', 'east', 'Position', [140 30 30 20], 'BackgroundColor', parser.Results.BackgroundColor);
            this.neButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'NE', 'Tag', 'northeast', 'Position', [140 55 35 20], 'BackgroundColor', parser.Results.BackgroundColor);
            this.seButton = uicontrol(this.positionModeGroup, 'Style', 'radio', 'String', 'SE', 'Tag', 'southeast', 'Position', [140 5 35 20], 'BackgroundColor', parser.Results.BackgroundColor);
            
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
            out = get(this.positionModeGroup, 'BackgroundColor');
        end
        
        %{
        Function:
        Setter for the background color of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newBackgroundColor - The new color of the background.
        %}
        function setBackgroundColor(this, newBackgroundColor)
           set(this.positionModeGroup, 'BackgroundColor', newBackgroundColor);
        end
        
        %{
        Function:
        Getter for the selection changement callback of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A function handler
        %}
        function out = getSelectionChangedCallback(this)
            out = get(this.positionModeGroup, 'SelectionChangedCallback');
        end
        
        %{
        Function:
        Setter for the callback of the changement of selection.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newCallback - The callback handler.
        %}
        function setSelectionChangedCallback(this, newCallback)
           set(this.positionModeGroup, 'SelectionChangedCallback', newCallback);
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
            position = get(this.positionModeGroup, 'Position');
            out = position(1:2);
        end
        
        %{
        Function:
        Setter for the new position of the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newPosition - A 2 elements double vector, expressing the new position in pixels.
        %}
        function setPosition(this, newPosition)
           set(this.positionModeGroup, 'Position', [newPosition(1) newPosition(2) 180 90]);
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
            out = get(this.positionModeGroup , 'Title');
        end
        
        %{
        Function:
        Setter for the title of the widget frame.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        newTitle - A string.
        %}
        function setTitle(this, newTitle)
            set(this.positionModeGroup , 'Title', newTitle);
        end
        
        %{
        Function:
        Getter for the selected position on the widget, with a syntax compatible with the "movegui" command.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A string
        %}
        function out = getSelectedPosition(this)
            selectedItem = get(this.positionModeGroup, 'SelectedObject');
            out = get(selectedItem, 'Tag');
        end
        
        %{
        Function:
        Setter for the position selected on the widget.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        position - A string among the following : center, north, south, east, west, northeast, northwest, southeast, southwest.
        %}
        function setSelectedPosition(this, position)
            if strcmp(position, 'center')
                set(this.positionModeGroup, 'SelectedObject', this.cButton);
            end
            if strcmp(position, 'south')
                set(this.positionModeGroup, 'SelectedObject', this.sButton);
            end
            if strcmp(position, 'north')
                set(this.positionModeGroup, 'SelectedObject', this.nButton);
            end
            
            if strcmp(position, 'east')
                set(this.positionModeGroup, 'SelectedObject', this.eButton);
            end
            if strcmp(position, 'northeast')
                set(this.positionModeGroup, 'SelectedObject', this.neButton);
            end
            if strcmp(position, 'southeast')
                set(this.positionModeGroup, 'SelectedObject', this.seButton);
            end
            
            if strcmp(position, 'west')
                set(this.positionModeGroup, 'SelectedObject', this.wButton);
            end
            if strcmp(position, 'northwest')
                set(this.positionModeGroup, 'SelectedObject', this.nwButton);
            end
            if strcmp(position, 'southwest')
                set(this.positionModeGroup, 'SelectedObject', this.swButton);
            end
        end
        
    end
end

