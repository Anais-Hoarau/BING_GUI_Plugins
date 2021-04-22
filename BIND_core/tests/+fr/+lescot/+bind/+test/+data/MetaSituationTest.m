classdef MetaSituationTest < TestCase
    
    methods
        function this = MetaEventTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            testMetaSituationObject = fr.lescot.bind.data.MetaSituation();
            
            % inherited methods            
            testMetaSituationObject.setIsBase(true);
            assertTrue(testMetaSituationObject.isBase());

            comments = 'tralala';
            testMetaSituationTestObject.setComments(comments);
            assertTrue(strcmp(comments,testMetaSituationObject.getComments()));
            
            name = 'tralalapimpon';
            testMetaSituationObject.setName(name);
            assertTrue(strcmp(name,testMetaSituationObject.getName()));            
            
            frameworkVariabes = testMetaSituationObject.getFrameworkVariables();
            % should return only one cell with a <fr.lescot.bind.MetaDataVariable>
            % inside
            assertTrue(length(frameworkVariabes)==2);
            % name of the framework variable 1 should be starttimecode
            assertTrue(isa(frameworkVariabes{1},'fr.lescot.bind.data.MetaSituationVariable'));
            assertTrue(strcmp('starttimecode',frameworkVariabes{1}.getName()));
            assertTrue(isa(frameworkVariabes{2},'fr.lescot.bind.data.MetaSituationVariable'));
            assertTrue(strcmp('endtimecode',frameworkVariabes{1}.getName()));
            
            testMetaSituationVariableObject = fr.lescot.bind.data.MetaSituationVariable;
            testMetaSituationVariableObject.setType('LOL');
            
            % timecode is among the kernel.Trip.RESERVED_VARIABLE_NAMES and should not be added 
            testMetaSituationVariableObject.setName('starttimecode');
            testMetaSituationObject.setVariables({testMetaSituationVariableObject});
            assertTrue(isempty(testMetaSituationObject.getVariables()));
            
            testMetaSituationVariableObject.setName('endtimecode');
            testMetaSituationObject.setVariables({testMetaSituationVariableObject});
            assertTrue(isempty(testMetaSituationObject.getVariables()));
            
            % TOTO can be added as a user variable
            variableName = 'TOTO';
            testMetaSituationVariableObject.setName(variableName);
            testMetaSituationObject.setVariables({testMetaSituationVariableObject});
            testUserVariable = testMetaSituationObject.getVariables();
            assertTrue(length(testUserVariable)==1);
            assertTrue(isa(testUserVariable{1},'fr.lescot.bind.data.MetaEventVariable'));
            assertTrue(strcmp(variableName,testUserVariable{1}.getName()));
                        
            % in total there should be 3 variables
            assertTrue(length(testMetaSituationObject.getVariablesAndFrameworkVariables())==3);
        end
    end
    
end

