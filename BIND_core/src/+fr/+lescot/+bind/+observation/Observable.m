%{
Class:
This class is to be extended to give Observable capabilities to an
object.

See also http://en.wikipedia.org/wiki/Observer_pattern for more details
about the Observer design pattern.

%}
classdef Observable < handle
    
    properties (Access = private)
        %{
        Property:
        The array containing all the registered <Observers>.
        
        %}
        observers = {}
    end
    
    methods (Access = public)
        
        %{
        Function:
        Register a new <Observer> for the current object.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        observer - The observer object to register
        %}
        function addObserver(obj, observer)
            fr.lescot.bind.observation.Observable.checkIfIsAnObserver(observer);
            newIndex = length(obj.observers) + 1;
            obj.observers{newIndex} = observer;
        end
        
        %{
        Function:
        Register all the <Observers> from the array observers for the current
        object.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        observers - A cell array containing all the objects to register
        
        Throws:
        ARGUMENT_EXCEPTION - If at least one element of
        the cell array is not an <Observer> object. If this Exception is
        thrown, no element of the array is added.
        %}
        function addObservers(obj, observers)
            import fr.lescot.bind.exceptions.ExceptionIds;
            arrayBackup = obj.observers;%No need to clone or deep copy, as an array is passed as value, not as reference.
            try
                for i=1:1:length(observers)
                    %Checking the interface is performed by addObserver, no need
                    %to do it again
                    obj.addObserver(observers{i});
                end
            catch ME
                obj.observers = arrayBackup;
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'At least one element of "observers" is not an Observer'));
            end
        end
        
        %{
        Function:
        Get all the Observer registered for the current object.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of objects implementing the <Observer> interface.
        %}
        function out = getAllObservers(obj)
            out = obj.observers;
        end
        
        %{
        Function:
        Call the update() method on all registered <Observers>
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        message - A <Message> object, whose value have been initialized,
        to give more informations about what triggered the call.
        %}
        function notifyAll(obj, message)
            fr.lescot.bind.observation.Observable.checkIfIsAMessage(message)
            for i=1:1:length(obj.observers)
                obj.observers{i}.update(message);
            end
        end
        
        %{
        Function:
        Remove the <Observer> passed as an argument from the list of
        registered objects.
        
        If the object have not been previously registered, or already have
        been unregistered, nothing happens.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        observer - An <Observer> object, that should be among the
        registered objects.
        
        %}
        function removeObserver(obj, observer)
            fr.lescot.bind.observation.Observable.checkIfIsAnObserver(observer);
            for i=1:1:length(obj.observers)
                if(obj.observers{i}.eq(observer))
                    %To understand why this non cell syntax :
                    %http://romanski.livejournal.com/1980.html
                    obj.observers(i) = [];
                    %End the loop right now, as the observer have been
                    %removed, and the length of the array have changed,
                    %wich causes troubles.
                    return;
                end
            end
        end
        
        %{
        Function:
        Clears the list of <Observers>.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        %}
        function removeAllObservers(obj)
            %Remove all observers for the current object.
            %
            obj.observers = {};
        end
        
    end
    
    methods(Access = private, Static)
       
        %{
        Function:
        Just throws an Exception if the argument is not a subclass of
        Observer.
        
        Arguments:
        observer - An object to check.

        Throws:
        ARGUMENT_EXCEPTION - If the observer argument is
        not an <Observer> object.
        %}
        function checkIfIsAnObserver(observer)
            import fr.lescot.bind.exceptions.ExceptionIds;
            %Throws an exception if the argument is not an Observer.
            if(~isa(observer, 'fr.lescot.bind.observation.Observer'))
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), '"observer" argument was expected to be a subclass of Observer interface'));
            end
        end
        
        %{
        Function:
        Just throws an Exception if the argument is not a subclass of
        Message.
        
        Arguments:
        message - An object to check.
        
        
        Throws:
        ARGUMENT_EXCEPTION - If the observer argument is
        not a <Message> object.
        %}
        function checkIfIsAMessage(message)
            import fr.lescot.bind.exceptions.ExceptionIds;
            %Throws an exception if the argument is not a Message.
            if(~isa(message, 'fr.lescot.bind.observation.Message'))
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), '"message" argument was expected to be a subclass of Message interface'));
            end
        end
        
    end

end