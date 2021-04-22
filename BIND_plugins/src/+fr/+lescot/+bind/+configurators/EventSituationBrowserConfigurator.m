%{
Class:
This class is the configurator of the <EventSituationBrowser> plugin

%}
classdef EventSituationBrowserConfigurator < fr.lescot.bind.configurators.PluginConfigurator_simplif
    
    properties
        %{
        Property:
        The handler on the widget.
        %}
        EventSituationSelector;
        
    end
    
    methods
        
        %{
        Function:
        The constructor of the EventSituationBrowserConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        tripInformation - a <data.MetaInformations> object that stores the
        available videos
        caller - handler to the interface that ask for a configuration, in
        order to be able to give back the configurator when closing.
        
        
        Returns:
        this - a new EventSituationBrowserConfigurator.
        %}
        function this = EventSituationBrowserConfigurator(pluginName, trip, metaTrip, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator_simplif(pluginName, trip, metaTrip, varargin);
            
            % first argument of varargin is a configuration that should
            % have a markerIdentifier value
            if length(varargin) == 1
                configuration = varargin{1};
                selectedIdentifier = configuration.findArgumentWithOrder(2).getValue();
            else
                selectedIdentifier = 'event.';
            end
            
            this.buildWindow(metaTrip,selectedIdentifier);
        end
        
        
    end
    
    methods(Access = protected)
                %{
        Function:
        This method is called when a configurator is called and there is
        already an existing configuration in the loader.
        
        Arguments:
        this - optional
        
        %}
        function setUIState(this, configuration)
            % TODO : Move configuration.selectedIdentifier in class
            % variable
        end
        
    end
    
    methods(Access = private)
        
        %{
        Function:
        Build the window and instanciate the Event Situation selector widget
        
        Arguments:
        this - optional
        
        %}
        function buildWindow(this,metaTrip,markerIdentifier)
            set(this.getFigureHandler(), 'position', [0 0 320 270]);
            set(this.getFigureHandler(), 'Name', 'Browser configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            
            this.EventSituationSelector = fr.lescot.bind.widgets.EventSituationSelector(this.getFigureHandler(), metaTrip,markerIdentifier, 'Position', [10 60]);
            
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
        function closeCallback(this, src, ~)
            import fr.lescot.bind.configurators.*;
            if src ~= this.getFigureHandler()
                % check if returned config is valide
                selectedItem = this.EventSituationSelector.getSelectedIdentifier();
                if ~isempty(selectedItem)
                    %GenerateConfiguration
                    configuration = Configuration();
                    arguments = {Argument('selectedIdentifier', false, this.EventSituationSelector.getSelectedIdentifier(),2)};
                    configuration.setArguments(arguments);
                    %Set configuration
                    this.configuration = configuration;
                else
                    this.configuration = {};
                end
                this.quitConfigurator();
            end
        end
    end
    
    methods(Static)
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip, configuration)
             valid = false;
            %Check if the object is a configuration
            if ~isa(configuration, 'fr.lescot.bind.configurators.Configuration')
                out = valid;
                return;
            else
                args = configuration.getArguments();
                % and verify if there is only 1 argument, as expected
                if length(args) > 1
                    out = valid;
                    return;
                end
            end
            
            %Check that the event / situation to browse is available in
            %the datas
            markerConfigured = configuration.findArgumentWithOrder(2).getValue();
            
            % check if markerConfigured is of the correct form
            if startsWith('situation.',markerConfigured)
                marker = 'situation';
            else
                if startsWith('event.',markerConfigured)
                    marker = 'event';
                else
                    % the marker must start by situation. or event.
                    out = valid;
                    return;
                end
            end
                       
            switch marker
                case ('situation')
                    markerNamesList = referenceTrip.getSituationsNamesList();
                case ('event')
                    markerNamesList = referenceTrip.getEventsNamesList();
            end
            
            for i=1:length(markerNamesList)
                markerId = [ marker '.' char(markerNamesList(i))];
                if strcmp(markerId,markerConfigured)
                    valid = true;
                end
            end
            
            out = valid;
        end
    end
    
end

