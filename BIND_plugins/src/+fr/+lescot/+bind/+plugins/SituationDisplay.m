%{
Class:
This class creates a plugin used to graphically display some situations variables.
%}
classdef SituationDisplay < fr.lescot.bind.plugins.VisualisationPlugin
    
    properties (Access = private)
        %{
        Property:
        The handler to the main plotting area.
        %}
        axesHandler;
        
        %{
        Property:
        The handler to the legend plotting area.
        %}
        legendAxesHandler;

        %{
        Property:
        The handler to the stem used as cursor.
        %}
        stemHandler;
        
        %{
        Property:
        Used to store the current min time for the plugin.
        %}
        currentMinTime;
        %{
        Property:
        Used to store the current max time for the plugin.
        %}
        currentMaxTime;
  
        %{
        Property:
        Stores the max value for the x scale of the axes.
        %}
        xMax;
        
        %{
        Property:
        A cell array of String containing the list of situations names. Their may be some
        redundancies, as there is one situation name for each variable name in <variableName>.
        %}
        situationName;
                
        %{
        Property:
        A cell array of String containing the list of variables names. Each variable name
        is placed at an index matching the index of it's situation's name in <situationName>.
        %}
        variableName
        
        %{
        Property:
        The number of situation name / variable name couples.
        %}
        situationsNumber;
        
        %{
        Property:
        The width of the time window to display in seconds.
        %}
        windowWidth;
        
        %{
        Property:
       	A cell array of strings containing the color codes in number equal to <situationsNumber>.
        %}
        colorsArray;
    end
    
    properties(Access = private, Constant)
		%{
        Constant:
        The list of marker codes used by the plugin.
        
        Value:
        {'v' 's' '^'}
        %}
        MARKERS_LIST = {'v' 's' '^'};
   
         %{
		Constant:
        The list of color codes supported by Matlab.
        
        Value:
        {'r', 'g', 'b', 'c', 'm', 'y', 'k'}
        %}
        COLORS_LIST = {'r', 'g', 'b', 'c', 'm', 'y', 'k'};
    end
    
    methods
        
        %{
        Function:
        The constructor of the Situation plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        trip - The <kernel.Trip> object on which the SituationDisplay will be
        synchronized and which situations will be displayed.
        situationIdentifiers - A cell array of strings, which are all of the
        form "situation.variableName".
        position - The starting position of the window. (In geographical notation).
        timeWindow - The width in seconds of the time windows displayed.
        
        Returns:
        out - a new SituationDisplay.
        %}
        function this = SituationDisplay(trip, situationIdentifiers, position, timeWindow)
            this@fr.lescot.bind.plugins.VisualisationPlugin(trip);
            
            %Setting the original window properties
            set(this.getFigureHandler(), 'Resize', 'on');
            callbackHandler = @this.resizeFigureCallback;
            set(this.getFigureHandler(), 'ResizeFcn', callbackHandler);
            set(this.getFigureHandler(), 'Name', 'Afficheur de situations');
            set(this.getFigureHandler, 'Position', [0 0 770 250]);
            %Positioning the window
            movegui(this.getFigureHandler, position);
            
            %Set the object variables
            this.currentMinTime = 0;
            this.currentMaxTime = timeWindow;
            this.windowWidth = timeWindow;
            this.situationsNumber = length(situationIdentifiers);
            this.xMax = this.situationsNumber + 1;
            this.colorsArray = this.generateColorsCellArray(this.situationsNumber);
            %Splitting the situation identifiers
            this.situationName = cell(1, this.situationsNumber);
            this.variableName = cell(1, this.situationsNumber);
            for i = 1:1:this.situationsNumber
                splittedSituationName = regexp(situationIdentifiers{i}, '\.', 'split');
                this.situationName{i} = splittedSituationName{1};
                this.variableName{i} = splittedSituationName{2};
            end
            
            %Adding ui elements
            this.axesHandler = axes('Parent', this.getFigureHandler, 'Unit', 'pixels', 'Position', [20 20 560 190]);
            this.legendAxesHandler = axes('Parent', this.getFigureHandler, 'Unit', 'pixels', 'Position', [600 20 150 190]');
            %Add the menu bar to the window
            menu = uimenu(this.getFigureHandler(), 'Label', 'Sauvegarder...');           
            callbackHandler = @this.saveFigureCallback;
            set(menu, 'Callback', callbackHandler);
            menu = uimenu(this.getFigureHandler(), 'Label', 'Centrer sur le curseur');
            callbackHandler = @this.centerWindowCallback;
            set(menu, 'Callback', callbackHandler);
            
            %Adding the stem cursor
            this.generateStemCursor(0);
            
            %Setting initial content
            this.refreshAxes();
            
            %Setting the color of the legend axes
            currentAxesBgColor = get(this.legendAxesHandler,'Color');
            set(this.legendAxesHandler, 'YColor', currentAxesBgColor);
            set(this.legendAxesHandler, 'YTick', []);
            set(this.legendAxesHandler, 'XColor', currentAxesBgColor);
            set(this.legendAxesHandler, 'XTick', []);
            axis(this.legendAxesHandler, [0 10 0 this.xMax])
            %Plot the lines of the legend
            
            for i = 1:1:this.situationsNumber
                line([2 9], [i i], 'Parent', this.legendAxesHandler, 'Color', this.colorsArray{i}, 'LineWidth', 2);
                %Adding the legend
                yText = i + 0.2;
                text(5, yText, [this.situationName{i} '.' this.variableName{i}], 'Parent', this.legendAxesHandler, 'HorizontalAlignment', 'center', 'FontSize', 7);                   
            end
            
            %Setting visible
            set(this.getFigureHandler,'Visible', 'on');
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)       
            %The case of a STEP or a GOTO message
            if(any(strcmp(message.getCurrentMessage(), {'STEP' 'GOTO'})))
                currentTime = this.getCurrentTrip().getTimer.getTime();
                multiplier = this.getCurrentTrip().getTimer.getMultiplier();
                %When current time goes out of the window
                if currentTime >= this.currentMaxTime || currentTime <= this.currentMinTime
                    if strcmp(message.getCurrentMessage(), 'STEP')
                        %Play forward
                        if(multiplier > 0)
                            this.currentMinTime = this.currentMinTime + this.windowWidth;
                            this.currentMaxTime = this.currentMaxTime + this.windowWidth;
                        %Play backward
                        else
                            %The max() are here to avoid going below 0
                            this.currentMinTime = max(0, this.currentMinTime - this.windowWidth);
                            this.currentMaxTime = max(this.windowWidth, this.currentMaxTime - this.windowWidth);
                        end
                    %Cas du GOTO    
                    else
                        this.currentMinTime = this.getCurrentTrip().getTimer.getTime() - this.windowWidth / 2;
                        this.currentMaxTime = this.getCurrentTrip().getTimer.getTime() + this.windowWidth / 2;
                    end
                    this.refreshAxes();
                end
                set(this.stemHandler,'XData', currentTime);
                refreshdata(this.stemHandler);
            end   
            if strcmp(message.getCurrentMessage(), 'DATA_CONTENT_CHANGED')
                this.refreshAxes();
            end
        end

    end
    
    methods(Access = private)
                        
        %{
        Function:
        
        Regenerates a stem plot fixed to the main axes area, with some specific axes display settings.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        timecode - The X value for the stem cursor, in seconds.
        %}
        function generateStemCursor(this, timeCode)
           %Adding the stem cursor
            this.stemHandler = stem(this.axesHandler, timeCode, this.xMax, 'Color', 'k', 'Marker', 'none');
            %Setting the scale of the axes and hidding X axis (for the main
            %axes)
            currentAxesBgColor = get(this.axesHandler,'Color');
            set(this.axesHandler, 'YColor', currentAxesBgColor);
            set(this.axesHandler, 'YTick', []); 
        end
        
        %{
        Function:
        
        Regenerates all the display from <currentMinTime> to <currentMaxTime>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function refreshAxes(this)
            %Clear all the objects previously existing
            cla(this.axesHandler)
            %Generate the stem cursor
            this.generateStemCursor(this.getCurrentTrip().getTimer.getTime());
            
            %Find the situation that are in the current time window.
            situationsToDiplay = this.findSituationsToDisplay();
            %Resize the axes first thing, since if we do it at the end, it
            %interferes with "Extent" property of texts ...
            axis(this.axesHandler, [this.currentMinTime this.currentMaxTime 0 this.xMax]);
                        
            if ~isempty(situationsToDiplay)
                for i = 1:1:this.situationsNumber
                    [numberOfSegments, ~] = size(situationsToDiplay{i});
                    markers = this.generateMarkersCellArray(numberOfSegments);
                    for j = 1:1:numberOfSegments
                        %Plotting the line
                        timecodes = cell2mat(situationsToDiplay{i}(j,:));
                        line(timecodes, [i i], 'Parent', this.axesHandler, 'Color', this.colorsArray{i}, 'MarkerFaceColor', this.colorsArray{i}, 'Marker', markers{j}, 'MarkerEdgeColor', 'k' ,'MarkerSize', 8, 'LineWidth', 2); 
                        %Adding the legend
                        record = this.getCurrentTrip().getSituationOccurenceAtTime(this.situationName{i}, timecodes(1), timecodes(2));
                        variableValue = record.getVariableValues(this.variableName{i});
                        variableValue = variableValue{1};
                        if ~ischar(variableValue)
                            variableValue = sprintf('%.12f', variableValue);
                        end
                        if mod(j, 2)
                            yText = i + 0.25;
                            textAngle = 20;
                        else
                            yText = i - 0.25;
                            textAngle = -20;
                        end 
                        newText = text(mean(timecodes), yText, variableValue, 'Parent', this.axesHandler, 'HorizontalAlignment', 'center', 'FontSize', 7, 'Rotation', textAngle);
                        %If the text is fully or partially outside the
                        %axes, it is not displayed
                        textPosition = get(newText, 'Extent');
                        if (textPosition(1)  < this.currentMinTime) || (textPosition(1) +  textPosition(3) > this.currentMaxTime)
                            delete(newText);
                            clear('newText');
                        end
                    end
                end
            end
        end
        
        %{
        Function:
        
        Find all the situations that are included, stat, or end between <currentMinTime> and <currentMaxTime>
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function out = findSituationsToDisplay(this)
           out = cell(1, this.situationsNumber);
           for i = 1:1:this.situationsNumber
               %Find all the situations completely enclosed in the viewing
               %window
               enclosedSituations = this.getCurrentTrip().getSituationOccurencesInTimeInterval(this.situationName{i}, this.currentMinTime, this.currentMaxTime);
               if ~enclosedSituations.isEmpty()
                   enclosedSituationsCellArray = enclosedSituations.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
               else
                   enclosedSituationsCellArray = {};
               end
               %Find all the situations ending in the window but not
               %starting in it.
               aroundLeftLimitSituations = this.getCurrentTrip().getSituationOccurencesAroundTime(this.situationName{i}, this.currentMinTime);
               if ~aroundLeftLimitSituations.isEmpty()
                   aroundLeftLimitSituationsCellArray = aroundLeftLimitSituations.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
               else
                   aroundLeftLimitSituationsCellArray = {};
               end
               %Find all the situations starting in the window but not
               %ending in it.
               aroundRightLimitSituations = this.getCurrentTrip().getSituationOccurencesAroundTime(this.situationName{i}, this.currentMaxTime);
               if ~aroundRightLimitSituations.isEmpty()
                   aroundRightLimitSituationsCellArray = aroundRightLimitSituations.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
               else
                   aroundRightLimitSituationsCellArray = {};
               end
               situationsForThisVariable = [enclosedSituationsCellArray'; aroundLeftLimitSituationsCellArray'; aroundRightLimitSituationsCellArray'];
               %Remove potential duplicates (could sometimes arise on some
               %border cases).
               situationsForThisVariable = num2cell(unique(cell2mat(situationsForThisVariable), 'rows'));
               out{i} = situationsForThisVariable;
           end
        end
        
        %{
        Function:
        
        Resizes the two axes components to fit in the new size of the figure.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function resizeFigureCallback(this, ~ ,~)
            newSize = get(this.getFigureHandler(), 'Position');
            %Repositionning and resizing the axes panel
            set(this.axesHandler, 'Position', [20 20 max(1,(newSize(3) - 210)) max(1, (newSize(4) - 40))]); 
            set(this.legendAxesHandler, 'Position', [max(1, (newSize(3) - 170)) 20 150 max(1, (newSize(4) - 40))]);
        end
        
        %{
        Function:
        
        Center the window display around the current time code.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function centerWindowCallback(this, ~, ~)
            %The following block is a *very dirty* workaround to prevent the
            %button from staying pressed once clicked.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            import java.awt.Robot;
            import java.awt.event.*;
            mouse = Robot;
            mouse.mousePress(InputEvent.BUTTON3_MASK);
            mouse.mouseRelease(InputEvent.BUTTON3_MASK);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            currentTime = this.getCurrentTrip().getTimer.getTime();
            this.currentMinTime = currentTime - (this.windowWidth / 2);
            this.currentMaxTime = currentTime + (this.windowWidth / 2);
            this.refreshAxes();
        end
        
        %{
        Function:
        The callback methods when trying to save the figure to a file.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function saveFigureCallback(this, ~, ~)
            filters = {'*.png' 'Portable Networks Graphics (.png)' 'png'; '*.bmp' 'Bitmap (.bmp)' 'bmp'; '*.jpg' 'JPEG (.jpg)' 'jpg'};
            defaultFileName = [this.getCurrentTrip().getAttribute('nom') ' ' this.getCurrentTrip().getAttribute('numSujet') ' - [' sprintf('%.2f', this.currentMinTime) ', ' sprintf('%.2f', this.currentMaxTime) ']'];
            for i = 1:1:this.situationsNumber
               defaultFileName = [defaultFileName ' - ' this.situationName{i} '.' this.variableName{i}]; %#ok<AGROW>
            end
            [file path filterIndex] = uiputfile(filters(:, 1:2), 'Sauvegarder...', defaultFileName);
            if filterIndex > 0
                [~, ~, ext, ~] = fileparts(file);
                if ~strcmp(ext, ['.' filters{filterIndex, 3}])
                    file = [file '.' filters{filterIndex, 3}];
                end
                print(['-f' num2str(this.getFigureHandler())], [path filesep file], ['-d' filters{filterIndex, 3}]);
            end
        end
        
        %{
        Function:
        Generate an array of color codes cycling on <COLORS_LIST>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        numberOfColors - The length of the array to generate.
        
        Returns:
        out - A cell array of strings
        
        %}
        function out = generateColorsCellArray(this, numberOfColors)
            if(numberOfColors ~= 0)
                if(numberOfColors <= 7)
                    out = cell(1, numberOfColors);
                    [out{1,1:numberOfColors}] = this.COLORS_LIST{1:numberOfColors};
                else
                    out = [this.COLORS_LIST{1:7} this.generateColorsCellArray(numberOfColors - 7)];
                end
            else
                out = {};
            end
        end
        
        
        %{
        Function:
        Generate an array of color codes cycling on <MARKERS_LIST>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        numberOfmarkers - The length of the array to generate.
        
        Returns:
        out - A cell array of strings
        
        %}
        function out = generateMarkersCellArray(this, numberOfMarkers)
            numberOfAvailableMarkers = length(this.MARKERS_LIST);
            if(numberOfMarkers ~= 0)
                if(numberOfMarkers <= numberOfAvailableMarkers)
                    out = cell(1, numberOfMarkers);
                    [out{1,1:numberOfMarkers}] = this.MARKERS_LIST{1:numberOfMarkers};
                else
                    out = [this.MARKERS_LIST{1:numberOfAvailableMarkers} this.generateMarkersCellArray(numberOfMarkers - numberOfAvailableMarkers)];
                end
            else
                out = {};
            end
        end
        
    end
    
    methods(Static)
        
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
            out = 'fr.lescot.bind.configurators.SituationDisplayConfigurator';   
        end
        
        %{
        Function:
        Implements <fr.lescot.bind.plugins.Plugin.geName()>.
        %}
        function out = getName()
            out = '[S] Afficheur de situations';   
        end
        
    end
    
end