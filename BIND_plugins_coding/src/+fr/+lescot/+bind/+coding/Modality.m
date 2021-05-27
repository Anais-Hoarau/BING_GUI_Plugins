classdef Modality < handle
    
    % The modality class contains all information dedicated for creating an
    % coding interface. It is meant to saved as a '.pro' file
    
    properties(Access = private)
        %{
      Property:
      Nom du protocole
        %}
        label;
        
        %{
      Property:
      Commentaire du protocole
        %}
        comments;
     
        button;
    end
    
    methods (Access= public)
        
        % constructor
        function this = Modality(name)
            this.setName(name);
        end
        
        % Get and Set
        function setName(this,name)
            this.label = name;
        end
        
        function out = getName(this)
            out= this.label;
        end
        
        function setComments(this,comments)
            this.comments = comments;
        end
        
        function out= getComments(this)
            out= this.comments;
        end
        
        function setModalityButton(this, button)
            this.button = button;
        end
        
        function out = getModalityButton(this)
            out = this.button;
        end
        
    end
end