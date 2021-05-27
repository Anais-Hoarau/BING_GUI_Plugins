%{
Class:
This class is used to create a generic coding protocol that can be used with
the Generic Coding Plugin <fr.lescot.bind.plugins.GenericCodingInterface>. 
It allows to create, visualize and modify coding windows and save every
information to protocol file (.pro).
%}
classdef ProtocolCreator < handle
    
    properties
        %{
        Property:
        Strucutre containing the handle of all graphical objects.
        %}
        handleGraphic;
        
        
        %{
        Property:
        Current edited protocol. It is an instance of <fr.lescot.bind.coding.Protocol>
        class.
        %}
        currentProtocol;
        
        %{
        Property:
        Currently selected Variable. It is an instance hereting from <fr.lescot.bind.coding.Variale>
        abstract class and can be instanciated as
        <fr.lescot.bind.coding.eventVariable>,
        <fr.lescot.bind.coding.stateVariable> or 
        <fr.lescot.bind.coding.situationVariable>
        %}
        activeVariable;
        
        %{
        Property:
        Currently selected Modality. It is an instance of the
        <fr.lescot.bind.coding.Modality> class 
        %}
        activeModality;
        
        %{
        Property:
        It is an instance of the
        <fr.lescot.bind.coding.InterfaceGraphiqueCodageCreator> class
        which handles the vizualisation and modification of the coding
        windows
        %}
        interfaceCreator;
        
    end
    
    properties (SetObservable)
        %{
        Property:
        Observable properties containing the fullpath to the current
        protocol.
        %}
        protocol_fullPath;
    end
        
    events
        %{
        Event:
        This event is nitified when the ProtocolCreator closes
        %}
        closingEvent;
    end
    
    methods
        function this = ProtocolCreator()
            % Initialisation des variables
            this.currentProtocol = {};
            this.protocol_fullPath = {};
            this.interfaceCreator = {};
      
            % Fenetre Principale
            this.handleGraphic.figureProtocole = figure('NumberTitle','off',...
                'Name', 'Editeur de protocoles de codage', ...
                'MenuBar','none',...
                'Units','normalized', ...
                'Position',[0.25 0.25 0.5 0.5],...
                'Resize','off',...
                'HandleVisibility','on',... > change to callback after developping
                'CloseRequestFcn', @this.menuQuitterCallback,...
                'Visible','off');
            
            %% MENU
            this.buildMenu()
            
            %% PANEL
            this.buildPanels()
            
            %% Display the Interface
            set(this.handleGraphic.figureProtocole, 'Visible','on')
        end
    end
    
    methods (Access = public)
        %{
        Function: protocol path getter
        
        Arguments:
        
        Returns:
        fullpath the current protocol
        %}
        function out = getPath(this)
            out = this.protocol_fullPath;
        end
        
        %{
        Function: protocol path setter
        
        Arguments: 
        fullpath the current protocol
        
        Returns:
        %}
        function setPath(this,path)
            this.protocol_fullPath = path;
        end
        
        %{
        Function: Protocol loader. Load a protocol file and updates the
        different panel of the ProtocolCreator. Its also initiates the
        currentVariable property.
        
        Arguments: 
        
        Returns:
        %}
        function out = loadProtocol(this)
            if isempty(this.protocol_fullPath) || isempty(strfind(this.protocol_fullPath, '.pro'))
                errordlg({'Le chemin du protocole de codage n''est pas défini.', ...
                          'Créez-en un nouveau ou ouvrez un protocole existant.'})
                out = false;
            else
                S = load(this.protocol_fullPath,'-mat');
                this.currentProtocol = S.protocol;
                this.updateProtocolPanel;
                this.updateEventVariablesList;
                this.updateStateVariablesList;
                this.updateSituationVariablesList;
                
                if ~isempty(this.currentProtocol.getAllEventVariables)
                    this.activeVariable = this.currentProtocol.getAllEventVariables{1};
                elseif ~isempty(this.currentProtocol.getAllStateVariables)
                    this.activeVariable = this.currentProtocol.getAllStateVariables{1};
                elseif ~isempty(this.currentProtocol.getAllSituationVariables)
                    this.activeVariable = this.currentProtocol.getAllSituationVariables{1};
                else
                    this.activeVariable = {};
                end
                this.updateModalitiesList;
            end
        end
        
        %{
        Function: Save the current procotol at fullpath_protocol location
        
        Arguments: 
        
        Returns:
        %}
        function saveProtocol(this)
            protocol = this.currentProtocol; %#ok! saved variable
            save(this.protocol_fullPath,'protocol')
        end
   
    end
    
    methods (Access=private)
        %{
        Function:
        Building the figure menu.
        %}
        function buildMenu(this)
            % Menu > Fichier
            this.handleGraphic.menuFichier = uimenu('Parent',this.handleGraphic.figureProtocole,...
                'Label','Fichier',...
                'Tag','menu_Fichier');
            
            this.handleGraphic.ss_menuOuvrir = uimenu('Parent',this.handleGraphic.menuFichier,...
                'Label','Ouvrir',...
                'Tag','ss_menu_Fichier_Ouvrir', ...
                'Callback',@this.menuOuvrirCallback);
            
            this.handleGraphic.ss_menuSauvegarder = uimenu('Parent',this.handleGraphic.menuFichier,...
                'Label','Sauvegarder',...
                'Tag','ss_menu_Fichier_Sauvergarder', ...
                'Callback',@this.menuSauvegarderCallback);
            
            this.handleGraphic.ss_menuQuitter = uimenu('Parent',this.handleGraphic.menuFichier,...
                'Label','Quitter',...
                'Tag','ss_menu_Fichier_Quitter', ...
                'Callback',@this.menuQuitterCallback);
            
            % Menu > Edition
            this.handleGraphic.menuEdition = uimenu('Parent',this.handleGraphic.figureProtocole,...
                'Label','Edition',...
                'Tag','menu_Edition');
            
            this.handleGraphic.ss_menuRAZ = uimenu('Parent',this.handleGraphic.menuEdition,...
                'Label','Remise à zéro',...
                'Tag','menu_Edition_RAZ',...
                'Callback',@this.menuRAZCallback);
            
            
            % Menu > Affichage
            this.handleGraphic.menuAffichage = uimenu('Parent',this.handleGraphic.figureProtocole,...
                'Label','Affichage',...
                'Tag','menu_Affichage');
            
            this.handleGraphic.ss_menuVisualiser = uimenu('Parent',this.handleGraphic.menuAffichage,...
                'Label','Visualiser',...
                'Tag','menu_Affichage_Visualiser',...
                'Callback',@this.menuVisualiserCallback);
        end
        
        %{
        Function:
        Building the figure panels.
        %}
        function buildPanels(this)
            %% Protocol Panel
            this.handleGraphic.panelProtocole = uipanel('Parent',this.handleGraphic.figureProtocole,...
                'Title','Protocole',...
                'Units','normalized',...
                'Position',[0.01 0.019 0.2 0.95],...
                'FontSize',12,...
                'FontWeight','bold',...
                'Tag','panel_Protocole',...
                'Clipping','on');
            
            this.handleGraphic.textProtocoleNom = uicontrol('Parent',this.handleGraphic.panelProtocole,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0.1 0.9 0.8 0.05],...
                'FontWeight','bold',...
                'String','Nom',...
                'HorizontalAlignment','left',...
                'Tag','text_panelProtocol_NomProtocole');
            
            this.handleGraphic.editTextProtocoleNom = uicontrol('Parent',this.handleGraphic.panelProtocole,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0.1 0.80 0.8 0.1],...
                'String','',...
                'Fontsize',12,...
                'HorizontalAlignment','left',...
                'BackgroundColor', [0.8 0.8 0.8],...
                'Tag','editText_panelProtocol_NomProtocole');
            
            this.handleGraphic.textProtocoleCommentaire = uicontrol('Parent',this.handleGraphic.panelProtocole,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0.1 0.70 0.8 0.05],...
                'FontWeight','bold',...
                'String','Commentaires',...
                'HorizontalAlignment','left',...
                'Tag','text_panelProtocol_CommentaireProtocole');
            
            this.handleGraphic.editTextProtocoleCommentaire = uicontrol('Parent',this.handleGraphic.panelProtocole,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0.1 0.55 0.8 0.15],...
                'String','',...
                'Fontsize',12,...
                'HorizontalAlignment','left',...
                'BackgroundColor', [0.8 0.8 0.8],...
                'Tag','EditText_panelProtocol_CommentaireProtocole');
            
            this.handleGraphic.textProtocoleDate = uicontrol('Parent',this.handleGraphic.panelProtocole,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0.1 0.45 0.8 0.05],...
                'FontWeight','bold',...
                'String','Date',...
                'HorizontalAlignment','left',...
                'Tag','text_panelProtocol_DateProtocole');
            
            this.handleGraphic.editTextProtocoleDate = uicontrol('Parent',this.handleGraphic.panelProtocole,...
                'Style','text',...
                'Units','normalized',...
                'Position',[0.1 0.40 0.8 0.05],...
                'String','',...
                'Fontsize',12,...
                'HorizontalAlignment','left',...
                'BackgroundColor', [0.8 0.8 0.8],...
                'Tag','EditText_panelProtocol_DateProtocole');
            
            this.handleGraphic.buttonModifierProtocole = uicontrol('Parent',this.handleGraphic.panelProtocole,...
                'Style','pushbutton',...
                'Units','normalized',...
                'Position',[0.1 0.20 0.8 0.1],...
                'String','Modifier',...
                'BackgroundColor', [0.8 0.8 0.8],...
                'Tag','ModifierButton_panelProtocole', ...
                'Callback', @this.initialiserProtocole);
            
            %% Variables panel
            
            this.handleGraphic.panelVariables = uipanel('Parent',this.handleGraphic.figureProtocole,...
                'Title','Variables',...
                'Units','normalized',...
                'Position',[0.22 0.02 0.35 0.95],...
                'FontSize',12,...
                'FontWeight','bold',...
                'Tag','panel_Variables',...
                'Clipping','on');
           % Event
            this.handleGraphic.textListEvent = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','text',...
                'String','Evènements',...
                'Units','normalized',...
                'Position',[0.05 0.9 0.8 0.05],...
                'HorizontalAlignment','left',...
                'FontWeight','bold',...
                'Tag','panel_Variables',...
                'Callback', @this.selectEventCallback);
            
           this.handleGraphic.listEvent = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','listbox',...
                'Units','normalized',...
                'Position',[0.05 0.68 0.9 0.22],...
                'FontWeight','bold',...
                'Tag','panel_Variables',...
                'Callback', @this.selectEventCallback);
                
          this.handleGraphic.buttonAddEvent = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','+',...
                'Position',[0.4 0.915 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',12,...
                'Tag','button_Variable_addEvent',...
                'Callback', @this.addEventCallback);
           
          this.handleGraphic.buttonRemoveEvent = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','-',...
                'Position',[0.5 0.915 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',14,...
                'Tag','button_Variable_removeEvent',...
                'Callback', @this.removeEventCallback);
           
           this.handleGraphic.buttonEditEvent = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','Editer',...
                'Position',[0.6 0.915 0.2 0.04],...
                'FontWeight','bold',...
                'FontSize',10,...
                'Tag','button_Variable_removeEvent',...
                'Callback', @this.editEventCallback);
            
          % State
          this.handleGraphic.textlistState = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','text',...
                'String','Etats',...
                'Units','normalized',...
                'Position',[0.05 0.585 0.5 0.05],...
                'HorizontalAlignment','left',...
                'FontWeight','bold',...
                'Tag','panel_Variables'); 
            
           this.handleGraphic.listState = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','listbox',...
                'Units','normalized',...
                'Position',[0.05 0.365 0.9 0.22],...
                'Tag','panel_Variables',...
                'Callback', @this.selectStateCallback);
            
            this.handleGraphic.buttonAddState = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','+',...
                'Position',[0.4 0.6 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',12,...
                'Tag','button_Variable_addState',...
                'Callback', @this.addStateCallback);
           
          this.handleGraphic.buttonRemoveState = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','-',...
                'Position',[0.5 0.6 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',14,...
                'Tag','button_Variable_removeState',...
                'Callback', @this.removeStateCallback);
           
           this.handleGraphic.buttonEditState = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','Editer',...
                'Position',[0.6 0.6 0.2 0.04],...
                'FontWeight','bold',...
                'FontSize',10,...
                'Tag','button_Variable_removeState',...
                'Callback', @this.editStateCallback);
            
            %Situation
            this.handleGraphic.textlistSituation = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','text',...
                'String','Situations',...
                'Units','normalized',...
                'Position',[0.05 0.27 0.5 0.05],...
                'HorizontalAlignment','left',...
                'FontWeight','bold',...
                'Tag','panel_Variables'); 
            
            this.handleGraphic.listSituation = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','listbox',...
                'Units','normalized',...
                'Position',[0.05 0.05 0.9 0.22],...
                'Tag','panel_Variables',...
                'Callback', @this.selectSituationCallback);
            
            this.handleGraphic.buttonAddSituation = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','+',...
                'Position',[0.4 0.285 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',12,...
                'Tag','button_Variable_addSituation',...
                'Callback', @this.addSituationCallback);
           
          this.handleGraphic.buttonRemoveSituation = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','-',...
                'Position',[0.5 0.285 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',14,...
                'Tag','button_Variable_removeSituation',...
                'Callback', @this.removeSituationCallback);
           
           this.handleGraphic.buttonEditSituation = uicontrol('Parent',this.handleGraphic.panelVariables,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','Editer',...
                'Position',[0.6 0.285 0.2 0.04],...
                'FontWeight','bold',...
                'FontSize',10,...
                'Tag','button_Variable_removeSituation',...
                'Callback', @this.editSituationCallback);
            
            %% Modalities panel
            this.handleGraphic.panelModalities = uipanel('Parent',this.handleGraphic.figureProtocole,...
                'Title','Modalités',...
                'Units','normalized',...
                'Position',[0.61 0.02 0.38 0.95],...
                'FontSize',12,...
                'FontWeight','bold',...
                'Tag','panel_Modalities');
            
            
            this.handleGraphic.textlistNomModality = uicontrol('Parent',this.handleGraphic.panelModalities,...
                'Style','text',...
                'String','Label',...
                'Units','normalized',...
                'Position',[0.05 0.9 0.5 0.05],...
                'HorizontalAlignment','left',...
                'FontWeight','bold',...
                'Tag','panel_Variables'); 
            
            this.handleGraphic.listModality = uicontrol('Parent',this.handleGraphic.panelModalities,...
                'Style','listbox',...
                'Units','normalized',...
                'Position',[0.05 0.05 0.85  0.85],...
                'Tag','panel_Variables');
            
            this.handleGraphic.buttonAddModality = uicontrol('Parent',this.handleGraphic.panelModalities,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','+',...
                'Position',[0.3 0.915 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',12,...
                'Tag','button_Variable_addModality',...
                'Callback', @this.addModalityCallback);
           
          this.handleGraphic.buttonRemoveModality = uicontrol('Parent',this.handleGraphic.panelModalities,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','-',...
                'Position',[0.4 0.915 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',14,...
                'Tag','button_Variable_removeModality',...
                'Callback', @this.removeModalityCallback);
           
            this.handleGraphic.buttonEditModality = uicontrol('Parent',this.handleGraphic.panelModalities,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','Editer',...
                'Position',[0.5 0.915 0.2 0.04],...
                'FontWeight','bold',...
                'FontSize',10,...
                'Tag','button_Variable_removeModality',...
                'Callback', @this.editModalityCallback);
            
            this.handleGraphic.buttonDefaultModality = uicontrol('Parent',this.handleGraphic.panelModalities,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','Default',...
                'Position',[0.7 0.915 0.2 0.04],...
                'FontWeight','bold',...
                'FontSize',10,...
                'Tag','button_Variable_removeModality',...
                'Enable','off',...
                'Callback', @this.setDefaultModalityCallback);
            this.handleGraphic.buttonUpModality = uicontrol('Parent',this.handleGraphic.panelModalities,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','^',...
                'Position',[0.9 0.55 0.1 0.04],...
                'FontWeight','normal',...
                'FontSize',16,...
                'Tag','button_Variable_uplistModality',...
                'Callback', @this.uplistModalityCallback);
            
            this.handleGraphic.buttonDownModality = uicontrol('Parent',this.handleGraphic.panelModalities,...
                'Style','pushbutton',...
                'Units','normalized',...
                'String','v',...       
                'Position',[0.9 0.45 0.1 0.04],...
                'FontWeight','bold',...
                'FontSize',11,...
                 'Tag','button_Variable_downlistModality',...
                 'Callback', @this.downlistModalityCallback);
            
        end
        

        %% Menu Callbacks
        %{
        Function:
        Callback of the menu>ouvrir button. Offers the possibility to save
        the current protocol before opening a new one.
        %}      
        function menuOuvrirCallback(this,source,~)
            if source == this.handleGraphic.ss_menuOuvrir
                % TODO : Ne pas proposer de sauvegarder si le protocol
                % courant est vide
                % Sauvegarder le protocole courant
                choice = questdlg('Voulez-vous sauvegarder le protocole en cours d''édition ?','Sauvegarde','Oui','Non','Oui');
                switch choice
                    case 'Oui'
                        this.menuSauvegarderCallback
                    case 'Non'
                end
            end
            % Ourvir un fichier protocol (.pro)
            [protocoleFile,protocolePath] = uigetfile('*.pro','Ouvrir un protocole de codage');
            this.protocol_fullPath = fullfile(protocolePath,protocoleFile);
            if protocoleFile ~= 0
                this.loadProtocol()
            end
        end
        
        %{
        Function:
        Callback of the menu>sauvegarder button. Offers the possibility to save
        the current protocol.
        %}
        function menuSauvegarderCallback(this,~,~)
            [FileName,PathName] = uiputfile('*.pro','Sauvegarde');
            this.protocol_fullPath = fullfile(PathName,FileName);
            protocol = this.currentProtocol; %#ok! saved variable
            try
                save(this.protocol_fullPath,'protocol')
            catch
                warndlg('Veuillez entrer un nom de protocole valide.');
            end
        end
        
        %{
        Function:
        Callback of the menu>quitter button. Quits the ProtocolCreator and
        notifies a closingEvent
        %}
        function menuQuitterCallback(this,~,~)
            %button = questdlg('Souhaitez vous sauvegarder le protocole avant de quitter ?');
            %TODO :  Proposer de sauvegarder avant de quitter
            delete(this.handleGraphic.figureProtocole)
            notify(this,'closingEvent')
        end
        
        %{
        Function:
        Callback of the edition>raz button. Resets the current protocol.
        %}
        function menuRAZCallback(this,~,~)
            button = questdlg('Etes-vous sûr de vouloir réinitialiser le protocole ?');
            if strcmp(button,'Yes')
                this.currentProtocol = {};
                this.activeVariable = {};
                set(this.handleGraphic.editTextProtocoleNom,'String','');
                set(this.handleGraphic.editTextProtocoleCommentaire,'String','');
                set(this.handleGraphic.editTextProtocoleDate,'String','');
                set(this.handleGraphic.listEvent,'String','');
                set(this.handleGraphic.listState,'String','');
                set(this.handleGraphic.listSituation,'String','');
                set(this.handleGraphic.listModality,'String','');
                
                set(this.handleGraphic.listEvent,'Value',zeros(0,1));
                set(this.handleGraphic.listState,'Value',zeros(0,1));
                set(this.handleGraphic.listSituation,'Value',zeros(0,1));
                set(this.handleGraphic.listModality,'Value',zeros(0,1));
            end
        end
        
        %{
        Function:
        Callback of the affichage>visualiser button. Instanciates a <fr.lescot.bind.coding.InterfaceGraphiqueCodageCreator>
        which Opens the different coding windows and allows editing.
        %}
        function menuVisualiserCallback(this,~,~)
            protocol = this.currentProtocol;
            if isempty(protocol)
                %TODO Afficher un message d'erreur
                errordlg('Il n''y a aucun protocole de codage à visualiser')
            else
                if isempty(this.protocol_fullPath)
                    this.menuSauvegarderCallback
                else
                    protocol = this.currentProtocol; %saved variable, used next line
                    save(this.protocol_fullPath,'protocol')
                end
                if ~isempty(this.interfaceCreator)
                    this.interfaceCreator.closingWindowsCallback
                end
                this.interfaceCreator = fr.lescot.bind.coding.InterfaceGraphiqueCodageCreator(protocol);
                addlistener(this.interfaceCreator,'closingEvent', @this.resetInterfaceCreator)
            end
        end
        
        %{
        Function:
        Save the current protocol and reset the InterfaceCreator property.
        %}
        function resetInterfaceCreator(this,~,~)
            this.saveProtocol
            this.interfaceCreator = {};
        end
        
        %% Panels Callbacks
        % Protocol Panel callback
        %{
        Function:
        Callback of the modifier button from the protocol panel. Opens a
        new window used to modify the general fields (name, comments, date) 
        of the protocol .
        %}
        function initialiserProtocole(this,~,~)
            if isempty(this.currentProtocol)
                default = {'Nom','Commentaires',date};
            else
                default = {this.currentProtocol.getName , ...
                           this.currentProtocol.getComments, ...
                           this.currentProtocol.getDate};
            end
            
            prompt = {'Nom du protocole','Commentaires','Date'};
            
            answers = inputdlg(prompt,'Initialisation du protocole',1, default);
            % Test si il y a un réponse / Cancel button
            if ~isempty(answers)
                name = answers{1};
                comments = answers{2};
                date_str = answers{3};
            else
                name = {};
            end

            if  ~isempty(name)

                % Test si il existe déjà une instance de protocole
                if isempty(this.currentProtocol)
                    this.currentProtocol = fr.lescot.bind.coding.Protocol(name);
                    this.currentProtocol.setComments(comments);
                    this.currentProtocol.setDate(date_str);
                else
                    this.currentProtocol.setName(name)
                    this.currentProtocol.setComments(comments)
                    this.currentProtocol.setDate(date_str)
                end
                this.updateProtocolPanel;
            end
        end
        
        % Variables Panel Callback
        % Event
        %{
        Function:
        Callback for the selecting an occurence in the event panel. 
        Updates the current variable and the modality list.
        %}
        function selectEventCallback(this,~,~)
            selectedIndex = get(this.handleGraphic.listEvent,'Value');
            if ~isempty(selectedIndex)
                this.activeVariable = this.currentProtocol.getAllEventVariables{selectedIndex};
                this.disableDefaultButton;
            end
            this.updateModalitiesList;
        end
        
        %{
        Function:
        Callback for the add (+) event panel. Opens a modal windows to
        define the event added to the protocol.
        %}
        function addEventCallback(this,~,~)
            % Test si un protocole est déjà instancié
            if isempty(this.currentProtocol)
                errordlg('Aucun protocole n''est chargé pour le moment. Vous pouvez soit ouvrir un protocole sauvargardé soit intialiser le protocole courant à l''aide du bouton "Modifier".')
            else
                prompt = {'Nom de l''évènement','Commentaires'};
                answers = inputdlg(prompt,'Ajouter une variable "Evènement"',1);
                if ~isempty(answers)
                nom = answers{1};
                comments = answers{2};
                %if ~isempty(nom)
                    % Test si il existe un variable évènement avec le même nom
                    if any(strcmp(this.currentProtocol.getAllEventVariablesNames,nom))
                        errordlg('Une variable évènement du même nom existe déjà.')
                    else
                        newEventVariable = fr.lescot.bind.coding.eventVariable(nom);
                        newEventVariable.setComments(comments)
                        this.currentProtocol.addVariable(newEventVariable);
                    end
                    this.updateEventVariablesList;
                    this.selectEventCallback;
                end
            end
        end
        
        %{
        Function:
        Callback for the remove (-) event panel. Remove the selected event
        to the protocol. Updates the current variable and the modality list
        %}
        function removeEventCallback(this,~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.currentProtocol.getAllEventVariables)
                selectionIndex = get(this.handleGraphic.listEvent,'Value');
                selectedEvent = this.currentProtocol.getAllEventVariables{selectionIndex};
                this.currentProtocol.removeVariable(selectedEvent)
                set(this.handleGraphic.listEvent,'Value', max(1,selectionIndex-1));
                this.updateEventVariablesList;
                this.activeVariable={};
                this.updateModalitiesList;
            end
        end
        
        %{
        Function:
        Callback for the edit (editer) event panel. Opens a modal windows
        to enter the new event properties (name, comments)
        %}
        function editEventCallback(this,~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.currentProtocol.getAllEventVariables)
                selectionIndex = get(this.handleGraphic.listEvent,'Value');
                selectedEvent = this.currentProtocol.getAllEventVariables{selectionIndex};
                name = selectedEvent.getName;
                comment = selectedEvent.getComments;
                prompt = {'Nom de l''évènement','Commentaires'};
                default = {name,comment};
                answers = inputdlg(prompt,'Modifier la variable "Evènement" sélectionnée',1, default);
                
                if ~isempty(answers)
                    new_name = answers{1};
                    % Test pour eviter d'avoir un nom vide
                    if ~eq(length(answers{1}),0)
                        new_comments = answers{2};
                        % Test si il existe un variable évènement avec le même nom
                        if any(strcmp(this.currentProtocol.getAllEventVariablesNames,new_name)) && ~strcmp(new_name, name)
                            errordlg('Une variable évènement du même nom existe déjà.')
                        else
                            selectedEvent.setName(new_name);
                            selectedEvent.setComments(new_comments);
                        end
                        this.updateEventVariablesList;
                    else
                         errordlg('le nom de l''évènement est vide');
                        
                        
                    end
                    
                end
            end
        end
        
        % State
        %{
        Function:
        Callback for the selecting an occurence in the state panel.
        Updates the current variable and the modality list.
        %}
        function selectStateCallback(this,~,~)
            selectedIndex = get(this.handleGraphic.listState,'Value');
            if ~isempty(selectedIndex)
                this.activeVariable = this.currentProtocol.getAllStateVariables{selectedIndex};
                if ~isempty(this.activeVariable.getAllModalities)
                    this.enableDefaultButton
                end
            end
            this.updateModalitiesList;
        end
        
        %{
        Function:
        Callback for the add (+) state panel. Opens a modal windows to
        define the state added to the protocol.
        %}
        function addStateCallback(this,~,~)
            % Test si un protocole est déjà instancié
            if isempty(this.currentProtocol)
                errordlg('Aucun protocole n''est chargé pour le moment. Vous pouvez soit ouvrir un protocole sauvargardé soit intialiser le protocole courant à l''aide du bouton "Modifier".')
            else
                prompt = {'Nom de l''état','Commentaires'};
                default = {'',''};
                answers = inputdlg(prompt,'Ajouter une variable "Etat"',1, default);
                %nom = answers{1};
                 if ~isempty(answers)
                nom = answers{1};  
                comments = answers{2};
               % if ~isempty(nom)
                    % Test si il existe une variable état avec le même nom
                    if any(strcmp(this.currentProtocol.getAllStateVariablesNames,nom))
                        errordlg('Une variable état du même nom existe déjà.')
                    else
                        newStateVariable = fr.lescot.bind.coding.stateVariable(nom);
                        newStateVariable.setComments(comments)
                        this.currentProtocol.addVariable(newStateVariable);
                    end
                    this.updateStateVariablesList;
                    this.selectStateCallback;
                end
            end
            
        end
        
        %{
        Function:
        Callback for the remove (-) state panel. Remove the selected state
        to the protocol. Updates the current variable and the modality list
        %}
        function removeStateCallback(this,~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.currentProtocol.getAllStateVariables)
                selectionIndex = get(this.handleGraphic.listState,'Value');
                selectedState = this.currentProtocol.getAllStateVariables{selectionIndex};
                this.currentProtocol.removeVariable(selectedState)
                set(this.handleGraphic.listState,'Value', max(1,selectionIndex-1));
                this.updateStateVariablesList;
                this.activeVariable={};
                this.updateModalitiesList;
            end
        end
        
        %{
        Function:
        Callback for the edit (editer) state panel. Opens a modal windows
        to enter the new state properties (name, comments)
        %}
        function editStateCallback(this,~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.currentProtocol.getAllStateVariables)
                selectionIndex = get(this.handleGraphic.listState,'Value');
                selectedState = this.currentProtocol.getAllStateVariables{selectionIndex};
                name = selectedState.getName;
                comment = selectedState.getComments;
                prompt = {'Nom de l''état','Commentaires'};
                default = {name,comment};
                answers = inputdlg(prompt,'Modifier la variable "Etat" sélectionnée',1, default);
                if ~isempty(answers)
                    new_name = answers{1};
                     % Test pour eviter d'avoir un nom vide
                    if ~eq(length(answers{1}),0)
                        new_comments = answers{2};
                        % Test si il existe un variable évènement avec le même nom
                        if any(strcmp(this.currentProtocol.getAllStateVariablesNames,new_name)) && ~strcmp(new_name, name)
                            errordlg('Une variable état du même nom existe déjà.')
                        else
                            selectedState.setName(new_name);
                            selectedState.setComments(new_comments)
                        end
                        this.updateStateVariablesList;
                    else
                        errordlg('le nom de l''etat est vide');
                    end
                end
            end
        end
        
        

        
        %{
        Function:
        Callback for the default button modality panel. Set the current
        selected modality as default for the current state variable. The
        button is disable when the current variable is not a stateVariable.
        %}
        function setDefaultModalityCallback(this, ~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.activeVariable) && ~isempty(this.activeVariable.getAllModalities)
                selectionIndex = get(this.handleGraphic.listModality,'Value');
                selectedModality = this.activeVariable.getAllModalities{selectionIndex};
                if ~isempty(selectedModality) && isa(this.activeVariable,'fr.lescot.bind.coding.stateVariable')
                    this.activeVariable.setDefaultModality(selectedModality)
                end
                this.updateModalitiesList
            end
        end
        
        %{
        Function:
        Enable the Default button of the modality panel
        %}
        function disableDefaultButton(this)
            set(this.handleGraphic.buttonDefaultModality, 'Enable', 'off')
        end
        
        %{
        Function:
        Disable the Default button of the modality panel
        %}
        function enableDefaultButton(this)
            set(this.handleGraphic.buttonDefaultModality, 'Enable', 'on')
        end
        
        % Situation
        %{
        Function:
        Callback for the selecting an occurence in the situation panel.
        Updates the current variable and the modality list.
        %}
        function selectSituationCallback(this,~,~)
            selectedIndex = get(this.handleGraphic.listSituation,'Value');
            if ~isempty(selectedIndex)
                this.activeVariable = this.currentProtocol.getAllSituationVariables{selectedIndex};
                this.disableDefaultButton;
            end
            this.updateModalitiesList;
        end
        %{
        Function:
        Callback for the add (+) situation panel. Opens a modal windows to
        define the situation added to the protocol.
        %}
        function addSituationCallback(this,~,~)
            % Test si un protocole est déjà instancié
            if isempty(this.currentProtocol)
                errordlg('Aucun protocole n''est chargé pour le moment. Vous pouvez soit ouvrir un protocole sauvargardé soit intialiser le protocole courant à l''aide du bouton "Modifier".')
            else
                prompt = {'Nom de la situation','Commentaires'};
                default = {'',''};
                answers = inputdlg(prompt,'Ajouter une variable "Situation"',1, default);
                if ~isempty(answers)
                nom = answers{1};
                comments = answers{2};
                %if ~isempty(nom)
                    % Test si il existe un variable état avec le même nom
                    if any(strcmp(this.currentProtocol.getAllSituationVariablesNames,nom))
                        errordlg('Une variable situation du même nom existe déjà.')
                    else
                        newSituationVariable = fr.lescot.bind.coding.situationVariable(nom);
                        newSituationVariable.setComments(comments)
                        this.currentProtocol.addVariable(newSituationVariable);
                    end
                    this.updateSituationVariablesList;
                    this.selectSituationCallback;
                end
            end
        end
        %{
        Function:
        Callback for the remove (-) situation panel. Remove the selected
        situation
        to the protocol. Updates the current variable and the modality list
        %}
        function removeSituationCallback(this,~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.currentProtocol.getAllSituationVariables)
                selectionIndex = get(this.handleGraphic.listSituation,'Value');
                selectedSituation = this.currentProtocol.getAllSituationVariables{selectionIndex};
                this.currentProtocol.removeVariable(selectedSituation)
                set(this.handleGraphic.listSituation,'Value', max(1,selectionIndex-1));
                this.updateSituationVariablesList;
                this.activeVariable={};
                this.updateModalitiesList;
            end
        end
        %{
        Function:
        Callback for the edit (editer) situation panel. Opens a modal windows
        to enter the new situation properties (name, comments)
        %}
        function editSituationCallback(this,~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.currentProtocol.getAllSituationVariables)
                selectionIndex = get(this.handleGraphic.listSituation,'Value');
                selectedSituation = this.currentProtocol.getAllSituationVariables{selectionIndex};
                name = selectedSituation.getName;
                comment = selectedSituation.getComments;
                prompt = {'Nom de la situation','Commentaires'};
                default = {name,comment};
                answers = inputdlg(prompt,'Modifier la variable "Situation" sélectionnée',1, default);
                if ~isempty(answers)
                    new_name = answers{1};
                     % Test pour eviter d'avoir un nom vide
                    if ~eq(length(answers{1}),0)
                        new_comments = answers{2};
                        % Test si il existe un variable évènement avec le même nom
                        if any(strcmp(this.currentProtocol.getAllSituationVariablesNames,new_name)) && ~strcmp(new_name, name)
                            errordlg('Une variable situation du même nom existe déjà.')
                        else
                            selectedSituation.setName(new_name);
                            selectedSituation.setComments(new_comments)
                        end
                        this.updateSituationVariablesList;
                    else
                        errordlg('le nom de la situation est vide');
                    end
                end
            end
        end
        
        
  
        %{
        Function:
        Callback for the selecting an occurence in the modality list. Not
        in used
        %}
        function selectModalityCallback(~,~,~)
        end
        
  
        %{
        Function:
        Callback for the add (+) modality panel. Opens a modal windows to
        add the new mlodality the current variable.
        %}
        function addModalityCallback(this,~,~)
            % Test si un protocole est déjà instancié
            if isempty(this.currentProtocol)
                errordlg('Aucun protocole n''est chargé pour le moment. Vous pouvez soit ouvrir un protocole sauvargardé soit intialiser le protocole courant à l''aide du bouton "Modifier".')
            elseif isempty(this.activeVariable)
                errordlg('Vous devez d''abord créer une variable. Si c''est déjà fait pensez à la sélectionner avant d''ajouter une modalité.')
            else
                prompt = {'Nom de la modalité','Commentaires'};
                default = {'',''};
                answers = inputdlg(prompt,'Ajouter une modalité à la variable sélectionnée',1, default);
                if ~isempty(answers)
                    nom = answers{1};
                    comments = answers{2};
                    % Test si il existe un variable état avec le même nom
                    if any(strcmp(this.activeVariable.getAllModalitiesNames,nom))
                        errordlg('Une modalité du même nom existe déjà.')
                    else
                        newModalityVariable = fr.lescot.bind.coding.Modality(nom);
                        newModalityVariable.setComments(comments)
                        this.activeVariable.addModality(newModalityVariable);
                    end
                    if ~isempty(this.activeVariable.getDefaultModality)
                        this.enableDefaultButton
                    end
                    this.updateModalitiesList;
                end
            end
        end
        
        %{
        Function:
        Callback for the add (-) modality panel. Removes the selected modality
        from the current variable.
        %}
           
            function removeModalityCallback(this,~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.activeVariable) && ~isempty(this.activeVariable.getAllModalities)
                selectionIndex = get(this.handleGraphic.listModality,'Value');
                selectedModality = this.activeVariable.getAllModalities{selectionIndex};
                this.activeVariable.removeModality(selectedModality)
                set(this.handleGraphic.listModality,'Value', max(1,selectionIndex-1));
                this.updateModalitiesList;
            end
            end
            

            %{
        Function:
        Callback for the up(^) modality panel. up selected modality from one
        step
    
        %}
            function uplistModalityCallback(this,~,~)
                if ~isempty(this.currentProtocol)  && ~isempty(this.activeVariable) && ~isempty(this.activeVariable.getAllModalities)
                    
                    selectionIndex = get(this.handleGraphic.listModality,'Value');
                    
                    
                    if selectionIndex >=2
                        upModality = this.activeVariable.getAllModalities{selectionIndex};
                        downModality = this.activeVariable.getAllModalities{selectionIndex-1};
                        
                        if ~isempty(this.activeVariable.getDefaultModality)
                            if eq(this.activeVariable.getAllModalities{selectionIndex}, upModality)
                                defaultModality = upModality;
                            end
                            
                            if eq(this.activeVariable.getAllModalities{selectionIndex-1}, downModality)
                                defaultModality = downModality ;
                            end
                        else
                            defaultModality = this.activeVariable.getDefaultModality;
                        end
                        
                        
                        nameup = upModality.getName;
                        commentup = upModality.getComments;
                        namedown = downModality.getName;
                        commentdown = downModality.getComments;
                        upModality.setName(namedown);
                        upModality.setComments(commentdown);
                        
                        downModality.setName(nameup);
                        downModality.setComments(commentup);
                        
                        if  isa(this.activeVariable,'fr.lescot.bind.coding.stateVariable')
                            this.activeVariable.setDefaultModality(defaultModality);
                        end
                        
                        this.updateModalitiesList;
                        set (this.handleGraphic.listModality,'Value',selectionIndex-1);
                    end
                end
            end
            
            %{
        Function:
        Callback for the down(v) modality panel. down selected modality from one
        step
    
        %}
   
            function downlistModalityCallback(this,~,~)
                if ~isempty(this.currentProtocol)  && ~isempty(this.activeVariable) && ~isempty(this.activeVariable.getAllModalities)
                    
                    selectionIndex = get(this.handleGraphic.listModality,'Value');
                    if selectionIndex < length(this.activeVariable.getAllModalities)
                        
                        downModality = this.activeVariable.getAllModalities{selectionIndex};
                        upModality = this.activeVariable.getAllModalities{selectionIndex+1};
                        
                        if ~isempty(this.activeVariable.getDefaultModality)
                            if eq(this.activeVariable.getAllModalities{selectionIndex}, downModality)
                                defaultModality = downModality;
                            end
                            
                            if eq(this.activeVariable.getAllModalities{selectionIndex+1}, upModality)
                                defaultModality = upModality ;
                            end
                        else
                            defaultModality=this.activeVariable.getDefaultModality;
                        end
                        % end
                        nameup = upModality.getName;
                        commentup = upModality.getComments;
                        namedown = downModality.getName;
                        commentdown = downModality.getComments;
                        upModality.setName(namedown);
                        upModality.setComments(commentdown);
                        downModality.setName(nameup);
                        downModality.setComments(commentup);
                        if  isa(this.activeVariable,'fr.lescot.bind.coding.stateVariable')
                            this.activeVariable.setDefaultModality(defaultModality)
                        end
                        this.updateModalitiesList;
                        set (this.handleGraphic.listModality,'Value',selectionIndex+1);
                    end
                end
            end
         
        %{
        Function:
        Callback for the edit (editer) modality panel. Opens a modal windows
        to enter the new modality properties (name, comments)
        %}
        function editModalityCallback(this,~,~)
            if ~isempty(this.currentProtocol)  && ~isempty(this.activeVariable) && ~isempty(this.activeVariable.getAllModalities)
                selectionIndex = get(this.handleGraphic.listModality,'Value');
                selectedModality = this.activeVariable.getAllModalities{selectionIndex};
                name = selectedModality.getName;
                comment = selectedModality.getComments;
                prompt = {'Nom de la modalité','Commentaires'};
                default = {name,comment};
                answers = inputdlg(prompt,'Modifier la modalité de la variable sélectionnée',1, default);
                if ~isempty(answers)
                    new_name = answers{1};
                     % Test pour eviter d'avoir un nom vide
                    if ~eq(length(answers{1}),0)
                    new_comments = answers{2};
                    % Test si il existe un variable évènement avec le même nom
                    if any(strcmp(this.activeVariable.getAllModalities,new_name)) && ~strcmp(new_name, name)
                        errordlg('Une modalité du même nom existe déjà pour la variable sélectionnée.')
                    else
                        selectedModality.setName(new_name);
                        selectedModality.setComments(new_comments)
                    end
                    this.updateModalitiesList;
                    else
                        errordlg('le nom de la modalité est vide');
                    end
                end
            end
        end
      
        
        %% UPDATE Lists
        %{
        Function:
        Updates the fields of the protcol panel.
        %}
        function updateProtocolPanel(this)
            if ~isempty(this.currentProtocol)
                set(this.handleGraphic.editTextProtocoleNom,'String',this.currentProtocol.getName);
                set(this.handleGraphic.editTextProtocoleCommentaire,'String',this.currentProtocol.getComments);
                set(this.handleGraphic.editTextProtocoleDate,'String',this.currentProtocol.getDate);
            end
        end
        %{
        Function:
        Updates the event list.
        %}
        function updateEventVariablesList(this)
            Names = this.currentProtocol.getAllEventVariablesNames;
            if isempty(get(this.handleGraphic.listEvent,'Value')) && ~isempty(Names)
                set(this.handleGraphic.listEvent,'Value',1)
            end
            set(this.handleGraphic.listEvent,'String',Names)
        end
        %{
        Function:
        Updates the state list.
        %}
        function updateStateVariablesList(this)
            Names = this.currentProtocol.getAllStateVariablesNames;
            if isempty(get(this.handleGraphic.listState,'Value')) && ~isempty(Names)
                set(this.handleGraphic.listState,'Value',1)
            end
            set(this.handleGraphic.listState,'String',Names)
        end
        %{
        Function:
        Updates the situation list.
        %}
        function updateSituationVariablesList(this)
            Names = this.currentProtocol.getAllSituationVariablesNames;
            if isempty(get(this.handleGraphic.listSituation,'Value')) && ~isempty(Names)
                set(this.handleGraphic.listSituation,'Value',1)
            end
            set(this.handleGraphic.listSituation,'String',Names)
        end
        %{
        Function:
        Updates the modality list.
        %}
        function updateModalitiesList(this)
            if ~isempty(this.activeVariable)
                Names = this.activeVariable.getAllModalitiesNames;
                if ~isempty(this.activeVariable.getDefaultModality)
                    for i=1:1:length(this.activeVariable.getAllModalities)
                        if eq(this.activeVariable.getAllModalities{i}, this.activeVariable.getDefaultModality)
                            Names{i} = [Names{i} ' (default)'];
                        end
                    end
                end
                if (isempty(get(this.handleGraphic.listModality,'Value')) && ~isempty(Names)) || get(this.handleGraphic.listModality,'Value') > length(Names)
                    set(this.handleGraphic.listModality,'Value',1)
                end
                set(this.handleGraphic.listModality,'String',Names)
            else
                set(this.handleGraphic.listModality,'String','')
            end
        end
    
    end
end