classdef FixedValuesMessageTest < TestCase

    methods
        function this = FixedValuesMessageTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            badConstructor = @()fr.lescot.bind.observation.FixedValuesMessage('12');
            assertExceptionThrown(badConstructor, 'FixedValuesMessage:FixedValuesMessage:IncorrectArgument');
            values = {'v1' 'v2'};
            message = fr.lescot.bind.observation.FixedValuesMessage(values);
            assertTrue(all(strcmp(message.getAllowedValues(), values)));
            message.setCurrentMessage('v1');
            assertTrue(strcmp('v1', message.getCurrentMessage()));
            f = @()message.setCurrentMessage('v8');
            assertExceptionThrown(f, 'FixedValuesMessage:setCurrentMessage:ForbiddenValue');
        end
    end
    
end

