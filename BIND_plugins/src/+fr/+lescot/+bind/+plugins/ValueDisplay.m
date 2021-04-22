%{
Class:
This class describes a plugin that allow to display the values of several
variables of the trip at the current time in a table.

%}
classdef ValueDisplay < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripStreamingPlugin
  %%%%%%%%
    properties(Access=public)
       newPosition; 
    end
    %%%%%%%%
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
        
        %{
        Property:
        The cell array containing the types, in string format, of the variables to plot.
        
        %}
        dataTypes;
    end
    
    methods
        
        %{
        Function:
        The constructor of the ValueDisplay plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        
        trip - The <kernel.Trip> object on which the DataPlotter will be
        synchronized and which data will be displayed.
        dataIdentifiers - A cell array of strings, which are all of the
        form "dataName.variableName".
        position - The initial position of the window.
        %}
        function this = ValueDisplay(trip, dataIdentifiers, position)
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            this@fr.lescot.bind.plugins.TripStreamingPlugin(trip, dataIdentifiers, 60, 'data');
            
            this.dataIdentifiers = dataIdentifiers;
            this.dataTypes = cell(dataIdentifiers);
            % look for the types of the variables in the trip metadata
            for i=1:length(dataIdentifiers)
                splittedDataName = regexp(dataIdentifiers{i}, '\.', 'split');
                dataName = splittedDataName{1};
                variableName = splittedDataName{2};
                metaVariables = trip.getMetaInformations.getMetaData(dataName).getVariables;
                for j=1:length(metaVariables)
                    if strcmp(metaVariables{j}.getName(),variableName)
                        this.dataTypes{i} = metaVariables{j}.getType();
                    end
                end
            end
           
            this.buildUI(position); 
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message) 
            this.update@fr.lescot.bind.plugins.TripStreamingPlugin(message);
            if any(strcmp(message.getCurrentMessage(),{'STEP' 'GOTO'}))
                currentTime = this.getCurrentTrip().getTimer().getTime();
                valuesColumn = cell(this.dataNumber, 1);
                for i = 1:1:this.dataNumber
                    [~, ind] = min( abs(cell2mat(this.dataBuffer{i,2}) - (currentTime)) );
                    if strcmp(this.dataTypes{i},'TEXT')
                        valuesColumn{i} = sprintf('%s', this.dataBuffer{i,1}{ind});
                    else
                        valuesColumn{i} = sprintf('%.12f', this.dataBuffer{i,1}{ind});
                    end
                end
                set(this.tableHandler, 'Data', {this.dataIdentifiers{:}; valuesColumn{:}}'); 
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
           set(this.getFigureHandler(), 'Position', [0 0 300 400]);
           set(this.getFigureHandler(), 'Name', 'Valeurs');
           this.tableHandler = uitable(this.getFigureHandler(), 'Position', [0 0 300 400]);
           values =  cell(this.dataNumber, 2);
           values(:, 1) = this.dataIdentifiers;
           values(:, 2) = {0};
           set(this.tableHandler, 'Data', values);
           set(this.tableHandler, 'ColumnName', []);
           set(this.tableHandler, 'RowName', []);
           set(this.tableHandler, 'ColumnWidth', {180 100});
           movegui(position);
           set(this.getFigureHandler(), 'Visible', 'on');
           set(this.getFigureHandler(), 'Resize', 'on');
           callbackHandler = @this.resizeFigureCallback;
           set(this.getFigureHandler(), 'ResizeFcn', callbackHandler);
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %fermeture de la figure
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler, 'CloseRequestFcn', closeCallbackHandle);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        %{
        Function:
        
        Resizes the components to fit in the new size of the figure.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function resizeFigureCallback(this, ~ ,~)
            newSize = get(this.getFigureHandler(), 'Position');
            %Repositionning and resizing the table
            set(this.tableHandler, 'Position', [10 10 max(1,(newSize(3) - 20)) max(1, (newSize(4) - 20))]); 
            %Resizing the table columns
            set(this.tableHandler, 'ColumnWidth', {180 max(1, (newSize(3) - 200))});
        end
        
        %%%%%%%%%%%%%%%
       function closeCallback(this, src, ~)%ajout closeCallback   
                nouvellePosition=this.getFigureHandler.Position();
                this.newPosition=nouvellePosition
                delete(this.getFigureHandler);
       end   
       %%%%%%%%%%%%%%%%
    end
    
    methods(Static)
        %{
        Function:
        Returns the human-readable name of the plugin.
        
        Returns:
        A String.
        
        %}
        function out = getName()
            out = '[D] Affichage valeurs instantanées';
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
            out = 'fr.lescot.bind.configurators.ValueDisplayConfigurator';   
        end
        
    end
    
end