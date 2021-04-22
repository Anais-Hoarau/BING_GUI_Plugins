classdef Vipere < Reptile 
    %Vipere est une classe qui définit l'objet tortue
    %   Detailed explanation goes here
    
    methods
        function seDeplacer(this)
            disp('huhu ca gliiiisse!');
        end
        
        function muer(this)
            disp('CHANGEMENT DE PEAU!!!!!');
        end
               
        function this = Vipere(nom)
            this@Reptile(nom);
        end
    end
    
end

