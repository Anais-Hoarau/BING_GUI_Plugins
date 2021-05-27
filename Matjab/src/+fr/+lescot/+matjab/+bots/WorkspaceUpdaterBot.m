%Class: fr.lescot.matjab.bots.WorkspaceUpdaterBot
%This class creates a bot that will monitor the messages it receives for
%some data forms containing some variables, and will update these variables
%in the base workspace. This bot can be used for example to provide some
%datas to a stateflow statechart, thanks to the ml command.
%
%Extends:
%- <fr.lescot.matjab.Bot>
%- <fr.lescot.matjab.MessageListener>
classdef WorkspaceUpdaterBot < fr.lescot.matjab.Bot & fr.lescot.matjab.MessageListener
    
    properties(Access = private)
        %Property: variablesList
        %The list of variables and inital values
        %
        %Modifiers:
        %- Private
        variablesList;
    end
    
    methods
        
        %Function: WorkspaceUpdaterBot()
        %Constructor of the bot. Very similar to the constructor of
        %fr.lescot.matjab.Bot, but with an additionnal argument
        %(variablesList) to indicate wich variable to place in the
        %workspace.
        %
        %Arguments:
        %serverName - A string indicating the name of the server to connect
        %login - A string indicating the login of the user
        %password - A string representing the password of the user on the
        %server.
        %ressource - A string representing the ressource from which the user is connected.
        %treatMessagesStoredOnServer - If this boolean is true, the
        %messages sent to the server while offline will be processed. If it
        %is false, they will be deleted.
        %variablesList - A cell array of string with the following format :
        %{'varName1', initialValue1, 'varName2', initialValue2, ...}
        %
        %Modifiers:
        %- Public
        function this = WorkspaceUpdaterBot(serverName, login, password, ressource, treatMessagesStoredOnServer, variablesList)
            this@fr.lescot.matjab.Bot(serverName, login, password, ressource, treatMessagesStoredOnServer);
            this.addMessageListener(this);
            
            %Check that variablesList if correctly formatted.
            %1 - The number of values is even
            if mod(length(variablesList), 2)
                throw(MException('WorkspaceUpdaterBot:WorkspaceUpdaterBot:IncorrectArgumentException', 'The argument variablesList should be formatted with an alternance of variable names an initial values.'));
            end
            %2 - No redundancies among the variables names
            variablesNamesList = {variablesList{1:2:length(variablesList)}};
            numberOfNames = length(variablesNamesList);
            numberOfUniqueNames = length(unique(variablesNamesList));
            if numberOfNames ~= numberOfUniqueNames
               throw(MException('WorkspaceUpdaterBot:WorkspaceUpdaterBot:IncorrectArgumentException', 'The variable names provided in variable list must be unique'));
            end
            %End of check
            this.variablesList = variablesList;
            
            %Create all the variables in the base workspace
            for i = 1:2:length(this.variablesList)
                evalin('base', [variablesList{i} ' = ' num2str(variablesList{i+1}) ';']);
            end
        end
        
        %Function: processMessage()
        %
        %This method is the implementation of the <fr.lescot.matjab.MessageListener.processMessage> method. It
        %takes the first extension of the message received, assuming it is
        %a dataform, and parses the fields. When a field name is also
        %present in the variable list passed to the constructor, the
        %variable with the same name is updated in the base workspace.
        %
        %Modifiers:
        %- Public
        function processMessage(this, ~, message)
            %We process only the first extension, since the bot only needs
            %to deal with a dataform.
            extension = message.getExtension('x', 'jabber:x:data');
            if ~isempty(extension)
                dataForm = fr.lescot.matjab.extension.dataForm.DataForm(extension);
                fields = dataForm.getFields();
                %For each field, we check if there is a matching variable name
                %in the config, and if there is, we update the workspace. This
                %may, even if the dataform do not contains all the values, the
                %non updated values remains in the workspace.
                for i = 1:1:length(fields)
                    field = fields{i};
                    fieldName = field.getVariable();
                    fieldValue = field.getValues{1};
                    comparedWithVarList = strcmpi(this.variablesList, fieldName);
                    if any(comparedWithVarList)
                        variableName = this.variablesList{comparedWithVarList};
                        evalin('base', [variableName ' = ' fieldValue ';']);
                    end
                end
            end
        end     
     end
    
end

