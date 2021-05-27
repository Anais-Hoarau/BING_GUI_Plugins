%{
Class:
The Variable class is abstact and can be instanciated as eventVariable,
stateVariable or situationVariable. Basically every variable will
correspond to a coding window.
%}
classdef (Abstract) Variable < handle
    
    properties(Access = private)
        %{
        Property:
        Name of the variable
        %}
        name;
        
        %{
        Property:
        Comments regarding the variable
        %}
        comments;
        
        %{
        Property:
        Cell array of <fr.lescot.bind.coding.Modality>
        %}
        modalities;
        
         %{
        Property:
        Default modality for variable. <fr.lescot.bind.coding.Modality>.
        Relevant only for state variable.
        %}
        defaultModality;
        
        %{
        Property:
        Structure contaning all the graphical informations of the conding
        windows. Structure fields : 
        Figure>Color/Position/Name ;
        Buttons>Colors/Positions/Fonts/FontSizes ; 
        CodedModalityList>Name/Position
        %}
        infosInterfaceGraphic;
        
    end
    
    methods
        % constructor
        function this = Variable(name)
            this.setName(name);
            this.infosInterfaceGraphic = {};
            this.modalities = {};
            this.defaultModality = {};
        end
        
        % Getters and Setters
        function setName(this,name)
            this.name = name;
        end
        
        function out = getName(this)
            out= this.name;
        end
        
        function setComments(this,comments)
            this.comments = comments;
        end
        
        function out= getComments(this)
            out= this.comments;
        end
        
        %{
        Function:
        Returns the list of Modality of the variable
        
        Arguments:
        
        Returns:
        A cell array of <fr.lescot.bind.coding.Modality>
        %}
        function out = getAllModalities(this)
            out = this.modalities;
        end
        
        function out = getAllModalitiesNames(this)
            N = length(this.modalities);
            out = cell(1,N);
            for i=1:1:N
                out{i} = this.modalities{i}.getName();
            end
        end
        
        %{
        Function:
        Returns the number of modalities in the variable
        
        Arguments:
        %}
        function out = getNumberOfModalities(this)
            out = length(this.modalities);
        end
        
        function out = getDefaultModality(this)
            out = this.defaultModality;
        end
        
        function setDefaultModality(this, modality)
            this.defaultModality = modality;
        end
        
        %{
        Function:
        Adds a modality to the variable
        
        Arguments:
        %}
        function addModality(this, modality)
            newIndex = length(this.getAllModalities)+1;
            this.modalities{newIndex} = modality;
            
            if isempty(this.getDefaultModality)
                this.setDefaultModality(modality);
            end
        end
        
        %{
        Function:
        remove a modality from the variable
        
        Arguments:
        this - The thisect on which the function is called, optionnal.
        modality - a <fr.lescot.bind.coding.Modality>
        %}
        function removeModality(this, modality)
            updated_modalities = cell(1,length(this.modalities)-1);
            j=1;
            for i=1:1:length(this.modalities)
                if(this.modalities{i}.ne(modality))
                    updated_modalities{j} = this.modalities{i};
                    j=j+1;
                end
            end
            this.modalities = updated_modalities;
        end
        
        %% infosInterfaceGraphic
        function setInfosGraphic(this,infos)
            this.infosInterfaceGraphic = infos;
        end
        
        function out = getInfosGraphic(this)
            out = this.infosInterfaceGraphic;
        end
        
        %{
        Function:
        Test if the infosInterfaceGraphic structure is valid
        
        Arguments:
        %}
        function out = isInfosGraphicOk(this)
            Infos = this.getInfosGraphic;
            out = true;
            if isempty(Infos)
                out = false;
            else
                if isempty(this.getInfosGraphic.Figure.Position) || ...
                        isempty(Infos.Figure.Position) || ...
                        isempty(Infos.Figure.Name) || ...
                        isempty(Infos.Figure.Color) || ...
                        isempty(Infos.Buttons.Colors) || ...
                        isempty(Infos.Buttons.Positions) || ...
                        isempty(Infos.Buttons.Fonts) ||...
                        isempty(Infos.Buttons.FontSizes) || ...
                        isempty(Infos.Buttons.FontWeights) || ...
                        isempty(Infos.CodedModalityList.Position) || ...
                        isempty(Infos.CodedModalityList.Name)
                    out = false;
                end
                
                if length(this.getAllModalities) ~= length(Infos.Buttons.Positions)
                    out = false;
                end
            end
        end
        

        
    end
end