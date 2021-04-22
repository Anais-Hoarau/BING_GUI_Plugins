classdef Mecano < handle
    
    properties(Access = private)
        vaisseau;
    end
    
    methods
        
        function this = Mecano(vaisseau)
            this.vaisseau = vaisseau;
        end
        
        function faireFonctionnerLeVaisseau(this)
            while(true)
                try
                    this.vaisseau.voyagerDansLHyperespace();
                catch ME
                    if(strcmp(ME.identifier, 'VaisseauSpatial:voyagerDansLHyperespace:PanneMoteur'))
                        if(rand > 0.2)
                            disp('Mécano : Moteur réparé, on repart !');
                        else
                            disp('Mécano : Aïe, le moteur va exploser !');
                            rethrow(ME);
                        end
                    else
                       disp('Mecano : cafetière réparée, tout va bien !');
                    end
                end
            end
        end
    end
    
end

