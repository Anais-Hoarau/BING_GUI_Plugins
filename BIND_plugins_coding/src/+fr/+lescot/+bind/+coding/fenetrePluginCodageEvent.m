classdef fenetrePluginCodageEvent < fr.lescot.bind.coding.fenetrePluginCodage
    properties
        eventButtons;
        
        codedEventList;
        
        currentVariable;
        
        currentEventIndex;
        
        lastClickedEvent;
        
        existingEvents;
        
        refreshList;
    end
    
    properties (Constant)
        columnNames = {'#','Timecode','Modalités'};
        
    end
    
    methods
        function this = fenetrePluginCodageEvent(figureHandler,Variable)
            this@fr.lescot.bind.coding.fenetrePluginCodage(figureHandler)
            this.currentVariable = Variable;
            this.currentEventIndex = [];
            this.lastClickedEvent = [];
            this.existingEvents = {};
            this.refreshList =true;
            
            if ~this.currentVariable.isInfosGraphicOk
                this.initiliazeWindow;
            else
                infosGraphic = this.currentVariable.getInfosGraphic;
                this.rebuildWindow(infosGraphic);
            end
            set(this.getFigureHandler(), 'Resize', 'On');
            set(this.getFigureHandler(), 'Visible', 'On');
        end
        
        function initiliazeWindow(this)
            %% Retrieving modalities
            Modalities = this.currentVariable.getAllModalities;
            N = length(Modalities);
            
            %% Figure (suite)
            this.setName(['Codage Evènement : ' this.currentVariable.getName])
%             this.setPosition([0 0 345 max(40+25*N,160)])
            this.setPosition([0 0 345 max(40+25*20,160)])
            this.setColor([0.8 0.8 0.8])
            movegui(this.getFigureHandler(),'center')
            
            %% Create Button
            this.eventButtons = cell(1,N);
            for i_buttons = 1:1:N
                this.eventButtons{i_buttons} = fr.lescot.bind.coding.eventCodingButtons(this.getFigureHandler(), Modalities{i_buttons}.getName);
                this.eventButtons{i_buttons}.setPosition([10 this.height-25*i_buttons 100 20])
                this.eventButtons{i_buttons}.setActive
            end
            
            %% Create Event List Panel
            this.codedEventList = fr.lescot.bind.coding.codedModalityList(this.getFigureHandler());
            this.codedEventList.setName('Evénements codés : ')
            this.codedEventList.setPosition([120 10 this.getWidth-125 this.getHeight-20])
            this.codedEventList.setColumnNames(this.columnNames)
            this.codedEventList.setActive
            
            set(this.getFigureHandler(), 'Visible', 'On');
        end
        
        function rebuildWindow(this,infosGraphic)
            Modalities = this.currentVariable.getAllModalities;
            % Figure
            this.setPosition(infosGraphic.Figure.Position)
            this.setName(infosGraphic.Figure.Name)
            this.setColor(infosGraphic.Figure.Color)
            % Buttons
            N = length(infosGraphic.Buttons.Positions);
            this.eventButtons = cell(1,N);
            for i_buttons = 1:1:N
                this.eventButtons{i_buttons} = fr.lescot.bind.coding.eventCodingButtons(this.getFigureHandler(), Modalities{i_buttons}.getName);
                this.eventButtons{i_buttons}.setPosition(infosGraphic.Buttons.Positions{i_buttons})
                this.eventButtons{i_buttons}.setColor(infosGraphic.Buttons.Colors{i_buttons})
                this.eventButtons{i_buttons}.setFont(infosGraphic.Buttons.Fonts{i_buttons})
                this.eventButtons{i_buttons}.setFontSize(infosGraphic.Buttons.FontSizes{i_buttons})
                this.eventButtons{i_buttons}.setFontWeight(infosGraphic.Buttons.FontWeights{i_buttons})
                this.eventButtons{i_buttons}.setActive
            end
            
            % CodedModalityList
            this.codedEventList = fr.lescot.bind.coding.codedModalityList(this.getFigureHandler());
            this.codedEventList.setName(infosGraphic.CodedModalityList.Name)
            this.codedEventList.setPosition(infosGraphic.CodedModalityList.Position)
            this.codedEventList.setColumnNames(this.columnNames)
            this.codedEventList.setActive
        end
        
        function defineObjectCallback(this,trip)
            eventCallback = @(x,y) this.eventButtonCallback(trip,x,y);
            for i=1:1:length(this.eventButtons)
                this.eventButtons{i}.setButtonCallback(eventCallback);
            end
            
            clickListCallback = @(x,y) this.clickListCallback(trip,x,y);
            this.codedEventList.setClickCallback(clickListCallback)
            
            suppressOccurenceCallback = @(x,y) this.suppressOccurenceButtonCallback(trip,x,y);
            this.codedEventList.setSuppressOccurenceCallback(suppressOccurenceCallback)
        end
        
        function eventButtonCallback(this,trip,source,~)
            clickedButton = {};
            %Find correct button
            for i=1:1:length(this.eventButtons)
                if this.eventButtons{i}.getButtonHandle == source
                    clickedButton = this.eventButtons{i};
                end
            end
            if ~isempty(clickedButton)
                currentTime = trip.getTimer.getTime();
                trip.setIsBaseEvent(this.currentVariable.getName, false)
                trip.setEventVariableAtTime(this.currentVariable.getName, 'Modalities', currentTime, clickedButton.getName)
                trip.setIsBaseEvent(this.currentVariable.getName, true)
            end
            this.updateExistingMods(trip);
            this.updateCurrentEvent(currentTime);
            this.refreshList = true;
            this.updateList(trip);
        end
        
        function clickListCallback(this,trip,source,eventData)
            handles = this.codedEventList.getHandles;
            if source == handles{3} && ~isempty(eventData.Indices)
                line_index = eventData.Indices(1);
                this.lastClickedEvent = size(this.existingEvents,2)-line_index+1;
                if this.lastClickedEvent > 0 && ~isempty(this.existingEvents)
                    timecode = this.existingEvents{1,size(this.existingEvents,2)-line_index+1};
                    trip.getTimer().stopTimer();
                    pause(0.02);
                    trip.getTimer().setTime(timecode);
                elseif this.lastClickedEvent == 0
                    this.lastClickedEvent = [];
                    this.currentEventIndex = [];
                end
            end
        end
        
        function suppressOccurenceButtonCallback(this,trip,source,eventData)
            if ~isempty(this.lastClickedEvent) && this.lastClickedEvent>0 && ~isempty(this.currentEventIndex) && ~isempty(this.existingEvents)
                this.lastClickedEvent
                timecode = this.existingEvents{1,this.currentEventIndex};
                trip.setIsBaseEvent(this.currentVariable.getName, false)
                if this.lastClickedEvent == 1 && size(this.existingEvents,2) == 1
                    this.currentEventIndex = [];
                end
                trip.removeEventOccurenceAtTime(this.currentVariable.getName, timecode);
                trip.setIsBaseEvent(this.currentVariable.getName, true)
                this.refreshList = true;
                this.updateList(trip)
            end
        end
        
        function updateCurrentEvent(this, currentTime)
            mask = cell2mat(this.existingEvents(1,:)) > currentTime-0.04  & cell2mat(this.existingEvents(1,:)) < currentTime+0.04;
            if any(mask)
                this.currentEventIndex = find(mask);
                this.refreshList = true;
            end
        end
        
        function updateExistingMods(this, trip)
            Metas = trip.getMetaInformations;
            if Metas.existEvent(this.currentVariable.getName)
                record = trip.getAllEventOccurences(this.currentVariable.getName);
                this.existingEvents = record.buildCellArrayWithVariables({'timecode','Modalities'});
            else
                this.existingEvents = {};
            end
            this.updateList(trip)
        end
        
        function updateList(this,trip)
            currentTime = trip.getTimer.getTime();
            % Text if table is empty
            if ~isempty(this.existingEvents)
                this.updateCurrentEvent(currentTime)
            end
            % Refresh List
            if this.refreshList
                this.codedEventList.setCodedModalities(this.existingEvents, this.currentEventIndex)
                this.refreshList = false;
            end
        end
        
        
    end
end