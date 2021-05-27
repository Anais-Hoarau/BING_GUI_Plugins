%{
Class:
This class creates a bot that will monitor XMPP messages with dataform extension. If the dataform contains 
any of the variables declares in the constructor of the bot, the bot will update these variables
in the base workspace, using the output names. 
The, objective is to make a bot that make it possible to use several data
sources and to homogeneise the outputs in order to have a unique
application.

%}
classdef Translate2WorkspaceBot < fr.lescot.matjab.Bot & fr.lescot.matjab.MessageListener
    
    properties(Access = private)
        %Property: variablesList
        %The list of input variables, inital values and output workspace name that the bot can decode in
        %the XMPP dataform messages
        %
        %Modifiers:
        %- Private
        variablesList;
    end
    
    methods
        
        %{
        Function:
        Constructor of the bot. Very similar to the constructor of
        fr.lescot.matjab.Bot, but with an additionnal argument
        (variablesList) to indicate wich variable to place in the
        workspace.
        
        Arguments:
        serverName - A string indicating the name of the server to connect
        login - A string indicating the login of the user
        password - A string representing the password of the user on the
        server.
        ressource - A string representing the ressource from which the user is connected.
        treatMessagesStoredOnServer - If this boolean is true, the
        messages sent to the server while offline will be processed. If it
        is false, they will be deleted.
        expectedVariablesList - A cell array of string with the following format :
        {'varName1', initialValue1, 'nameInWorkspace', 'varName2', initialValue2, 'nameInWorkspace'...} that
        describes the variables that the bot will decode, the default value and the associated
        worskpace name that will be used
        
        Modifiers:
        - Public
        %}
        function this = Translate2WorkspaceBot(serverName, login, password, ressource, treatMessagesStoredOnServer, expectedVariablesList)
            this@fr.lescot.matjab.Bot(serverName, login, password, ressource, treatMessagesStoredOnServer);
            this.addMessageListener(this);
            
            %Check that variablesList if correctly formatted.
            %1 - The list must be a set of triplets 
            if mod(length(expectedVariablesList), 3)
                throw(MException('WorkspaceUpdaterBot:WorkspaceUpdaterBot:IncorrectArgumentException', 'The argument expectedVariablesList should be formatted with triplets : input variable names, initial values, output name in workspace.'));
            end
            %2 - No redundancies among the input variables names
            variablesNamesList = {expectedVariablesList{1:3:length(expectedVariablesList)}};
            numberOfNames = length(variablesNamesList);
            numberOfUniqueNames = length(unique(variablesNamesList));
            if numberOfNames ~= numberOfUniqueNames
               throw(MException('WorkspaceUpdaterBot:WorkspaceUpdaterBot:IncorrectArgumentException', 'The input variable names provided in variable list must be unique'));
            end
            %End of check
            this.variablesList = expectedVariablesList;
            
            %Create all the variables in the base workspace
            for i = 1:3:length(this.variablesList)
                evalin('base', [expectedVariablesList{i+2} ' = ' num2str(expectedVariablesList{i+1}) ';']);
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
                        matchingVariableName = find(comparedWithVarList==1);
                        % use the output name of the variable
                        variableName = this.variablesList{matchingVariableName+2};
                        evalin('base', [variableName ' = ' fieldValue ';']);
                    end
                end
            end
        end     
     end
    
end

