classdef Ornithorynque < Mammifere
    %ORNITHORYNQUE Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function seReproduire(this)
        end
        function seDeplacer(this)
        end
        function out = getNom(this)
            %% on doit d�clarer explicitement le this pour que getNom sache
            %% sur quoi il est appel�
            out = [this.getNom@Animal ' ' this.getNom@Animal];
        end
        function this = Ornithorynque(nom)
            this@Mammifere(nom);
        end
    end
    
end

