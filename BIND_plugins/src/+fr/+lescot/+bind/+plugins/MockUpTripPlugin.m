classdef MockUpTripPlugin < fr.lescot.bind.plugins.TripPlugin

    
    methods
        function this = MockUpTripPlugin(trip)
            this@fr.lescot.bind.plugins.TripPlugin(trip);
        end
        
        function update(this, message)
            disp 'UUUUUP !';
        end
        
        function out = getConfiguratorClass(this)
            out = 'banana.split'; 
        end
    end
    
end

