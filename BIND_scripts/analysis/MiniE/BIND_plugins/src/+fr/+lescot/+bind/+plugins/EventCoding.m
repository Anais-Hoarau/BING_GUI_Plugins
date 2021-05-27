%Class: fr.lescot.bind.plugins.EventCoding
%This class creates a plugin used to access easily to events or situations.
%
%
%Extends:
%- <fr.lescot.bind.plugins.GraphicalPlugin>
%- <fr.lescot.bind.plugins.TripStreamingPlugin>
classdef EventCoding < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripPlugin
    
    properties (Access = private)
        
        %{
        Property:
        the widget, a <fr.lescot.bind.widget.EventSituationList> widget that can be used to browse through events
        
        %}
        EventSituationList
        
        %{
        Property:
        Explain which marker is displayed. Need to be written as a cell with a string of the
        following structure :
        markerType.markerName
        markerType needs to be "event" or "situation"
                
        %}
        markerIdentifier
        
        %{
        Property:
        handler on the trip where the coded data are stored
        %}
        theTrip
        
        %{
        Property:
        cell array of handler of uicontrol button... useful to make a single call back
        %}
        buttonsHandlerList
        
        %{
        Property:
        handler of the text that display current coded value
        %}
        labelCurrentCodedValue
        
        %{
        Property:
        Handler of the cell array that contain the names of all the buttons
        %}
        labelList

        %{
        Property:
        String to save the name of current event table to be enriched
        %}
        tableName
        
        %{
        Property:
        Integer : width of the main window
        %}
        windowWidth;
        
        %{
        Property:
        Integer : heigth of the main window
        %}
        windowHeigth;
        
        %{
        Property:
        Integer : width of the coded events list
        %}
        EventSituationListWidth;
        
        %{
        Property:
        Variable that store the configuration of the buttons in plugin
        friendly manner for button creation
        %}
        linesButtonValues;
        
        %{
        Property:
        Variable that store the configuration of the buttons in plugin
        friendly manner for button creation
        %}        
        linesButtonNames;
        
        %{
        Property:
        Variable that store the configuration of the buttons in plugin
        friendly manner for buttons callback
        %}        
        buttonsNamesSerialised
        %{
        Property:
        Variable that store the configuration of the buttons in plugin
        friendly manner for buttons callback
        %}  
        buttonsValuesSerialised
        %{
        Property:
        String that store the title of the window
        %}  
        windowTitle
    end
    
    methods
        %{
        Function:
        The constructor of the INTERACTION_WP5_PositionPied plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        trip - The <kernel.Trip> object on which the EventSituationBrowser will be
        synchronized and which data will be displayed.
        markerIdentifier - A cell string of the form "event.EventName" OR "situation.SituationName".
        
        
        Returns:
        this - a new event and situation browser plugin.
        %}
        function this = EventCoding(trip, configFile, positionAtStart, varargin)
            import fr.lescot.bind.utils.StringUtils;
            % we call the constructor of the superclasses "TripPlugin" &
            % "GraphicalPlugin"
            this@fr.lescot.bind.plugins.TripPlugin(trip);
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            
            this.theTrip = trip;
            
            % set all class variable and returns the config of the buttons
            buttonsDescription = this.loadConfigFromTxtFile(configFile);
                        
            %verify metadata... if requirement are not met, create required
            %meta structure
            this.verifyMetaInformations()
                    
            % creation of the UI
            this.buildUI(positionAtStart,buttonsDescription)
        end
        
        %{
        Function:
        This method can be called to verify if the required meta informations are
            already present in the trip for information coding
        
        Arguments:
        this - optional, the object on which the method is called
        
        Returns:
        out - a boolean that is true if all conditions are met for the meta inforamtions of the trip with the requirement
            of the coding plugin
        %}
        function out = verifyMetaInformations(this)
            metas = this.theTrip.getMetaInformations();
            eventName = this.tableName;
            % create meta event in memory
            event = fr.lescot.bind.data.MetaEvent();
            event.setName(eventName);
            
            % add it to the trip if it does not exist
            if  ~metas.existEvent(eventName)
                %Add event to trip and refresh meta datas
                this.theTrip.addEvent(event);
                metas = this.theTrip.getMetaInformations();
            end
            
            namesOfRequiredVariables = {'numericValue' 'textualValue'};
            typesOfRequiredVariables = {fr.lescot.bind.data.MetaEventVariable.TYPE_REAL fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT}; 
                        
            for i=1:length(namesOfRequiredVariables)
                if (~metas.existEventVariable(eventName,namesOfRequiredVariables{i}))
                    metaVariable = fr.lescot.bind.data.MetaEventVariable();
                    metaVariable.setName(namesOfRequiredVariables{i});
                    metaVariable.setType(typesOfRequiredVariables{i});
                    this.theTrip.addEventVariable(eventName,metaVariable);
                end
            end
        end
        
        %Function: update()
        %
        %This method is the implementation of the <observation.Observer.update> method. It
        %updates the display after each message from the Trip.
        function update(this, message)
            %launch the update method of the widget, if it is already
            %created. Messages can be sent during metaData creation, when
            %the widget is not there yet!
            try
                if ~isempty(this.EventSituationList)
                    this.EventSituationList.update(message);
                end
            end
            
%             if any(strcmp(message.getCurrentMessage(),{'EVENT_CONTENT_CHANGED' 'SITUATION_CONTENT_CHANGED'}))
%                 
%             end
            if any(strcmp(message.getCurrentMessage(),{'STEP' 'GOTO' 'EVENT_CONTENT_CHANGED'}))
                borneDeDebut = 0;
                currentTimecode = this.theTrip.getTimer.getTime();
                record = this.theTrip.getEventOccurencesInTimeInterval(this.tableName,borneDeDebut,currentTimecode);
                toutesLesValeursTexte = record.getVariableValues('textualValue');
                if ~isempty(toutesLesValeursTexte)
                    value = toutesLesValeursTexte{end};
                else
                    value = 'No Event';
                end
                set(this.labelCurrentCodedValue,'String',value);
            end
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
        function buildUI(this,positionAtStart,buttonsConfiguration)            
            hauteur = this.windowHeigth;
            largeur = this.windowWidth;
            
            set(this.getFigureHandler(), 'Position', [0 0 largeur hauteur ]);
            set(this.getFigureHandler(), 'Name', this.windowTitle);
            
            % use the fancy widget to monitor coded events ^^
            this.EventSituationList = fr.lescot.bind.widgets.EventSituationList(this.getFigureHandler(),...
                this.theTrip,...
                this.markerIdentifier,...
                'Position', [0 0 ],...
                'Size', [this.EventSituationListWidth hauteur-20],...
                'BackgroundColor', get(this.getFigureHandler(), 'Color') );
            
            % create a label for monitoring last coded value regarding
            % current timecode
            uicontrol(this.getFigureHandler(),'Style','text', 'String', 'Valeur courante du codage :',...
                'Position', [10 hauteur-20 largeur/2 20]); 
            this.labelCurrentCodedValue = uicontrol(this.getFigureHandler(),'Style','text', 'String', '???',...
                'FontWeight', 'bold', 'Position', [largeur/2 hauteur-20 largeur/2 20]); 
            
            % strip configuration of the button to create class variables
            for i=1:length(buttonsConfiguration)
                configLine = buttonsConfiguration{i};
                splittedLine = regexp(configLine, '\|', 'split');
                names = splittedLine{1};
                values = splittedLine{2};
                newButtons = regexp(names, ';', 'split');
                this.linesButtonNames{i} = newButtons;    
                newButtons = regexp(values, ';', 'split');
                this.linesButtonValues{i} = newButtons;
            end
                
            if length(this.linesButtonNames) == length(this.linesButtonValues)
                nbLines = length(this.linesButtonValues);
            else
                msgbox('Error on button configuration');
            end
            
            % sub method that add different buttons and their call back
            % handlers for Coding
            for i=1:nbLines
                this.addCodingButtonsLine(i);          
            end
            
            % specific addition of delete button
            this.addDeleteButton();
            
            % serialise configuration to enable auto callback
            this.serialiseButtonsConfiguration();
            
            movegui(this.getFigureHandler, positionAtStart);
             %Setting visible
            set(this.getFigureHandler,'Visible', 'on');
        end
        
        %{
        Function:
        this function takes the configuration of the buttons and serialise
        it as it must be seralised in order to work with the auto callback
        
        Arguments:
        this - optionnal, the object on which the function is called
        lineId - integer : number of the line to code (useful to define
        automagically position for the buttons)
        %}
        function serialiseButtonsConfiguration(this)
            if length(this.linesButtonNames) == length(this.linesButtonValues)
                nbLines = length(this.linesButtonValues);
            else
                msgbox('Error on button configuration');
            end
            this.buttonsNamesSerialised = {};
            this.buttonsValuesSerialised = {};
            for i=1:nbLines
                names = this.linesButtonNames{i};
                values = this.linesButtonValues{i};
                buttonsNumber = length(names);
                for j=1:buttonsNumber
                    this.buttonsNamesSerialised = {this.buttonsNamesSerialised{:}  names{j}};
                    this.buttonsValuesSerialised = {this.buttonsValuesSerialised{:} values{j}};
                end
            end
        end
        
        %{
        Function:
        dynamic user interface for adding coding lines
        
        Arguments:
        this - optionnal, the object on which the function is called
        lineId - integer : number of the line to code (useful to define
        automagically position for the buttons)
        %}
        function addCodingButtonsLine(this,lineId)
            newButtons = this.linesButtonNames{lineId};
            buttonColor = [rand(1)*0.7 rand(1)*0.7 rand(1)*0.7];

            % start position of the left of the button line (10 px margin
            % from end of the event list)
            startLeftPosition = this.EventSituationListWidth + 10;
            % start Top position of the first line : differents lines are
            % displayed below each other (10px margin from window top)
            startTopPosition = this.windowHeigth - 45;
           
            % free pixel where buttons can be displayed
            totalFreeWidth = this.windowWidth-startLeftPosition;

            buttonHeigth = 21;
            margin = 5;
            fontSize = 11;
            
            buttonNumber = length(newButtons);
            buttonWidth = floor(totalFreeWidth / buttonNumber );
            
            % creation of all the buttons
            for i=1:buttonNumber
                % extend structures to end+1
                this.labelList{end+1} = newButtons{i};
                this.buttonsHandlerList{end+1} = uicontrol(this.getFigureHandler(),... then use the end position
                 'Style', 'pushbutton', 'String', this.labelList{end}, 'Position', [startLeftPosition+(buttonWidth*(i-1)) startTopPosition-(buttonHeigth*(lineId-1))-(margin*(lineId-1)) buttonWidth buttonHeigth],'FontSize',fontSize,'FontWeight','bold','ForegroundColor',[1 1 1]);
                set(this.buttonsHandlerList{end},'BackgroundColor', buttonColor);
                callbackHandler = @this.buttonAutoCallback;
                set(this.buttonsHandlerList{end}, 'Callback', callbackHandler);
            end
        end
        
        %{
        Function:
        dynamic user interface for delete coding
        
        Arguments:
        this - optionnal, the object on which the function is called
        lineId - integer : number of the line to code (useful to define
        automagically position for the buttons
        %}
        function addDeleteButton(this)
                % extend structures to end+1
                this.labelList{end+1} = 'Del. event';
                this.buttonsHandlerList{end+1} = uicontrol(this.getFigureHandler(),... then use the end position
                 'Style', 'pushbutton', 'String', this.labelList{end}, 'Position', [400 5 80 20]);
                set(this.buttonsHandlerList{end},'BackgroundColor', [1 0 0]);
                callbackHandler = @this.deleteButtonCallback;
                set(this.buttonsHandlerList{end}, 'Callback', callbackHandler);
        end
                
        %{
        Function:
        unique callback that handle all the button subroutines.
        It launch the good function according to the button that is pressed
        
        Arguments:
        this - optionnal, the object on which the function is called
        source - the handler to the button that has been pressed and that trigger the callback
        eventdata - additional data...
        %}
        function buttonAutoCallback(this, source, eventdata)
            % dispatching to the good subroutine
            currentTimecode = this.theTrip.getTimer.getTime();
            buttonLabel = get(source,'String');
            
            buttonId = strcmp(buttonLabel, this.buttonsNamesSerialised);
            textualValue = this.buttonsNamesSerialised{buttonId};
            numericValue = this.buttonsValuesSerialised{buttonId};
            
            this.theTrip.setEventVariableAtTime(this.tableName,'numericValue',currentTimecode,str2num(numericValue));
            this.theTrip.setEventVariableAtTime(this.tableName,'textualValue',currentTimecode,textualValue);
            
           %Dirty patch for MiniE.
            this.theTrip.getTimer().setTime(this.theTrip.getTimer().getTime() + 0.0001);
        end
     
        %{
        Function:
        unique callback that handle all the button subroutines.
        It launch the good function according to the button that is pressed
        
        Arguments:
        this - optionnal, the object on which the function is called
        source - the handler to the button that has been pressed and that trigger the callback
        eventdata - additional data...
        %}
        function deleteButtonCallback(this, source, eventdata)
            validation = questdlg('You are about to delete an event','Event deletion','Yes','No','No');
            if strcmp(validation,'Yes')
               
                currentTimecode = this.theTrip.getTimer.getTime();                
                record = this.theTrip.getEventOccurenceNearTime(this.tableName,currentTimecode);
                timecodeOccurenceToDelete = cell2mat(record.getVariableValues('timecode'));
                if abs(timecodeOccurenceToDelete-currentTimecode) < 0.04
                    this.theTrip.removeEventOccurenceAtTime(this.tableName,timecodeOccurenceToDelete)
                else
                    msgbox('Pas d''evenement séléctionné');
                end
            end
        end
        
        %{
        Function:
        unique callback that handle all the keypress subroutines.
        It launch the good function according to the key that is pressed
        
        Arguments:
        this - optionnal, the object on which the function is called
        source - the handler to the control were the key was pressed
        eventdata - additional data...
        %}
        function keyPressCallback(this, source, eventdata)
            if strcmp(eventdata.Key,'return')
                uicontrol(source)
                switch source
                    %can be useful to handle keypress!
                end
            end
        end
        
        %{
        Function:
        This method read an external file and set the button definitions
        and the other setting for the coding window
        
        Arguments:
        this - optional, the object on which the method is called
        configFile - the path to the file that contain the configuration.
        It has to be a txt file with a very specific syntaxt. Only very few
        error control is done.
        
        Returns:
        out - a cell array of "buttons description" : a string divided in
        2 parts 'name of button 1; name of button 2| value associated to
        button 1;value associated to button2'
        %}
        function out = loadConfigFromTxtFile(this,configFile)
            
            config = {};
            fid = fopen(char(configFile));
            % read the file
            line = 1;
            while ~feof(fid)
                config{line} = fgetl(fid);
                line = line+1;
            end
            % close the file
            fclose(fid);
            
            % load the class variable with the value of the config file
            this.tableName = char(config{2}); % config line 2 contains table name
            this.markerIdentifier = ['event.' char(config{2})];
            this.windowTitle = char(config{4});
            this.windowHeigth = str2num(config{6}); % convert to num 
            this.windowWidth = str2num(config{8});
            this.EventSituationListWidth = str2num(config{10});
            out = {};
            compteur = 1;
            for i = 12:length(config)
                out{compteur} = char(config{i});
                compteur = compteur + 1;
            end
        end
    end
    
    methods(Static)
        %Function: isInstanciable()
        %Overwrite <plugins.Plugin.isInstanciable()>.
        %
        %Returns:
        %out - true
        function out = isInstanciable()
            out = true;
        end
        
        function out = getName()
            out = 'Codage d''Events';
        end
        
        %Function: getConfiguratorClass()
        %Implements <fr.lescot.bind.plugins.Plugin.getConfiguratorClass()>.
        function out = getConfiguratorClass()
            out = 'fr.lescot.bind.configurators.EventCoding_Configurator';
        end
        
    end
    
end