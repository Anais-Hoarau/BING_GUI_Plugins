classdef Tortue < Reptile & Quadrupede
    %TORTUE est une classe qui d�finit l'objet tortue
    %   Detailed explanation goes here
    
    methods
        function seDeplacer(this)
            disp('je me traine!! Mais laisse tomber');
        end
        
        function sEtouffeAvecDesSacsPlastiques(this)
            disp('Arrrrrg je ne peux plus respirer!!!');
        end
        
        function bougerLesPattes(this)
            disp('Je bouge les pattes � 2 � lheure!!!');
        end
        
        function this = Tortue(nom)
            this@Reptile(nom);
        end
    end
    
end

