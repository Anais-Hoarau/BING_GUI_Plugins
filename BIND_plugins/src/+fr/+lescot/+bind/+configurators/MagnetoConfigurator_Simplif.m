
classdef MagnetoConfigurator_Simplif < fr.lescot.bind.configurators.PluginConfigurator_simplif
    
    properties  
        positionChooser;
        positionCardinale;
       
    end
    
    methods
        function this = MagnetoConfigurator_Simplif(pluginId, pluginName, trip, metaTrip,varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator_simplif(pluginId, pluginName, trip, metaTrip);
            
            this.buildWindow();
            
            if length(varargin) == 1
                tthis.setUIState(varargin{1});
            end
            
            
        end
        
        
    end
    
    methods(Access = private)
        
 
        function buildWindow(this)
            set(this.getFigureHandler(), 'position', [0 0 200 150]);
            set(this.getFigureHandler(), 'Name', 'Magneto configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            this.positionChooser = fr.lescot.bind.widgets.PositionChooser(this.getFigureHandler(), 'Position', [10 60]);
            validateCallbackHandle = @this.validateCallback;
            uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [60 10 80 40], 'Callback', validateCallbackHandle);
            %Set the initial GUI position
            movegui(this.getFigureHandler(), 'center');
        end
        
        %{
        Function:
        Launched when the validate button is pressed. It launch the close
        callback.
        
        Arguments:
        this - optional
        source - for callback
        eventdata - for callback
        
        %}
        function validateCallback(this, src, eventdata)
            this.closeCallback(src, eventdata);
        end
        
       
        function closeCallback(this, src, ~)
            import fr.lescot.bind.configurators.*;
            if src ~= this.getFigureHandler()
                %GenerateConfiguration
                configuration = Configuration();
                arguments = {Argument('position', false, this.positionChooser.getSelectedPosition(),2)};
                configuration.setArguments(arguments);
                %Set configuration
                setUIState(this, configuration);
                this.positionCardinale=listArg{1};
                this.configuration = configuration;
                this.quitConfigurator();
               
            end
        end 
        
       
    end
    
    methods(Access = protected)
        %{
        Function:
        see <configurators.PluginConfigurator.setUIState()>
         %}
        function setUIState(this, configuration)%modifié pour retourner liste arguments
            this.positionCardinale = configuration.findArgumentWithOrder(2).getValue()
            this.positionChooser.setSelectedPosition(listArg(1));
            %this.configuration=configuration;
%            monTrip=fr.lescot.bind.kernel.implementation.SQLiteTrip('C:\Users\hoarau\Desktop\Bind_GIT\bind\BIND_examples\trip_307\demoTrip.trip',0.04,false)
%            fr.lescot.bind.plugins.Magneto(monTrip,this.positionChooser); %il manque juste a recuperer le plugin et place toujours au meme endroit
             
        end
        
         function quitConfigurator(this)
           delete(this.figureHandler);
        end
       
         
      
        
    end
    
 
    
    methods(Static)
        %{
        Function:
        See
        <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip, configuration) %#ok<INUSL>
            args = configuration.getArguments();
            if length(args) == 1
                out = true;
            else
                out = false;
            end
        end
        
        %{
        function tripRecup=recupereTrip(this)
            tripRecup=this.metaTrip;
         end
        %}
        
    end
    
end
