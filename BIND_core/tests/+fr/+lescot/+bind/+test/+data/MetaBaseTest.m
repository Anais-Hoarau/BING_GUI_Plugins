classdef MetaBaseTest < TestCase
    
    methods
        function this = MetaBaseTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            testMetaBaseObject = fr.lescot.bind.data.MetaBase();
            
            comment = 'toto';
            testMetaBaseObject.setComments(comment);
            assertTrue(strcmp(comment,testMetaBaseObject.getComments()));
            
            name = 'titi';
            testMetaBaseObject.setName(name);
            assertTrue(strcmp(name,testMetaBaseObject.getName()));
            
            testMetaBaseObject.setIsBase(true);
            assertTrue(testMetaBaseObject.isBase);
            testMetaBaseObject.setIsBase(false);
            assertFalse(testMetaBaseObject.isBase);
            
        end
        
    end
    
end

