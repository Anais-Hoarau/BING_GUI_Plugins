classdef RegexpMessageTest < TestCase

    methods
        function this = RegexpMessageTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            badConstructor = @()fr.lescot.bind.observation.RegexpMessage(12);
            assertExceptionThrown(badConstructor, 'RegexpMessage:RegexpMessage:IncorrectArgument');
            expr = '^tot.?$';
            message = fr.lescot.bind.observation.RegexpMessage(expr);
            assertTrue(all(strcmp(message.getAllowedValues(), expr)));
            message.setCurrentMessage('toto');
            assertTrue(strcmp('toto', message.getCurrentMessage()));
            f = @()message.setCurrentMessage('totor');
            assertExceptionThrown(f, 'RegexpMessage:setCurrentMessage:ForbiddenValue');
        end
    end
    
end

