%{
Class:
This class creates a plugin used for the coding of Atlas cardiac data. Each
event of the double task has to be coded in terms of : 1 - usability of the
cadiac data ; 2 - cognitive load of the participant 3 - type of task
%}
classdef AtlasCoding < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripStreamingPlugin
    
    properties (Access = private)
        
        %{
        Property:
        List of all Events table in the trip.
        %}
        eventsNamesList;
        
        %{
        Property:
        Complete information about the coded data. Structure containing the timecodes, table name, the coded values, etc.
        %}
        completeEventsList;
        
        %{
        Property:
        Array of the press buttons handles
        %}
        event_bouttons_handles;
        
        %{
        Property:
        Array containing the press buttons color infos
        %}
        event_bouttons_colors;
        
        %{
        Property:
        Strucutre containg the current Event infos : id, handles. Current
        Event  = the first preceding Event with regard to the the current
        timer
        %}
        current_event;
        
        %{
        Property:
        Strucutre containg the previous Event infos : id, handlesn, color. 
        %}
        previous_event;
      
        %{
        Property:
        Strucutre containing the handles of the different radio button group. 
        %}
        radio_button_handles;
        
        %{
        Property:
        Strucutre containing the element concerning the progressBar : front, back, text. 
        %}
        progressBar;
        
        %{
        Property:
        Cardiac data. 
        %}
        data_cardiac;
               
        %{
        Property:
        axes handles
        %}
        axe_handles;
        
        %{
        Property:
        plot handles
        %}
        plot_handles;
        
        %{
        Property:
        stem handles
        %}
        stem_handle;       
    end
    
    properties(Access = private, Constant)
        % 1 : initial color - grey ; 2 : current event color - red ;
        % 3 : modified - blue ; 4 : completed - green
        
        color_list = {[0.8 0.8 0.8] , [0.84706 0.16078 0] , [0.043137 0.51765 0.78039] , [0 0.49804 0]};
        
    end
    
    methods     
        %{
        Function:
        The constructor of the 'AtlasCoding' plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        trip - The <kernel.Trip> object on which the SituationDisplay will be
        synchronized and which situations will be displayed.
        situationIdentifiers - A cell array of strings, which are all of the
        form "situation.variableName".
        position - The starting position of the window. (In geographical notation).
        timeWindow - The width in seconds of the time windows displayed.
        
        Returns:
        out - a new 'AtlasCoding'.
        %}
        function this = AtlasCoding(trip, dataIdentifiers, position)
            import fr.lescot.bind.exceptions.ExceptionIds;
            
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            this@fr.lescot.bind.plugins.TripStreamingPlugin(trip, dataIdentifiers, 13, 'data');
            
            metas = trip.getMetaInformations;
            eventTablesNames = metas.getEventsNamesList;
            this.eventsNamesList = eventTablesNames;
            
            this.data_cardiac.timecode = nan;
            this.data_cardiac.values = nan;
            
            % Initiation 
            this.completeEventsList.timecodes =[];
            this.completeEventsList.cardiaque_exploitable =[];
            this.completeEventsList.charge_mentale =[];
            this.completeEventsList.type = [];
            this.completeEventsList.Nom = {};
            this.completeEventsList.Num_Section = {};
            this.completeEventsList.tableName ={};
            
            % Retrieving and formatting all Event table from the trip
            for i_eventTable = 1:1:length(eventTablesNames)
                if strcmp(eventTablesNames{i_eventTable},'Topage_A')...
                   || strcmp(eventTablesNames{i_eventTable},'Topage_B') ...
                   || strcmp(eventTablesNames{i_eventTable},'MindWandering') ...
                   
                    record = trip.getAllEventOccurences(eventTablesNames{i_eventTable});
                    
                    timecode_cell = record.getVariableValues('timecode');
                    N_events = length(timecode_cell);
                    table_Names = cell(1,N_events);
                    for ii=1:1:N_events
                        table_Names{ii} = eventTablesNames{i_eventTable};
                    end
                    this.completeEventsList.tableName = [this.completeEventsList.tableName table_Names];
                    variablesNames = record.getVariableNames;
                    
                    %Create coding information if the doesn't exist
                    if ~(any(strcmp(variablesNames, 'cardiaque_exploitable')) && any(strcmp(variablesNames, 'charge_mentale')) && any(strcmp(variablesNames, 'type'))) ...
                       && ~isempty(variablesNames)
                        new_variable_list = {'cardiaque_exploitable','charge_mentale','type'};
                        for i=1:1:3
                            var=fr.lescot.bind.data.MetaEventVariable();
                            var.setName(new_variable_list{i});
                            var.setType('REAL');
                            addEventVariable(trip,eventTablesNames{i_eventTable}, var);
                            trip.setBatchOfTimeEventVariablePairs(eventTablesNames{i_eventTable},new_variable_list{i},[timecode_cell ; num2cell(-1*ones(1,N_events))])
                            trip.setIsBaseEvent(eventTablesNames{i_eventTable},false)
                        end
                        record = trip.getAllEventOccurences(eventTablesNames{i_eventTable});
                        variablesNames = record.getVariableNames;
                    end
                    
                    for i_variable=1:1:length(variablesNames)
                        switch variablesNames{i_variable}
                            case 'timecode'
                                this.completeEventsList.timecodes = [this.completeEventsList.timecodes cell2mat(record.getVariableValues('timecode'))];
                                if any(strcmp('Nom',variablesNames))
                                    this.completeEventsList.Nom = [this.completeEventsList.Nom record.getVariableValues('Nom')];
                                else
                                    this.completeEventsList.Nom = [this.completeEventsList.Nom cell(1,N_events)];
                                end
                                
                                if  any(strcmp('Num _Section',variablesNames))
                                    this.completeEventsList.Num_Section = [this.completeEventsList.Num_Section record.getVariableValues('Num_Section')];
                                else
                                    this.completeEventsList.Num_Section = [this.completeEventsList.Num_Section cell(1,N_events)];
                                end
                                
                                if  any(strcmp('cardiaque_exploitable',variablesNames))
                                    this.completeEventsList.cardiaque_exploitable = [this.completeEventsList.cardiaque_exploitable cell2mat(record.getVariableValues('cardiaque_exploitable'))];
                                end
                                
                                if  any(strcmp('charge_mentale',variablesNames))
                                    this.completeEventsList.charge_mentale = [this.completeEventsList.charge_mentale cell2mat(record.getVariableValues('charge_mentale'))];
                                end
                                
                                if  any(strcmp('type',variablesNames))
                                    this.completeEventsList.type = [this.completeEventsList.type cell2mat(record.getVariableValues('type'))];
                                end
                        end
                    end
                end
            end
            
            % Sorting the event in time ascending order
            [this.completeEventsList.timecodes, id_sorted] = sort(this.completeEventsList.timecodes);
            this.completeEventsList.Nom = this.completeEventsList.Nom(id_sorted);
            this.completeEventsList.Num_Section = this.completeEventsList.Num_Section(id_sorted);
            this.completeEventsList.tableName = this.completeEventsList.tableName(id_sorted);
            this.completeEventsList.cardiaque_exploitable = this.completeEventsList.cardiaque_exploitable(id_sorted);
            this.completeEventsList.charge_mentale = this.completeEventsList.charge_mentale(id_sorted);
            this.completeEventsList.type = this.completeEventsList.type(id_sorted);
            
            % Build the GUI
            this.buildUI(position);  
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip : update the current Event, the button color and selection and the progress bar.
        %}
        function update(this, message)
            
            this.update@fr.lescot.bind.plugins.TripStreamingPlugin(message);
            %The case of a STEP or a GOTO message
            if(any(strcmp(message.getCurrentMessage(), {'STEP' 'GOTO'})))
                
                currentTime = this.getCurrentTrip().getTimer.getTime();
                eventBeforeCurrentTime_ID = find(this.completeEventsList.timecodes < currentTime+0.1);
                
                % Update current Event if necessary
                if isempty(eventBeforeCurrentTime_ID)
                    this.current_event.id = 1;
                    this.current_event.handle = this.event_bouttons_handles(1);
                else
                    this.current_event.id = eventBeforeCurrentTime_ID(end);
                    this.current_event.handle = this.event_bouttons_handles(eventBeforeCurrentTime_ID(end));
                    this.updateDataBuffer;
                end
                
                % Update previous Event
                if this.previous_event.handle == this.current_event.handle
                else
                    % restore the previous Event color
                    this.event_bouttons_colors(this.previous_event.id) = this.previous_event.color;
                    % update the previous Event
                    this.previous_event.handle = this.current_event.handle;
                    this.previous_event.id = this.current_event.id;
                    this.previous_event.color =  this.event_bouttons_colors(this.current_event.id);
                end      
                % update the radiobuttons
                this.updateRadioButtons;
                % update the color of all buttons
                this.updateAllColorsButtons;
                % update the progress bar
                this.progressionBarUpdate;
                
                % update plot
                this.updatePlot;
                % updateStem
                this.updateStem(currentTime);

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
           %set(this.getFigureHandler(), 'Visible', 'on');
           movegui(this.getFigureHandler(),position);
           
           % Size of the push buttons : the UI is build 
           b_height = 30;
           b_width = 90;
            
           N_events = length(this.completeEventsList.timecodes);
           w_height = ceil(N_events/10)*(b_height+5) + 455;
           w_width = 10*(b_width+5)+5;
           
           set(this.getFigureHandler, 'Position', [0 0 w_width w_height]);
           set(this.getFigureHandler, 'Color',[0.8 0.8 0.8]);
           set(this.getFigureHandler(), 'Name', 'Plugin Codage Atlas Route : Données Cardiaque');
           
           % Custom Progress bar
            this.progressBar.back = uicontrol(this.getFigureHandler,'Style', 'text','String','', 'Enable','inactive', ...
                   'Position', [50 w_height-75  w_width-100 20],'BackgroundColor', [0.7 0.7 0.7]);
            this.progressBar.front = uicontrol(this.getFigureHandler,'Style', 'text','String','', 'Enable','inactive', ...
                   'Position', [50 w_height-75  0.01*(w_width-100) 20],'BackgroundColor', [0 0.496 0]);
            this.progressBar.text = uicontrol(this.getFigureHandler,'Style', 'text','String','Progression', 'Enable','inactive', ...
                   'Position', [50 w_height-50  w_width-100 20],'BackgroundColor', [0.8 0.8 0.8]);
           
           % Event buttons
           EventNames = this.completeEventsList.Nom;
           %EventSection = this.completeEventsList.Num_Section;
           
           this.event_bouttons_handles = zeros(1, N_events);
           this.event_bouttons_colors = ones(1, N_events);
           moveToEventPositionHandler = @this.moveToEventPosition;
           i_col=0;
           i_ligne=1;
           for i_handles = 1:1:N_events
               if i_col>=10
                   i_col = 0;
                   i_ligne =i_ligne+1;
               end
               i_col =  i_col+1;
               this.event_bouttons_handles(i_handles) = uicontrol(this.getFigureHandler,'Style', 'pushbutton', ...
                   'String', [EventNames{i_handles}], ...
                   'Position', [5+(i_col-1)*(b_width+5) w_height-100-(i_ligne*(b_height+5))  b_width b_height], ...
                   'FontSize', 8, ...
                   'BackgroundColor', this.color_list{this.event_bouttons_colors(i_handles)}, ...
                   'Callback', moveToEventPositionHandler);
           end
           
           this.current_event.handle = this.event_bouttons_handles(1);
           this.previous_event.handle = this.event_bouttons_handles(1);
           this.current_event.id = 1;
           this.previous_event.id = 1;
           this.previous_event.color = 1;
           
           % Plot cardiac and TopConsigne
           set(0, 'currentfigure', this.getFigureHandler)
           hold on
           this.plot_handles.cardiac = plot(this.data_cardiac.timecode, this.data_cardiac.values);
           this.axe_handles.cardiac = gca;
           
           axes = axis(this.axe_handles.cardiac);
           event_bar_size = axes(3:4);
           this.plot_handles.event_position = plot([0 0],event_bar_size, 'Color', [0 0.496 0]);
           this.axe_handles.event_position = gca;
           
           set(this.axe_handles.cardiac,'Units','pixels','Position',[40 170 w_width-80 150])
           set(this.axe_handles.event_position,'Units','pixels','Position',[40 170 w_width-80 150])
           this.stem_handle = stem(0,0,'Color','red');
           hold off
        
           % Radio buttons
           radioButtonsValueChangedUpdateHandle = @this.radioButtonsValueChangedUpdate;
           
           % Group cardiaque
           this.radio_button_handles.cardiaque = uibuttongroup(this.getFigureHandler,'visible','on','Units', 'pixels','Position',[w_width/2-305 10 200 120], ...
               'Title', 'Cardiaque exploitable', 'SelectionChangeFcn', radioButtonsValueChangedUpdateHandle);
           this.radio_button_handles.cardiaque_na = uicontrol(this.getFigureHandler,'Style','radiobutton','String','n/a',...
               'pos',[10 55 50 30],'parent', this.radio_button_handles.cardiaque,'HandleVisibility','off');
           this.radio_button_handles.cardiaque_Y = uicontrol(this.getFigureHandler,'Style','radiobutton','String','oui',...
               'pos',[10 30 50 30],'parent', this.radio_button_handles.cardiaque,'HandleVisibility','off');
           this.radio_button_handles.cardiaque_N = uicontrol(this.getFigureHandler,'Style','radiobutton','String','non',...
               'pos',[10 5 50 30],'parent', this.radio_button_handles.cardiaque,'HandleVisibility','off');
           
           % Group charge mentale
           this.radio_button_handles.charge = uibuttongroup(this.getFigureHandler,'visible','on','Units', 'pixels','Position',[w_width/2-100 10 200 120], ...
               'Title', 'Charge mentale élevée', 'SelectionChangeFcn', radioButtonsValueChangedUpdateHandle);
           % Create three radio buttons in the button group.
           this.radio_button_handles.charge_na = uicontrol(this.getFigureHandler,'Style','radiobutton','String','n/a',...
               'pos',[10 55 50 30],'parent', this.radio_button_handles.charge,'HandleVisibility','off');
           this.radio_button_handles.charge_Y = uicontrol(this.getFigureHandler,'Style','radiobutton','String','oui',...
               'pos',[10 30 50 30],'parent', this.radio_button_handles.charge,'HandleVisibility','off');
           this.radio_button_handles.charge_N = uicontrol(this.getFigureHandler,'Style','radiobutton','String','non',...
               'pos',[10 5 50 30],'parent', this.radio_button_handles.charge,'HandleVisibility','off');
           
           % Group type
           this.radio_button_handles.type = uibuttongroup(this.getFigureHandler,'visible','on','Units', 'pixels','Position',[w_width/2+105 10 200 120], ...
               'Title', 'Type d''évennement', 'SelectionChangeFcn', radioButtonsValueChangedUpdateHandle);
           this.radio_button_handles.type_na = uicontrol(this.getFigureHandler,'Style','radiobutton','String','n/a',...
               'pos',[10 55 70 30],'parent', this.radio_button_handles.type,'HandleVisibility','off');
           this.radio_button_handles.type_None = uicontrol(this.getFigureHandler,'Style','radiobutton','String',{'indéfini'},...
               'pos',[10 30 70 30],'parent', this.radio_button_handles.type,'HandleVisibility','off');
           this.radio_button_handles.type_VS = uicontrol(this.getFigureHandler,'Style','radiobutton','String','Tache VS',...
               'pos',[90 55 90 30],'parent', this.radio_button_handles.type,'HandleVisibility','off');
           this.radio_button_handles.type_Verbale = uicontrol(this.getFigureHandler,'Style','radiobutton','String','Tache Verbale',...
               'pos',[90 30 90 30],'parent', this.radio_button_handles.type,'HandleVisibility','off');
           
           % Resize figure callback
           set(this.getFigureHandler(), 'Resize', 'off');
           resizeFigureCallbackHandler = @this.resizeFigureCallback;
           set(this.getFigureHandler(), 'ResizeFcn', resizeFigureCallbackHandler);
           
           movegui(this.getFigureHandler(),position);
           set(this.getFigureHandler(), 'Visible', 'on');
        end     

        %{
        Function:
        
        the resizing is handled automatically.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function resizeFigureCallback(this, ~ ,~)      
        end  
        
        function moveToEventPosition(this, button_handle, ~)
            eventTimecode = this.completeEventsList.timecodes(button_handle == this.event_bouttons_handles);
            
            this.getCurrentTrip().getTimer().stopTimer();
            pause(0.02);
            this.getCurrentTrip().getTimer().setTime(eventTimecode);     
        end
        
        function updateDataBuffer(this)
        % DataBuffer cell-array with the size [lengh(dataIdentifiers x 2] : first colum containing the data , the second column containing the timecode
            data = this.dataBuffer;   
            this.data_cardiac.timecode = cell2mat(data{1,2});
            this.data_cardiac.values =  cell2mat(data{1,1});       
        end
        
        function updateAllColorsButtons(this)
            % set modified and terminated Event to 3 and 4
            
            mask_modified_Event = ((this.completeEventsList.cardiaque_exploitable ~= -1) | ...
                                  (this.completeEventsList.charge_mentale ~= -1) | ...
                                  (this.completeEventsList.type ~= -1)) ;
            
           mask_terminated_Event = ((this.completeEventsList.cardiaque_exploitable ~= -1) & ...
                                  (this.completeEventsList.charge_mentale ~= -1) & ...
                                  (this.completeEventsList.type ~= -1)) ;
            
            this.event_bouttons_colors(~mask_modified_Event)=1;
            this.event_bouttons_colors(mask_modified_Event)=3;                  
            this.event_bouttons_colors(mask_terminated_Event)=4;
             
            % set current event to 2="red"
            this.event_bouttons_colors(this.current_event.id) = 2;
            for i = 1:1:length(this.event_bouttons_handles)
                set(this.event_bouttons_handles(i) , 'BackgroundColor', this.color_list{this.event_bouttons_colors(i)});
            end
        end
        
        function updateRadioButtons(this)
            switch this.completeEventsList.cardiaque_exploitable(this.current_event.id)
                case -1
                    h1 = this.radio_button_handles.cardiaque_na;
                case 1
                    h1 = this.radio_button_handles.cardiaque_Y;
                case 2
                    h1 = this.radio_button_handles.cardiaque_N;
            end
            set(this.radio_button_handles.cardiaque, 'SelectedObject', h1)
            
            switch this.completeEventsList.charge_mentale(this.current_event.id)
                case -1
                    h2 = this.radio_button_handles.charge_na;
                case 1
                    h2 = this.radio_button_handles.charge_Y;
                case 2
                    h2 = this.radio_button_handles.charge_N;
            end
            set(this.radio_button_handles.charge, 'SelectedObject', h2)
            
            switch this.completeEventsList.type(this.current_event.id)
                case -1
                    h3 = this.radio_button_handles.type_na;
                case 1
                    h3 = this.radio_button_handles.type_None;
                case 2
                    h3 = this.radio_button_handles.type_VS;
                case 3
                    h3 = this.radio_button_handles.type_Verbale;
            end
            set(this.radio_button_handles.type, 'SelectedObject', h3)
        end
        
        function radioButtonsValueChangedUpdate(this,source,Eventdata)
            trip = this.getCurrentTrip();
            switch source
                case this.radio_button_handles.cardiaque
                    switch Eventdata.NewValue
                        case this.radio_button_handles.cardiaque_na
                            this.completeEventsList.cardiaque_exploitable(this.current_event.id) = -1;
                        case this.radio_button_handles.cardiaque_Y
                            this.completeEventsList.cardiaque_exploitable(this.current_event.id) = 1;
                        case this.radio_button_handles.cardiaque_N
                            this.completeEventsList.cardiaque_exploitable(this.current_event.id) = 2;
                    end
                    trip.setEventVariableAtTime(this.completeEventsList.tableName{this.current_event.id}, 'cardiaque_exploitable', ...
                                                this.completeEventsList.timecodes(this.current_event.id), this.completeEventsList.cardiaque_exploitable(this.current_event.id))
                    
                case this.radio_button_handles.charge
                    switch Eventdata.NewValue
                        case this.radio_button_handles.charge_na
                            this.completeEventsList.charge_mentale(this.current_event.id) = -1;
                        case this.radio_button_handles.charge_Y
                            this.completeEventsList.charge_mentale(this.current_event.id) = 1;
                        case this.radio_button_handles.charge_N
                            this.completeEventsList.charge_mentale(this.current_event.id) = 2;
                    end
                    trip.setEventVariableAtTime(this.completeEventsList.tableName{this.current_event.id}, 'charge_mentale', ...
                                                this.completeEventsList.timecodes(this.current_event.id), this.completeEventsList.charge_mentale(this.current_event.id))

                case this.radio_button_handles.type
                    switch Eventdata.NewValue
                        case this.radio_button_handles.type_na
                            this.completeEventsList.type(this.current_event.id) = -1;
                        case this.radio_button_handles.type_None
                            this.completeEventsList.type(this.current_event.id) = 1;
                        case this.radio_button_handles.type_VS
                            this.completeEventsList.type(this.current_event.id) = 2;
                        case this.radio_button_handles.type_Verbale
                            this.completeEventsList.type(this.current_event.id) = 3;   
                    end
                    trip.setEventVariableAtTime(this.completeEventsList.tableName{this.current_event.id}, 'type', ...
                                                this.completeEventsList.timecodes(this.current_event.id), this.completeEventsList.type(this.current_event.id))
            end
        end
        
        function progressionBarUpdate(this)
            
            pos_back = get(this.progressBar.back,'Position');
            pos_front = get(this.progressBar.front,'Position');
            
            ratio = nnz(this.event_bouttons_colors == 4)/length(this.event_bouttons_colors);
            pour = 100*ratio;
   
            set(this.progressBar.front, 'Position', [pos_front(1) pos_front(2) (ratio+0.01)*pos_back(3) pos_front(4)]);
            set(this.progressBar.text, 'String', ['Progression - le trip est complété à ' num2str(ceil(pour)) ' %']);
            
        end
        
        function updatePlot(this)
            
            import fr.lescot.bind.utils.StringUtils;
            
            currentEventTime = this.completeEventsList.timecodes(this.current_event.id);
            [~,closestCurrentTime_id] =  min(abs(this.data_cardiac.timecode - currentEventTime));
            closestCurrentTime = this.data_cardiac.timecode(closestCurrentTime_id);
            if max(this.data_cardiac.timecode) - closestCurrentTime > 6 && closestCurrentTime - min(this.data_cardiac.timecode) > 0.5
                mask_cardiac = (this.data_cardiac.timecode < currentEventTime + 6) & (this.data_cardiac.timecode > currentEventTime - 0.5);
            else
                return
            end
            xData = this.data_cardiac.timecode(mask_cardiac);
            yData = this.data_cardiac.values(mask_cardiac);
            
            Utils = fr.lescot.bind.utils.StringUtils;
            formatTimecode = @(x) Utils.formatSecondsToString(x);
            
            if ~isempty(xData)             
                set(this.plot_handles.cardiac, 'XData', xData, 'YData', yData)
                
                current_axes =  [min(xData), max(xData), min(yData)*1.1 , max(yData)*1.1+0.1];
                
                axis(this.axe_handles.cardiac, current_axes);
                axis(this.axe_handles.event_position, current_axes);
                
                set(this.axe_handles.cardiac,'XTickLabel',arrayfun(formatTimecode,round(min(xData):1:max(xData)),'UniformOutput',0));

                xData = [currentEventTime currentEventTime];
                yData = current_axes(3:4);
                set(this.plot_handles.event_position, 'XData', xData, 'YData', yData)
            end
        end

        function updateStem(this,currentTime)
             [~,id_time]= min(abs(this.data_cardiac.timecode - currentTime));
            set(this.stem_handle,'XData', this.data_cardiac.timecode(id_time) ,'YData', this.data_cardiac.values(id_time));
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
            out = 'fr.lescot.bind.configurators.AtlasCodingConfigurator';   
        end
        
        %{
        Function:
        Implements <fr.lescot.bind.plugins.Plugin.geName()>.
        %}
        function out = getName()
            out = '[Atlas] Codage cardiaque';   
        end  
    end
end