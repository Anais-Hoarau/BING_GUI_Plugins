%{
Class:
This class is the configurator of the <GpsViewer> plugin

%}
classdef GpsViewerConfigurator < fr.lescot.bind.configurators.PluginConfigurator_simplif
    properties
      msg='';  
    end
    properties
        %{
        Property:
        The handler on the position chooser widget.
        %}
        positionChooser;
        
        %{
        Property:
        String containing the type of map that will capteur from the static gmaps API (roadmap|satellite|terrain|hybrid).
        %}
        MapTypeChooser;
        
        %{
        Property:
        Structure containg the handlers of the differents objects
        %}
        ObjectHandler;
        
        %{
        Property:
        Boolean
        %}
        gpsDataAvailable;
             
        gpsDataList;
        
        gpsSourceChooser;
    end
    
    
    methods
        
        %{
        Function:
        The constructor of the GpsViewerConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        tripInformation - a <data.MetaInformations> object that stores the
        available videos
        caller - handler to the interface that ask for a configuration, in
        order to be able to give back the configurator when closing.
        
        
        Returns:
        this - a new VideoPlayerConfigurator.
        %}
        function this = GpsViewerConfigurator(pluginName, trip, metaTrip, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator_simplif(pluginName, trip, metaTrip, varargin);
            % selecteur des données GPS a afficher
            this.gpsDataAvailable = false;
            this.checkGpsData(metaTrip);
            
            this.buildWindow(metaTrip);
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
        function buildWindow(this,metaTrip)
            if (this.gpsDataAvailable==false)
                this.msg = 'Pas de données GPS';
            else
                % main figure
                set(this.getFigureHandler(), 'position', [0 0 200 280]);
                set(this.getFigureHandler(), 'Name', 'GpsViewer configurator');
                closeCallbackHandle = @this.closeCallback;
                set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);

                %{
                % selecteur des données GPS a afficher
                this.gpsDataAvailable = false;
                this.checkGpsData(metaTrip);
                %}

                if this.gpsDataAvailable

                    this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 180]);

                    % Selecteur de fond de carte
                    uicontrol(this.getFigureHandler(),'Style','text','String','Type de fond de carte :',...
                        'fontsize',9,'Position',[10 150 180 20],'HorizontalAlignment','left','Backgroundcolor',[0.8 0.8 0.8]);

                    chooseMaptypeCallbackHandle = @this.chooseMaptypeCallback;
                    this.ObjectHandler.popupmenu = uicontrol(this.getFigureHandler(),'Style', 'popupmenu', 'Position', [10 50 180 100], ...
                        'String', 'roadmap|satellite|terrain|hybrid','Callback', chooseMaptypeCallbackHandle);
                    this.MapTypeChooser = 'roadmap';

                    uicontrol(this.getFigureHandler(),'Style','text','String','Source des données GPS : ',...
                        'fontsize',9,'Position',[10 90 180 20],'HorizontalAlignment','left','Backgroundcolor',[0.8 0.8 0.8]);

                    this.gpsSourceChooser = this.gpsDataList{1};
                    gps_str = this.gpsDataList{1};
                    for i=2:1:length(this.gpsDataList)
                        gps_str = [gps_str '|' this.gpsDataList{i}];%#ok
                    end
                    chooseGpsSourceCallbackHandle = @this.chooseGpsSourceCallback;
                    this.ObjectHandler.popupmenu = uicontrol(this.getFigureHandler(),'Style', 'popupmenu', 'Position', [10 50 180 40], ...
                        'String', gps_str, 'Callback', chooseGpsSourceCallbackHandle);
                    this.MapTypeChooser = 'roadmap';

            else
                
                % Message d'absence de données GPS
               
                %uicontrol(this.getFigureHandler(),'Style','text','String',('Ce plugin ne peut pas être utilisée avec le trip sélectionné car aucune table de données GPS n''a été trouvé.'),...
                   % 'fontsize',9,'Position',[10 150 180 80],'HorizontalAlignment','center','Backgroundcolor',[0.8 0.8 0.8]); 
                
                %this.msg = 'Pas de données GPS';
                
            
            end
                        
            validateCallbackHandle = @this.validateCallback;
            uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [60 10 80 40], 'Callback', validateCallbackHandle);
            
            %Set the initial GUI position
            movegui(this.getFigureHandler(), 'center');
            
            end    
        end
        
        %{
        Function:
        Check the presence of GPS data
        %}
        function checkGpsData(this,metaTrip)
        j=0;  
            if metaTrip.existDataVariable('Mopad_GPS_5Hz','Latitude_5Hz') && metaTrip.existDataVariable('Mopad_GPS_5Hz','Longitude_5Hz')
                this.gpsDataAvailable = true;
                j=j+1;
                this.gpsDataList{j} = 'GPS 5Hz';
            end
            
            if metaTrip.existDataVariable('Mopad_CentraleInertielle_IGN500','latitude_IGN') ...
                    && metaTrip.existDataVariable('Mopad_CentraleInertielle_IGN500','longitude_IGN')
                this.gpsDataAvailable = true;
                j=j+1;
                this.gpsDataList{j} = 'Centrale Inertielle';
            end
            
            if metaTrip.existDataVariable('Mopad_CentraleInertielle_IGN500','GPSraw_latitude') ...
                    && metaTrip.existDataVariable('Mopad_CentraleInertielle_IGN500','GPSraw_longitude')
                this.gpsDataAvailable = true;
                j=j+1;
                this.gpsDataList{j} = 'Centrale Inertielle (Raw Data)';   
            end
        end
        
        %{
        Function:
        Callback for the Gps Source chooser PopUpMenu
        %}
        function chooseGpsSourceCallback(this,src,~)
        val = get(src,'Value');
            for i=1:1:length(this.gpsDataList)
                if val == i
                this.gpsSourceChooser = this.gpsDataList{i};   
                end
            end
        end
        
        %{
        Function:
        Callback for the Map property chooser PopUpMenu
        %}
        function chooseMaptypeCallback(this, src, ~)
            val = get(src,'Value');
            if  val == 1
                this.MapTypeChooser = 'roadmap';
            elseif  val ==2
                this.MapTypeChooser = 'satellite';
            elseif  val ==3
                this.MapTypeChooser = 'terrain';
            elseif  val ==4
                this.MapTypeChooser = 'hybrid';
            else
                this.MapTypeChooser = 'roadmap';
            end
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
        Launched when the window have to be closed.
        
        Arguments:
        this - optional
        source - for callback
        eventData - for callback
        
        %}
        function closeCallback(this, src, eventdata)
            import fr.lescot.bind.configurators.*;
            if src ~= this.getFigureHandler()
                %GenerateConfiguration
                configuration = Configuration();
                %Set configuration
                arguments{1} = Argument('position', false, this.positionChooser.getSelectedPosition(),2);
                arguments{2} = Argument('MapType', false, this.MapTypeChooser,3);
                arguments{3} = Argument('gpsSource', false, this.gpsSourceChooser,4);
                configuration.setArguments(arguments);
                this.configuration = configuration;
                this.quitConfigurator();
                
            else
                configuration = Configuration();
                arguments = {};
                configuration.setArguments(arguments);
                this.configuration = configuration;
                this.quitConfigurator();
            end
        end
    end
    
    methods(Access = protected)
        %{
        Function:
        see <configurators.PluginConfigurator.setUIState()>
        %}
        function setUIState(this, configuration)
            position = configuration.findArgumentWithOrder(2).getValue();
            this.positionChooser.setSelectedPosition(position);
        end
    end
    
    methods(Static)
        
        function gpsDataAvailable =checkGpsDataStatic(metaTrip)
        j=0;
             gpsDataAvailable = false;
            if metaTrip.existDataVariable('Mopad_GPS_5Hz','Latitude_5Hz') && metaTrip.existDataVariable('Mopad_GPS_5Hz','Longitude_5Hz')
                gpsDataAvailable = true;
                j=j+1;
                gpsDataList{j} = 'GPS 5Hz';
            end
            
            if metaTrip.existDataVariable('Mopad_CentraleInertielle_IGN500','latitude_IGN') ...
                    && metaTrip.existDataVariable('Mopad_CentraleInertielle_IGN500','longitude_IGN')
                gpsDataAvailable = true;
                j=j+1;
                gpsDataList{j} = 'Centrale Inertielle';
            end
            
            if metaTrip.existDataVariable('Mopad_CentraleInertielle_IGN500','GPSraw_latitude') ...
                    && metaTrip.existDataVariable('Mopad_CentraleInertielle_IGN500','GPSraw_longitude')
                gpsDataAvailable = true;
                j=j+1;
                gpsDataList{j} = 'Centrale Inertielle (Raw Data)';   
            end
            
            
        end
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip,configuration) %#ok<INUSL>
            
            %Tester la présence des fichiers la tablea GPS 5Hz
            args = configuration.getArguments();
            if length(args) == 3
                out = true;
            else
                out = false;
            end
        end
    end
    
end

