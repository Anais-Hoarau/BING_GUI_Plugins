classdef MetaDataTest < TestCase
    
    methods
        function this = MetaDataTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            testMetaDataObject = fr.lescot.bind.data.MetaData();
            
            % class methods
            frequency = '50';
            testMetaDataObject.setFrequency(frequency);
            assertTrue(strcmp(frequency,testMetaDataObject.getFrequency()));
            
            type = 'LOLILOL';
            testMetaDataObject.setType(type);
            assertTrue(strcmp(type,testMetaDataObject.getType()));
            
            testMetaDataObject.setIsBase(true);
            assertTrue(testMetaDataObject.isBase());
            
            % inherited methods
            comments = 'tralala';
            testMetaDataObject.setComments(comments);
            assertTrue(strcmp(comments,testMetaDataObject.getComments()));
            
            name = 'tralalapimpon';
            testMetaDataObject.setName(name);
            assertTrue(strcmp(name,testMetaDataObject.getName()));            
            
            frameworkVariabes = testMetaDataObject.getFrameworkVariables();
            % should return only one cell with a <fr.lescot.bind.MetaDataVariable>
            % inside
            assertTrue(length(frameworkVariabes)==1);
            assertTrue(isa(frameworkVariabes{1},'fr.lescot.bind.data.MetaDataVariable'));
            % name of the framework variable should be timecode
            assertTrue(strcmp('timecode',frameworkVariabes{1}.getName()));
            
            testMetaDataVariableObject = fr.lescot.bind.data.MetaDataVariable;
            testMetaDataVariableObject.setType('REAL');
            
            % timecode is among the kernel.Trip.RESERVED_VARIABLE_NAMES and should not be added 
            testMetaDataVariableObject.setName('timecode');
            testMetaDataObject.setVariables({testMetaDataVariableObject});
            assertTrue(isempty(testMetaDataObject.getVariables()));
            
            % TOTO can be added as a user variable
            variableName = 'TOTO';
            testMetaDataVariableObject.setName(variableName);
            testMetaDataObject.setVariables({testMetaDataVariableObject});
            testUserVariable = testMetaDataObject.getVariables();
            assertTrue(length(testUserVariable)==1);
            assertTrue(isa(testUserVariable{1},'fr.lescot.bind.data.MetaDataVariable'));
            assertTrue(strcmp(variableName,testUserVariable{1}.getName()));
                        
            % in total there should be 2 variables
            assertTrue(length(testMetaDataObject.getVariablesAndFrameworkVariables())==2);
  
        end
    end
    
end

