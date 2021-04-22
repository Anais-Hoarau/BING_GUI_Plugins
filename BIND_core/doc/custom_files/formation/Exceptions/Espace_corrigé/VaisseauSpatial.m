classdef VaisseauSpatial < handle
    
    properties(Access = private)
        parsecs
    end
    
    methods
        
        function this = VaisseauSpatial()
            this.parsecs = 0;
        end
        
        function voyagerDansLHyperespace(this)
           while(true)
              if(rand() > 0.3)
                  this.parsecs = this.parsecs + 1;
                  disp(['Vaisseau : ' num2str(this.parsecs) ' parsecs parcourus.']);
              else
                  if(rand() > 0.5)
                      disp('Vaisseau : Ouuuups ! Problème de moteur');
                      throw(MException('VaisseauSpatial:voyagerDansLHyperespace:PanneMoteur', 'Le vaisseau est à la dérive !'));
                  else
                      disp('Vaisseau : Panne de cafetière !');
                      throw(MException('VaisseauSpatial:voyagerDansLHyperespace:PanneCafetiere', 'Le vaisseau n''a plus de café !'));
                  end
              end
           end
        end
    end
    
end

