classdef Quadrupede < handle
    %QUADRUPEDE est une interface
    %   elle donne la liste des methodes qui vont etre r�impl�ment�e dans
    %   tous les machins qui implemente le quadrupede
      
    methods(Abstract)
        bougerLesPattes; %% on doit passer en parametre ... machin truc 
    end
    
end

