classdef Machine < fr.lescot.bind.observation.Observable
    
    properties(Access = private)
        pression;
        temperature;
    end
    
    methods
        function this = Machine()
            this.pousserLevierNoir();
        end
        
        function pousserLevierRouge(this)
            this.temperature = this.temperature + 5;
            message = MachineMessage();
            message.setCurrentMessage('levierRouge');
            this.notifyAll(message);
        end
        
        function pousserLevierBleu(this)
            this.pression = this.pression + 0.5;
            message = MachineMessage();
            message.setCurrentMessage('levierBleu');
            this.notifyAll(message);
        end
        
        function pousserLevierNoir(this)
            this.pression = 1;
            this.temperature = 20;
            message = MachineMessage();
            message.setCurrentMessage('levierNoir');
            this.notifyAll(message);
        end
        
        function out = getPression(this)
            out = this.pression;
        end
        
        function out = getTemperature(this)
            out = this.temperature;
        end
    end
    
end

