classdef Mammifere < Animal
    %MAMMIFERE ce sont les animaux à MAMELLES !
    %   ils se reproduisent viviparement
    
    methods
        %% on grille aussi le this
        function seReproduire(this)
            disp('je me reproduit viviparement!');
        end
        
        function this = Mammifere(nom)
            this@Animal(nom);
        end
    end
    
end

