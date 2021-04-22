classdef MachineConsole < fr.lescot.bind.observation.Observer
    
    properties(Access = private)
        machine;
    end
    
    methods
        
        function this = MachineConsole(machine)
            this.machine = machine;
            machine.addObserver(this);
        end
        
        function update(this, message)
            messageString = message.getCurrentMessage();
            disp(['Message reçu : ' messageString]);
            if(strcmp(messageString, 'levierNoir'))
                disp(['Température : ' num2str(this.machine.getTemperature()) '°']);
                disp(['Pressions : ' num2str(this.machine.getPression()) ' bars']);
            else if(strcmp(messageString, 'levierRouge'))
                    disp(['Température : ' num2str(this.machine.getTemperature()) '°']);
                else if(strcmp(messageString, 'levierBleu'))
                        disp(['Pressions : ' num2str(this.machine.getPression()) ' bars']);
                    end
                end
            end
        end
        
    end
    
end

