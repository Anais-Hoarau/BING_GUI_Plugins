classdef MetaParticipantTest < TestCase
    
    methods
        function this = MetaParticipantTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            testMetaParticipantObject = fr.lescot.bind.data.MetaParticipant();
            assertTrue(isempty(testMetaParticipantObject.getAttributesList()));
            
            attributKey1 = 'nono';
            attributValue1 = 'gros';
            testMetaParticipantObject.setAttribute(attributKey1,attributValue1);
            assertTrue(length(testMetaParticipantObject.getAttributesList())==1);
            assertTrue(strcmp(attributValue1,testMetaParticipantObject. getAttribute(attributKey1)));

            % testing update of values
            newValue = 'sac';
            testMetaParticipantObject.setAttribute(attributKey1,newValue);
            assertTrue(length(testMetaParticipantObject.getAttributesList())==1);
            assertTrue(strcmp(newValue,testMetaParticipantObject. getAttribute(attributKey1)));
            
            badAttributeGet = @()testMetaParticipantObject.getAttribute('titi');
            assertExceptionThrown(badAttributeGet, 'Participant:getAttribute:keyDoesntExists');
            
            attributKey2 = 'damien';
            attributValue2 = 'grognon';
            
            testMetaParticipantObject.setAttribute(attributKey2,attributValue2);
            assertTrue(length(testMetaParticipantObject.getAttributesList())==2);
            assertTrue(strcmp(attributValue2,testMetaParticipantObject.getAttribute(attributKey2)));
            
            % testing the list
            attributeKeys = testMetaParticipantObject.getAttributesList();
            assertTrue(strcmp(attributKey1,attributeKeys{1} && strcmp(attributKey2,attributeKeys{2})
            
            badAttributeRemove = @()testMetaParticipantObject.removeAttribute('titi');
            assertExceptionThrown(badAttributeRemove, 'Participant:removeAttribute:keyDoesntExists');
            
            %let's remove the first attribute
            testMetaParticipantObject.removeAttribute(attributKey1,attributValue1);
            assertTrue(length(testMetaParticipantObject.getAttributesList())==1);
            assertTrue(strcmp(attributValue2,testMetaParticipantObject. getAttribute(attributKey2)));
        end
    end
end

