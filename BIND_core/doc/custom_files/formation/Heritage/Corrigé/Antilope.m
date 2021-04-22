classdef Antilope <  Mammifere & Quadrupede
    %ANTILOPE 
    
    methods
        function seDeplacer(this)
            disp('tagada tagada');
        end
        function bougerLesPattes(this)
            disp('Je bouge les pattes comme une antilope!!!');
        end
        function this = Antilope(nom)
            this@Mammifere(nom);
        end
    end
    
end

