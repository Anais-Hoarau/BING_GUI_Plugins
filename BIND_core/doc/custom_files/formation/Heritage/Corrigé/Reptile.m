classdef Reptile < Animal
    %Reptile ce sont les animaux 
    %   ils se reproduisent oviparement
    
    methods
        %% on grille aussi le this
        function seReproduire(this)
            disp('je me reproduit oviparement!');
        end
        
        function this = Reptile(nom)
            this@Animal(nom);
        end
    end
    
end

