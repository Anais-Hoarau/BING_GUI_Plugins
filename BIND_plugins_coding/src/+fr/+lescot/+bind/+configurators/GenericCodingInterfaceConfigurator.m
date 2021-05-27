%{
Class:
This class is the configurator of the <Magneto> plugin

%}
classdef GenericCodingInterfaceConfigurator < fr.lescot.bind.configurators.PluginConfigurator
    
    properties
        handlesGraphic;
        
        protocolCreator;
        
        protocol_fullpath;
    end
    

    
    methods
        
        %{
        Function:
        The constructor of the GenericCodingInterfaceConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        tripInformation - a <data.MetaInformations> object that stores the
        available videos
        caller - handler to the interface that ask for a configuration, in
        order to be able to give back the configurator when closing.
        
        
        Returns:
        this - a new VideoPlayerConfigurator.
        %}
        function this = GenericCodingInterfaceConfigurator(pluginId, metaTrip, caller, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator(pluginId, metaTrip, caller);

            this.buildWindow();
            if length(varargin) == 1
                this.setUIState(varargin{1});
            end
        end
    end
    
    methods(Access = private)
        
        %{
        Function:
        Build the window
        
        Arguments:
        this - optional
        
        %}
        function buildWindow(this)
            
            set(this.getFigureHandler(),...
                'position', [0 0 300 300], ...
                'Name', 'Generic Coding Interface configurator',...
                'Visible','off', ...
                'HandleVisibility','off', ...
                'WindowStyle','modal',...
                'CloseRequestFcn', @this.closeCallback);
            
            this.handlesGraphic.buttonLoad = uicontrol(this.getFigureHandler(), ...
                'Style', 'pushbutton', ...
                'String', 'Charger un protocole codage existant', ...
                'Position', [25 240 250 40], ...
                'Callback', @this.loadProtocol);
            
            this.handlesGraphic.buttonNew = uicontrol(this.getFigureHandler(), ...
                'Style', 'pushbutton', ...
                'String', {'Créer un nouveau protocole','ou','Editer un protocole existant'}, ...
                'Position', [25 170 250 40], ...
                'Callback', @this.newProtocol);
            
            this.handlesGraphic.buttonEdit = uicontrol(this.getFigureHandler(), ...
                'Style', 'pushbutton', ...
                'String', {'Editer un protocole existant'}, ...
                'Position', [25 125 250 40], ...
                'Callback', @this.editProtocol);
            
            this.handlesGraphic.textPath = uicontrol(this.getFigureHandler(), ...
                'Style','text', ...
                'String','Chemin du fichier (.pro):', ...
                'HorizontalAlignment','left',...
                'BackgroundColor',[0.796 0.796 0.796],...
                'Position', [25 90 250 20]);
            
            this.handlesGraphic.editTextPath = uicontrol(this.getFigureHandler(), ...
                'Style', 'text', ...
                'String','', ...
                'HorizontalAlignment','left',...
                'Position', [25 65 250 30]);
            
            % Boutton Démmarer
            this.handlesGraphic.buttonStart = uicontrol(this.getFigureHandler(), ...
                'Style', 'pushbutton', ...
                'String', 'Charger le protocole', ...
                'Position', [25 10 250 40], ...
                'Callback', @this.validateCallback);
            
            movegui(this.getFigureHandler(), 'center');
            set(this.getFigureHandler(),'Visible','on')
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
        
        %{
        Function:
        Launched when the window have to be closed.
        
        Arguments:
        this - optional
        source - for callback
        eventData - for callback
        
        %}
        function closeCallback(this, source, eventData)
            import fr.lescot.bind.configurators.*;
            if source ~= this.getFigureHandler()
                %GenerateConfiguration
                configuration = Configuration();
                arguments = {Argument('protocol_path', false, this.protocol_fullpath,2)};
                configuration.setArguments(arguments);
                %Set configuration
                this.configuration = configuration;
                this.quitConfigurator();
            else
                delete(source)
            end
        end   
    end
     
    methods(Access = protected)
        %{
        Function:
        see <configurators.PluginConfigurator.setUIState()>
        %}
        function setUIState(this, configuration)
            this.protocol_fullpath = configuration.findArgumentWithOrder(2).getValue();
            set(this.handlesGraphic.editTextPath,'String',this.protocol_fullpath)
        end
        
        function loadProtocol(this, source, eventData)
            [protocolFile,protocolPath] = uigetfile('*.pro', 'Charger un protocole de codage existant :');
            if ~isequal(protocolFile,0) && ~isequal(protocolPath,0)
                this.protocol_fullpath = fullfile(protocolPath,protocolFile);
                set(this.handlesGraphic.editTextPath,'String',this.protocol_fullpath)
            end
            this.closeCallback(source,[]);
        end
        
        function newProtocol(this, source, eventData)
            this.initiateProtocolCreator
            this.hide;
        end
        
        function editProtocol(this, source, eventData)
            if isempty(this.protocol_fullpath)
                [protocolFile, protocolPath] = uigetfile('*.pro','Load un protocole');
                this.protocol_fullpath = fullfile(protocolPath,protocolFile);
            end
                this.initiateProtocolCreator
                this.hide;
                this.protocolCreator.setPath(this.protocol_fullpath)
                this.protocolCreator.loadProtocol
        end
        
        function initiateProtocolCreator(this)
            this.protocolCreator = fr.lescot.codingProtocolEditor.ProtocolCreator;
            addlistener(this.protocolCreator,'protocol_fullPath','PostSet',@this.updatePath)
            addlistener(this.protocolCreator,'closingEvent',@this.show);
        end
        
        function show(this, src, eventData)
            set(this.getFigureHandler(),'Visible','on');
        end
        
        function hide(this, src, eventData)
            set(this.getFigureHandler(),'Visible','off');
        end
        
        function updatePath(this, metaProp, eventData)
            this.protocol_fullpath = eventData.AffectedObject.getPath;
            set(this.handlesGraphic.editTextPath,'String',this.protocol_fullpath)
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
            if isempty(args{1}.getValue) || ~exist(args{1}.getValue, 'file') % || isempty(strfind(args{1}.getValue, '.pro')) %test : protocole name / file / extension file
                %errordlg('Veuillez sélectionner un protocole valide.')
                out = false;
            else
                if  strcmp(args{1}.getName,'protocol_path')
                    S = load(args{1}.getValue,'-mat');
                    currentProtocol = S.protocol;
                    [isValid, errorMessage, warningMessage] = currentProtocol.isValid;
                else
                    isValid = false;
                end
                
                if length(args) == 1 && isValid
                    if ~isempty(warningMessage)
                        warndlg(warningMessage)
                    end
                    out = true;
                else
                    out = false;
                    errordlg(errorMessage)
                end
            end
        end
        
    end
    
end

