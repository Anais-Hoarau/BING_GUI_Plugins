 classdef InterfaceGraphiqueCodagePluginStatic < handle
    properties
        handleGraphic;
        
        fenetresCodage;
    end
    
    events
        closingEvent;
    end
    
    methods
        function this = InterfaceGraphiqueCodagePluginStatic(figureHandler,protocol)
            import fr.lescot.bind.coding.*
            this.handleGraphic.fenetreCodage = figureHandler;
            this.initializeWindows(protocol)
        end
        
        function  initializeWindows(this,protocol)
            table = protocol.getName;
            variables = protocol.getAllVariables;
           N = length(variables);
            this.fenetresCodage = cell(1,N);
            for i=1:1:N
                if isa(variables{i},'fr.lescot.bind.coding.eventVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetrePluginCodageEvent(this.handleGraphic.fenetreCodage{i},variables{i});
                elseif isa(variables{i},'fr.lescot.bind.coding.stateVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetrePluginCodageStateStatic(this.handleGraphic.fenetreCodage,table,variables{i},i,N);
                elseif isa(variables{i},'fr.lescot.bind.coding.situationVariable')
                    this.fenetresCodage{i} = fr.lescot.bind.coding.fenetrePluginCodageSituation(this.handleGraphic.fenetreCodage{i},variables{i});
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