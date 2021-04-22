%{
Class:
Container class that holds the different values used as a Message when
a Trip notifies his Observers, and a value for this message.
It both contains allowed values and current value.

%}
classdef TripMessage < fr.lescot.bind.observation.FixedValuesMessage
    
    methods
        
        %{
        Function:
        This contructor builds a new TripMessage object with the following list of
        allowed values :
        
        - DATA_ADDED
        - DATA_REMOVED
        - DATA_VARIABLE_ADDED
        - DATA_VARIABLE_REMOVED
        - DATA_CONTENT_CHANGED
        - EVENT_ADDED
        - EVENT_REMOVED
        - EVENT_VARIABLE_ADDED
        - EVENT_VARIABLE_REMOVED
        - EVENT_CONTENT_CHANGED
        - SITUATION_ADDED
        - SITUATION_REMOVED
        - SITUATION_VARIABLE_ADDED
        - SITUATION_VARIABLE_REMOVED
        - SITUATION_CONTENT_CHANGED
        - TRIP_META_CHANGED
        
        Returns:
        A TripMessage object
        %}
        function out = TripMessage()
            out = out@fr.lescot.bind.observation.FixedValuesMessage({'DATA_ADDED', 'DATA_REMOVED', 'DATA_VARIABLE_ADDED', 'DATA_VARIABLE_REMOVED', 'DATA_CONTENT_CHANGED',  'EVENT_ADDED', 'EVENT_REMOVED', 'EVENT_VARIABLE_ADDED', 'EVENT_VARIABLE_REMOVED', 'EVENT_CONTENT_CHANGED', 'SITUATION_ADDED', 'SITUATION_REMOVED', 'SITUATION_VARIABLE_ADDED', 'SITUATION_VARIABLE_REMOVED', 'SITUATION_CONTENT_CHANGED', 'TRIP_META_CHANGED'});
        end
    
    end
    
end

