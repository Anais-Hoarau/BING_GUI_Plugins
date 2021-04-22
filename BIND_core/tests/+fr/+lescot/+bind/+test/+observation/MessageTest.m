classdef MessageTest < TestCase

    methods
        
        function this = MessageTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
            message = fr.lescot.bind.observation.Message('allowed');
            assertEqual('allowed', message.getAllowedValues);
            message.setCurrentMessage('aMessage');
            assertEqual('aMessage', message.getCurrentMessage());
        end
        
    end
    
end

