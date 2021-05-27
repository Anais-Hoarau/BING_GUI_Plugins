%{
Class:
This class is used to vizualize the coding windows with the aim of modify 
them and saving the correspong graphical information. It is instanciated
from a ProcotolCreator.
%}
classdef InterfaceGraphiqueCodageCreator < handle
    properties
        %{
        Property:
        Strucutre containing the handle of all graphical objects.
        %}
        handleGraphic;
        
        fenetresCodage;
    end
    
    events
        closingEvent;
    end
    
    methods
        % contructor
        function this = InterfaceGraphiqueCodageCreator(protocol)
            this.initializeWindows(protocol)
            this.closeAllWindow
        end
        
        %{
        Function: 
        Initialize the different coding windows : 
        <fr.lescot.bind.coding.fenetreCodage> variables

        Arguments: 
        protocol : a <fr.lescot.bind.coding.Protocol> variable
        %}
        function initializeWindows(this,protocol)
            Variables = protocol.getAllVariables;
            N = length(Variables);
            this.fenetresCodage = cell(1,N);
            for i=1:1:N
                if isa(Variables{i},'fr.lescot.bind.coding.eventVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetreCodageEvent(Variables{i});
                elseif isa(Variables{i},'fr.lescot.bind.coding.stateVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetreCodageState(Variables{i});
                elseif isa(Variables{i},'fr.lescot.bind.coding.situationVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetreCodageSituation(Variables{i});
                end
                this.handleGraphic.fenetreCodage{i} = this.fenetresCodage{i}.getFigureHandler();
            end
        end
        
        %{
        Function: 
        Creates the a figure with a "save and close all" button
        %}
        function closeAllWindow(this)
            this.handleGraphic.closeWindow = figure('NumberTitle','off',...
                'Position', [0 0 300 50], ...
                'MenuBar','none',...
                'Resize','off', ...
                'CloseRequestFcn',@this.saveAndCloseAllCodingWindows);
            
    
            
            this.handleGraphic.closeWindowButton = uicontrol('Parent',this.handleGraphic.closeWindow, ...
                'Style', 'pushbutton', ...
                'String','Sauvergarder et Fermer toutes les fenêtres', ...
                'Units', 'normalized', ...
                'Position', [0.05 0.05 0.90 0.90], ...
                'Callback', @this.closingWindowsCallback);
            movegui(this.handleGraphic.closeWindow, 'center')
        end
        
        %{
        Function: 
        Callback of the "Fermer et Sauvegarder" button. Notify a
        closingEvent;
        %}
        function closingWindowsCallback(this,~,~)
                close(this.handleGraphic.closeWindow)
                notify(this,'closingEvent')
        end
        
        %{
        Function: 
        CloseCallback of the "Fermer et Sauvegarder" windows. Notify a
        closingEvent;
        %}
        function saveAndCloseAllCodingWindows(this,source,~)
                for i=1:1:length(this.handleGraphic.fenetreCodage)
                    if ishghandle(this.handleGraphic.fenetreCodage{i})
                        this.fenetresCodage{i}.saveGraphicObjetProperties
                        delete(this.handleGraphic.fenetreCodage{i})
                    end
                end
                if source == this.handleGraphic.closeWindow
                    delete(this.handleGraphic.closeWindow)
                end
                notify(this,'closingEvent')
        end
    end
end