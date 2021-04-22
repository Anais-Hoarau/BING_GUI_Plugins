classdef Animal < handle
    %ANIMAL est un animal
    %   l'animal
    
    properties(Access=private)
        nom;
    end
    
    methods
        %% methodes normales : on doit griller le premier parametre
        %% d'entree! Mais on l'utilise quand meme dans la manipulation 
        %% des m�thodes ici !
        function out = getNom(this)
            out = this.nom;
        end
        
        function setNom(this,nom)
            this.nom = nom;
        end
        
        function manger(this, aliment)
            disp(['J''ai mang� : ' aliment]);
        end
        %% constructeur : this est la sortie du bazard
        function this = Animal(nom)
            this.setNom(nom);
        end
        
    end
    %% les m�thodes abstraitres
    methods(Abstract)
        seReproduire(this)
        seDeplacer(this)
    end
    
end

