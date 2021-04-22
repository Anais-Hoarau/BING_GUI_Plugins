%{
Class:
This class describes a plugin that allow to display the values of several
variables of the trip at the current time in a table.

%}
classdef MessageDisplay < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripPlugin
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
        
        dernierMessage;
        
    end
    
    methods
        
        %{
        Function:
        The constructor of the MessageDisplay plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        
        trip - The <kernel.Trip> object on which the DataPlotter will be
        synchronized and which data will be displayed.
        dataIdentifiers - A cell array of strings, which are all of the
        form "dataName.variableName".
        position - The initial position of the window.
        %}
        function this = MessageDisplay(trip, position)
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            this@fr.lescot.bind.plugins.TripPlugin(trip);
            
            this.buildUI(position);
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)
            this.dernierMessage = message.getCurrentMessage();
            set(this.tableHandler, 'Data', {'Dernier message'; this.dernierMessage}');
        end
        
        %{
        Function:
        Build the window of the GUI
        
        Arguments:
        this - The object on which the function is called, optionnal.
        position - The initial position of the GUI.
        
        %}
        function buildUI(this, position)
            set(this.getFigureHandler(), 'Position', [0 0 300 50]);
            set(this.getFigureHandler(), 'Name', 'Dernier message');
            this.tableHandler = uitable(this.getFigureHandler(), 'Position', [0 0 300 400]);
            values = cell(this.dernierMessage, 2);
            values{1, 1} = 'Dernier message';
            values{1, 2} = 'Aucun message';
            set(this.tableHandler, 'Data', values);
            set(this.tableHandler, 'ColumnName', []);
            set(this.tableHandler, 'RowName', []);
            set(this.tableHandler, 'ColumnWidth', {180 100});
            movegui(this.tableHandler, position);
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
        
        
                     %%%%%%%%%%%%%%%%%%%%%
         function closeCallback(this, src, ~)%ajout closeCallback
             class(this)
             
               try
                    p=get(this.getFigureHandler(), 'Position')
                    this.newPosition=p;
                    msg='ok'
                catch ME
                    msg="pas position recup"
                end

                
                nouvellePosition=this.getFigureHandler.Position();
                this.newPosition=nouvellePosition
                delete(this.getFigureHandler);
         end
        %%%%%%%%%%%%%%%%%%
    end
    
    methods(Static)
        %{
        Function:
        Returns the human-readable name of the plugin.
        
        Returns:
        A String.
        
        %}
        function out = getName()
            out = '[D] Affichage dernier message';
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
            out = 'fr.lescot.bind.configurators.MessageDisplayConfigurator';
        end
        

    end
    
end