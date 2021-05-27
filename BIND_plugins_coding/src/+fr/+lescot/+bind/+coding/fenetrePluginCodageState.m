classdef fenetrePluginCodageState < fr.lescot.bind.coding.fenetrePluginCodage
    properties
        stateButtons;
        
        codedStateList;
        
        currentVariable;
        
        currentStateIndex;
        
        lastClickedState;
        
        existingStates;
        
        refreshList;
    end
    
    properties (Constant)
        columnNames = {'#','StartTimecode','EndTimecode','Modalités'};
    end
    
    methods
        function this = fenetrePluginCodageState(figureHandler,Variable)
            this@fr.lescot.bind.coding.fenetrePluginCodage(figureHandler)
            this.currentVariable = Variable;
            
            this.existingStates = {};
            this.currentStateIndex = [];
            this.refreshList =true;
            
            %if ~this.currentVariable.isInfosGraphicOk
                this.initiliazeWindow;
%             else
%                 infosGraphic = this.currentVariable.getInfosGraphic;
%                 this.rebuildWindow(infosGraphic);
%             end
            set(this.getFigureHandler(), 'Resize', 'On');
            set(this.getFigureHandler(), 'Visible', 'On');
        end
        
        function initiliazeWindow(this)
            %% Retrieving modalities
            Modalities = this.currentVariable.getAllModalities;
            N = length(Modalities);
            
            %% Figure (suite)
            this.setName(['Codage Etat : ' this.currentVariable.getName])
%             this.setPosition([0 0 370 max(40+25*N,160)])
            this.setPosition([0 0 435 max(40+25*20,160)])
            this.setColor([0.8 0.8 0.8])
            movegui(this.getFigureHandler(),'center')
            
            %% Create Button
            this.stateButtons = cell(1,N);
            for i_buttons = 1:1:N
                this.stateButtons{i_buttons} = fr.lescot.bind.coding.stateCodingButtons(this.getFigureHandler(), Modalities{i_buttons}.getName);
                this.stateButtons{i_buttons}.setPosition([10 this.height-25*i_buttons 100 20])
                this.stateButtons{i_buttons}.setActive
            end
            
            %% Create State List Panel
            this.codedStateList = fr.lescot.bind.coding.codedModalityList(this.getFigureHandler());
            this.codedStateList.setName('Etats codés : ')
            this.codedStateList.setPosition([120 10 this.getWidth-125 this.getHeight-20])
            this.codedStateList.setColumnNames(this.columnNames)
            this.codedStateList.setActive
        end
        
        function rebuildWindow(this,infosGraphic)
            Modalities = this.currentVariable.getAllModalities;
            % Figure
            this.setPosition(infosGraphic.Figure.Position)
            this.setName(infosGraphic.Figure.Name)
            this.setColor(infosGraphic.Figure.Color)
            % Buttons
            N = length(infosGraphic.Buttons.Positions);
            this.stateButtons = cell(1,N);
            for i_buttons = 1:1:N
                this.stateButtons{i_buttons} = fr.lescot.bind.coding.stateCodingButtons(this.getFigureHandler(), Modalities{i_buttons}.getName);
                this.stateButtons{i_buttons}.setPosition(infosGraphic.Buttons.Positions{i_buttons})
                this.stateButtons{i_buttons}.setColor(infosGraphic.Buttons.Colors{i_buttons})
                this.stateButtons{i_buttons}.setFont(infosGraphic.Buttons.Fonts{i_buttons})
                this.stateButtons{i_buttons}.setFontSize(infosGraphic.Buttons.FontSizes{i_buttons})
                this.stateButtons{i_buttons}.setFontWeight(infosGraphic.Buttons.FontWeights{i_buttons})
                this.stateButtons{i_buttons}.setActive
            end
            
            % CodedModalityList
            this.codedStateList = fr.lescot.bind.coding.codedModalityList(this.getFigureHandler());
            this.codedStateList.setName(infosGraphic.CodedModalityList.Name)
            this.codedStateList.setPosition(infosGraphic.CodedModalityList.Position)
            this.codedStateList.setColumnNames(this.columnNames)
            this.codedStateList.setActive
        end
        
        function defineObjectCallback(this,trip)
            stateCallback = @(x,y) this.stateButtonCallback(trip,x,y);
            for i=1:1:length(this.stateButtons)
                this.stateButtons{i}.setButtonCallback(stateCallback);
            end
            
            clickListCallback = @(x,y) this.clickListCallback(trip,x,y);
            this.codedStateList.setClickCallback(clickListCallback)
            
            suppressOccurenceCallback = @(x,y) this.suppressOccurenceButtonCallback(trip,x,y);
            this.codedStateList.setSuppressOccurenceCallback(suppressOccurenceCallback)
        end
        
        function stateButtonCallback(this,trip,source,~)
            clickedButton = {};
            currentTime = trip.getTimer.getTime();
            maxTime = trip. getMaxTimeInDatas();
            %Find correct button
            for i=1:1:length(this.stateButtons)
                if this.stateButtons{i}.getButtonHandle == source
                    clickedButton = this.stateButtons{i};
                end
            end
            if ~isempty(clickedButton)
                if isempty(this.existingStates)
                    newStates = {0 ,maxTime ,clickedButton.getName};
                else
                    currentState = this.existingStates(:,this.currentStateIndex);
                    % Replace a existing State
                    if currentTime == currentState{1}
                        newStates = this.existingStates;
                        newStates{3,this.currentStateIndex} = clickedButton.getName;
                        newStates = newStates';
                    else
                        if size(this.existingStates,2) < 2
                            newStates = [{currentState{1}, currentTime , currentState{3}} ; {currentTime, currentState{2} , clickedButton.getName}];
                        else
                            newStates = this.existingStates(:,1:this.currentStateIndex-1)';
                            newStates = [newStates ; {currentState{1}, currentTime , currentState{3}}];
                            newStates = [newStates ;{currentTime, currentState{2} , clickedButton.getName}];
                            newStates = [newStates ; this.existingStates(:,this.currentStateIndex+1:end)'];
                        end
                    end
                end
                trip.setIsBaseSituation(this.currentVariable.getName,false);
                trip.removeAllSituationOccurences(this.currentVariable.getName);
                trip.setBatchOfTimeSituationVariableTriplets(this.currentVariable.getName,'Modalities',newStates');
                trip.setIsBaseSituation(this.currentVariable.getName,true);
            end
        end
        
        function clickListCallback(this,trip,source,eventData)
            handles = this.codedStateList.getHandles;
            if source == handles{3} && ~isempty(eventData.Indices)
                line_index = eventData.Indices(1);
                this.lastClickedState = size(this.existingStates,2)-line_index+1;
                if this.lastClickedState > 0 && ~isempty(this.existingStates)
                    StartTimecode = this.existingStates{1,this.lastClickedState};
                    trip.getTimer().stopTimer();
                    pause(0.02);
                    trip.getTimer().setTime(StartTimecode);
                elseif this.lastClickedState == 0
                    this.lastClickedState = [];
                    this.currentStateIndex = [];
                end
            end
        end
        
        function suppressOccurenceButtonCallback(this,trip,source,eventData)
            if ~isempty(this.lastClickedState) && this.lastClickedState>0 && ~isempty(this.currentStateIndex) && ~isempty(this.existingStates)
                this.lastClickedState
                StartTimecode = this.existingStates{1,this.lastClickedState};
                EndTimecode = this.existingStates{2,this.lastClickedState};
                trip.setIsBaseSituation(this.currentVariable.getName, false)
                if this.lastClickedState == 1 && size(this.existingStates,2) == 1
                    this.currentStateIndex = [];
                end
                if size(this.existingStates,2) == 1
                    trip.removeSituationOccurenceAtTime(this.currentVariable.getName,StartTimecode,EndTimecode)
                else
                    if this.lastClickedState == size(this.existingStates,2)
                        prevStartTimecode = this.existingStates{1,this.lastClickedState-1};
                        %prevEndTimecode = this.existingStates{2,this.lastClickedState-1};
                        prevMod = this.existingStates{3,this.lastClickedState-1};
                        
                        new_states = this.existingStates;
                        new_states = [new_states(:,1:end-2) {prevStartTimecode,EndTimecode,prevMod}'];
                        trip.removeAllSituationOccurences(this.currentVariable.getName)
                        trip.setBatchOfTimeSituationVariableTriplets(this.currentVariable.getName,'Modalities',new_states);
                    else
                        %nextStartTimecode = this.existingStates{1,this.lastClickedState-1};
                        nextEndTimecode = this.existingStates{2,this.lastClickedState+1};
                        nextMod = this.existingStates{3,this.lastClickedState+1};
                        
                        trip.removeSituationOccurenceAtTime(this.currentVariable.getName,StartTimecode,EndTimecode);
                        
                        new_states = this.existingStates;
                        new_states = [new_states(:,1:this.lastClickedState-1) {StartTimecode,nextEndTimecode,nextMod}' new_states(:,this.lastClickedState+1:end)];
                        trip.removeAllSituationOccurences(this.currentVariable.getName)
                        trip.setBatchOfTimeSituationVariableTriplets(this.currentVariable.getName,'Modalities',new_states);
                    end
                end
                trip.setIsBaseSituation(this.currentVariable.getName, true)
                
                currentTime = trip.getTimer.getTime();
                this.updateCurrentState(currentTime);
                this.refreshList = true;
                this.updateExistingMods(trip);
                this.updateList(trip);
            end
        end
        
        function updateExistingMods(this, trip)
            Metas = trip.getMetaInformations;
            if Metas.existSituation(this.currentVariable.getName)
                record = trip.getAllSituationOccurences(this.currentVariable.getName);
                this.existingStates = record.buildCellArrayWithVariables({'startTimecode','endTimecode','Modalities'});
            else
                this.existingStates = {};
            end
            this.updateList(trip)
        end
        
        function updateCurrentState(this, currentTime)
            for i=1:1:size(this.existingStates,2)
                if this.existingStates{1,i}-eps <= currentTime && currentTime < this.existingStates{2,i}
                    if isempty(this.currentStateIndex)
                        this.currentStateIndex = 1;
                        this.refreshList = true;
                    elseif i == this.currentStateIndex
                        this.refreshList =false;
                    else
                        this.currentStateIndex = i;
                        this.refreshList = true;
                    end
                end
            end
        end
        
        function updateList(this, trip)
            currentTime = trip.getTimer.getTime();
            % Text if table is empty
            if ~isempty(this.existingStates)
                this.updateCurrentState(currentTime)
                % exclusive behaviour
                for i=1:1:length(this.stateButtons)
                    if strcmp(this.stateButtons{i}.getName, this.existingStates{3,this.currentStateIndex})
                        this.stateButtons{i}.setInactive;
                    else
                        this.stateButtons{i}.setActive;
                    end
                end
            end
            % Refresh List
            if this.refreshList
                this.codedStateList.setCodedModalities(this.existingStates, this.currentStateIndex)
                this.refreshList = false;
            end
        end
    end
    
end
