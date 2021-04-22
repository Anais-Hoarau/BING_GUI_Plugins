%{
Class:
This class is the base class for the plugin configurators. A plugin
configurator is most of the time a GUI that allow the user to select some
parameters for a given class of plugin. As a plugin is able to return the
class of its configurator, it allows a launcher to instanciante the right
class of configurator. The launcher have to implement the interface
<ConfiguratorUser> to be able to use the plugin configurator. This
interface provides a method that is used when the user validates the
configurations and closes the window. It's a form of callback. The
configuration passed to the launcher is the one stored in the property
<configuration>.

%}
classdef PluginConfigurator_simplif < handle
    properties (Access= public)
           %{
        Property:
        The <MetaInformations> object that contains all the data and
        variables the plugin should be able to propose.
        
        %}
        trip; %rajout
        
        pluginName; %rajout
        
        
        %{
        Property:
        The handler on the window.
        
        %}
        figureHandler; %rajout passe de private à public
        
        configuration;% passage de 'protected' à public
    end
    properties(Access = private)
       
        
        
        %{
        Property:
        The reference to the software object that launched the plugin
        configurator and needs the configuration.
        
        %}
        %caller; suprimer 
        
        %{
        Property:
        The identifier of the plugin instance that is configured. Used to
        be passed to the caller during the callback so that it is able to
        link the configuratio returned to the instance.
        
        %}
        pluginId;
        
    end
    
    properties(Access = protected)
        %{
        Property:
        The object that contains the <Configuration> returned when the
        window is closed.
        
        %}
        
        
        metaTrip;
        
      
    end
    
    methods(Access = public)
        
        %{
        Function:
        
        Build a configurator window. By default, the WindowStyle property
        is "modal", wich means that when the configurator is open, it is
        impossible to access other matlab windows.
        
        Arguments:
        metaTrip - A <data.MetaInformation> object that contains all the
        data that the loader determined as being usable by the
        configurator.
        pluginId - A unique value referencinf the plugin instance that
        will be configured. This value is passed back to the
        <ConfiguratorUser> object. The structure and value of the id does
        not matter, as long as the <ConfiguratorUser> is able to
        understand it.
        caller - A reference to the object that instanciated the
        configurator, and that implements the <ConfiguratorUser>
        interface.
        configuration - An optionnal argument containing a configuration
        to restore.
        
        Throws:
        ARGUMENT_EXCEPTION - if "caller" does not implement <ConfiguratorUser>
        
        %}
        function this = PluginConfigurator_simplif( pluginName, trip, metaTrip, varargin)%caller supr
            import fr.lescot.bind.exceptions.ExceptionIds;
            %{
            if ~isa(caller, 'fr.lescot.bind.configurators.ConfiguratorUser')
                 throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The argument "caller" must implement the interface fr.lescot.bind.configurators.ConfiguratorUser'));
            end
            %}
            this.trip=trip; %rajout
            this.pluginName=pluginName;%rajout
            this.metaTrip = metaTrip;
            
            %this.caller = caller;
            %this.pluginId = pluginId;
            this.figureHandler = figure('MenuBar', 'none', 'Name', 'Plugin', 'NumberTitle', 'off', 'Resize', 'off', 'Toolbar', 'none', 'Visible', 'on', 'Position', [0 0 100 100]);
            set(this.figureHandler,'WindowStyle','modal');
        end
        
        %{
        Function:
        
        Returns the handler to manipulate the window of the configurator.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A figure handler.
        
        %}
        function out = getFigureHandler(this)
            out = this.figureHandler;
        end
        
        %{
        Function:
        
        Returns the reference of the list of trips.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A <plugins.Plugin> reference.
        
        %}
        function out = getTripsList(this)
            out = this.tripsList;
        end
        
        %{
        Function:
        
        Stores the configuration that will be returned when quitting the plugin.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        config - the <Configuration> object representing the new
        configuration to set.
        
        %}
        function setConfiguration(this, config)
           this.configuration = config;
           this.megaConfig.addConfigurationInMega(config);
        end
        

    
    end
    
    methods(Access = protected)
        
        %{
        Function:
        
        Closes the plugin, and send the configuration (stored in the
        attribute <PluginConfigurator.configuration>) to the object that
        instanciated the configurator. This method is mostly intended to
        be called by something like a "Validate configuration" button,
        that closes the configurator and returns to the launcher.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        config - the <Configuration> object that is finally returned by the
        plugin.
        
        %}
        function configChoisie=quitConfigurator(this)
            configExistante=this.configuration
            if isempty(configExistante)
                disp('La config est nulle');
            end
            configChoisie=this.configuration%.findArgumentWithOrder(2).getValue();
            %this.caller.receiveConfiguration(this.pluginId, this.configuration);
            
            setUIState(this, configChoisie);
            
            %{
            try
                %afficheElementConfig(this,argList);
                newP=VersPlugin(this,this.trip,configChoisie);
                
            catch ME
                msg='Erreur lors du lancement du plugin'
                delete(this.figureHandler);
            end   
            
            try 
                afficheElementConfig(this,argList,newP);
            catch ME
                msg='Erreur lors de l''affichage de newP'
            end
            %delete(this);
            %positionChoisie=this.configuration; %.findArgumentWithOrder(2).getValue()
            %}
            delete(this.figureHandler);
        end
        
        function newP=versPlugin(this, monTrip,configChoisie, varargin )%ajout
            
            if (length(varargin) == 1)
                nomPlugin=varargin{1};
            elseif (length(varargin) == 0)
                nomPlugin=this.pluginName;
            else
                msg='Trop de paramètres dans l''appel de fonction lancePlugin'
            end
            
            switch nomPlugin
                case 'Magneto'
                 fr.lescot.bind.configurators.MagnetoConfigurators_Simplif.reconstructorMagnetoConfigurator_Simplif(configChoisie)
                  
                otherwise;
                    %rien faire, on mettra ensuite plus d'arguments
                    newP='';
            end
        end
        
        function afficheElementConfig(this,argumentsList,newP)%ajout
            argumentsList{1}  
            newP
              
        end
        
              
        
        
    end
    
    methods(Abstract, Static)
        %{
        Function:
        Validates a configuration in regard of the referenceTrip passed as
        an argument. Used to check if the configuration is still valid for
        a new set of Trip for example.
        
        Arguments:
        referenceTrip - a <kernel.Trip> object.
        configuration - a <plugins.configurators.Configuration> object.
        
        %}
        out = validateConfiguration(referenceTrip, configuration);
            
    end    
    
    methods(Abstract, Access = protected)
        %{
        Function:
        Restore a configuration, so that if the plugin is validated
        immediately after, the same configuration will be generated.
        
        Arguments:
        this - optional
        configuration - The configuration to restore
        
        %}
        setUIState(this, configuration);
    end
    
    methods(Static)
        function newP=lancePluginStatic( monTrip,argumentsList, varargin )%ajout
            % où argumentsList est MegaConfigurator.getConfigurationNum(2).findArgumentWithOrder(100)
            %monTrip=fr.lescot.bind.kernel.implementation.SQLiteTrip('C:\Users\hoarau\Desktop\Bind_GIT\bind\BIND_examples\trip_307\demoTrip.trip',0.04,false)
            
            lenVarargin=size(varargin)
            if (~isempty(varargin) | lenVarargin==0)
                nomPlugin= char(varargin)
                
            elseif (lenVarargin>2)
                msg='Trop de paramètres dans l''appel de fonction lancePlugin'
                return
            else
                nomPlugin=this.pluginName
            end
            
            switch nomPlugin
                case 'Magneto'
                nbArguments=length(argumentsList)
                nouvellePosition=argumentsList.getValue()
                %monTrip=fr.lescot.bind.kernel.implementation.SQLiteTrip('C:\Users\hoarau\Desktop\Bind_GIT\bind\BIND_examples\trip_307\demoTrip.trip',0.04,false)
                newP=eval(['fr.lescot.bind.plugins.' nomPlugin '_simplif(monTrip,nouvellePosition)']); 
                 
                case 'VideoPlayer'
                    %newP=eval(['fr.lescot.bind.plugins.' nomPlugin '(monTrip,nouvellePosition)']);
                otherwise;
                    %rien faire, on mettra ensuite plus d'arguments
                    
            end
        end
    end
    

end
    
   