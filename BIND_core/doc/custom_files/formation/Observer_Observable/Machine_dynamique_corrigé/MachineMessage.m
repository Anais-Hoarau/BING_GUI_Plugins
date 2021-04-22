classdef MachineMessage < fr.lescot.bind.observation.FixedValuesMessage

    properties
    end
    
    methods
        function this = MachineMessage()
            this@fr.lescot.bind.observation.FixedValuesMessage({'levierRouge' 'levierBleu' 'levierNoir'});
        end
    end
    
end

