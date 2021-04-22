%{
Class:
This class creates a plugin used to browse easily to events or situations.


%}
classdef EventSituationBrowser < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripPlugin
    %%%%%
    properties(Access=public)
        newPosition;
    end
    %%%%
    
    properties (Access = private)
        %{
        Property:
        the widget, a <fr.lescot.bind.widget.EventSituationList> widget that can be used to browse through events
        
        %}       
        EventSituationList
        
        %{
        Property:
        the handler of the trip that is synchronised with the plugin
        
        %}
        theTrip
        
        %{
        Property:
        a string explaining which marker is followed : formed like 'event'.EventName or 'situation'.SituationName
        %}
        markerIdentifier
        
        %{
        Property:
        the handler of the panel that holds controls for filter use
        
        %}
        filterPanel
        
        %{
        Property:
        the handler of the list of active filters
        
        %}
        filterList
        
        %{
        Property:
        the handler of button to add a filter
        
        %}
        filterAddButton
        
        %{
        Property:
        the handler of the button that allow filter removal
        
        %}
        filterRemoveButton
        
        %{
        Property:
        a cell array of string describing filters : 'variable = value'
        
        %}
        filtersArray
    end
    
    methods
        %{
        Function:
        The constructor of the EventSituationBrowser plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        trip - The <kernel.Trip> object on which the EventSituationBrowser will be
        synchronized and which data will be displayed.
        markerIdentifier - A cell string of the form "event.EventName" OR "situation.SituationName".
        
        
        Returns:
        this - a new event and situation browser plugin.
        %}
        function this = EventSituationBrowser(trip, markerIdentifier, varargin)
            import fr.lescot.bind.utils.StringUtils;
            % we call the constructor of the superclasses "TripPlugin" &
            % "GraphicalPlugin"
            this@fr.lescot.bind.plugins.TripPlugin(trip);
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            
            this.theTrip = trip;
            this.filtersArray = {};
            % check if markerIdentifier is of the correct form
            if strmatch('situation.',char(markerIdentifier))
                marker = 'situation';
            else
                if strmatch('event.',char(markerIdentifier))
                    marker = 'event';
                end
            end
            
            if ~exist('marker','var')
                msgbox('wrong declaration of marker, should be situation.name or event.name');
                return
            else
                this.markerIdentifier = markerIdentifier;
            end
            
            % creation of the UI
            this.buildUI()
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)
            %launch the update method of the widget
            this.EventSituationList.update(message);            
        end        
    end
    
    methods(Access = private)
        
        %{
        Function:
        Create graphical user interface dynamically according to event
        properties and load the widget.
        
        Arguments:
        this - optionnal, the object on which the function is called        
        %}
        function buildUI(this)
            set(this.getFigureHandler(), 'Position', [0 0 600 350]);
            set(this.getFigureHandler(), 'Name', 'Browser');
            set(this.getFigureHandler(), 'Resize', 'on');
            callbackHandler = @this.resizePluginCallback;
            set(this.getFigureHandler(), 'ResizeFcn', callbackHandler);
            
            % use the fancy widget ^^
            this.EventSituationList = fr.lescot.bind.widgets.EventSituationList(this.getFigureHandler(),...
                this.theTrip,...
                this.markerIdentifier,...
                'Position', [5 2],...
                'Size', [400 350],...
                'BackgroundColor', get(this.getFigureHandler(), 'Color') );
            
            % panel for filters and filter controls
            this.filterPanel =  uipanel(this.getFigureHandler(), 'Units', 'pixels', 'Position', [410 2 170 350], 'Title', 'Filters', 'BackgroundColor', get(this.getFigureHandler(), 'Color')  );
            
            this.filterList = uicontrol(this.filterPanel,'Style','listbox','Position',[2 50 160 280],'BackgroundColor','White','String',{});
            set(this.filterList, 'Max',0,'Min',0);
            
            this.filterAddButton = uicontrol(this.filterPanel,'Style','pushbutton','Position',[20 12 30 30], 'String','+');
            callbackHandler = @this.filterAddButtonCallback;
            set(this.filterAddButton, 'Callback', callbackHandler);
            
            this.filterRemoveButton = uicontrol(this.filterPanel,'Style','pushbutton','Position',[60 12 30 30], 'String','-');
            callbackHandler = @this.filterRemoveButtonCallback;
            set(this.filterRemoveButton, 'Callback', callbackHandler);
            set(this.filterRemoveButton,'Enable','off');
            
            % this plugin is always at the center
            movegui(this.getFigureHandler, 'center');
            
            %Setting visible
            set(this.getFigureHandler,'Visible', 'on');
            
            
            
             %%%%%%%%%%%%%%%
            %fermeture de la figure
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            %%%%%%%%%%%%%
        end
        
        %{
        Function:
        callback triggered when the user resize the plugin window with the mouse
        
        Arguments:
        this - optionnal, the object on which the function is called        
        source - the button clicked bu the user
        eventdata - additional information for callback
        %}
        function resizePluginCallback(this,source, eventdata)
            % get the new windows dimension 
            newPosition = get(this.getFigureHandler,'Position');
            newHeigth = newPosition(4);
            newWidth = newPosition(3);
            targetWidth = max(600,newWidth);
            targetHeigth = max(350,newHeigth);
            
            % prevent window to become to small!
            set(this.getFigureHandler,'Position',[newPosition(1) newPosition(2) targetWidth targetHeigth]);
            
            % set dimension for the widget 
            this.EventSituationList.setSize([targetWidth-200 targetHeigth]);
            
            %set dimension of other components of the plugin
            set(this.filterPanel, 'Position', [targetWidth-200+10 2 170 targetHeigth]);
            set(this.filterList,'Position',[2 50 160 targetHeigth-70]);
        end
        
        
         %%%%%%%%%%%%%%  
         function closeCallback(this, src, ~)%ajout closeCallback
                nouvellePosition=this.getFigureHandler.Position();
                this.newPosition=nouvellePosition
                delete(this.getFigureHandler);
        end
        %%%%%%%%%%%%%%%
        
        %{
        Function:
        callback triggered when the user click on the button to add a filter on the user interface.
        
        Arguments:
        this - optionnal, the object on which the function is called        
        source - the button clicked bu the user
        eventdata - additional information for callback
        %}
        function filterAddButtonCallback(this,source, eventdata)
            answer = inputdlg('Type in filter ( column=value )','Add filter');
            splittedName = regexp(answer, '\=', 'split');
            if length(splittedName{1}) ~=2
                msgbox('Noob');
            else
                this.EventSituationList.addFilter(splittedName{1}{1},'equal',splittedName{1}{2});
                this.filtersArray = {this.filtersArray{:} char(answer)};
                set(this.filterList,'String',this.filtersArray);
            end
            this.setFilterButtonStatus();
            set(this.filterList,'Value',length(this.filtersArray));
        end

        %{
        Function:
        callback triggered when the user click on the button to delete a filter on the user interface.
        
        Arguments:
        this - optionnal, the object on which the function is called        
        source - the button clicked bu the user
        eventdata - additional information for callback
        %}
        function filterRemoveButtonCallback(this,source, eventdata)
            filterIndice = get(this.filterList,'Value');
            this.EventSituationList.deleteFilter(filterIndice);
            this.filtersArray(filterIndice) = [];
            set(this.filterList,'String',this.filtersArray);
            set(this.filterList,'Value',length(this.filtersArray));
            this.setFilterButtonStatus();
        end
        
        %{
        Function:
        Enable or disable the filter buttons according to the contents of the filter list  

        Arguments:
        this - optionnal, the object on which the function is called        
        %}
        function setFilterButtonStatus(this)
            if isempty(this.filtersArray)
                set(this.filterRemoveButton,'Enable','off');
            else
                set(this.filterRemoveButton,'Enable','on');
            end
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
            out = 'Explorer Events & Situations';
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
            out = 'fr.lescot.bind.configurators.EventSituationBrowserConfigurator';
        end
        
   

        
    end
    
end
