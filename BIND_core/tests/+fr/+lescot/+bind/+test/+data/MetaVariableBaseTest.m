classdef MetaVariableBaseTest < TestCase
    
    methods
        function this = MetaVariableBaseTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            testMetaVariableBaseObject = fr.lescot.bind.data.MetaVariableBase();
            
            name = 'titi';
            testMetaVariableBaseObject.setName(name);
            assertTrue(strcmp(name,testMetaVariableBaseObject.getName()));
            
            type = 'REAL';
            testMetaVariableBaseObject.setType(type);
            assertTrue(strcmp(type,testMetaVariableBaseObject.getType()));
            
            type = 'TEXT';
            testMetaVariableBaseObject.setType(type);
            assertTrue(strcmp(type,testMetaVariableBaseObject.getType()));
            
            type = 'unSaleType';
            f = @()testMetaVariableBaseObject.setType(type);
            assertExceptionThrown(f, 'MetaVariableBase:setType:InvalidType');
        end
        
    end
    
end

