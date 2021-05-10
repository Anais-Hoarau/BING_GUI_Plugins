%{
Class:
This class creates a plugin used to graphically display some datas.

%}
classdef DataPlotterAnais < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripStreamingPlugin
    %%%%%%%%
    properties(Access=public)
       newPosition; 
    end
    %%%%%%%%
    properties (Access = private)
        %{
        Property:
        The handler to the plotting area.
        
        %}
        axesHandler;
        %{
        Property:
        The handler to the plotted lines themselves.
        
        %}
        plotHandler;
        %{
        Property:
        The handler to the stem used as cursors.
        
        %}
        stemHandler;
        
        %{
        Property:
        Used to store the current min time for the plugin (not always equals to the one of the subject for some
        programmatic reasons).
        
        %}
        currentMin;
        %{
        Property:
        Used to store the current max time for the plugin (not always equals to the one of the subject for some
        programmatic reasons).
        
        %}
        currentMax;
        
        
        %{
        Property:
        If the manual scale mode have been chosen, the property contains
        the lower and upper bounds.
        
        %}
        manualScale;
        %{
        Property:
        If the manual color mode is used, contains the list of colors.
        
        %}
        colors;
        %{
        Property:
        Contains the chosen scale mode.
        
        %}
        scaleMode;
        %{
        Property:
        If the line types are set manually, contains the lines types.
        
        %}
        lineTypes;
        %{
        Property:
        If the markers are set manually, contains the markers.
        
        %}
        markers;
    end
    
    properties (Access = private, Constant)
        %{
		Constant:
        The list of color codes supported by Matlab.
        
        Value:
        {'r', 'g', 'b', 'c', 'm', 'y', 'k'}
        %}
        COLORS_LIST = {'r', 'g', 'b', 'c', 'm', 'y', 'k'};
		
		%{
		Constant:
        The list of line types codes supported by Matlab.
        
        Value:
        {'-', ':', '-.', '--'}
        %}
        LINE_TYPES_LIST = {'-', ':', '-.', '--'};
		
		%{
        Constant:
        The list of position codes supported by Matlab movegui function.
        
        Value:
        {'north', 'south', 'east', 'west', 'northeast', 'northwest',
        'southeast', 'southwest', 'center'}
        %}
        POSITIONS_LIST = {'north', 'south', 'east', 'west', 'northeast', 'northwest', 'southeast', 'southwest', 'center'};
        
		%{
        Constant:
        The list of marker codes supported by Matlab .
        
        Value:
        {'+' 'o' '*' '.' 'x' 's' 'd' '^' 'v' '<' '>' 'p' 'h'}
        %}
        MARKERS_LIST = {'+' 'o' '*' '.' 'x' 's' 'd' '^' 'v' '<' '>' 'p' 'h' ''};
   
    end
    
    methods
        
        %{
        Function:
        The constructor of the DataPlotter plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        The arguments marqued with a star (*) are optionnal and have to be
        specified with the key / value syntax. For example, if you want to
        change the name of the window, you'll have to pass 2 arguments,
        with the following syntax : "DataPlotter(..., 'windowTitle',
        'myTitle', ...)"
        
        trip - The <kernel.Trip> object on which the DataPlotter will be
        synchronized and which data will be displayed.
        dataIdentifiers - A cell array of strings, which are all of the
        form "dataName.variableName".
        position - The starting position of the window. A value among
        those of <POSITIONS_LIST> is expected.
        timeWindow - The width in seconds of the time windows displayed.
        *scaleMode - The algorithm that determines the Y scale. The
        allowed values are :
         - MinMaxFile : Sets the scale to fit the min and the max of the
         data contained in the file and selected to be plotted.
         - MinMaxWindow : Fits the scale to the data displayed.
         - Manual : Allow to fix a manual value for Ymin et Ymax. The
         values are fixed via the "scale" argument or defaulted to [0,
         100].
        *scale - This argument is used only if scaleMode is set to Manual.
        The expected argument is an array of 2x1 doubles, with the form
        [Ymin YMax].
        *colors - This argument is used to overwrite the automatic color
        mode used by default. The value have to be a cell array of
        string. Each of these strings have to be among the values of
        <COLORS_LIST>. The number of values have to be exactly the same
        thant the number of elements of dataIdentifiers.
        *lineTypes - Works in the same way than the previous argument, but
        changes the type of line (dashed, continuous, ...). The allowed
        values are described by <LINE_TYPES_LIST>.
        *markers - As line types and colors, but describes the marker to
        use (point, plus, circle, ...). The allowed values are in
        <MARKERS_LIST>.
        *windowTitle - The title of the window.
        
        Throws:
        exceptions.ArgumentException - when an
        argument does not match the expected specifications.
        
        Returns:
        out - a new DataPlotter.
        %}
        function dataPlotter = DataPlotterAnais(trip, dataIdentifiers, position, timeWindow, varargin)
            import fr.lescot.bind.exceptions.ExceptionIds;
            import fr.lescot.bind.utils.StringUtils;
            dataPlotter@fr.lescot.bind.plugins.GraphicalPlugin();
            dataPlotter@fr.lescot.bind.plugins.TripStreamingPlugin(trip, dataIdentifiers, timeWindow, 'data');
            
            if strcmp(class(position),'char')
                parser = dataPlotter.buildInputParser();
                parser.parse(trip, dataIdentifiers, position, varargin{:});

                dataPlotter.scaleMode = parser.Results.scaleMode;
            else
                screenSize=get(0,'ScreenSize');
                L=screenSize(3);
                H=screenSize(4);
                x=position(1);
                y=position(2);
                if ( (x<L/3-x/2) && (y>2*H/3-y/2) )
                    position='northwest'
                elseif ( (x<L/3-x/2) && (y<2*H/3-y/2) )
                    position='west'  
                elseif ( (x<L/3-x/2) && (y<H/3-y/2) )
                    position='southwest'
                    
                    
                elseif ( (x<2*L/3-x/2) && (y>2*H/3-y/2) )
                    position='north'
                elseif ( (x<2*L/3-x/2) && (y<2*H/3-y/2) )
                    position='center'  
                elseif ( (x<2*L/3-x/2) && (y<H/3-y/2) )
                    position='west'
                    
                
                 elseif ( (x>2*L/3-x/2) && (y>2*H/3-y/2) )
                    position='northeast'
                elseif ( (x>2*L/3-x/2) && (y<2*H/3-y/2) )
                    position='east'  
                elseif ( (x>2*L/3-x/2) && (y<H/3-y/2) )
                    position='southeast'
                    
                end
                
                
                parser = dataPlotter.buildInputParser();
                parser.parse(trip, dataIdentifiers, position, varargin{:});

                dataPlotter.scaleMode = parser.Results.scaleMode;

            end 
                    
            
            set(dataPlotter.getFigureHandler(), 'Resize', 'on');
            callbackHandler = @dataPlotter.resizeFigureCallback;
            set(dataPlotter.getFigureHandler(), 'ResizeFcn', callbackHandler);
            set(dataPlotter.getFigureHandler, 'Position', [0 0 600 250]);
            movegui(dataPlotter.getFigureHandler, position);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %fermeture de la figure
            closeCallbackHandle = @dataPlotter.closeCallback;
            set(dataPlotter.getFigureHandler, 'CloseRequestFcn', closeCallbackHandle);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            
            %Adding ui elements
            dataPlotter.axesHandler = axes('Parent', dataPlotter.getFigureHandler, 'Units', 'pixels', 'Position', [20 20 560 210]);
            
            hold(dataPlotter.axesHandler);
            
            %Set the object variables
            dataPlotter.currentMin = 0;
            dataPlotter.currentMax = timeWindow;
            dataPlotter.manualScale = parser.Results.scale;
            dataPlotter.colors = parser.Results.colors;
            if(isempty(dataPlotter.colors))
                dataPlotter.colors = dataPlotter.generateColorsCellArray(dataPlotter.dataNumber);
            else
                if length(dataPlotter.colors) ~= length(dataPlotter.dataName)
                    throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Length of "colors" should be the same than the length of data'));
                end
            end
            dataPlotter.lineTypes = parser.Results.lineTypes;
            if(isempty(dataPlotter.lineTypes))
                dataPlotter.lineTypes = dataPlotter.generateLineTypesCellArray(dataPlotter.dataNumber);
            else
                if length(dataPlotter.lineTypes) ~= length(dataPlotter.dataName)
                    throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Length of "lineTypes" should be the same than the length of data'));
                end
            end
            dataPlotter.markers = parser.Results.markers;
            if(isempty(dataPlotter.markers))
                dataPlotter.markers = dataPlotter.generateMarkersCellArray(dataPlotter.dataNumber);
            else
                if length(dataPlotter.markers) ~= length(dataPlotter.dataName)
                    throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Length of "markers" should be the same than the length of data'));
                end
            end
            
            %Plot the initial datas
            dataPlotter.plotHandler = cell(1,dataPlotter.dataNumber);
            dataPlotter.stemHandler = cell(1,dataPlotter.dataNumber);
            for i = 1:1:dataPlotter.dataNumber
                %(:, 1) : Datas
                %(:, 2) : Timecodes
                formatString = [dataPlotter.markers{i} dataPlotter.lineTypes{i} dataPlotter.colors{i}];
                if ~isempty(dataPlotter.dataBuffer{i,2})
                    dataPlotter.plotHandler{i} = plot(dataPlotter.axesHandler, cell2mat(dataPlotter.dataBuffer{i,2}), cell2mat(dataPlotter.dataBuffer{i,1}), formatString);
                    dataPlotter.stemHandler{i} = stem(dataPlotter.axesHandler, cell2mat(dataPlotter.dataBuffer{i,2}(1)), cell2mat(dataPlotter.dataBuffer{i,1}(1)), 'Color', dataPlotter.colors{i});
                else
                    dataPlotter.plotHandler{i} = plot(dataPlotter.axesHandler, (0), (0), formatString);
                    dataPlotter.stemHandler{i} = stem(dataPlotter.axesHandler, 0, 0, 'Color', dataPlotter.colors{i});
                end
                set(get(get(dataPlotter.stemHandler{i},'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude line from legend
            end
            
            dataPlotter.calculateScale(true);
            legendHandler = legend(dataPlotter.axesHandler, dataPlotter.variableName);
            set(legendHandler, 'Interpreter', 'none');
            
            %set the grid properties
            set(dataPlotter.axesHandler,'XGrid','off','YGrid','on','ZGrid','off'); % draw Y lines
            set(dataPlotter.axesHandler,'GridLineStyle','-'); % full lines
            set(dataPlotter.axesHandler,'YTickMode','manual'); % set manual spacing
            set(dataPlotter.axesHandler,'YMinorGrid','on'); % add minor lines
            set(dataPlotter.axesHandler,'YMinorTick','on');            
            set(dataPlotter.axesHandler,'MinorGridLineStyle',':'); % dotted
            
            
            %Set the windows title
            set(dataPlotter.getFigureHandler(), 'Name', parser.Results.windowTitle);
            %Add the menu bar to the window
            menu = uimenu(dataPlotter.getFigureHandler(), 'Label', 'Screenshot...');            
            callbackHandler = @dataPlotter.saveFigureCallback;
            set(menu, 'Callback', callbackHandler);
            menu = uimenu(dataPlotter.getFigureHandler(), 'Label', 'Centre');
            callbackHandler = @dataPlotter.centerWindowCallback;
            set(menu, 'Callback', callbackHandler);
        
            %Setting visible
            set(dataPlotter.getFigureHandler,'Visible', 'on');
        end
        
           function closeCallback(this, src, ~)%%ajout closeCallback
            %sauvegarde de la position
                class(this) % le type de fenetre est 'matlab.ui.Figure�
               try
                    p=get(this.getFigureHandler, 'Position')
                    this.newPosition=p;
                catch ME
                    msg="pas position recup"
                end
                               
                delete(this.getFigureHandler());
        end
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)
            
            this.update@fr.lescot.bind.plugins.TripStreamingPlugin(message);
            
            currentTime = this.getCurrentTrip.getTimer.getTime();
            %The case of a STEP or a GOTO message
            if(any(strcmp(message.getCurrentMessage(), {'STEP' 'GOTO'})))
                %When current time goes out of the window
                if currentTime >= this.currentMax || currentTime <= this.currentMin
                    this.regenerateDisplay();
                    this.currentMin = this.minTime;
                    this.currentMax = this.maxTime; 
                end
                %Set the cursors at the right position
                this.setStemPosition(currentTime);
            end
        end
        
    end
    
    methods(Access = private)
        
        function regenerateDisplay(this)
            for i = 1:1:this.dataNumber
                set(this.plotHandler{i},'YData', cell2mat(this.dataBuffer{i,1}));
                set(this.plotHandler{i},'XData', cell2mat(this.dataBuffer{i,2}));
                refreshdata(this.plotHandler{i});
            end
            this.calculateScale(false);
            this.currentMin = this.minTime;
            this.currentMax = this.maxTime;
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
            this.changeBufferStartTime(currentTime - (this.windowWidth / 2));
            this.regenerateDisplay();
            this.currentMin = this.minTime;
            this.currentMax = this.maxTime;
            this.setStemPosition(currentTime);
        end
        
        %{
        Function:
        
        Resizes the components to fit in the new size of the figure.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function resizeFigureCallback(this, ~ ,~)
            newSize = get(this.getFigureHandler(), 'Position');
            %Repositionning and resizing the axes panel
            
            % Orignal Code
            %set(this.axesHandler, 'Position', [20 20 max(1,(newSize(3) - 40)) max(1, (newSize(4) - 40))]);
            
            % Code modifi� S�bastian Gauthier : Evite que des nombres soient
            % coup�s quand il y a des puissance de 10. exple : 5 x 10^-6
            set(this.axesHandler, 'Position', [50 30 max(1,(newSize(3) - 70)) max(1, (newSize(4) - 50))]);
        end
        
        %{
        Function:
        The callback methods when trying to save the figure to a file.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function saveFigureCallback(this, ~, ~)
            filters = {'*.png' 'Portable Networks Graphics (.png)' 'png'; '*.bmp' 'Bitmap (.bmp)' 'bmp'; '*.jpg' 'JPEG (.jpg)' 'jpg'};
            defaultFileName = [ '[' sprintf('%.2f', this.currentMin) ', ' sprintf('%.2f', this.currentMax) ']'];
            for i = 1:1:this.dataNumber
               defaultFileName = [defaultFileName ' - ' this.dataName{i} '.' this.variableName{i}]; %#ok<AGROW>
            end
            [file, path, filterIndex] = uiputfile(filters(:, 1:2), 'Screenshot...', defaultFileName);
            if filterIndex > 0
                [~, ~, ext] = fileparts(file);
                if ~strcmp(ext, ['.' filters{filterIndex, 3}])
                    file = [file '.' filters{filterIndex, 3}];
                end
                print(this.getFigureHandler(), [path filesep file], ['-d' filters{filterIndex, 3}]);
            end
        end
        
        %{
        Function:
        This method builds the input parser object used to validate and
        extract the arguments of <DataPlotter()>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        out - an input parser.
        %}
        function out = buildInputParser(this)
            ip = inputParser;
            ip.addRequired('trip');
            ip.addRequired('dataIdentifiers');%Format check performed by parent class
            ip.addRequired('position', @this.positionValidator);
            ip.addParamValue('scaleMode', 'MinMaxWindow', @this.scaleModeValidator);
            ip.addOptional('scale', [0, 100], @this.scaleValidator);
            ip.addOptional('colors', {}, @this.colorsValidator);
            ip.addOptional('lineTypes', {}, @this.lineTypesValidator);
            ip.addOptional('markers', {}, @this.markersValidator);
            ip.addOptional('windowTitle', 'Plotter');
            out = ip;
        end
        
        %{
        Function:
        This method is used to validate the lineTypes argument of
        <DataPlotter>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        type - The cell array of line types to validate
        
        
        Returns:
        out - a logical.
        
        Throws:
        exceptions.ArgumentException - If the argument
        to validate does not match specifications.
        %}
        function out = lineTypesValidator(this, types)
            import fr.lescot.bind.exceptions.ExceptionIds;
            valid = true;
            for i = 1:1:length(types)
                validThisType = any(strcmpi(types{i}, this.LINE_TYPES_LIST));
                if ~validThisType
                    throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Argument is not a valid value for lineTypes'));
                end
                valid = valid && validThisType;
            end
            out = valid;
        end
        
        %{
        Function:
        This method is used to validate the colors argument of
        <DataPlotter>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        colors - The cell array of colors types to validate
        
        
        Returns:
        out - a logical.
        
        Throws:
        exceptions.ArgumentException - If the argument
        to validate does not match specifications.
        %}
        function out = colorsValidator(this, colors)
            import fr.lescot.bind.exceptions.ExceptionIds;
            isColorsOk = true;
            for i = 1:1:length(colors)
                isThisColorOk = any(strcmpi(colors{i}, this.COLORS_LIST));
                if ~isThisColorOk
                    throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Argument is not a valid value for colors'));
                end
                isColorsOk =  isColorsOk && isThisColorOk;
            end
            out = isColorsOk;
        end
        
        %{
        Function:
        This method is used to validate the markers argument of
        <DataPlotter>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        markers - The cell array of markers types to validate
        
        
        Returns:
        out - a logical.
        
        Throws:
        exceptions.ArgumentException - If the argument
        to validate does not match specifications.
        %}
        function out = markersValidator(this, markers)
            import fr.lescot.bind.exceptions.ExceptionIds;
            isMarkersOk = true;
            for i = 1:1:length(markers)
                isThisMarkerOk = any(strcmpi(markers{i}, this.MARKERS_LIST));
                if ~isThisMarkerOk
                    throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Argument is not a valid value for markers'));
                end
                isMarkerOk =  isMarkersOk && isThisMarkerOk;
            end
            out = isMarkerOk;
        end
        
        %{
        Function:
        This method is used to validate the scale argument of
        <DataPlotter>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        scale - The cell array of line types to validate
        
        
        Returns:
        out - a logical.
        
        Throws:
        exceptions.ArgumentException - If the argument
        to validate does not match specifications.
        %}
        function out = scaleValidator(this, scale)
            import fr.lescot.bind.exceptions.ExceptionIds;
            isSizeOk = all(([1 2] == size(scale)));
            isOrderOk = (scale(1) < scale(2));
            isValid = isSizeOk && isOrderOk;
            if ~isValid
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Argument is not a valid value for scale'));
            end
            out = isValid;
        end
        
        
        %{
        Function:
        This method is used to validate the positionValidator argument of
        <DataPlotter>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        position - The cell array of line types to validate
        
        
        Returns:
        out - a logical.
        
        Throws:
        exceptions.ArgumentException - If the argument
        to validate does not match specifications.
        %}
        function out = positionValidator(this, position)
            import fr.lescot.bind.exceptions.ExceptionIds;
            isValid = any(strcmpi(position, this.POSITIONS_LIST));
            if ~isValid
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Argument is not a valid value for position'));
            end
            out = isValid;
        end
        
        %{
        Function:
        This method is used to validate the scaleModeValidator argument of
        <DataPlotter>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        scaleMode - The cell array of line types to validate
        
        
        Returns:
        out - a logical.
        
        Throws:
        exceptions.ArgumentException - If the argument
        to validate does not match specifications.
        %}
        function out = scaleModeValidator(this, scaleMode)
            import fr.lescot.bind.exceptions.ExceptionIds;
            isValid = any(strcmpi(scaleMode, {'MinMaxFile' 'MinMaxWindow' 'Manual'}));
            if ~isValid
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'Argument is not a valid value for scaleMode'));
            end
            out = isValid;
        end
        
        %{
        Function:
        This method calculates both X and Y scales depending on the modes
        passed in parameter for Y and of the diplayed time window for X.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        isInitialCalculation - A logical indicating if the calculateScale
        is the first one or not. Used for example when in MinMaxFile mode
        to parse the whole datas only at the initialisation of the
        display, not at each refresh.
        
        %}
        function calculateScale(this, isInitialCalculation)
            %calculate X scale
            xMin = this.minTime;
            xMax = this.maxTime;
            
            
            %Calculate Y scale
            yMin = -1;
            yMax = 1;
            if(strcmp(this.scaleMode, 'MinMaxWindow'))
                yMins = zeros(1,this.dataNumber);
                yMaxs = zeros(1,this.dataNumber);
                for i = 1:1:this.dataNumber
                    %If the data buffer is empty, the min/max functions will
                    %return nothing, so we let 1/-1 as a limit.
                    if ~all(cellfun('isempty', this.dataBuffer(i, 1)))
                        
                        %Code Original du Data Plotter
                        %yMins(i) = min(cell2mat(this.dataBuffer{i, 1})); 
                        %yMaxs(i) = max(cell2mat(this.dataBuffer{i, 1}));
                        
                        % Code modifi� par S�bastian Gauthier - permet
                        % d'avoir une fenetre un peu plus large que le
                        % min/max (5% suppl�mentaire)
                        yMins(i) = min(cell2mat(this.dataBuffer{i, 1})) - 5/100*abs(min(cell2mat(this.dataBuffer{i, 1}))); 
                        yMaxs(i) = max(cell2mat(this.dataBuffer{i, 1})) + 5/100*abs(max(cell2mat(this.dataBuffer{i, 1})));
                        
                    end
                end
                if ~isempty(yMin) && ~isempty(yMax)
                    yMin = min(yMins);
                    yMax = max(yMaxs);
                end
            end
            if(strcmp(this.scaleMode, 'MinMaxFile'))
                if(isInitialCalculation)
                    yMins = zeros(1,this.dataNumber);
                    yMaxs = zeros(1,this.dataNumber);
                    for i = 1:1:this.dataNumber
                        yMins(i) = this.getCurrentTrip.getDataVariableMinimum(this.dataName{i}, this.variableName{i});
                        yMaxs(i) = this.getCurrentTrip.getDataVariableMaximum(this.dataName{i}, this.variableName{i});
                    end
                    yMin = min(yMins);
                    yMax = max(yMaxs);
                else
                    %Get the previously set limits to avoid to recalculate
                    %them
                    ylims = get(this.axesHandler, 'YLim');
                    yMin = ylims(1);
                    yMax = ylims(2);
                end
            end
            if(strcmp(this.scaleMode, 'Manual'))
                if(isInitialCalculation)
                    %Set the initial limits
                    yMin = this.manualScale(1);
                    yMax = this.manualScale(2);
                else
                    ylims = get(this.axesHandler, 'YLim');
                    yMin = ylims(1);
                    yMax = ylims(2);
                end
            end
            %If all the datas are the same in the time intervall, we have
            %to get some different values for yMax and yMin anyway to avoid
            %a crash.
            if yMin == yMax
                yMax = yMin + 0.1;
            end
            
            %Setting the scale
            % error handling : in case where no data are available in trip,
            % the min and max can be set to NaN... in this case, it is
            % necessary to alert the user
            if any(isnan([xMin xMax yMin yMax]))
                axis(this.axesHandler, [0 1 0 1]);
                msgbox('No data in selected variable : default scale used','DataPlotter Error : No data');
            else
                axis(this.axesHandler, [xMin xMax yMin yMax]);
                % Corrige le bug de d'affichage
                if yMin == yMax
                    yMax = yMin + 0.1;
                end
                    set(this.axesHandler,'YTickMode','manual')
                    set(this.axesHandler,'YTick',round(linspace(yMin,yMax,10)*100)/100) 

            end
        end
        
        %{
        Function:
        Moves the stem plot used as a cursor to match the current time.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        currentTime - The time where the cursor have to be moved.
        
        %}
        function setStemPosition(this, currentTime)
            for i = 1:1:this.dataNumber
                [~, ind] = min( abs(cell2mat(this.dataBuffer{i,2}) - (currentTime)) );
                set(this.stemHandler{i},'YData', this.dataBuffer{i,1}{ind});
                set(this.stemHandler{i},'XData', this.dataBuffer{i,2}{ind});
                refreshdata(this.stemHandler{i});
            end
        end
        
        %{
        Function:
        When the colors are not user-specified, this method is used to
        generate an array of the right size by cycling through the
        standard matlab colors.
        
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
        When the type of lines are not user-specified, this method
        generates a cell array with the default value (continuous line).
        
        Arguments:
        this - The object on which the function is called, optionnal.
        numberOfLines - The length of the array to generate.
        
        Returns:
        out - A cell array of strings
        
        %}
        function out = generateLineTypesCellArray(this, numberOfLines)
            typesArray = cell(1, numberOfLines);
            for i = 1:1:numberOfLines
                typesArray{1, i} = '-';
            end
            out = typesArray;
        end
        
        %{
        Function:
        When the markers are not user-specified, this method
        generates a cell array with the default value (dot).
        
        Arguments:
        this - The object on which the function is called, optionnal.
        numberOfmarkers - The length of the array to generate.
        
        Returns:
        out - A cell array of strings
        
        %}
        function out = generateMarkersCellArray(this, numberOfMarkers)
            markersArray = cell(1, numberOfMarkers);
            for i = 1:1:numberOfMarkers
                markersArray{1, i} = '';
            end
            out = markersArray;
        end
        
    end
    
    methods(Static)
        %{
        Function:
        Returns the human-readable name of the plugin.
        
        Returns:
        A String.
        
        %}
        function out = getName()
            out = '[D] Plotter';
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
            out = 'fr.lescot.bind.configurators.DataPlotterConfigurator';   
        end
        
   
        
        

    end
    
end