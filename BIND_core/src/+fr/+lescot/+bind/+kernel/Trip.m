%{
Class:

This abstract class represents a Trip of an Experimentation.
%}
classdef Trip < handle & fr.lescot.bind.observation.Observable & fr.lescot.bind.observation.Observer
    
    properties(Constant)
        %{
        Property:
        The name of the variables used as keys.
        
        Values:
        - 'timecode'
        - 'startTimecode'
        - 'endTimecode'
        %}
        RESERVED_VARIABLE_NAMES = {'timecode', 'startTimecode', 'endTimecode'}
    end
    
    properties (Access = private)
        %{
        Property:
        The inner timer of the Trip.
        
        %}
        timer;
    end
    
    methods(Sealed = true);
        %{
        Function:
        The contructor of a Trip. Don't forget to use
        <setMaxTimeInSeconds()> before using the timer.
        
        Arguments:
        period - The initial period of the embedded timer. Remember that the set period is only an
        initial value. If the computer lags, the value will be automatically risen.
        
        %}
        function trip = Trip(period)
          trip.timer = fr.lescot.bind.kernel.TimerTrip(period);
          trip.timer.addObserver(trip);
        end
        
        %{
        Function:
        Getter for the embedded timer.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        %}
        function out = getTimer(obj)
            out = obj.timer;
        end
        
        %{
        Function:
        See <observation.Observer.update>.
        
        Implements:
        - <observation.Observer.update()>
        
        %}
        function update(obj, message)
           obj.notifyAll(message); 
        end
        
    end
    
    methods
        %{
        Function:
        This method overwrite the default delete to ensure that the timer
        is properly deleted when the Trip is deleted.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        %}
        function delete(obj)
            delete(obj.timer);
        end 
        
        %{
        Function:
        This methods sets the maximum value of the timecode of the Trip's data.
        When reached, the embedded timer stops.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        maxTime - The integer representing the max value.
        %}
        function setMaxTimeInSeconds(this, maxTime)
            this.timer.setMaxTimeInSeconds(maxTime);
        end
    end
    
    methods (Abstract)
        
        %{
        Function:
        Generates a <data.MetaInformations> object based on the structure of the
        object.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        
        Returns:
        out - a MetaDatas object.
        %}
        getMetaInformations(this)
        
        %{
        Function:
        Returns the <data.Records> of the specified data in the specified time
        interval. The result is ordered by ascending timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data to retrieve.
        startTime - the beginning time code for the interval.
        endTime : the ending time code for the interval.
        
        Returns:
        A <data.Record> object.
        
        %}
        results = getDataOccurencesInTimeInterval(this, dataName, startTime, endTime)
        
        %{
        Function:
        Returns the <data.Records> of the specified event in the specified time
        interval. The result is ordered by ascending timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event to retrieve.
        startTime - the beginning time code for the interval.
        endTime : the ending time code for the interval.
        
        Returns:
        A <data.Record> object.
        
        %}
        results = getEventOccurencesInTimeInterval(this, eventName, startTime, endTime)
        
        %{
        Function:
        Returns the <data.Records> of the specified situation in the specified time
        interval. The return is ordered by ascending startTimecode, then 
        by ascending endTimecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the situation to retrieve.
        startTime - the beginning time code for the interval.
        endTime : the ending time code for the interval.
        
        Returns:
        A <data.Record> object.
        
        %}
        results = getSituationOccurencesInTimeInterval(this, situationName, startTime, endTime)
        
        %{
        Function:
        Retrieves all the record for wich TimeCode is between the two
        limits passed as argument. The result is ordered by ascending
        timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the table to explore
        variableName - The name of the variable in the data to extract
        startTime - The lower limit for TimeCode
        endTime - The upper limit for TimeCode
        
        
        Returns:
        A <data.Record> object.
        %}
        results = getDataVariableOccurencesInTimeInterval(obj, dataName, variableName, startTime, endTime)
        
        %{
        Function:
        Retrieves all the record for wich timecode is between the two
        limits passed as argument. The result is ordered by ascending
        timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event to explore
        startTime - The lower limit for TimeCode
        endTime - The upper limit for TimeCode
        
        
        Returns:
        A <data.Record> object.
        %}
        results = getEventVariableOccurencesInTimeInterval(obj, eventName, variableName, startTime, endTime)
        
        %{
        Function:
        Retrieves all the record for wich startTimecode >= startTime arg
        and endTimecode <= endTime arg. The return is ordered by ascending
        startTimecode, then by ascending endTimecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the situation to explore
        startTime - The lower limit for TimeCode
        endTime - The upper limit for TimeCode
        
        
        Returns:
        A <data.Record> object.
        %}
        results = getSituationVariableOccurencesInTimeInterval(obj, eventName, variableName, startTime, endTime)
        
        %{
        Function:
        Retrieves the record whose timecode is the nearest from the one
        provided.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the table to explore
        time - The time near which you need to find a record
        
        Returns:
        A <data.Record> object.
        %}
        results = getDataOccurenceNearTime(obj, dataName, time);
        
        %{
        Function:
        Retrieves the record whose timecode is the nearest from the one
        provided.

        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event to explore
        time - The time near which you need to find a record        
        
        Returns:
        A <data.Record> object.
        %}
        results = getEventOccurenceNearTime(obj, eventName, time);
        
        %{
        Function:
        Retrieves the record whose timecode is the one passed as argument
        if it exists, nothing if it doesn't.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the table to explore
        time - The time at which you need to find a record
        
        Returns:
        A <data.Record> object.
        
        Throws:
        Trip:getDataOccurenceAtTime:TimeCodeNotFound - If the provided
        timecode does not match any record.
        %}
        results = getDataOccurenceAtTime(obj, dataName, time);
        
        %{
        Function:
        Retrieves the record whose timecode is the one passed as argument
        if it exists, nothing if it doesn't.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event to explore
        time - The time at which you need to find a record
        
        Returns:
        A <data.Record> object.
        %}
        results = getEventOccurenceAtTime(obj, eventName, time);
        
        %{
        Function:
        Retrieves the record whose matching the two timecodes if it exist, nothing if it doesn't.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the situation to explore
        startTime - The startTime of the record
        endTime - The endTime of the record
        
        Returns:
        A <data.Record> object.
        %}
        results = getSituationOccurenceAtTime(obj, situationName, startTime, endTime);
        
        %{
        Function:
        Returns the <data.Record> of the situation surrounding the
        timecode, if there is one that exists in the situation. The
        return is ordered by ascending startTimecode, then by ascending
        endTimecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the situation to explore
        timecode - The time around which you need to find a record
        
        
        Returns:
        A <data.Record> object.
        %}
        result = getSituationOccurencesAroundTime(this, situationName, timecode)
            
        %{
        Function:
        Returns all the content of an Event. The result is ordered by
        ascending timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - a String giving the name of the event to retrieve.
        
        
        Returns:
        out - a <data.Record>.
        %}
        results = getAllEventOccurences(obj, eventName)
        
        %{
        Function:
        Returns all the content of a Situtation. The result is ordered by
        ascending startTimecode then by ascending endTimecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - a String giving the name of the situation to retrieve.
        
        
        Returns:
        out - a <data.Record>.
        %}
        results = getAllSituationOccurences(obj, situationName)
        
        %{
        Function:
        Returns all the content of a Data. The result is ordered by
        ascending timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - a String giving the name of the data to retrieve.
        
        
        Returns:
        out - a <data.Record>.
        %}
        results = getAllDataOccurences(obj, dataName)
        
        %{
        Function:
        Delete all occurences from a Data 
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - a String giving the name of the data to retrieve.
        
        %}
        removeAllDataOccurences(obj, dataName)
        
        %{
        Function:
        Delete all occurences from an Event
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - a String giving the name of the data to retrieve.

        %}
        removeAllEventOccurences(obj, eventName)
                
        %{
        Function:
        Delete all occurences from a Situation
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - a String giving the name of the data to retrieve.

        %}
        removeAllSituationOccurences(obj, situationName)
        
        %{
        Function:
        Returns the minimum value of a variable of a Data. If the data
        contains no occurences, the function returns NaN.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data containing the variable.
        variableName - The name of the variable
        
        
        Returns:
        the minimum value of the variable.
        %}
        results = getDataVariableMinimum(obj, dataName, variableName)
        
        %{
        Function:
        Returns the minimum value of a variable of an Event. If the event
        contains no occurences, the function returns NaN.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event containing the variable.
        variableName - The name of the variable
        
        
        Returns:
        the minimum value of the variable.
        %}
        results = getEventVariableMinimum(obj, eventName, variableName)
        
        %{
        Function:
        Returns the minimum value of a variable of a Situation. If the
        situation
        contains no occurences, the function returns NaN.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the situation containing the variable.
        variableName - The name of the variable
        
        
        Returns:
        the minimum value of the variable.
        %}
        results = getSituationVariableMinimum(obj, situationName, variableName)
        
        %{
        Function:
        Returns the maximum value of a variable. If the data
        contains no occurences, the function returns NaN.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data containing the variable.
        variableName - The name of the variable
        
        
        Returns:
        the maximum value of the variable.
        %}
        results = getDataVariableMaximum(obj, dataName, variableName)
        
        %{
        Function:
        Returns the maximum value of a variable. If the event
        contains no occurences, the function returns NaN.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eve,tName - The name of the event containing the variable.
        variableName - The name of the variable
        
        
        Returns:
        the maximum value of the variable.
        %}
        results = getEventVariableMaximum(obj, eventName, variableName)
        
        %{
        Function:
        Returns the maximum value of a variable. If the situation
        contains no occurences, the function returns NaN.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the situation containing the variable.
        variableName - The name of the variable
        
        
        Returns:
        the maximum value of the variable.
        %}
        results = getSituationVariableMaximum(obj, situationName, variableName)
        
        %{
        Function:
        Changes the value of a given variable at a given
        timecode. If the given timecode do not exist, it is created. This
        methods sends a 'DATA_CONTENT_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data where the value needs to be
        changed
        variableName - The name of the variable to change
        time - The time at which you need to change a record
        value - The new value of the column
        %}
        setDataVariableAtTime(this, dataName, variableName, time, value);
        
        %{
        Function: removeDataOccurenceAtTime()
        
        Removes an occurence of a variable at the specified time. If there is no entry at the
        timecode, nothing happens. This methods sends a 'DATA_CONTENT_CHANGED' <TripMessage>
        to its observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data where the value needs to be removed
        variableName - The name of the variable where the value needs to be removed
        time - The time at which you need to change a record
        
        Modifiers:
        - Public
        %}
        removeDataOccurenceAtTime(this, dataName, time);
        
        %{
        Function: removeEventOccurenceAtTime()
        
        Removes an occurence of a variable at the specified time. If there is no entry at the
        timecode, nothing happens. This methods sends a 'EVENT_CONTENT_CHANGED' <TripMessage>
        to its observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event where the value needs to be removed
        variableName - The name of the variable where the value needs to be removed
        time - The time at which you need to change a record
        
        Modifiers:
        - Public
        %}
        removeEventOccurenceAtTime(this, dataName, time);
        
        %{
        Function: removeSituationOccurenceAtTime()
        
        Removes an occurence of a variable at the specified time. If there is no entry at the
        timecode, nothing happens. This methods sends a 'SITUATION_CONTENT_CHANGED' <TripMessage>
        to its observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the situation where the value needs to be removed
        variableName - The name of the variable where the value needs to be removed
        time - The time at which you need to change a record
        
        Modifiers:
        - Public
        %}
        removeSituationOccurenceAtTime(this, dataName, startTime, endTime);
        
        %{
        Function:
        Changes the value of a given variable at a given
        timecode. If the given timecode do not exist, it is created. This
        methods sends an 'EVENT_CONTENT_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event where the value needs to be
        changed
        variableName - The name of the variable to change
        time - The time at which you need to change a record
        value - The new value of the variable
        %}
        setEventVariableAtTime(this, eventName, variableName, time, value)
        
        %{
        Function:
        Changes the value of a given variable at a given
        pair of timecode. If the given timecodes do not exist, they are
        created. This methods sends a 'SITUATION_CONTENT_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the event where the value needs to be
        changed
        variableName - The name of the variable to change
        startTime - The start time of the line that have to be changed
        endTime - The start time of the line that have to be changed
        value - The new value of the variable
        %}
        setSituationVariableAtTime(this, situationName, variableName, startTime, endTime, value)
        
        %{
        Function:
        Update or insert the time / values pairs in the given variable. This methods sends a 'DATA_CONTENT_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data where the value needs to be
        changed
        variableName - The name of the variable to change
        timeValueCellArray - A 2xn cell array with the timecodes on the
        first line and the corresponding values on the second line.
                
        %}
        setBatchOfTimeDataVariablePairs(this, dataName, variableName, timeValueCellArray)
        
        %{
        Function:
        Update or insert the time / values pairs in the given variable. This methods sends a 'EVENT_CONTENT_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event where the value needs to be
        changed
        variableName - The name of the variable to change
        timeValueCellArray - A 2xn cell array with the timecodes on the
        first line and the corresponding values on the second line.
        
        %}
        setBatchOfTimeEventVariablePairs(this, eventName, variableName, timeValueCellArray)
        
        %{
        Function:
        Update or insert the start time / end time / values triplets in
        the given variable. This methods sends a 'SITUATION_CONTENT_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the situation where the value needs to be
        changed
        variableName - The name of the variable to change
        timeValueCellArray - 3xn cell array with the start timecodes on the first line, the stop timecodes on
        the second and the corresponding values on the third line.
        %}
        setBatchOfTimeSituationVariableTriplets(this, eventName, variableName, timeValueCellArray)
        
        %{
        Function:
        Insert a new event occurence in the selected event. If there is already an event at this timecode, nothing happens.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event where the occurence will be inserted.
        timecode - The timecode at which to insert the occurence.
        
        %}
        setEventAtTime(this, eventName, timecode)
        
        %{
        Function:
        Insert a new situation occurence in the selected situation. If there is already a situation with the same pair of timecodes, nothing happens.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event where the occurence will be inserted.
        startTime - The start timecode of the situation.
        endTime - The end timecode of the situation.
        
        %}
        setSituationAtTime(this, situationName, startTime, endTime);
        
        %{
        Function:
        Insert a batch of new events occurence in the selected situation. It behaves
        exactly as <setEventAtTime()>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event where the occurence will be inserted.
        timecodeCellArray - A cell array of timecodes.

        %}
        setBatchOfEventsAtTime(this, eventName, timecodeCellArray);
        
        %{
        Function:
        Insert a batch of new situation occurences in the selected situation.  It behaves
        exactly as <setSituationAtTime()>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event where the occurence will be inserted.
        timecodesPairsCellArray - A 2xn cell array, with the start timecodes on the first line
        and the end time codes on the second line.
        %}
        setBatchOfSituationsAtTime(this, situationName, timecodesPairsCellArray);
        
        %{
        Function:
        Returns the maximum timecode found for the Trip through all the
        datas.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        the maximal timecode in seconds for the trip.
        
        %}
        getMaxTimeInDatas(this);
        
        %{
        Function:
        Returns the maximum timecode found for the Trip through all the
        events.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        the maximal data timecode in seconds for the trip.
        
        %}
        getMaxTimeInEvents(this);
        
        %{
        Function:
        Returns the maximum endTimecode found for the Trip through all the
        situations.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        the maximal data endTimecode in seconds for the trip.
        
        %}
        getMaxEndTimeInSituations(this);
      
        %{
        Function:
        Adds a new data to the Trip. The data created is then accessible
        via all the other methods of the trip. In case of error, the whole
        modification is rollbacked to preserve the consistency of the
        datas. This methods sends a 'DATA_ADDED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        metadata - a <data.MetaData> object that describes the data to
        insert, its variables, and so on.

        %}
        addData(this, metaData);
        
        %{
        Function:
        Adds a new event to the Trip. The event created is then accessible
        via all the other methods of the trip. In case of error, the whole
        modification is rollbacked to preserve the consistency of the
        datas. This methods sends a 'EVENT_ADDED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        metaEvent - a <data.MetaEvent> object that describes the event to
        insert, its variables, and so on.
        %}
        addEvent(this, metaEvent);
        
        %{
        Function:
        Adds a new situation to the Trip. The situation created is then accessible
        via all the other methods of the trip. In case of error, the whole
        modification is rollbacked to preserve the consistency of the
        datas. This methods sends a 'SITUATION_ADDED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        metaSituation - a <data.MetaSituation> object that describes the situation to
        insert, its variables, and so on.
        
        %}
        addSituation(this, metaSituation);
        
        %{
        Function:
        Adds a new variable to a data of the Trip. The variable created is then accessible
        via all the other methods of the trip. This methods sends a 'DATA_VARIABLE_ADDED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - the name of the data that will hold the variable.
        metaDataVariable - a <data.MetaDataVariable> object that describes the variable to
        insert, and so on.
        %}
        addDataVariable(this, dataName, metaDataVariable);
        
        %{
        Function:
        Adds a new variable to an event of the Trip. The variable created is then accessible
        via all the other methods of the trip. This methods sends a 'EVENT_VARIABLE_ADDED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - the name of the event that will hold the variable.
        metaEventVariable - a <data.MetaEventVariable> object that describes the variable to
        insert and details about it.
        %}
        addEventVariable(this, eventName, metaDataVariable);
        
        %{
        Function:
        Adds a new variable to a situation of the Trip. The variable created is then accessible
        via all the other methods of the trip. This methods sends a 'SITUATION_VARIABLE_ADDED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - the name of the situation that will hold the variable.
        metaSituationVariable - a <data.MetaSituationVariable> object that describes the variable to
        insert and details about it.
        %}
        addSituationVariable(this, eventName, metaDataVariable);

        %{
        Function:
        Removes a data from a trip. Both the data in itself and it's
        content are deleted.There is no way to rollback this function once commited, as
        it alters directly the data. This methods sends a 'DATA_REMOVED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - the name of the data that will be deleted.
        %}
        removeData(this, dataName);
        
        %{
        Function:
        Removes an event from a trip. Both the event in itself and it's
        content are deleted. There is no way to rollback this function once commited, as
        it alters directly the data. This methods sends a 'EVENT_REMOVED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - the name of the event that will be deleted.
            
        %}
        removeEvent(this, eventName);
        
        %{
        Function:
        Removes a situation from a trip. Both the situation in itself and it's
        content are deleted. There is no way to rollback this function once commited, as
        it alters directly the data. This methods sends a 'SITUATION_REMOVED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - the name of the situation that will be deleted.
        
        %}
        removeSituation(this, eventName);

        %{
        Function:
        Removes a variable from a data. Both the data and it's content are deleted.
        There is no way to rollback this function once commited, as
        it alters directly the data. This methods sends a 'DATA_VARIABLE_REMOVED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - the name of the data in which the variable exists.
        variableName - the name of the variable to delete.
       
        %}
        removeDataVariable(this, dataName, variableName);
        
        %{
        Function:
        Removes a variable from an event. Both the event and it's content are deleted.
        There is no way to rollback this function once commited, as
        it alters directly the data. This methods sends a 'EVENT_VARIABLE_REMOVED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - the name of the event in which the variable exists.
        variableName - the name of the variable to delete.

        %}
        removeEventVariable(this, eventName, variableName);
        
        %{
        Function:
        Removes a variable from a situation. Both the situation and it's content are deleted.
        There is no way to rollback this function once commited, as
        it alters directly the data. This methods sends a 'SITUATION_VARIABLE_REMOVED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - the name of the situation in which the variable exists.
        variableName - the name of the variable to delete.
        
        %}
        removeSituationVariable(this, situationName, variableName); 
        
        
        %{
        Function:
        Returns an an attribute of the Trip. This attribute represents an
        element of metadata about the trip in itself, for example the date
        of the trip, the weather conditions, the model of the car, ...
        
        Arguments:
        this - The object on which the function is called, optionnal.
        attributeName - the name of the attribute
        
        Returns:
        a string containing the value of the attribute
      
        %}
        getAttribute(this, attributeName);
        
        %{
        Function:
        Changes the value of an attribute of the trip. If the attribute
        doesn't exists, it is created. This methods sends a 'TRIP_META_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        attributeName - the name of the attribute
        attributeValue - a string with the new value of the attribute.
        
        %}
        setAttribute(this, attributeName, attributeValue);
        
        %{
        Function:
        Remove an attribute of the trip. No rollback is possible. This methods sends a 'TRIP_META_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        attributeName - the name of the attribute
    
        %}
        removeAttribute(this, attributeName);
        
        %{
        Function:
        Add the informations about a videoFile to the trip if it doesn't exist, and update
        the if they already exist. This methods sends a 'TRIP_META_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        videoFile - the <data.MetaVideoFile> object.
        %}
        addVideoFile(this, videoFile)

        %{
        Function:
        For this implementation, you have to pass the MetaVideoFile. The offset will be modified
        according to the description of the video. The filenames are unchanged.

        Arguments:
        this - The object on which the function is called, optionnal.
        videoFile - the <data.MetaVideoFile> object.
        %}
        updateVideoFileOffset(this, videoFile)
        
        %updateMetaInformations(this, metaInformations)
        
        %{
        Function:
        This method will replace all the informations for the event -except the event name and timecode -
        and its variables -except the names- identified by the name property of
        the <data.metaEvent> object. 
        Warning: Unset properties in the <data.metaEvent> will be
        considered as empty, and thus be emptied in the trip. All the
        properties of the variables will be set to the values of the
        properties of the variables set in the <data.metaEvent> object. If a
        metaEventVariable is present in the metaEvent argument, it will
        also be updated.

        Arguments:
        this - The object on which the function is called, optionnal.
        metaEvent - the <data.metaEvent> containing the new
        values.
        
        Throws:
        EVENT_EXCEPTION - If the event or one of the variables don't exist.
        %}
        updateMetaEvent(this, metaEvent)
        
        %{
        Function:
        This method will replace all the informations for the situation -except the names and timecode-
        and its variables -except the names- identified by the name property of
        the <data.metaSituation> object. 
        Warning: Unset properties in the <data.metaSituation> will be
        considered as empty, and thus be emptied in the trip. All the
        properties of the variables will be set to the values of the
        properties of the variables set in the <data.metaSituation> object. If a
        metaSituationVariable is present in the metaSituation argument, it will
        also be updated.

        Arguments:
        this - The object on which the function is called, optionnal.
        metaSituation - the <data.metaSituation> containing the new
        values.
        
        Throws:
        SITUATION_EXCEPTION - If the situation or one of the variables don't exist.
        %}
        updateMetaSituation(this, metaSituation)
         
        %{
        Function:
        This method will replace all the informations for the data -except name and timecode-
        and its variables -except the name- identified by the name property of
        the <data.metaData> object. 
        Warning : Unset properties in the <data.metaDataVariable> will be
        considered as empty, and thus be emptied in the trip. All the
        properties of the variables will be set to the values of the
        properties of the variables set in the <data.metaData> object. If a
        metaDataVariable is present in the metaData argument, it will
        also be updated.

        Arguments:
        this - The object on which the function is called, optionnal.
        metaData - the <data.metaData> containing the new values (including data descriptions and variables descriptions.
        
        Throws:
        DATA_EXCEPTION - If the data or one of the variables don't exist.
        %}
        updateMetaData(this, metaData)
        
        %{
        Function:
        This method will replace all the informations for the data variable
        identified by both the dataName argument and the name property of
        the <data.metaDataVariable> object. Unset properties in the <data.metaDataVariable> will be
        considered as empty, and thus be emptied in the trip.

        Arguments:
        this - The object on which the function is called, optionnal.
        metaDataVariable - the <data.metaData> containing the new
        values.
        
        Throws:
        DATA_EXCEPTION - If the data or the variable don't exist.
        %}
        updateMetaDataVariable(this, dataName, metaDataVariable)
        
        %{
        Function:
        This method will replace all the informations for the event variable
        identified by both the eventName argument and the name property of
        the <data.metaEventVariable> object. Unset properties in the <data.metaEventVariable> will be
        considered as empy, and thus be emptied in the trip.

        Arguments:
        this - The object on which the function is called, optionnal.
        metaEventVariable - the <data.metaEventVariable> containing the new
        values.
        
        Throws:
        EVENT_EXCEPTION - If the event or the variable don't exist.
        %}
        updateMetaEventVariable(this, eventName, metaEventVariable)
        
        %{
        Function:
        This method will replace all the informations for the situation variable
        identified by both the situationName argument and the name property of
        the <data.metaSituationVariable> object. Unset properties in the <data.metaSituationVariable> will be
        considered as empy, and thus be emptied in the trip.

        Arguments:
        this - The object on which the function is called, optionnal.
        metaSituationVariable - the <data.metaSituationVariable> containing the new
        values.
        
        Throws:
        SITUATION_EXCEPTION - If the situation or the variable don't exist.
        %}
        updateMetaSituationVariable(this, situationName, metaSituationVariable)
            
        %{
        Function:
        Remove a video file of the trip. No rollback is possible. Only the
        reference in the trip will be removed, not the physical file it
        points to. This methods sends a 'TRIP_META_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        fileName - the name of the attribute
        %}
        removeVideoFile(this, fileName);
        
        %{
        Function:
        Set the metadatas for the participant to the trip. This methods sends a 'TRIP_META_CHANGED' <TripMessage> to its
        observers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        participant - A data.MetaParticipant object.
        
        %}
        setParticipant(this, participant);
        
        %{
        Function:
        Change the isBase attribute of the data. If the attribute is true,
        all the methods that changes this data or its content will throw
        an exception.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - A string containing the name of the data.
        isBase - The new boolean value for the attribute.
        
        
        Throws:
        META_INFOS_EXCEPTION - when the given arguments did not
        allow the retrieval of the data to change.
        %}
        setIsBaseData(this, dataName, isBase);
        
        %{
        Function:
        Change the isBase attribute of the event. If the attribute is true,
        all the methods that changes this event or its content will throw
        an exception.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - A string containing the name of the event.
        isBase - The new boolean value for the attribute.
        
        
        Throws:
        META_INFOS_EXCEPTION - when the given arguments did not
        allow the retrieval of the event to change.
        %}
        setIsBaseEvent(this, eventName, isBase);
        
        %{
        Function:
        Change the isBase attribute of the situation. If the attribute is true,
        all the methods that changes this situation or its content will throw
        an exception.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - A string containing the name of the situation.
        isBase - The new boolean value for the attribute.
        
        
        Throws:
        META_INFOS_EXCEPTION - when the given arguments did not
        allow the retrieval of the situation to change.
        %}
        setIsBaseSituation(this, situationName, isBase);
        
        %{
        Function:
        This method start a new transaction, wich means all the
        modifications that occurs after the call to this method will be
        able to be rollbacked (for example upon a failure). However, it
        means that as long as you don't call the <commitTransaction>
        method, the values are not definitely saved. Beign in a
        transaction have no impact on getters.
        
        A simple and straightforward implementation of this mechanism for
        a file oriented trip implementation would be to create a copy of
        the file. In a tranactional system, the implementation will rely on
        the the built-in transaction features.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        beginTransaction(this);
        
        %{
        Function:
        This method cancel all the changes that occured since the opening
        of the transaction and close the transaction.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        backupPointName - A string identifying the backup point.
        
        %}
        rollbackTransaction(this);
        
        %{
        Function:
        This method validate all the changes that where performed since
        the opening of the transaction, and close it.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        backupPointName - A string identifying the backup point.
        
        %}
        commitTransaction(this);
        
        %{
        Function:
        Returns the type of a variable in a specified data.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data in which the variable is located.
        variableName - the name of the variable.
        %}
        out =  getDataVariableType(this, dataName, variableName)
        
        %{
        Function:
        Returns the type of a variable in a specified event.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data in which the variable is located.
        eventName - the name of the event.
        %}
        out =  getEventVariableType(this, dataName, eventName)
        
        %{
        Function:
        Returns the type of a variable in a specified situation.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data in which the variable is located.
        situationName - the name of the event.
        %}
        out =  getSituationVariableType(this, dataName, situationName)
    end
    
end

