%{
Class:
This class creates a plugin used to display some scrolling datas contained
in a certain timeframe to avoid loading the whole data.

%}
classdef TripStreamingPlugin < fr.lescot.bind.plugins.TripPlugin
    
    properties (Access = protected)
        %{
        Property:
        The cell array of strings that contains the name of the data to
        plot. Their can be some redundancies if several variables from the
        same data have to be plotted.
        
        %}
        dataName;
        %{
        Property:
        The cell array of strings that contains the name of the variables to plot
        . They will be put in relation with the data name at the same
        index in <dataName> to access the data.
        
        %}
        variableName;
        %{
        Property:
        The number of datas to plot.
        
        %}
        dataNumber;
        
        %{
        Property:
        The lower boundary of the displayed time window.
        
        %}
        minTime;
        %{
        Property:
        The upper boundary of the displayed time window.
        
        %}
        maxTime;
        %{
        Property:
        The cell array that contains the datas to display.
        
        %}
        dataBuffer;
        %{
        Property:
        The width in seconds of the time window to display.
        
        %}
        windowWidth;
        
        %TODO: doc
        mode;
    end
    
    methods
        
        %{
        Function:
        This contructor builds a TripStreamingPlugin object linked to a sqlite
        file and focusing on some variables in a time frame of a certain
        width.
        
        Arguments:
        trip - A <kernel.Trip> object.
        dataIdentifiers - A cell array of strings that all have the "dataName.variableName" format if mode is "data" or "eventName.variableName" format if mode is "event".
        These strings represents the variables that will be stored in the
        data buffer.
        timeWindow - The width of the sliding time window in seconds.
        mode - A string containing either "data" or "event".
        
        
        Throws:
        ARGUMENT_EXCEPTION - If the
        time window is < 0 or if at least one of the dataIdentifiers does
        not match the correct pattern.
        
        Returns:
        out - a new TripStreamingPlugin object.
        %}
        function this = TripStreamingPlugin(trip, identifiers, timeWindow, mode)
            import fr.lescot.bind.exceptions.ExceptionIds;
            this@fr.lescot.bind.plugins.TripPlugin(trip);
            
            %Check the validity of timeWindow
            if(timeWindow <= 0)
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The timeWindow argument should be > 0'));
            end
            %Check the validity of the dataIdentifiers
            for i = 1:1:length(identifiers)
                %if isempty(regexp(identifiers{i}, '^[^\.]+\.[^\.]+$', 'match', 'warnings'))
                    %throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The identifiers elements should respect the dataName.variableName format.'));
                %end
            end
            %Check the validty of mode
            if ~any(strcmpi({'data' 'event'}, mode))
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The mode argument should be either "data" or "event"'));
            end
            %End of checks
            this.dataNumber = length(identifiers);
            length(identifiers)
           
                for i = 1:1:this.dataNumber
                    splittedDataName = regexp(identifiers{i}, '\.', 'split');
                    this.dataName{i} = splittedDataName{1};
                    this.variableName{i} = splittedDataName{2};
                end

          
            
            
            this.minTime = 0;
            this.maxTime = timeWindow;
            this.windowWidth = timeWindow;
            this.mode = mode;
            %Grab the initial datas
            this.refreshDataBuffer();
        end
        
        %{
        Function:
        
        This method is the implementation of the
        <observation.Observer.update> method. If the current time is still
        in the time window, nothing is done. If it crosses one of the
        boundaries, the time window is shifted and the dataBuffer is
        updated.
        %}
        function update(this, message)
            if(any(strcmp(message.getCurrentMessage(), {'STEP' 'GOTO'})))
                currentTime = this.getCurrentTrip().getTimer.getTime();

                multiplier = this.getCurrentTrip().getTimer.getMultiplier();
                %When current time goes out of the window
                if currentTime >= this.maxTime || currentTime <= this.minTime
                    if strcmp(message.getCurrentMessage(), 'STEP')
                        %Play forward
                        if(multiplier > 0)
                            this.minTime = this.minTime + this.windowWidth;
                            this.maxTime = this.maxTime + this.windowWidth;
                        %Play backward
                        else
                            %The max() are here to avoid going below 0
                            this.minTime = max(0, this.minTime - this.windowWidth);
                            this.maxTime = max(this.windowWidth, this.maxTime - this.windowWidth);
                        end
                    %Cas du GOTO    
                    else
                        this.minTime = this.getCurrentTrip().getTimer.getTime() - this.windowWidth / 2;
                        this.maxTime = this.getCurrentTrip().getTimer.getTime() + this.windowWidth / 2;
                    end
                    this.refreshDataBuffer();
                end
            end
            if (strcmp(message.getCurrentMessage(), 'DATA_CONTENT_CHANGED') && strcmp(this.mode, 'data')) || (strcmp(message.getCurrentMessage(), 'EVENT_CONTENT_CHANGED') && strcmp(this.mode, 'event'))
                this.refreshDataBuffer();
            end
        end
        
         %{
        Function:
        
        This method allows to move the start time of the window in the buffer, as long as the current time
        remains in the time range. After executing this method, the buffer contains the data in the interval [startTime, startTime + windowWidth].
                
        Arguments:
        startTime - The new start time in seconds.
        
        Throws:
        ARGUMENT_EXCEPTION - If the new value of the start time code would be outside the correct range.
        %}
        function changeBufferStartTime(this, startTime)
            import fr.lescot.bind.exceptions.ExceptionIds;
            %Error management
            currentTime = this.getCurrentTrip().getTimer.getTime();
            if (currentTime < startTime) || (currentTime > startTime + this.windowWidth)
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The new buffer start time can''t be set to a value that would exclude the current time'))
            end
            %End of error management
            this.minTime = startTime;
            this.maxTime = startTime + this.windowWidth;
            this.refreshDataBuffer();
        end
    end   
    
    methods(Access = private)
       
        %TODO: doc
        function refreshDataBuffer(this)
            for i = 1:1:this.dataNumber
                if strcmp(this.mode, 'data')
                    newDatas = this.getCurrentTrip.getDataVariableOccurencesInTimeInterval(this.dataName{i}, this.variableName{i}, this.minTime, this.maxTime);
                else
                    newDatas = this.getCurrentTrip.getEventVariableOccurencesInTimeInterval(this.dataName{i}, this.variableName{i}, this.minTime, this.maxTime);
                end
                    timeValues = newDatas.getVariableValues('TimeCode');
                    dataValues = newDatas.getVariableValues(this.variableName{i});
                    this.dataBuffer{i,1} = dataValues;
                    this.dataBuffer{i,2} = timeValues;
            end
        end
        
    end
end

