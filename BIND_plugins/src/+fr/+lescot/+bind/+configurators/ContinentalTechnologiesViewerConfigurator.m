%{
Class:
This class is the configurator of the <ContinentalTechnologiesViewer> plugin

%}
classdef ContinentalTechnologiesViewerConfigurator < fr.lescot.bind.configurators.PluginConfigurator
    
    properties
        %{
        Property:
        The handler on the position chooser widget.
        %}
        positionChooser;
    end
    
    properties (Access = private, Constant)
        %{
        Property:
        
        List of variables used in the ContinentalTechnologiesViewer plugin.
        
        %}
        CONTI_DATA = {  'Kvaser_ARS', ...
                        'Kvaser_LDW1', ...
                        'Kvaser_LDW2', ...
                        'Kvaser_LDW3', ...
                        'Kvaser_SLA'};
        
        CONTI_VARIABLES = {{'ID','LatDispl','LongDispl','Length','Width','VrelLong','LatSpeed'} ... % cell 1
                           {'ALDW_LaneLtrlDist','ALDW_LaneNum','ALDW_LaneWidth','ALDW_LaneYawAngl','ALDW_NumLane'}... % cell 2
                           {'ALDW_LanClothoidPara', 'ALDW_LaneHrztCrv', 'ALDW_LanMkCol_Lt','ALDW_LanMkCol_Rt','ALDW_LanMkLftType','ALDW_LanMkRitType'} ... % cell 3
                           {'ALDW_LanMkLftWidth','ALDW_LanMkRitWidth'} ... % cell 4
                           {'SLA_WarnSpd_Val'}}; % cell 4
    
    end
    methods
        
        %{
        Function:
        The constructor of the ContinentalTechnologiesViewer plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        tripInformation - a <data.MetaInformations> object that stores the
        available videos
        caller - handler to the interface that ask for a configuration, in
        order to be able to give back the configurator when closing.
        
        
        Returns:
        this - a new ContinentalTechnologiesViewerConfigurator.
        %}
        function this = ContinentalTechnologiesViewerConfigurator(pluginId, metaTrip, caller, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator(pluginId, metaTrip, caller);
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
            set(this.getFigureHandler(), 'position', [0 0 200 150]);
            set(this.getFigureHandler(), 'Name', 'ContinentalTechnologiesViewer configurator');
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
        function closeCallback(this, src,~)
            import fr.lescot.bind.configurators.*;
            if src ~= this.getFigureHandler()
                % GenerateConfiguration
                configuration = Configuration();
                arguments = {};
                
                % Formating of Data.Identifier
                i_identifiers =1;
                for i_data =1:1:length(this.CONTI_DATA)
                    for i_variables=1:1:length(this.CONTI_VARIABLES{i_data})
                        temp = this.CONTI_VARIABLES{i_data};
                        CONTI_dataIdentifiers{i_identifiers} = [this.CONTI_DATA{i_data} '.' temp{i_variables}];%#ok!
                        i_identifiers = i_identifiers+1;
                    end 
                end
                % Creating the configurator arguments
                arguments{1} = Argument('dataIdentifiers', false, CONTI_dataIdentifiers, 2);
                arguments{2} = Argument('position', false, this.positionChooser.getSelectedPosition(), 3);
                configuration.setArguments(arguments);
                %Set configuration
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
            position = configuration.findArgumentWithOrder(3).getValue();
            this.positionChooser.setSelectedPosition(position);
        end
    end
    
methods(Static)
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip, configuration)
            valid = true;
            %Check if the object is a configuration
            if ~isa(configuration, 'fr.lescot.bind.configurators.Configuration')
                valid = false;
            end
            
            %Check that the data to display are all available in the datas
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
                    warndlg(sprintf('The required data for the plugin are not available in the selected trip. \n Pleased check that kvaser data were imported using the ad hoc script.'));
                    break;
                end
            end
            out = valid;
        end
    end
    
end

