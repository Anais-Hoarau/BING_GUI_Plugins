%{
Class:
This class represents all the datas concerning a database.

%}
classdef MetaInformations < handle
    
    properties (Access = private)
        %{
        Property:
        the cell array containing all the <MetaDatas> of a trip.
        
        %}
        datasList = {};
        
        %{
        Property:
        the cell array containing all the <MetaEvents> of a trip.
        
        %}
        eventsList = {};
        
        %{
        Property:
        the cell array containing all the <MetaSituations> of a trip.
        
        %}
        situationsList = {};

        %{
        Property:
        the cell array containing all the attributes of a trip.
        
        %}
        attributesList = {};
        
        %{
        Property:
        The <MetaParticipant> object that holds the data
        about the participant to the trip.
        
        %}
        participant;
        
        %{
        Property:
        The <MetaVideoFile> cell array that holds the data
        about the video files related to the trip.
        
        %}
        videoFiles = {};
    end
    
    methods
        
        %{
        Function:
        Getter for the list of the events of the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        Returns:
        The cell array of the <MetaEvents> of the base.
        %}
        function out = getEventsList(obj)
            out = obj.eventsList;
        end
        
        %{
        Function:
        Returns a cell array of strings containing then names of all the
        events available in the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of strings.
        %}
        function out = getEventsNamesList(obj)
            eventList = obj.getEventsList();
            out = cell(1, length(eventList));
            for i = 1:1:length(eventList)
                out{i} = eventList{i}.getName();
            end
        end
        
        %{
        Function:
        Returns a cell array of strings containing then names of all the
        variables available in the event, including the timecode variable.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event which variables are required, as a
        String.
        
        Returns:
        A cell array of strings.

        %}
        function out = getEventVariablesNamesList(this, eventName)
            variablesList = this.getMetaEvent(eventName).getVariablesAndFrameworkVariables();
            out = cell(1, length(variablesList));
            for i = 1:1:length(variablesList)
                out{i} = variablesList{i}.getName();
            end
        end
        
        %{
        Function:
        Setter for the list of the events in the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        datasList - the cell array containing the new <MetaEvents> list to set.
        %}
        function setEventsList(obj, eventsList)
            obj.eventsList = eventsList;
        end

        %{
        Function:
        Getter for the list of the situations of the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        Returns:
        The cell array of the <MetaSituations> of the trip.
        %}
        function out = getSituationsList(obj)
            out = obj.situationsList;
        end
        
        %{
        Function:
        Returns a cell array of strings containing then names of all the
        situations available in the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of strings.
        %}
        function out = getSituationsNamesList(obj)
            situationList = obj.getSituationsList();
            out = cell(1, length(situationList));
            for i = 1:1:length(situationList)
                out{i} = situationList{i}.getName();
            end
        end
        
        %{
        Function:
        Returns a cell array of strings containing then names of all the
        variables available in the situation, including the timecodes variables.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The name of the situation which variables are required, as a
        String.
        
        Returns:
        A cell array of strings.
        %}
        function out = getSituationVariablesNamesList(this, situationName)
            variablesList = this.getMetaSituation(situationName).getVariablesAndFrameworkVariables();
            out = cell(1, length(variablesList));
            for i = 1:1:length(variablesList)
                out{i} = variablesList{i}.getName();
            end
        end
        
        %{
        Function:
        Setter for the list of the situations in the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        situationsList - the cell array containing the new datas list to set.
        %}
        function setSituationsList(obj, situationsList)
            obj.situationsList = situationsList;
        end

        %{
        Function:
        Getter for the list of the datas of the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        Returns:
        The cell array of the <MetaDatas> of the base.
        %}
        function out = getDatasList(obj)
            out = obj.datasList;
        end
        
        %{
        Function:
        Returns a cell array of strings containing then names of all the
        datas available in the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of strings.
        %}
        function out = getDatasNamesList(obj)
            dataList = obj.getDatasList();
            out = cell(1, length(dataList));
            for i = 1:1:length(dataList)
                out{i} = dataList{i}.getName();
            end
        end
        
        %{
        Function:
        Returns a cell array of strings containing then names of all the
        variables available in the data, including the timecode variable.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data which variables are required, as a
        String.
        
        Returns:
        A cell array of strings.
        %}
        function out = getDataVariablesNamesList(this, dataName)
            variablesList = this.getMetaData(dataName).getVariablesAndFrameworkVariables();
            out = cell(1, length(variablesList));
            for i = 1:1:length(variablesList)
                out{i} = variablesList{i}.getName();
            end
        end
        
        %{
        Function:
        Setter for the list of the datas in the Trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        datasList - the cell array containing the new datas list to set.
        %}
        function setDatasList(obj, datasList)
            obj.datasList = datasList;
        end
        
        %{
        Function:
        Getter for the list of the datas of the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        Returns:
        A cell array of string containing the keys of the attributes.
        %}
        function out = getTripAttributesList(obj)
            out = obj.attributesList;
        end
        
        %{
        Function:
        Setter for the list of the datas in the trip.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        attributesList - The cell array of string containing the keys of the attributes
        %}
        function setTripAttributesList(obj, attributesList)
            obj.attributesList = attributesList;
        end
        
        %{
        Function:
        Returns the <MetaData> object corresponding to the data name passed
        in argument.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - the name of the data
        
        Returns:
        A <MetaData> object
        
        Throws:
        META_INFOS_EXCEPTION - if the data passed in
        argument is not present.
        %}
        function out = getMetaData(this, dataName)
            import fr.lescot.bind.exceptions.ExceptionIds;
            for i = 1:1:length(this.datasList)
               if strcmp(this.datasList{i}.getName(), dataName)
                  data = this.datasList{i}; 
               end
            end
            if ~exist('data', 'var')
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'The requested data was not found in the metainformations'));
            end
            out = data;
        end
        
        %{
        Function:
        Returns the <MetaEvent> object corresponding to the event name passed
        in argument.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - the name of the event
        
        Returns:
        A <MetaEvent> object
        
        Throws:
        META_INFOS_EXCEPTION - if the event passed in
        argument is not present.
        %}
        function out = getMetaEvent(this, eventName)
            import fr.lescot.bind.exceptions.ExceptionIds;
            for i = 1:1:length(this.eventsList)
               if strcmp(this.eventsList{i}.getName(), eventName)
                  event = this.eventsList{i}; 
               end
            end
            if ~exist('event', 'var')
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'The requested event was not found in the metainformations'));
            end
            out = event;
        end
        
        %{
        Function:
        Returns the <MetaSituation> object corresponding to the situation name passed
        in argument.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - the name of the situation
        
        Returns:
        A <MetaSituation> object
        
        Throws:
        META_INFOS_EXCEPTION - if the situation passed in
        argument is not present.
        %}
        function out = getMetaSituation(this, situationName)
            import fr.lescot.bind.exceptions.ExceptionIds;
            for i = 1:1:length(this.situationsList)
               if strcmp(this.situationsList{i}.getName(), situationName)
                  situation = this.situationsList{i}; 
               end
            end
            if ~exist('situation', 'var')
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'The requested situation was not found in the metainformations'));
            end
            out = situation;
        end
        
        %{
        Function:
        Set the datas about the participant to the trip.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        aParticipant - the <data.MetaParticipant> objet that describes the
        trip to store.
        
        %}
        function setParticipant(this, participant)
            this.participant = participant;
        end
        
        %{
        Function:
        Returns the <MetaParticipant> object that holds the datas about
        the participant to the trip.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function out = getParticipant(this)
            out = this.participant;
        end
        
        %{
        Function:
        Set the list of video files that are linked to the Trip.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        videoFilesArray - A cell array of <MetaVideoFile>.
        %}
        function setVideoFiles(this, videoFiles)
            this.videoFiles = videoFiles;
        end
        
        %{
        Function:
        Returns the datas about the video files linked to the Subject.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of <MetaVideoFile>.
        
        %}
        function out = getVideoFiles(this)
            out = this.videoFiles;
        end

        %{
        Function:
        Determine the existence of the given data.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - A string with the name of the data to check.
        
        Returns:
        A boolean.
        
        %}
        function out = existData(this, dataName)
           dataList = this.getDatasNamesList();
           out = false;
           for i = 1:1:length(dataList)
               if strcmp(dataName, dataList{i})
                   out = true;
               end
           end
        end
        
        %{
        Function:
        Determine the existence of a user variable in the given data. If
        the data does not exist, false is returned.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - A string with the name of the data to check.
        variableName - A string with the name of the variable to check.
        
        Returns:
        A boolean.
        
        %}
        function out = existDataVariable(this, dataName, variableName)
           if ~this.existData(dataName)
               out = false;
           else
               variablesList = this.getDataVariablesNamesList(dataName);
               out = false;
               for i = 1:1:length(variablesList)
                   if strcmp(variableName, variablesList{i})
                       out = true;
                   end
               end
           end
        end
        
        %{
        Function:
        Determine the existence of the given event.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - A string with the name of the event to check.
        
        Returns:
        A boolean.
        
        %}
        function out = existEvent(this, eventName)
           eventList = this.getEventsNamesList();
           out = false;
           for i = 1:1:length(eventList)
               if strcmp(eventName, eventList{i})
                   out = true;
               end
           end
        end
        
        %{
        Function:
        Determine the existence of a user variable in the given event. If
        the Event does not exist, false is returned.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - A string with the name of the event to check.
        variableName - A string with the name of the variable to check.
        
        Returns:
        A boolean.
        
        %}
        function out = existEventVariable(this, eventName, variableName)
            if ~this.existEvent(eventName)
                out = false;
            else
                variablesList = this.getEventVariablesNamesList(eventName);
                out = false;
                for i = 1:1:length(variablesList)
                    if strcmp(variableName, variablesList{i})
                        out = true;
                    end
                end
            end
        end
        
        %{
        Function:
        Determine the existence of the given situation.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - A string with the name of the situation to check.
        
        Returns:
        A boolean.
        
        %}
        function out = existSituation(this, situationName)
           situationList = this.getSituationsNamesList();
           out = false;
           for i = 1:1:length(situationList)
               if strcmp(situationName, situationList{i})
                   out = true;
               end
           end
        end
        
        %{
        Function:
        Determine the existence of a user variable in the given situation.
        If the Situation does not exist, false is returned.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - A string with the name of the situation to check.
        variableName - A string with the name of the variable to check.
        
        Returns:
        A boolean.
        
        %}
        function out = existSituationVariable(this, situationName, variableName)
            if ~this.existSituation(situationName)
                out = false;
            else
                variablesList = this.getSituationVariablesNamesList(situationName);
                out = false;
                for i = 1:1:length(variablesList)
                    if strcmp(variableName, variablesList{i})
                        out = true;
                    end
                end
            end
        end
        
        %{
        Function:
        Determine the existence of the given attribute.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        attributeName - A string with the name of the situation to check.
        
        Returns:
        A boolean.
        
        %}
        function out = existAttribute(this, attributeName)
           attributeList = this.getTripAttributesList();
           out = false;
           for i = 1:1:length(attributeList)
               if strcmp(attributeName, attributeList{i})
                   out = true;
               end
           end
        end
    end
    
end

