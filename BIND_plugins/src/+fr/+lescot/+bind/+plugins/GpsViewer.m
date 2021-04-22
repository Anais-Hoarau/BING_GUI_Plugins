%{
Class:
This class creates a plugin used to plot the GPS position on a google maps card (static Google Map API). The current position in the trip is highlighted.
It allows the navigation in the trip through the GPS position using the DataCursorMode
%}
classdef GpsViewer < fr.lescot.bind.plugins.TripPlugin & fr.lescot.bind.plugins.GraphicalPlugin
     %%%%%%%%
    properties(Access=public)
       newPosition; 
    end
    %%%%%%%%
    properties (Access = private)
        %{
        Property:
        The handler to the main plotting area.
        %}
        gMapHandle;
        
        %{
        Property:
        The handler to the main plotting area.
        %}
        gMapAxesHandle;
        
        %{
        Property:
        The handler of the actual GPS position plot .
        %}
        actualPositionHandle;
        
        %{
        Property:
        The handler of the GPS line plot .
        %}
        gpsPlotHandle;
        
        %{
        Property:
        The handler of the axe of the GPS plot.
        %}
        gpsAxesHandle;
        
        %{
        Property:
        The handler to the datacursor used to navigate in the trip through the GPS position.
        %}
        dataCursorHandle;
        
        %{
        Property:
        The handler to the centerControl used to center the map on the current GPS position.
        %}
        centerControlHandle;
        
        %{
        Property:
        Structure containing the MapProperties used to configure the plot_google_map function.
        %}
        mapProperties;
        
        %{
        Property:
        Gps data source passed from the configurator.
        %}
        gpsDataSource;
        
        %{
        Property:
        Latitude array.
        %}
        latitude;
        
        %{
        Property:
        Longitude array.
        %}
        longitude;
        
        %{
        Property:
        Gps timecode array.
        %}
        gpsTimecode;
        
        %{
        Property:
        Latitude of the current time.
        %}
        actualLatitude;
        
        %{
        Property:
        Longitude of the current time.
        %}
        actualLongitude;
        
        %{
        Property:
        GPS timecode of the current time.
        %}
        actualTimecode;
        
        %{
        Property:
        previous gps timecode associated to the DataCursor.
        %}
        previousDataCursorTime;
        
    end
    
    properties(Access = private, Constant)
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
        function this = GpsViewer(trip, position, MapType, gpsSource)
            import fr.lescot.bind.utils.StringUtils;
            % we call the constructor of the superclasses "TripPlugin" & "GraphicalPlugin"
            this@fr.lescot.bind.plugins.TripPlugin(trip);
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            
            % load and filter the GPS data
            this.gpsDataSource = gpsSource;
            this.getLatitudeLongitude()
            this.mapProperties.maptype = MapType;
            
            
            % Initialisation
            this.actualLatitude = this.latitude(1);
            this.actualLongitude = this.longitude(1);
            this.actualTimecode = this.gpsTimecode(1);
            this.previousDataCursorTime =0;
            
            % Build the GUI
            this.buildUI(position);
            
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
                [~,id_min] = min(abs(this.gpsTimecode - currentTime));
                
                % update the GPS position (if a new value is available)
                if ~(this.actualTimecode == this.gpsTimecode(id_min))
                    this.actualTimecode = this.gpsTimecode(id_min);
                    this.actualLatitude = this.latitude(id_min);
                    this.actualLongitude = this.longitude(id_min);
                    set(this.actualPositionHandle,'XData', this.actualLongitude, 'YData', this.actualLatitude)
                end
            end
        end
    end
    
    methods(Access = private)
        %{
        Function:
        Build the window of the GUI
        
        Arguments:
        this - The object on which the function is called, optionnal.
        position - The initial position of the GUI.
        
        %}
        function buildUI(this, position)
            set(this.getFigureHandler, 'Position', [0 0 1080/2 1080/2]);
            set(this.getFigureHandler, 'Color',[0.8 0.8 0.8]);
            set(this.getFigureHandler(), 'Name', 'Tracé GPS');
            set(this.getFigureHandler(),'Toolbar','figure')
            set(this.getFigureHandler(), 'Visible', 'off');

            
            % Onmap navigation
            datacursormode on
            this.dataCursorHandle =  datacursormode(this.getFigureHandler());
            DataCursorUpdateHandle = @this.DataCursorUpdate;
            set(this.dataCursorHandle,'UpdateFcn',DataCursorUpdateHandle);
            %
            centerCallbackHandle = @this.centerCallback;
            this.centerControlHandle = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'CENTER', ...
                'Position', [460 480 50 30], 'Callback', centerCallbackHandle);
            % Plot initialisation
            this.gpsPlotHandle = plot(this.longitude,this.latitude,'bs','MarkerFaceColor','b','MarkerSize',4);
            this.gpsAxesHandle = gca;
            set(this.gpsAxesHandle,'position',[0.082 0.05 0.9 0.92]);
            %axis square
            
            hold on
            this.actualPositionHandle = plot(this.actualLongitude,this.actualLatitude,'sr','MarkerFaceColor','red');
            hold off
            
            this.gMapHandle = plot_google_map('MapType',this.mapProperties.maptype);
            this.gMapAxesHandle = gca;
            
            % Resize figure callback
            set(this.getFigureHandler(), 'Resize', 'off');
            resizeFigureCallbackHandler = @this.resizeFigureCallback;
            set(this.getFigureHandler(), 'ResizeFcn', resizeFigureCallbackHandler);
            
            movegui(this.getFigureHandler(),position);
            set(this.getFigureHandler(), 'Visible', 'on');
            
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %fermeture de la figure
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler, 'CloseRequestFcn', closeCallbackHandle);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        %{
        Function:
        
        Load and filter the GPS poistion from the data tabel 'Mopad_GPS_5Hz'.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        theTrip - the trip associated to the plug in.
        %}
        function getLatitudeLongitude(this)
            theTrip = this.getCurrentTrip;
            switch this.gpsDataSource
                case 'GPS 5Hz'
                    record = theTrip.getAllDataOccurences('Mopad_GPS_5Hz');
                    latitude_full = cell2mat(record.getVariableValues('Latitude_5Hz'));
                    if mean(latitude_full(~isnan(latitude_full)))>10^5
                        latitude_full = latitude_full/10^6;
                    end
                    
                    longitude_full = cell2mat(record.getVariableValues('Longitude_5Hz'));
                    if mean(longitude_full(~isnan(longitude_full)))>10^5
                        longitude_full = longitude_full/10^6;
                    end
                case 'Centrale Inertielle'
                    record = theTrip.getAllDataOccurences('Mopad_CentraleInertielle_IGN500');
                    latitude_full = cell2mat(record.getVariableValues('latitude_IGN'));
                    longitude_full = cell2mat(record.getVariableValues('longitude_IGN'));
                case 'Centrale Inertielle (Raw Data)'
                    record = theTrip.getAllDataOccurences('Mopad_CentraleInertielle_IGN500');
                    latitude_full = cell2mat(record.getVariableValues('GPSraw_latitude'));
                    longitude_full = cell2mat(record.getVariableValues('GPSraw_longitude'));
            end
            timecode_full = cell2mat(record.getVariableValues('timecode'));
            
            mask_nan = ~isnan(latitude_full) & ~isnan(longitude_full);
            latitude_full = latitude_full(mask_nan);
            longitude_full = longitude_full(mask_nan);
            
            mask_gps = logical(diff(latitude_full)) | logical(diff(longitude_full));
            
            this.latitude = latitude_full(mask_gps);
            this.longitude = longitude_full(mask_gps);
            this.gpsTimecode = timecode_full(mask_gps);
            
            clear record latitude_full longitude_full
        end
        
        %{
        Function:
        
        the resizing is handled automatically.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function centerCallback(this, ~ ,~)
            currAxis = axis(this.gpsAxesHandle);
            
            axisHeight =(currAxis(2) - currAxis(1))*0.7; % the '0.7' factor compensates the dezoom effect that you get when you refresh the axis
            axisWidth = (currAxis(4) - currAxis(3))*0.7; % the '0.7' factor compensates the dezoom effect that you get when you refresh the axis
            
            axis(this.gpsAxesHandle,[this.actualLongitude-axisWidth/2 this.actualLongitude+axisWidth/2 ...
                this.actualLatitude-axisHeight/2 this.actualLatitude+axisHeight/2]);
            
            this.update_google_map_fig;
            
        end
        
        %{
        Function:
        
        the resizing is handled automatically.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function resizeFigureCallback(this, ~ ,~)
        end
        
          %%%%%%%%%%%%%%%
       function closeCallback(this, src, ~)%ajout closeCallback   
                nouvellePosition=this.getFigureHandler.Position();
                this.newPosition=nouvellePosition
                delete(this.getFigureHandler);
       end   
       %%%%%%%%%%%%%%%%
        
        %{
        Function:
        Allows the navigation on the GPS map using the matlab DataCursorMode
        
        Arguments:
        this - The object on which the function is called, optionnal.
        event_obj - default matlab event when using the datacursormode
        %}
        function output_txt = DataCursorUpdate(this,~,event_obj)
            dataIndex = get(event_obj,'DataIndex');
            if length(dataIndex)>1
                output_txt = {'En dehors du trajet !!'};
            else
                actualDataCursorTime = this.gpsTimecode(dataIndex);
                Pos=get(event_obj,'Position');
                if ~(actualDataCursorTime == this.previousDataCursorTime )
                    this.previousDataCursorTime = actualDataCursorTime;
                    this.getCurrentTrip().getTimer().setTime(actualDataCursorTime);
                else
                end
                output_txt = {['Longitude : ' num2str(Pos(1))]; ['Latitude : ' num2str(Pos(2))]};
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
            out = 'fr.lescot.bind.configurators.GpsViewerConfigurator';
        end
        
        %{
        Function:
        Implements <fr.lescot.bind.plugins.Plugin.geName()>.
        %}
        function out = getName()
            out = '[D] Tracé GPS';
        end
    end
    
end