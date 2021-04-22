classdef Dauphin < Mammifere
    %DAUPHIN Summary of this class goes here
    %   Detailed explanation goes here
    
    
    methods
        function seDeplacer(this)
            disp('je nage comme un poisson dans la piscine');
        end
        
        function this = Dauphin(nom)
            this@Mammifere(nom);
        end
    end
    
end

