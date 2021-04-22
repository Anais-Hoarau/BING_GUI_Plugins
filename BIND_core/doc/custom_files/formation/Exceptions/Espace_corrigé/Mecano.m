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
                            disp('M�cano : Moteur r�par�, on repart !');
                        else
                            disp('M�cano : A�e, le moteur va exploser !');
                            rethrow(ME);
                        end
                    else
                       disp('Mecano : cafeti�re r�par�e, tout va bien !');
                    end
                end
            end
        end
    end
    
end

