%{
Class:
This class describes a plugin that allow to display the values of several
variables of the trip at the current time in a table.

%}
classdef Annotation < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripStreamingPlugin
    
    properties(Access = private)
        %{
        Property:
        The handler of the display table.
        
        %}
        tableHandler;
        
        %{
        Property:
        The cell array containing the variables to plot with a "data.variable" format.
        
        %}
        dataIdentifiers;
        
        editList;
        labelDisplayCurrentTimecode;
        eventReferenceTimecode;
        updateEventButton;
        addNewEventButton;
        removeEventButton;
    end
    
    methods
        
        %{
        Function:
        The constructor of the Annotation plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        
        trip - The <kernel.Trip> object on which the DataPlotter will be
        synchronized and which data will be displayed.
        dataIdentifiers - A cell array of strings, which are all of the
        form "dataName.variableName".
        position - The initial position of the window.
        %}
        function this = Annotation(trip, dataIdentifiers, position)
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            this@fr.lescot.bind.plugins.TripStreamingPlugin(trip, dataIdentifiers, 60, 'event');
            
            this.dataIdentifiers = dataIdentifiers;
            
            this.buildUI('center');
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)
            this.update@fr.lescot.bind.plugins.TripStreamingPlugin(message);
            if any(strcmp(message.getCurrentMessage(),{'STEP' 'GOTO' 'EVENT_CONTENT_CHANGED'}))
                this.refreshUI();
            end
        end
        
        function refreshUI(this)
            currentTime = this.getCurrentTrip().getTimer().getTime();
            set(this.labelDisplayCurrentTimecode,'String',num2str(currentTime));
            for i = 1:1:this.dataNumber
                [~, ind] = min( abs(cell2mat(this.dataBuffer{i,2}) - (currentTime)) );
                
                if (isscalar(ind))
                    this.eventReferenceTimecode = num2str(this.dataBuffer{i,2}{ind});
                    
                    set(this.editList{1},'String',this.eventReferenceTimecode);
                    valeur = this.dataBuffer{i,1}{ind};
                    set(this.editList{i+1},'String',valeur);
                end
            end
            if isempty(this.eventReferenceTimecode)
                % disactive update and remove buttons
                set(this.removeEventButton,'Enable','off');
                set(this.updateEventButton,'Enable','off');
            else
                % reactive update and remove buttons
                set(this.removeEventButton,'Enable','on');
                set(this.updateEventButton,'Enable','on');
            end
        end
        
        %{
        Function:
        Build the window of the GUI
        
        Arguments:
        this - The object on which the function is called, optionnal.
        position - The initial position of the GUI.
        
        %}
        function buildUI(this, position)
            cellHeigth = 20;
            spacing = cellHeigth + 5; % decallage du label vers le bas
            lineNumber = (this.dataNumber + 4); % 4 more lines : 2 timecodes 1 buttons and 1 spare
            windowHeigth = lineNumber * spacing;
            
            % main window creation
            splittedEventName = regexp(this.dataIdentifiers{1}, '\.', 'split');
            eventName = splittedEventName{1};
            set(this.getFigureHandler(), 'Position', [0 0 300 windowHeigth]);
            set(this.getFigureHandler(), 'Name', [ 'Annotation - Event : ' eventName]);
            
            % display texts for current timecode
            position = windowHeigth - spacing ;
            labelCurrentTimecode = uicontrol(this.getFigureHandler(), 'Style', 'text', 'Position', [0 position 150 cellHeigth], 'BackgroundColor', get(this.getFigureHandler(), 'Color'));
            set(labelCurrentTimecode,'String', [eventName ' timecode']);
            this.labelDisplayCurrentTimecode = uicontrol(this.getFigureHandler(), 'Style', 'text', 'Position', [150 position 120 cellHeigth], 'BackgroundColor', get(this.getFigureHandler(), 'Color'));
            
            % display arrow button that permit to copy current tc to event field
            position = position - 5;
            setEventWithCurrentTimecodeButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'Position',[200 position 10 10], 'BackgroundColor', get(this.getFigureHandler(), 'Color'));
            set(setEventWithCurrentTimecodeButton,'String', 'v');
            setEventWithCurrentTimecodeCallbackHandle = @this.setEventWithCurrentTimecode;
            set(setEventWithCurrentTimecodeButton, 'Callback', setEventWithCurrentTimecodeCallbackHandle);
            
            % display event timecode
            position = windowHeigth - 2*spacing ;
            labelEventTimecode = uicontrol(this.getFigureHandler(), 'Style', 'text', 'Position', [0 position 150 cellHeigth], 'BackgroundColor', get(this.getFigureHandler(), 'Color'));
            set(labelEventTimecode,'String', 'Event Timecode');
            this.editList{1} =  uicontrol(this.getFigureHandler(), 'Style', 'edit', 'Position', [150 position 120 cellHeigth], 'BackgroundColor', 'w');
            
            % display event variables
            for i = 1:1:this.dataNumber
                position = windowHeigth - (spacing * (i+2));
                label = uicontrol(this.getFigureHandler(), 'Style', 'text', 'Position', [0 position 150 cellHeigth], 'BackgroundColor', get(this.getFigureHandler(), 'Color'));
                set(label,'String', this.dataIdentifiers{i});
                this.editList{i+1} =  uicontrol(this.getFigureHandler(), 'Style', 'edit', 'Position', [150 position 120 cellHeigth], 'BackgroundColor', 'w');
            end
            
            % add buttons for actions on events
            position = windowHeigth - (spacing * (this.dataNumber+3));
            
            this.updateEventButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'Position', [0 position 80 cellHeigth]);
            set(this.updateEventButton,'String', 'Update Event');
            updateEventCallbackHandle = @this.updateEventCallback;
            set(this.updateEventButton, 'Callback', updateEventCallbackHandle);
            
            this.addNewEventButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'Position', [100 position 80 cellHeigth]);
            set(this.addNewEventButton,'String', 'Add New Event');
            addNewEventCallbackHandle = @this.addNewEventCallback;
            set(this.addNewEventButton, 'Callback', addNewEventCallbackHandle);
            
            this.removeEventButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'Position', [200 position 80 cellHeigth]);
            set(this.removeEventButton,'String', 'Remove Event');
            removeEventCallbackHandle = @this.removeEventCallback;
            set(this.removeEventButton, 'Callback', removeEventCallbackHandle);
            
            % populate the user interface
            this.refreshUI();
            
            movegui('center');
            set(this.getFigureHandler(), 'Visible', 'on');
        end
        
        function setEventWithCurrentTimecode(this, src, eventdata)
            currentTime = this.getCurrentTrip().getTimer().getTime();
            set(this.editList{1},'String',num2str(currentTime));
        end
        
        function removeEventCallback(this, src, eventdata)
            referenceTimecode =str2num(this.eventReferenceTimecode);
            splittedEventName = regexp(this.dataIdentifiers{1}, '\.', 'split');
            eventName = splittedEventName{1};
            this.getCurrentTrip().removeEventOccurenceAtTime(eventName,referenceTimecode);
            this.refreshUI();
        end
        
        function addNewEventCallback(this, src, eventdata)
            timecode = get(this.editList{1},'String');
            referenceTimecode =this.eventReferenceTimecode;
            
            if strcmp(timecode,referenceTimecode)
                message = sprintf('Vous essayer d''ajouter un nouvel événement... \n mais un événement avec ce timecode existe déjà!');
                title = 'Warning : event already exists';
                choice = questdlg(message,title,'Ecraser','Annuler','Annuler' );
                % Handle response
                if strcmp(choice,'Stop')
                    return
                end
            end
            
            if ~isempty(timecode)
                for i = 1:1:this.dataNumber
                    splittedEventName = regexp(this.dataIdentifiers{i}, '\.', 'split');
                    eventName = splittedEventName{1};
                    variableName = splittedEventName{2};
                    value = char(get(this.editList{i+1},'String'));
                    this.getCurrentTrip().setEventVariableAtTime(eventName,variableName,str2num(timecode),value);
                end
            else
                msgbox('cannot add this event: no time code specified');
            end
            this.refreshUI();
        end
        
        function updateEventCallback(this, src, eventdata)
            referenceTimecode = str2num(this.eventReferenceTimecode);
            if ~isempty(referenceTimecode)
                % save data of current event
                timecode = get(this.editList{1},'String');
                for i = 1:1:this.dataNumber
                    value{i} = char(get(this.editList{i+1},'String'));
                end
                
                %delete old event
                splittedEventName = regexp(this.dataIdentifiers{1}, '\.', 'split');
                eventName = splittedEventName{1};
                variableName = splittedEventName{2};
                this.getCurrentTrip().removeEventOccurenceAtTime(eventName,referenceTimecode);
                
                
                % then we re create new event
                for i = 1:1:this.dataNumber
                    splittedEventName = regexp(this.dataIdentifiers{i}, '\.', 'split');
                    eventName = splittedEventName{1};
                    variableName = splittedEventName{2};
                    this.getCurrentTrip().setEventVariableAtTime(eventName,variableName,str2num(timecode),value{i});
                end
            end
            this.refreshUI();
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
            out = '[E][S] Editeur de valeurs';
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
            out = 'fr.lescot.bind.configurators.AnnotationConfigurator';
        end
        
    end
    
end