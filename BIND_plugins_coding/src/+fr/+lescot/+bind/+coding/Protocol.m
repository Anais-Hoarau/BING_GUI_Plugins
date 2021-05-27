%{
Class:
The protocol class contains all information dedicated for creating an
coding interface. It is meant to saved as a '.pro' file. Basilically, it
has general fields information (name, comments, date) and variables.
%}
classdef Protocol < handle   
    properties(Access = private)
      %{
      Property:
      Name of the protocol
      %}
      name;
      
      %{
      Property:
      Comments regarding the protocol
      %}
      comments;
      
      %{
      Property:
      Date of protocol creation
      %}
      date;
      
      %{
      Property:
      Cell array of <fr.lescot.bind.coding.Variable>
      %}
      variables = {};
    end
   
    methods (Access= public)
        
        %{
        Function: Contructor of the protocol class
        
        Arguments: 
        name : name of the protocol
        
        Returns:
        %}
        function this = Protocol(name)
            this.setName(name);
        end
        
        %{
        Function: protocol path setter
        
        Arguments: 
       
        Returns:
        bool : boollean  true if the protocol is valid false otherwise
        errorMessage : error message, if not empty bool == false
        warningMessage : warning message
        %}
        function [bool, errorMessage, warningMessage] = isValid(this)
            % TODO : Tester la validité du protole !! A implémeter
            % Function à utiliser pour valider la configuration avec de lancer le plugin
            % Vérifier notamment que des states et des situations variables
            % n'ont pas le même nom
            bool =true;
            errorMessage = {};
            warningMessage = {};
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
        
        function setDate(this,date)
            this.date = date;
        end
        
        function out= getDate(this)
            out= this.date;
        end
        %% get Variables Functions
        %{
        Function:
         Returns the list of family of the protocol
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
         A cell array of <fr.lescot.bind.coding.Variable>
        %}
        function out = getAllVariables(this)
            out = this.variables;
        end
        
        function out = getAllEventVariables(this)
            testfunc = @(x)isa(x,'fr.lescot.bind.coding.eventVariable');
            mask = cellfun(testfunc,this.variables,'UniformOutput',true);
            out = this.variables(mask);
        end
        
        function out = getAllStateVariables(this)
            testfunc = @(x)isa(x,'fr.lescot.bind.coding.stateVariable');
            mask = cellfun(testfunc,this.variables,'UniformOutput',true);
            out = this.variables(mask);
        end
        
        function out = getAllSituationVariables(this)
            testfunc = @(x)isa(x,'fr.lescot.bind.coding.situationVariable');
            mask = cellfun(testfunc,this.variables,'UniformOutput',true);
            out = this.variables(mask);
        end
        
        % Get Variables Names 
        function out = getAllVariablesNames(this)
            N= length(this.variables);
            Variables = this.getAllVariables;
            out = cell(1,N);
            for i = 1:1:N
                out{i} = Variables.getName;
            end
        end
        
        function out = getAllEventVariablesNames(this)
            N= length(this.getAllEventVariables);
            eventVariables = this.getAllEventVariables;
            out = cell(1,N);
            for i = 1:1:N
                out{i} = eventVariables{i}.getName;
            end
        end
    
        function out = getAllStateVariablesNames(this)
            N= length(this.getAllStateVariables);
            stateVariables = this.getAllStateVariables;
            out = cell(1,N);
            for i = 1:1:N
                out{i} = stateVariables{i}.getName;
            end
        end
        
        function out = getAllSituationVariablesNames(this)
            N= length(this.getAllSituationVariables);
            situationVariables = this.getAllSituationVariables;
            out = cell(1,N);
            for i = 1:1:N
                out{i} = situationVariables{i}.getName;
            end
        end
        
        %{
        Function:
        returns the number of variables in the protocol
        %}
        function out = getNumberOfVariables(this)
            out = length(this.variables);
        end
        
        %{
        Function:
         add a variable to the protocol
        
        Arguments:
        this - The object on which the function is called, optionnal.
        variable - a <fr.lescot.bind.coding.Variable>
        
        %}
        function addVariable(this, variable)
            newIndex = length(this.variables)+1;
            this.variables{newIndex} = variable;
        end
        
        %{
        Function:
        Remove input variable of the protocole variables
        
        Arguments:
        this - The object on which the function is called, optionnal.
        variable - a <fr.lescot.bind.coding.Variable> to be deleted
        %}
        function removeVariable(this, variable)
            updated_variables = cell(1,length(this.variables)-1);
            j=1;
            for i=1:1:length(this.variables)
                if(this.variables{i}.ne(variable))
                    updated_variables{j} = this.variables{i};
                    j=j+1;
                end
            end
            this.variables = updated_variables;
        end
    end

end
