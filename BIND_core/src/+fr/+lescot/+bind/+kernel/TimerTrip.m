%{
Class:
This class is used to instanciate and manipulate a timer object. It
basically embbed a Matlab Timer, adding a layer of functionnalities and
higher level / more semantic functions.

%}
classdef TimerTrip < fr.lescot.bind.observation.Observable
    
    properties (Access = private)
        %{
        Property:
        The matlab timer object. The ExecutionMode is set to "fixedRate"
        and the BusyMode to "queue" (type "doc timer" for more about
        this).
        
        %}
        myTimer;
        
        %{
        Property:
        The current timestamp in seconds. It should never go
        negative.
        
        %}
        currentTimeInSeconds;
        
        %{
        Property:
        The current multiplier. It is applied to the time increment at
        each timer call. It can be negative. The default value is 1.
        
        %}
        multiplier = 1;
        
        %{
        Property:
        The maximum time that the timer can reach. When it is reached, the
        timer stops.
        
        %}
        maxTimeInSeconds = 0;
        
        %{
        Property:
        The period set in the constructor.
        
        %}
        defaultPeriod;
        
    end
    
    methods(Access = public)
        
        %{
        Function:
        This constructors instanciate a new TimerTrip object whith the
        period set to the argument value. Note that the set period is only an
        initial value. If the computer lags, the value will be automatically risen.
        Before running the timer, don't
        forget to use the setMaxTimeInSeconds method.
        
        Arguments:
        period - a positive not null value representing the period
        at wich the timer will throw a "STEP" message.
        
        Returns:
        A TimerTrip object
        
        %}
        function obj = TimerTrip(period)
            obj.myTimer = timer;
            obj.myTimer.ExecutionMode = 'fixedRate';
            onTickCallback = @obj.onTick;
            obj.myTimer.TimerFcn = onTickCallback;
            obj.myTimer.BusyMode = 'drop';
            obj.currentTimeInSeconds = 0;
            obj.myTimer.period = period;
            obj.defaultPeriod = period;
        end
        
        %{
        Function:
        This method overwrite the default delete to ensure the deletion of the inner <kernel.TimerTrip> object..
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        %}
        function delete(obj)
            delete(obj.myTimer);
            clear 'obj.myTimer';
        end
        
        %{
        Function:
        Launch the timer if it isn't running.
        
        Arguments:
         obj - The object on which the function is called, optionnal.
        %}
        function startTimer(obj)
            if(~obj.isRunning)
                start(obj.myTimer);
                obj.notifyWithMessage('START');
            end
        end
        
        %{
        Function:
        Stop the timer if it isn't running.
        
        Arguments:
         obj - The object on which the function is called, optionnal. 
        %}
        function stopTimer(obj)
            if(obj.isRunning)
                stop(obj.myTimer);
                obj.notifyWithMessage('STOP');
            end
        end
        
        %{
        Function:
        Returns the current time (in seconds).
        
        Arguments:
         obj - The object on which the function is called, optionnal.
        
        Returns:
        The current time
        %}
        function out = getTime(obj)
            out = obj.currentTimeInSeconds;
        end
        
        %{
        Function:
        Returns the period of the timer in seconds.
        
        Arguments:
         obj - The object on which the function is called, optionnal.
        
        Returns:
        The period of the timer.
        %}
        function out = getPeriod(obj)
            out = obj.myTimer.period;
        end
        
        %{
        Function:
        Returns the current multiplier.
        
        Arguments:
         obj - The object on which the function is called, optionnal.
        
        Returns:
        The current multiplier.
        %}
        function out = getMultiplier(obj)
            out = obj.multiplier;
        end
        
        %{
        Function:
        Sets the current time to a new value (wich in turn launches a
        "GOTO" message)
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        time - The new current time in seconds.
        %}
        function setTime(obj, time)
            obj.currentTimeInSeconds = time;
            obj.notifyWithMessage('GOTO');
        end
        
        %{
        Function:
        Sets the multiplier of the time increment.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        multiplier - The new multiplier.
        %}
        function setMultiplier(obj, multiplier)
            obj.multiplier = multiplier;
            obj.notifyWithMessage('MULTIPLIER_CHANGED');
        end
        
        %{
        Function:
        Sets the period at wich the timer is running.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        period - The new current period of the timer.
        %}
        function setPeriod(obj, period)
            run = obj.isRunning;
            if(run)
                stop(obj.myTimer);
            end
            obj.myTimer.period = period;
            if(run)
                start(obj.myTimer);
            end
            obj.notifyWithMessage('PERIOD_CHANGED');
        end
        
        %{
        Function:
        Returns a boolean describing the running state of the server.
        
        Arguments:
         obj - The object on which the function is called, optionnal.
        
        Returns:
        A boolean describing the running state of the server.
        
        %}
        function out = isRunning(obj)
            out = strcmp('on',obj.myTimer.Running);
        end
        
        %{
        Function:
        Returns the average period at which the embedded timer is running.
        
        Arguments:
         this - The object on which the function is called, optionnal.
        
        Returns:
        The average cycle period, in seconds.
        
        %}
        function out = getAveragePeriod(this)
            out = this.myTimer.averagePeriod;
        end
        
        %{
        Function:
        Returns the period at which the embedded timer have run its last iteration.
        
        Arguments:
         this - The object on which the function is called, optionnal.
        
        Returns:
        The instant cycle period, in seconds.
        
        %}
        function out = getInstantPeriod(this)
            out = this.myTimer.instantPeriod;
        end
        
        %{
        Function:
        Returns the default period of the timer.
        
        Arguments:
         this - The object on which the function is called, optionnal.
        
        Returns:
        The initial cycle period, in seconds.
        
        %}
        function out = getDefaultPeriod(this)
            out = this.defaultPeriod;
        end
        
        %{
        Function:
        Sets the maximum time reachable by the timer. *MUST* be called at least one time before running the timer.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        maxTime - A double representing the max time, in seconds.
        
        %}
        function setMaxTimeInSeconds(this, maxTime)
            this.maxTimeInSeconds = maxTime;
        end
        
        %{
        Function:
        Return the maximum time reachable by the time.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A double
        
        %}
        function out = getMaxTimeInSeconds(this)
            out = this.maxTimeInSeconds;
        end
        
        %{
        Function:
        Resets the timer to its initial values, as if it has just been instanciated.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function resetTimer(this)
            this.stopTimer();
            this.setTime(0);
            this.setPeriod(this.defaultPeriod);
            this.setMultiplier(1);
        end
        
    end
    
    methods(Access = private)
        
        %{
        Function:
        Utility function that instanciates a <TimerMessage> object and
        call notifyAll with this message as an argument.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        message - The string value to pass as argument to the contructor
        of <TimerMessage>.
        %}
        function notifyWithMessage(obj,message)
            toSend = fr.lescot.bind.kernel.TimerMessage();
            toSend.setCurrentMessage(message);
            obj.notifyAll(toSend);
        end
        
        %{
        Function:
        This function is passed as the function handle of myTimer.
        It increments / decrements currentTimeInSeconds, and stops the
        timer if the time reaches 0 (to avoid negative time when going backward).
        If maxTimeInSeconds is reached, the timer stops. This method also monitors the
        execution time, so that the period can be auto-adjusted if execuctionTime > period.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Throws:
        OBSERVER_EXCEPTION - if the method
        <setMaxTimeInSeconds> have not been used before running the timer.
        %}
        function onTick(obj, ~, ~)
            import fr.lescot.bind.exceptions.ExceptionIds;
            tic;
            if(obj.maxTimeInSeconds <= 0)
                throw(MException(ExceptionIds.OBSERVER_EXCEPTION.getId(), 'The maxTimeInSeconds variable have not been set to a value > 0'))
            end
            newTime = obj.getTime() + (obj.myTimer.Period * obj.multiplier);
            if(newTime <= 0)
                obj.currentTimeInSeconds = 0;
                obj.notifyWithMessage('STEP');
                obj.stopTimer();
            else if(newTime >= obj.maxTimeInSeconds)
                    obj.stopTimer();
                    obj.currentTimeInSeconds = obj.maxTimeInSeconds;
                else
                    obj.currentTimeInSeconds = newTime;
                    obj.notifyWithMessage('STEP');
                end
            end
            elapsedTime = toc;
            
            if elapsedTime >= obj.myTimer.period * 0.80
                obj.setPeriod(obj.getPeriod() + 0.02)
            elseif elapsedTime <= obj.myTimer.period * 0.20
                lowerPeriod = obj.getPeriod() - 0.01;
                if lowerPeriod >= obj.defaultPeriod
                    obj.setPeriod(lowerPeriod)
                end
            end
        end
        
    end
    
end