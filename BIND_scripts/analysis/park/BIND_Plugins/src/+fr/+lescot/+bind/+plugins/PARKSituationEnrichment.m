%{
Class:
This class describes a plugin that allow to display the values of several
variables of the trip at the current time in a table.

%}
classdef PARKSituationEnrichment < fr.lescot.bind.plugins.VisualisationPlugin
    
    properties(Access = private)
        %{
        Property:
        a cell array of handler on uiControl type ToggleButton
        
        %}
        uiToggleButtonList;
        
        %{
        Property:
        the button to save parameters
        
        %}
        saveSituationParametersButton
        
        %{
        Property:
        list of the name of the buttons
        
        %}
        buttonNameList
        
        %{
        Property:
        handler on the ui list of the current situations
        
        %}
        currentSituationsList
        
        %{
        Property:
        a cell array containing the [timeStart timeStop] of the current
        situations
        
        %}
        currentSituationTimeLimits
        

        
        %{
        Property:
        a handler on the radio boutton group
        
        %}        
        playPauseButton
        
        coder;
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
        function this = PARKSituationEnrichment(trip, position, coder)
            this@fr.lescot.bind.plugins.VisualisationPlugin(trip);
            this.uiToggleButtonList = {};
            this.coder = coder;
            % TODO : verifier qu'on a le droit de lancer le plugin et que
            % les structures de sauvegarde sont bien présentes.
            
            this.buildUI(position);
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)
            %trouver la situation courante
            currentTime = this.getCurrentTrip().getTimer().getTime();
            result = this.getCurrentTrip().getSituationOccurencesAroundTime('errorSituationsByMaud',currentTime);
            if ~result.isEmpty()
                situationNames = result.getVariableValues('Label');
                situationStartTimeCode = result.getVariableValues('startTimeCode');
                situationEndTimeCode = result.getVariableValues('endTimeCode');
                for i = 1:length(situationStartTimeCode)
                    tempsDebut = situationStartTimeCode{i};
                    tempsFin = situationEndTimeCode{i};
                    this.currentSituationTimeLimits{i} = [tempsDebut tempsFin];
                end
                set(this.currentSituationsList,'String',situationNames);
                set(this.saveSituationParametersButton,'Enable', 'on');
            else
                set(this.currentSituationsList,'String','Pas de situation');
                set(this.saveSituationParametersButton,'Enable', 'off');
            end
            
            
            if isa(message,'fr.lescot.bind.kernel.TimerMessage')
                if strcmp(message.getCurrentMessage(),'STOP')
                    set(this.saveSituationParametersButton,'Enable','on');
                end
                
                if strcmp(message.getCurrentMessage(),'START')
                    set(this.saveSituationParametersButton,'Enable','off');
                end
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
            %Setting the original window properties
            set(this.getFigureHandler(), 'Name', 'Codage de la manip PARK');
            set(this.getFigureHandler, 'Position', [0 0 700 410]);
            %Positioning the window
            movegui(this.getFigureHandler, position);
            backgroundColor = get(this.getFigureHandler,'Color');
            
            %un texte qui explique ce qu'il y a dans la liste
            uicontrol(this.getFigureHandler(),'Style','text','String','Situations courantes','Position',[450 370 200 40],'BackgroundColor', backgroundColor);
            
            % la list
            this.currentSituationsList = uicontrol(this.getFigureHandler(),'Style','listbox','Position',[500 350 200 40]);
   
            %%%% LES BOUTONS!!
            
            buttonHeigth = 25;
            buttonWidth = 100;
            
            % le bouton save
            this.saveSituationParametersButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'Position', [350 10 120 395]);
            set(this.saveSituationParametersButton,'String', 'Save');
            callbackHandle = @this.saveSituationParametersCallback;
            set(this.saveSituationParametersButton, 'Callback', callbackHandle);
            
            % le bouton raz
            razButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'Position', [500 10 100 50]);
            set(razButton,'String', 'RAZ');
            callbackHandle = @this.razSituationParametersCallback;
            set(razButton, 'Callback', callbackHandle);
            
            % le bouton play pause
            this.playPauseButton = uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'Position', [500 100 100 100]);
            set(this.playPauseButton,'String', 'Play/Pause');
            callbackHandle = @this.playPauseButtonCallback;
            set(this.playPauseButton, 'Callback', callbackHandle);            
            
            % les autres boutons
            buttonTitleList = {'Priorité à droite',...
                'Feu orange',...
                'Feu rouge',...
                'Cédez le passage',...
                'Stop',...
                'Abs. clign',...
                'Clignotant tardif',...
                'Pb Boite de Vitesse',...
                'Pb Pédales',...
                'Freinage brusque',...
                'Freinage tardif',...
                'Regard fixe',...
                'Angle mort',...
                'Abs. rétro',...
                'Mvs choix de voie',...
                'Chgmt de voie tardif',...
                'Trajectoire coupée',...
                'Trajectoire large',...
                'Position G++',...
                'Position D++',...
                'Franchissement ligne',...
                'ARRET tardif',...
                'ARRET voie',...
                'Trop vite',...
                'Trop lent',...
                'DIV courte',...
                'GAP court',...
                'Non détection piétons',...
                'Klaxon',...
                'Interv. Frein',...
                'Interv. Volant',...
                'Interv. Boite de Vitesse',...
                'Interv. Orale',...
                };
            
            this.buttonNameList = {'PAD',...
                'FO',...
                'FR',...
                'CLD',...
                'Stop',...
                'AbsCli',...
                'CliTardif',...
                'PbBV',...
                'PbPedales',...
                'FreinBrusque',...
                'FreinTardif',...
                'RegardFixe',...
                'AngleMort',...
                'AbsRetro',...
                'MvsChoixVoie',...
                'ChgmtVoieTardif',...
                'TrajCoupee',...
                'TrajLarge',...
                'PosG++',...
                'PosD++',...
                'FranchiLigne',...
                'ArretTardif',...
                'ArretVoie',...
                'TropVite',...
                'TropLent',...
                'DIVCourte',...
                'GAPCourt',...
                'NDPietons',...
                'Klaxon',...
                'IntervFrein',...
                'IntervVolant',...
                'IntervBoite de Vitesse',...
                'IntervOrale',...
                };
            % [vers la droite / hauteur depuis le bas /  ]
            positionList = { [5 380 buttonWidth buttonHeigth],...
                [5 350 buttonWidth buttonHeigth],...
                [5 320 buttonWidth buttonHeigth],...
                [5 290 buttonWidth buttonHeigth],...
                [5 260 buttonWidth buttonHeigth],... % bouton stop
                [5 200 buttonWidth buttonHeigth],... % bouton abs cli
                [5 170 buttonWidth buttonHeigth],... 
                [5 140 buttonWidth buttonHeigth],... 
                [5 110 buttonWidth buttonHeigth],... 
                [5 80 buttonWidth buttonHeigth],... 
                [5 50 buttonWidth buttonHeigth],...  % frein tardif (fin colonne 1)
                [115 380 buttonWidth buttonHeigth],...
                [115 350 buttonWidth buttonHeigth],...
                [115 320 buttonWidth buttonHeigth],...
                [115 260 buttonWidth buttonHeigth],... % bouton mvs changement de voie
                [115 230 buttonWidth buttonHeigth],... 
                [115 200 buttonWidth buttonHeigth],... 
                [115 170 buttonWidth buttonHeigth],... 
                [115 140 buttonWidth buttonHeigth],... 
                [115 110 buttonWidth buttonHeigth],... 
                [115 80 buttonWidth buttonHeigth],... 
                [115 40 buttonWidth buttonHeigth],...                
                [115 10 buttonWidth buttonHeigth],...  % bouton arret voie (fin colonne 2)
                [225 350 buttonWidth buttonHeigth],...
                [225 320 buttonWidth buttonHeigth],...
                [225 260 buttonWidth buttonHeigth],... % bouton div courte
                [225 230 buttonWidth buttonHeigth],...                 
                [225 170 buttonWidth buttonHeigth],... % bouton nd pieton
                [225 140 buttonWidth buttonHeigth],... 
                [225 110 buttonWidth buttonHeigth],... 
                [225 80 buttonWidth buttonHeigth],... 
                [225 50 buttonWidth buttonHeigth],...                
                [225 20 buttonWidth buttonHeigth],...  
                };
            
            colorList =  { [1 0 0],...
                [1 0 0],...
                [1 0 0],...
                [1 0 0],...
                [1 0 0],... % bouton stop
                [0 1 0],... % bouton abs cli
                [0 1 0],... 
                [0 1 0],... 
                [0 1 0],... 
                [0 1 0],... 
                [0 1 0],...  % frein tardif (fin colonne 1)
                [0.8 0.8 1],...
                [0.8 0.8 1],...
                [0.8 0.8 1],...
                [1 0.5 0.5],... % bouton mvs changement de voie
                [1 0.5 0.5],... 
                [0.9 0.9 1],... 
                [0.9 0.9 1],... 
                [1 0.7 0.5],... 
                [1 0.7 0.5],... 
                [1 0.9 0.9],... 
                [1 0 0],...                
                [1 0 0],...  % bouton arret voie (fin colonne 2)
                [0.8 0.8 0.8],...
                [0.8 0.8 0.8],...
                [0.9 0.9 1],... % bouton div courte
                [0.9 0.9 1],...                 
                [1 1 1],... % bouton nd pieton
                [1 1 1],... 
                [1 0 1],... 
                [1 0 1],... 
                [1 0 1],...                
                [1 0 1],...  
                };
            
            for i= 1 : length(this.buttonNameList)
               this.uiToggleButtonList{i} = uicontrol(this.getFigureHandler(),'Style','togglebutton','String',buttonTitleList{i},'Position',positionList{i},'Min',0,'Max',1,'BackgroundColor',colorList{i});
               callbackHandler = @this.buttonSelectedCallback;
               set(this.uiToggleButtonList{i},'Callback',callbackHandler);
            end
            
            set(this.getFigureHandler(), 'Visible', 'on');
        end
        
        %{
        Function:
        Callback when user clic on set all buttons to 0
        
        Parameters:
        this - optional, the objet on which the method is called
        source - the source of the clic
        eventdata - additional info
        %}
        function razSituationParametersCallback(this,source,eventdata)
                this.razUI();
        end
        
        %{
        Function:
        function that reset all buttons to default position
        
        Parameters:
        this - optional, the objet on which the method is called
        %}
        function razUI(this)
            for i=1:length(this.uiToggleButtonList)
                set(this.uiToggleButtonList{i},'Value',0);
                set(this.uiToggleButtonList{i},'FontWeight','normal');
            end            
        end
        
        %{
        Function:
        Callback when user clic on a button to put the text in bold
        
        Parameters:
        this - optional, the objet on which the method is called
        source - the source of the clic
        eventdata - additional info
        %}
        function buttonSelectedCallback(this,source,eventdata)
            buttonValue = get(source,'Value');
            switch buttonValue
                case 1 
                    set(source,'FontWeight','bold');
                case 0
                    set(source,'FontWeight','normal');
            end
        end
        
        %{
        Function:
        Callback when user clic on the play/pause button 
        
        Parameters:
        this - optional, the objet on which the method is called
        source - the source of the clic
        eventdata - additional info
        %}
        function playPauseButtonCallback(this,source,eventdata)
            if this.getCurrentTrip.getTimer.isRunning()
                this.getCurrentTrip.getTimer.stopTimer();
                set(this.playPauseButton,'String','Play');
            else
                this.getCurrentTrip.getTimer.setMultiplier(1);
                this.getCurrentTrip.getTimer.startTimer();
                set(this.playPauseButton,'String','Pause');
            end
        end
        
        %{
        Function:
        Callback when user clic on save
        
        Parameters:
        this - optional, the objet on which the method is called
        source - the source of the clic
        eventdata - additional info
        %}
        function saveSituationParametersCallback(this,~,~)
            set(this.saveSituationParametersButton,'Enable', 'off');
            set(this.saveSituationParametersButton,'String','Saving...');
            pause(0.01);
            if ~isempty(this.currentSituationTimeLimits)
                selectionSituation = get(this.currentSituationsList,'Value');
                
                situationTimeLimits = this.currentSituationTimeLimits{selectionSituation};
                situationStartTime = situationTimeLimits(1);
                situationEndTime = situationTimeLimits(2);
                
                switch this.coder
                    case 'Maud' %maud
                        errorSituationTable = 'errorSituationsByMaud';
                    case 'Laurence' %laurence
                        errorSituationTable  = 'errorSituationsByLaurence';
                end
                theTrip = this.getCurrentTrip();
                for i=1:length(this.buttonNameList)
                    theTrip.setSituationVariableAtTime(errorSituationTable, this.buttonNameList{i},situationStartTime,situationEndTime,get(this.uiToggleButtonList{i},'Value')); 
                end
                % re enable UI
            
                this.razUI();
            end
           set(this.saveSituationParametersButton,'Enable', 'on');
           set(this.saveSituationParametersButton,'String','Save');
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
            out = '[PARK] Enrichissement de situations';
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
            out = 'fr.lescot.bind.configurators.PARKSituationEnrichmentConfigurator';
        end
        
    end
    
end