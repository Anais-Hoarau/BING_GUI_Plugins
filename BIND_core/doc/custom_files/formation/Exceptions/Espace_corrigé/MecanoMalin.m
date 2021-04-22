classdef MecanoMalin < Mecano
    
    methods
        
        function this = MecanoMalin(vaisseau)
            this@Mecano(vaisseau);
        end
        
        function faireFonctionnerLeVaisseau(this)
            try
                this.faireFonctionnerLeVaisseau@Mecano;
            catch ME
                this.sEjecter();
                rethrow(ME);
            end
        end
        
        function sEjecter(this)
            disp('MecanoMalin : Je m''éjecte pendant qu''il est encore temps !');
        end
        
    end
    
end

