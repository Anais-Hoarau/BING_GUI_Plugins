classdef MetaEventTest < TestCase
    
    methods
        function this = MetaEventTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            testMetaEventObject = fr.lescot.bind.data.MetaEvent();
            
            % inherited methods            
            testMetaEventObject.setIsBase(true);
            assertTrue(testMetaEventObject.isBase());

            comments = 'tralala';
            testMetaEventObject.setComments(comments);
            assertTrue(strcmp(comments,testMetaEventObject.getComments()));
            
            name = 'tralalapimpon';
            testMetaEventObject.setName(name);
            assertTrue(strcmp(name,testMetaEventObject.getName()));            
            
            frameworkVariabes = testMetaEventObject.getFrameworkVariables();
            % should return only one cell with a <fr.lescot.bind.MetaDataVariable>
            % inside
            assertTrue(length(frameworkVariabes)==1);
            assertTrue(isa(frameworkVariabes{1},'fr.lescot.bind.data.MetaEventVariable'));
            % name of the framework variable should be timecode
            assertTrue(strcmp('timecode',frameworkVariabes{1}.getName()));
            
            testMetaEventVariableObject = fr.lescot.bind.data.MetaEventVariable;
            testMetaEventVariableObject.setType('TEXT');
            
            % timecode is among the kernel.Trip.RESERVED_VARIABLE_NAMES and should not be added 
            testMetaEventVariableObject.setName('timecode');
            testMetaEventObject.setVariables({testMetaEventVariableObject});
            assertTrue(isempty(testMetaEventObject.getVariables()));
            
            % TOTO can be added as a user variable
            variableName = 'TOTO';
            testMetaEventVariableObject.setName(variableName);
            testMetaEventObject.setVariables({testMetaEventVariableObject});
            testUserVariable = testMetaEventObject.getVariables();
            assertTrue(length(testUserVariable)==1);
            assertTrue(isa(testUserVariable{1},'fr.lescot.bind.data.MetaEventVariable'));
            assertTrue(strcmp(variableName,testUserVariable{1}.getName()));
                        
            % in total there should be 2 variables
            assertTrue(length(testMetaEventObject.getVariablesAndFrameworkVariables())==2);
        end
    end
    
end

