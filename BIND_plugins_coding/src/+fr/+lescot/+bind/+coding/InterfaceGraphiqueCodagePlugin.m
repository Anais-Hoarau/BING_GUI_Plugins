 classdef InterfaceGraphiqueCodagePlugin < handle
    properties
        handleGraphic;
        
        fenetresCodage;
    end
    
    events
        closingEvent;
    end
    
    methods
        function this = InterfaceGraphiqueCodagePlugin(figureHandlers,protocol)
            import fr.lescot.bind.coding.*
            this.handleGraphic.fenetreCodage = figureHandlers;
            this.initializeWindows(protocol)
        end
        
        function  initializeWindows(this,protocol)
            Variables = protocol.getAllVariables;
            N = length(Variables);
            this.fenetresCodage = cell(1,N);
            for i=1:1:N
                if isa(Variables{i},'fr.lescot.bind.coding.eventVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetrePluginCodageEvent(this.handleGraphic.fenetreCodage{i},Variables{i});
                elseif isa(Variables{i},'fr.lescot.bind.coding.stateVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetrePluginCodageState(this.handleGraphic.fenetreCodage{i},Variables{i});
                elseif isa(Variables{i},'fr.lescot.bind.coding.situationVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetrePluginCodageSituation(this.handleGraphic.fenetreCodage{i},Variables{i});
                end
            end
        end
        
        function out = getFiguresHandler(this)
            out =  this.handleGraphic.fenetreCodage;
        end
        
        function out = getInterfaceWindows(this)
            out = this.fenetresCodage;
        end
    end
end