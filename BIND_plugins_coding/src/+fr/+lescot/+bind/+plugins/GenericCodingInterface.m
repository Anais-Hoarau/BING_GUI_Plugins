%{
Class:
This class describes a plugin that allow to display the values of several
variables of the trip at the current time in a table.

%}
classdef GenericCodingInterface < fr.lescot.bind.plugins.MultiGraphicalPlugin & fr.lescot.bind.plugins.TripPlugin
    properties(Access = private)
        currentProtocol;
        
        pluginInterface;
        
        figureHandlers;
        
        interfaceWindows;
        
        Variables;
        
        codedEventLists;
        
        codedStateLists;
        
        codedSituationLists;
        
        
        
    end
    
    properties (Constant)
        genericTag = '__genericCodingTable__'
    end
    
    methods
        %{
        Function:
        The constructor of the GenericCodingInterface plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        
        trip - The <kernel.Trip> object on which the DataPlotter will be
        synchronized and which data will be displayed.
        dataIdentifiers - A cell array of strings, which are all of the
        form "dataName.variableName".
        position - The initial position of the window.
        %}
        function this = GenericCodingInterface(trip, protocol_fullpath)
            import fr.lescot.bind.utils.StringUtils;
            import fr.lescot.bind.coding.*;
            
            N = fr.lescot.bind.plugins.GenericCodingInterface.getNumberVariables(protocol_fullpath);
            
            this@fr.lescot.bind.plugins.TripPlugin(trip);
            this@fr.lescot.bind.plugins.MultiGraphicalPlugin(N);
            
            this.figureHandlers = this.getFigureHandlers;
            
            this.loadProtocol(protocol_fullpath);
            this.buildUI;
            
            this.initializeTripTables;
           
            this.defineCallbacks;
            
            this.updateExistingModalities;
            
            this.updateLists
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)
            period = this.getCurrentTrip.getTimer().getPeriod();
            if period > 0.1  
            elseif any(strcmp(message.getCurrentMessage(),{'STEP' 'GOTO'}))
                %disp('Lists Update')
                this.updateLists;
            elseif any(strcmp(message.getCurrentMessage(),{'START' 'EVENT_CONTENT_CHANGED' 'SITUATION_CONTENT_CHANGED'}))
                disp('Mods Update')
                this.updateExistingModalities;
            end
        end
        
        %{
        Function:
        Build the window of the GUI
        
        Arguments:
        this - The object on which the function is called, optionnal.
        position - The initial position of the GUI.
        
        %}
        function loadProtocol(this, protocol_fullpath)
                S = load(protocol_fullpath,'-mat');
                this.currentProtocol = S.protocol;
        end

        function buildUI(this)
            this.pluginInterface = fr.lescot.bind.coding.InterfaceGraphiqueCodagePlugin(this.figureHandlers, this.currentProtocol);
            this.interfaceWindows = this.pluginInterface.getInterfaceWindows;
        end
        
        function initializeTripTables(this)
            MetaInfos = this.getCurrentTrip.getMetaInformations;
            
            this.Variables.Events = this.currentProtocol.getAllEventVariables;
            for i=1:1:length(this.Variables.Events)
                if this.existGenericEventTable(MetaInfos,this.Variables.Events{i})
                    this.loadGenericEventTable(this.Variables.Events{i})
                else
                    this.createGenericEventTable(this.Variables.Events{i})
                end
            end
            
            this.Variables.Situations = this.currentProtocol.getAllSituationVariables;
            for i=1:1:length(this.Variables.Situations)
                if this.existGenericSituationTable(MetaInfos,this.Variables.Situations{i})
                    this.loadGenericSituationTable(this.Variables.Situations{i})
                else
                    this.createGenericSituationTable(this.Variables.Situations{i})
                end
            end
            
            % The creation of the state table has to be done at last
            % because its modifies the table contents leading th
            this.Variables.States = this.currentProtocol.getAllStateVariables;
            for i=1:1:length(this.Variables.States)
                if this.existGenericStateTable(MetaInfos,this.Variables.States{i})
                    this.loadGenericStateTable(this.Variables.States{i})
                else
                    this.createGenericStateTable(this.Variables.States{i})
                end
            end
            
        end
        
        function out = existGenericEventTable(this,MetaInfos,eventVariable)
            name = eventVariable.getName;
            out = false;
            EventsList = MetaInfos.getEventsList;
            for i=1:1:length(EventsList)
                if strcmp(EventsList{i}.getName,name) && strcmp(EventsList{i}.getComments, this.genericTag)
                    out = true;
                end
            end
        end
        
        function createGenericEventTable(this,eventVariable)
            name = eventVariable.getName;
            
            newEventTable = fr.lescot.bind.data.MetaEvent;
            newEventTable.setName(name)
            newEventTable.setComments(this.genericTag)
            
            var{1} = fr.lescot.bind.data.MetaEventVariable();
            var{1}.setName('Modalities')
            var{1}.setType('TEXT')
            
            newEventTable.setVariables(var)
            this.getCurrentTrip.addEvent(newEventTable)
            this.getCurrentTrip.setIsBaseEvent(name,true)
        end
        
        function loadGenericEventTable(this, eventVariable)
            name = eventVariable.getName;
            record = this.getCurrentTrip.getAllEventOccurences(name);
            this.codedEventLists{end+1} = record.buildCellArrayWithVariables({'timecode','Modalities'});
        end
          
        function out = existGenericStateTable(this,MetaInfos,stateVariable)
            name = stateVariable.getName;
            out = false;
            StatesList = MetaInfos.getSituationsList;
            for i=1:1:length(StatesList)
                if strcmp(StatesList{i}.getName,name) && strcmp(StatesList{i}.getComments, this.genericTag)
                    out = true;
                end
            end
        end
        
        function createGenericStateTable(this, stateVariable)
            name = stateVariable.getName;
            
            newStateTable = fr.lescot.bind.data.MetaSituation;
            newStateTable.setName(name)
            newStateTable.setComments(this.genericTag)
            
            var{1} = fr.lescot.bind.data.MetaSituationVariable();
            var{1}.setName('Modalities')
            var{1}.setType('TEXT')
            
            newStateTable.setVariables(var)
            this.getCurrentTrip.addSituation(newStateTable)
            this.getCurrentTrip.setIsBaseSituation(name,true)
            
            if ~isempty(stateVariable.getDefaultModality)
                defaultMod = stateVariable.getDefaultModality.getName;
                this.getCurrentTrip.setIsBaseSituation(name,false)
                maxTime = this.getCurrentTrip.getMaxTimeInDatas;
                this.getCurrentTrip.setSituationVariableAtTime(name,'Modalities',0,maxTime,defaultMod)
                this.getCurrentTrip.setIsBaseSituation(name,true)
            else
                errordlg(['Protocol Error: There is no default modality for the state variable :' name])
            end
            
        end
        
        function loadGenericStateTable(this, stateVariable)
            name = stateVariable.getName;
            record = this.getCurrentTrip.getAllSituationOccurences(name);
            this.codedStateLists{end+1} = record.buildCellArrayWithVariables({'startTimecode','endTimecode','Modalities'});
        end
        
        function out = existGenericSituationTable(this,MetaInfos,situationVariable)
            name = situationVariable.getName;
            out = false;
            SituationsList = MetaInfos.getSituationsList;
            for i=1:1:length(SituationsList)
                if strcmp(SituationsList{i}.getName,name) && strcmp(SituationsList{i}.getComments, this.genericTag)
                    out = true;
                end
            end
        end
        
        function createGenericSituationTable(this, situationVariable)
            name = situationVariable.getName;
            
            newSituationTable = fr.lescot.bind.data.MetaSituation;
            newSituationTable.setName(name)
            newSituationTable.setComments(this.genericTag)
            
            var{1} = fr.lescot.bind.data.MetaSituationVariable();
            var{1}.setName('Modalities')
            var{1}.setType('TEXT')
            
            newSituationTable.setVariables(var)
            this.getCurrentTrip.addSituation(newSituationTable)
            this.getCurrentTrip.setIsBaseSituation(name,true)
        end
        
        function loadGenericSituationTable(this, situationVariable)
            name = situationVariable.getName;
            record = this.getCurrentTrip.getAllSituationOccurences(name);
            this.codedSituationLists{end+1} = record.buildCellArrayWithVariables({'startTimecode','endTimecode','Modalities'});
        end
        
        function defineCallbacks(this)
            for i=1:1:length(this.interfaceWindows)
                this.interfaceWindows{i}.defineObjectCallback(this.getCurrentTrip)
            end
        end
        
        function updateCurrentModalities(this)
            for i=1:1:length(this.interfaceWindows)
                this.interfaceWindows{i}.updateCurrentModality(this.getCurrentTrip)
            end
        end
        
        function updateLists(this)
            for i=1:1:length(this.interfaceWindows)
                this.interfaceWindows{i}.updateList(this.getCurrentTrip)
            end
        end
        
        function updateExistingModalities(this)
            for i=1:1:length(this.interfaceWindows)
                this.interfaceWindows{i}.updateExistingMods(this.getCurrentTrip)
            end
        end
        
        %{
        Function:
        
        Resizes the components to fit in the new size of the figure.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function resizeFigureCallback(this, ~ ,~)
            for i=1:1:length(this.interfaceWindows)
%                 this.interfaceWindows{i}.getFigureHandler()
%                 this.setPosition([0 0 370 max(100+20*N,160)])
            end
%                         % Resize figure callback
%             set(this.getFigureHandler(), 'Resize', 'off');
%             resizeFigureCallbackHandler = @this.resizeFigureCallback;
%             set(this.getFigureHandler(), 'ResizeFcn', resizeFigureCallbackHandler);
        end
    end
    
    methods(Static)
        function out = getNumberVariables(protocol_fullpath)
            S = load(protocol_fullpath,'-mat');
            protocol = S.protocol;
            out= length(protocol.getAllVariables);
        end

        %{
        Function:
        Returns the human-readable name of the plugin.
        
        Returns:
        A String.
        
        %}
        function out = getName()
            out = '[ALL] Codage générique';
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
            out = 'fr.lescot.bind.configurators.GenericCodingInterfaceConfigurator';   
        end
        
    end
    
end