%{
Class:
This abstract class is the template for all the plugins that focus on
time driven data analysis focused on an only <kernel.Trip> object.

Implements:
- <observation.Observer>
%}
classdef TripPlugin < fr.lescot.bind.plugins.Plugin & fr.lescot.bind.observation.Observer

properties (Access = private);
        %{
        Property:
        The <kernel.Trip> object.
        
        %}
        currentTrip;

    end
    
    methods (Abstract = true)
        
        %{
        Function:
        See <observation.Observer.update()>.
        
        %}
        update(object, message)   
    end
    
    methods
        
        %{
        Function:
        Constructor of the plugin. It set the <currentTrip> to the one
        passed as argument.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        varagin - An array of argument. However, the only correct number
        of arguments is ONE, and it must be the <kernel.Trip> to
        monitor.
        
        TripPlugin:TripPlugin:WrongArguments - if the
        number of arguments is not 1. The goal of this way to handle the
        arguments of the constructor is to enforce an explicit call to the
        constructor (implicit call are made with 0 args).
        %}
        function this = TripPlugin(varargin)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if(length(varargin) ~= 1)
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The number of arguments of the constructor should be one. A length of 0 might denote an implicit call to the constructor of TripPlugin as a superclass. If this is the case, replace it by an explicit call with the correct args.'));
            end
            this.currentTrip = varargin{1};
            this.currentTrip.addObserver(this);
        end
        
        %{
        Function:
        This method overwrite the default delete to ensure a proper
        removal of the object as an Observer before being totally deleted.
        A call to this methods also provoke the emission of an
        "OBSERVER_REMOVED" message from the trip previously monitored.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        %}
        function delete(obj)
            obj.currentTrip.removeObserver(obj);
            message = fr.lescot.bind.kernel.TimerMessage();
            message.setCurrentMessage('OBSERVER_REMOVED');
            obj.currentTrip.notifyAll(message);
        end
        
        %{
        Function:
        Get the current trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        A <kernel.Trip> object.
        %}
        function out = getCurrentTrip(obj)
            out = obj.currentTrip;
        end
        
        %{
        Function:
        See <plugins.Plugin.isMultiTrip()>
        %}
        function out = isMultiTrip(this)
           out = true; 
        end
    end
    
end

