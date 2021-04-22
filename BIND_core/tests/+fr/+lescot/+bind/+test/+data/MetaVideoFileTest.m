classdef MetaVideoFileTest < TestCase
    
    methods
        function this = MetaVideoFileTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            fileName = 'gnagnagna.avi';
            offset = 666;
            description = 'LePetitChatEstMort';
            testMetaVideoFileObject = fr.lescot.bind.data.MetaVideoFile(fileName,offset,description);
            assertTrue(strcmp(fileName,testMetaVideoFileObject. getFileName()));
            assertTrue(offset == testMetaVideoFileObject.getOffset());
            assertTrue(strcmp(description,testMetaVideoFileObject.getDescription()));
            
            fileName = 'Tralala';
            testMetaVideoFileObject.setFileName(fileName);
            assertTrue(strcmp(fileName,testMetaVideoFileObject. getFileName()));
            
            offset = 42;
            testMetaVideoFileObject. setOffset(offset);
            assertTrue(offset == testMetaVideoFileObject.getOffset());
            
            description = 'PAG';
            testMetaVideoFileObject.setDescription(description);
            assertTrue(strcmp(description,testMetaVideoFileObject.getDescription()));
        end
        
    end
    
end

