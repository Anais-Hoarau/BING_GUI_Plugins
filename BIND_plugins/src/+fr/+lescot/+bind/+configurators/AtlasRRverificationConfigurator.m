%{
Class:
This class is the configurator of the <AtlasRRverificationConfigurator> plugin

%}
classdef AtlasRRverificationConfigurator < fr.lescot.bind.configurators.PluginConfigurator
    
    properties
        %{
        Property:
        The handler on the position chooser widget.
        %}
        positionChooser;
        
    end
    
    
    methods
        
        %{
        Function:
        The constructor of the AtlasCodingConfigurator plugin. When instanciated, a
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
        function this = AtlasRRverificationConfigurator(pluginId, metaTrip, caller, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator(pluginId, metaTrip, caller);
         
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
            % main figure
            set(this.getFigureHandler(), 'position', [0 0 200 180]);
            set(this.getFigureHandler(), 'Name', 'AtlasCoding configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            
            this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 60]);
            validateCallbackHandle = @this.validateCallback;
            uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [60 10 80 40], 'Callback', validateCallbackHandle);
            
            %Set the initial GUI position
            movegui(this.getFigureHandler(), 'center');
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
                MP150_dataIdentifiers{1} = 'MP150_data.Cardiaque_filtre';
                arguments{1} = Argument('dataIdentifiers', false, MP150_dataIdentifiers, 2);
                arguments{2} = Argument('position', false, this.positionChooser.getSelectedPosition(),3);
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
        
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip,configuration)

            % Tester si les 2 arguments ont bien était passés
            args = configuration.getArguments();
   
            if length(args) == 2 && referenceTrip.existData('MP150_data') && referenceTrip.existEvent('cardiac_RRintervals')
                out = true;
            elseif ~referenceTrip.existData('MP150_data')
                warndlg('There is no MP150_data table in the selected trip. Make sure that the trip contain cardiac data to use this the Atlas coding plugin')
                out = false;
            elseif ~referenceTrip.existEvent('cardiac_RRintervals')
                warndlg(['No RR intervals present in the trip. Make sure to run the script :' sprintf('\n') ...
                    ''' atlas_cardiac_RRintervalsdectection'' before using this plugin'])
                out = false;
            end
        end
    end
end

