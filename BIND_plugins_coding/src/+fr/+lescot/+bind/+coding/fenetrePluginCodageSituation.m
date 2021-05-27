classdef fenetrePluginCodageSituation < fr.lescot.bind.coding.fenetrePluginCodage
    properties
        situationButtons;
        
        codedSituationList;
        
        currentVariable;
        
        currentSituationIndex;
        
        lastClickedSituation;
        
        existingSituations;
        
        refreshList;
    end
    
    properties (Constant)
        columnNames = {'#','StartTimecode','EndTimecode','Modalités'};
    end
    
    methods
        function this = fenetrePluginCodageSituation(figureHandler,Variable)
            this@fr.lescot.bind.coding.fenetrePluginCodage(figureHandler)
            this.currentVariable = Variable;
            
            this.currentSituationIndex = [];
            this.lastClickedSituation = [];
            this.existingSituations = {};
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
            this.setName(['Codage Situation : ' this.currentVariable.getName])
%             this.setPosition([0 0 435 max(100+20*N,160)])
            this.setPosition([0 0 500 max(100+20*20,160)])
            this.setColor([0.8 0.8 0.8])
            movegui(this.getFigureHandler(),'center')
            
            %% Create Button
            this.situationButtons = cell(1,N);
            for i_buttons = 1:1:N
                this.situationButtons{i_buttons} = fr.lescot.bind.coding.situationCodingButtons(this.getFigureHandler(), Modalities{i_buttons}.getName);
                this.situationButtons{i_buttons}.setPosition([10 this.height-40*i_buttons 60 20]);
                this.situationButtons{i_buttons}.setActive;
            end
            
            %% Create Situation List Panel
            this.codedSituationList = fr.lescot.bind.coding.codedModalityList(this.getFigureHandler());
            this.codedSituationList.setName('Situations codées : ');
            this.codedSituationList.setPosition([145 10 this.getWidth-150 this.getHeight-20]);
            this.codedSituationList.setColumnNames(this.columnNames)
            this.codedSituationList.setActive;
            
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
            this.situationButtons = cell(1,N);
            for i_buttons = 1:1:N
                this.situationButtons{i_buttons} = fr.lescot.bind.coding.situationCodingButtons(this.getFigureHandler(), Modalities{i_buttons}.getName);
                this.situationButtons{i_buttons}.setPosition(infosGraphic.Buttons.Positions{i_buttons})
                this.situationButtons{i_buttons}.setColor(infosGraphic.Buttons.Colors{i_buttons})
                this.situationButtons{i_buttons}.setFont(infosGraphic.Buttons.Fonts{i_buttons})
                this.situationButtons{i_buttons}.setFontSize(infosGraphic.Buttons.FontSizes{i_buttons})
                this.situationButtons{i_buttons}.setFontWeight(infosGraphic.Buttons.FontWeights{i_buttons})
                this.situationButtons{i_buttons}.setActive;
            end
            
            % CodedModalityList
            this.codedSituationList = fr.lescot.bind.coding.codedModalityList(this.getFigureHandler());
            this.codedSituationList.setName(infosGraphic.CodedModalityList.Name)
            this.codedSituationList.setPosition(infosGraphic.CodedModalityList.Position)
            this.codedSituationList.setColumnNames(this.columnNames)
            this.codedSituationList.setActive;
        end
        
        function defineObjectCallback(this,trip)
            situationCallback = @(x,y) this.situationButtonCallback(trip,x,y);
            for i=1:1:length(this.situationButtons)
                this.situationButtons{i}.setButtonCallback(situationCallback);
            end
            
            clickListCallback = @(x,y) this.clickListCallback(trip,x,y);
            this.codedSituationList.setClickCallback(clickListCallback)
            
            suppressOccurenceCallback = @(x,y) this.suppressOccurenceButtonCallback(trip,x,y);
            this.codedSituationList.setSuppressOccurenceCallback(suppressOccurenceCallback)
        end
        
        function situationButtonCallback(this,trip,source,~)
            clickedButton = {};
            %Find correct button
            for i=1:1:length(this.situationButtons)
                if this.situationButtons{i}.getButtonHandle.debut == source || this.situationButtons{i}.getButtonHandle.fin == source
                    clickedButton = this.situationButtons{i};
                end
            end
            if ~isempty(clickedButton)
                if source == clickedButton.getButtonHandle.debut
                    if ~clickedButton.isPressed
                        clickedButton.setDebutPressed(true)
                        currentTime = trip.getTimer.getTime();
                        clickedButton.setPressedTimecode(currentTime)
                        new_color = clickedButton.getColor - 0.2*[1 1 1];
                        clickedButton.setColorDebut([max(0.05,new_color(1)) max(0.05,new_color(2)) max(0.05,new_color(2))])
                    else
                        clickedButton.setDebutPressed(false)
                        clickedButton.setPressedTimecode([])
                        clickedButton.setColorDebut(clickedButton.getColor)
                    end
                    
                elseif source == clickedButton.getButtonHandle.fin
                    if clickedButton.isPressed && ~isempty(clickedButton.getPressedTimecode)
                        currentTime = trip.getTimer.getTime();
                        if clickedButton.getPressedTimecode ~= currentTime
                            trip.setIsBaseSituation(this.currentVariable.getName, false)
                            trip.setSituationVariableAtTime(this.currentVariable.getName, 'Modalities', clickedButton.getPressedTimecode,currentTime, clickedButton.getName)
                            trip.setIsBaseSituation(this.currentVariable.getName, true)
                            
                            clickedButton.setDebutPressed(false)
                            clickedButton.setPressedTimecode([])
                            clickedButton.setColorDebut(clickedButton.getColor)
                        end
                    end
                end
                
            end
        end
        
        function clickListCallback(this,trip,source,eventData)
            handles = this.codedSituationList.getHandles;
            if source == handles{3} && ~isempty(eventData.Indices)
                line_index = eventData.Indices(1);
                this.lastClickedSituation = size(this.existingSituations,2)-line_index+1;
                if this.lastClickedSituation > 0 && ~isempty(this.existingSituations)
                    StartTimecode = this.existingSituations{1,this.lastClickedSituation};
                    trip.getTimer().stopTimer();
                    pause(0.02);
                    trip.getTimer().setTime(StartTimecode);
                elseif this.lastClickedSituation == 0
                    this.lastClickedSituation = [];
                    this.currentSituationIndex = [];
                end
            end
        end
        
        function suppressOccurenceButtonCallback(this,trip,source,eventData)
            if ~isempty(this.lastClickedSituation) && this.lastClickedSituation>0 && ~isempty(this.currentSituationIndex) && ~isempty(this.existingSituations)
                this.lastClickedSituation
                StartTimecode = this.existingSituations{1,this.lastClickedSituation};
                EndTimecode = this.existingSituations{2,this.lastClickedSituation};
                trip.setIsBaseSituation(this.currentVariable.getName, false)
                if this.lastClickedSituation == 1 && size(this.existingSituations,2) == 1
                    this.currentSituationIndex = [];
                end
                trip.removeSituationOccurenceAtTime(this.currentVariable.getName, StartTimecode, EndTimecode);
                trip.setIsBaseSituation(this.currentVariable.getName, true)
                this.refreshList = true;
                this.updateList(trip)
            end
        end
        
        function updateExistingMods(this, trip)
            Metas = trip.getMetaInformations;
            if Metas.existSituation(this.currentVariable.getName)
                record = trip.getAllSituationOccurences(this.currentVariable.getName);
                this.existingSituations = record.buildCellArrayWithVariables({'startTimecode','endTimecode','Modalities'});
            else
                this.existingSituations = {};
            end
            this.refreshList = true;
            this.updateList(trip)
        end
        
        function updateList(this,trip)
            currentTime = trip.getTimer.getTime();
            % Text if table is empty
            if ~isempty(this.existingSituations)
                this.updateCurrentSituation(currentTime)
            end
            % Refresh List
            if this.refreshList % && ~isempty(this.existingSituations)
                this.codedSituationList.setCodedModalities(this.existingSituations, this.currentSituationIndex)
                this.refreshList = false;
            end
        end
        
        function updateCurrentSituation(this, currentTime)
            mask = cell2mat(this.existingSituations(1,:)) <= currentTime & cell2mat(this.existingSituations(2,:)) > currentTime;
            old_indexes = this.currentSituationIndex;
            new_indexes = find(mask);
            if isempty(new_indexes)
                new_indexes = [];
            end
            if length(old_indexes) == length(new_indexes) && all(old_indexes == new_indexes)
                
            else
                this.currentSituationIndex = new_indexes;
                this.refreshList = true;
            end
        end
    end
end