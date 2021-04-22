%{
Class:
Container class that holds the different values used as a Message when
timer notifies his Observers, and a value for this message.
It both contains allowed values and current value.

%}
classdef TimerMessage < fr.lescot.bind.observation.FixedValuesMessage
    
    methods
        
        %{
        Function:
        This contructor builds a new TimerMessage object with the following list of
        allowed values :
        
        - STOP
        - GOTO
        - START
        - PERIOD_CHANGED
        - MULTIPLIER_CHANGED
        - STEP
        - OBSERVER_REMOVED
        
        Returns:
        A TimerMessage object
        %}
        function out = TimerMessage()
            out = out@fr.lescot.bind.observation.FixedValuesMessage({'STOP','GOTO','START','PERIOD_CHANGED','MULTIPLIER_CHANGED','STEP', 'OBSERVER_REMOVED'});
        end
    
    end
    
end

