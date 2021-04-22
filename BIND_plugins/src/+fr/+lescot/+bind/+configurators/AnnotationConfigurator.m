%{
Class:
This class is the configurator of the <EventSituationBrowser> plugin

%}
classdef AnnotationConfigurator < fr.lescot.bind.configurators.PluginConfigurator
    
    properties
        %{
        Property:
        The handler on the widget.
        %}
        EventSituationSelector;
        
        tripMetaInformation;
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
        function this = AnnotationConfigurator(pluginId, metaTrip, caller, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator(pluginId, metaTrip, caller);
            
            % first argument of varargin is a configuration that should
            % have a markerIdentifier value
            if length(varargin) == 1
                configuration = varargin{1};
                
                cellArrayOfMarkerIdentifier = configuration.findArgumentWithOrder(2).getValue();
                firstElement = cellArrayOfMarkerIdentifier{1};
                splittedDataName = regexp(firstElement, '\.', 'split');
                markerName = splittedDataName{1};
                
                if metaTrip.existEvent(markerName)
                    selectedIdentifier = 'event.';
                end
                if metaTrip.existSituation(firstElement)
                    selectedIdentifier = 'situation.';
                end
                    
                
                selectedIdentifier = [selectedIdentifier markerName];
            else
                selectedIdentifier = 'event.';
            end
             
            this.buildWindow(metaTrip,selectedIdentifier);
            this.tripMetaInformation = metaTrip;
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
                    
                    splittedDataName = regexp(this.EventSituationSelector.getSelectedIdentifier(), '\.', 'split');
                    type = splittedDataName{1};
                    markerName = splittedDataName{2};
                    switch type
                        case 'event'
                        markerVariablesNamesList =  this.tripMetaInformation.getEventVariablesNamesList(markerName);
                    case 'situation'
                        markerVariablesNamesList = this.tripMetaInformation.getSituationVariablesNamesList(markerName);
                    end
                    
                    N = length(markerVariablesNamesList);
                    cellArrayOfMarkerIdentifier = cell(1,N);
                    for i = 1:N
                        cellArrayOfMarkerIdentifier{i} = [ markerName '.' markerVariablesNamesList{i}];
                    end
                    
                    arguments = {Argument('selectedIdentifier', false, cellArrayOfMarkerIdentifier,2)};
                    configuration.setArguments(arguments);
                    %Set configuration
                    this.configuration = configuration;
                    this.quitConfigurator();
                end
            end
        end
    end
    
    methods(Static)
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip, configuration) %#ok<INUSL>
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
            
            out = true;
            return;
            
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

