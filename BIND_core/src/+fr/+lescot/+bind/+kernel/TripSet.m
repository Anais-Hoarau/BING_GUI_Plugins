%{
Class:
Container class that holds a list of <Trips> and allow some operation to be
performed on all the trips at once, as if it was only one <Trip>. It implements the <Observer>
interface so that it can update union and intersections of properties if the content of
one of the trips changes.

TODO:
faire les tests unitaires de la methode
calculateTripsCommonProperties

%}
classdef TripSet < handle & fr.lescot.bind.observation.Observer
    
    properties(Access = private)
        %{
        Property:
        The array containing all the trips usable in the current environnement.
        
        %}
        trips = {};
        
        %{
        Property:
        This contains a <data.MetaInformations> that describes the
        properties that are common with all the trips of the
        experimentation (intersection).
        
        %}
        tripsCommonProperties;
        
        %{
        Property:
        This contains a <data.MetaInformations> that describes all the
        possible properties that are available on the trips of the
        experimentation (union).
        
        %}
        tripPossibleProperties;
    end
    
    methods
        
        %{
        Function:
        This method overwrite the default delete to ensure that all the
        objects are properely deleted by calling their own delete method.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function delete(this)
            for i = 1:1:length(this.trips)
                this.trips{i}.removeObserver(this);
            end
        end
        
        %{
        Function:
        Getter for the trips
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        out - A cell array of <Trips>
        %}
        function out = getTrips(this)
            out = this.trips;
        end
        
        %{
        Function:
        Setter for the trips.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        trips - The new cell array of <Trips>.
        %}
        function setTrips(this, trips)
            for i = 1:1:length(this.trips)
                this.trips{i}.addObserver(this);
            end
            this.trips = trips;
            this.refreshTripProperties();
        end
        
        %{
        Function:
        Add one trip to the already set trips.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        trip - the <Trip> to add.
        %}
        function addTrip(this, trip)
            this.trips{end + 1} = trip;
            trip.addObserver(this);
            this.refreshTripProperties();
        end
        
        %{
        Function:
        Remove all occurences of a specified trip from the already set trips. If the trip is not found,
        nothing happens.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripToDelete - the <Trip> to remove.
        %}
        function removeTrip(this, tripToDelete)
            tripToDelete.removeObserver(this);
            logicalTripIndexes = ([this.trips{:}] == tripToDelete);
            this.trips(logicalTripIndexes) = [];
            this.refreshTripProperties();
        end
        
        
        %{
        Function:
        Get the properties that are common for all the trips of the
        experimentation.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        out - A <data.MetaInformations> object
        %}
        function out = getTripsCommonProperties(this)
            out = this.tripsCommonProperties;
        end
        
        %{
        Function:
        Get all the properties that may be available for the trips of the
        experimentation.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        out - A <data.MetaInformations> object
        %}
        function out = getTripsPossibleProperties(this)
            out = this.tripPossibleProperties;
        end
        
        %{
        Function:
            Updates the union and intersection of properties when we are notified by one the trips thanks to
        the Observer / Observable pattern.
        %}
        function update(this, message)
            if isa(message, 'fr.lescot.bind.kernel.TripMessage')
                if ~any(strcmp(message.getCurrentMessage(),{'EVENT_CONTENT_CHANGED' 'SITUATION_CONTENT_CHANGED' 'DATA_CONTENT_CHANGED'}))
                    % refresh only if structure change
                    this.refreshTripProperties();
                end
            end
        end
        
        %{
        Function:
        Get the values of the attributes requested from all the trips of
        the tripset. Each line returned match the corresponding trip, in
        the same order than returned by <getTrips()>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        attributesNamesList - The cell array containing the names of the data variables requested
        
        Returns:
        out - A cell array
        %}
        function out = getAttributesValuesForAllTrips(this,attributesNamesList)
            tripsCellArray = this.getTrips();
            values = cell(length(tripsCellArray),length(attributesNamesList));
            for i = 1:length(tripsCellArray)
                theTrip = tripsCellArray{i};
                for j = 1:length(attributesNamesList)
                    attributeName = attributesNamesList{j};
                    values{i,j} = theTrip.getAttribute(attributeName);
                end
            end
            out = values;
        end
        
        %{
        Function:
        Get the values of the participant attributes requested from all the trips of
        the tripset. Each line returned match the corresponding trip, in
        the same order than returned by <getTrips()>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        attributesNamesList - The cell array containing the names of the data variables requested
        
        Returns:
        out - A cell array
        %}
        function out = getParticipantAttributesValuesForAllTrips(this,attributesNamesList)
            tripsCellArray = this.getTrips();
            values = cell(length(tripsCellArray),length(attributesNamesList));
            for i = 1:length(tripsCellArray)
                theTrip = tripsCellArray{i};
                participant = theTrip.getMetaInformations().getParticipant();
                for j = 1:length(attributesNamesList)
                    attributeName = attributesNamesList{j};
                    values{i,j} = participant.getAttribute(attributeName);
                end
            end
            out = values;
        end
        
        %{
        Function:
        Get the values of all the variables of the given event. The DataRecord returned are ordered as the trips
        returned by <getTrips()>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The event name, as a string
        
        Returns:
        A cell array of <data.Record>
        %}
        function out = getEventVariablesValuesForAllTrips(this, eventName)
            tripsCellArray = this.getTrips();
            out = cell(1, length(tripsCellArray));
            for i = 1:length(tripsCellArray)
                currentTrip = tripsCellArray{i};
                out{i} = currentTrip.getAllEventOccurences(eventName);
            end
        end
        
        %{
        Function:
        Get the values of all the variables of the given situation. The DataRecord returned are ordered as the trips
        returned by <getTrips()>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The situation name, as a string
        
        Returns:
        A cell array of <data.Record>
        %}
        function out = getSituationVariablesValuesForAllTrips(this,situationName)
            tripsCellArray = this.getTrips();
            out = cell(1, length(tripsCellArray));
            for i = 1:length(tripsCellArray)
                currentTrip = tripsCellArray{i};
                out{i} = currentTrip.getAllEventOccurences(situationName);
            end
        end
        
        %{
        Function:
        Get the values of all the variables of the given data. The DataRecord returned are ordered as the trips
        returned by <getTrips()>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The situation name, as a string
        
        Returns:
        A cell array of <data.Record>
        %}
        function out = getDataVariablesValuesForAllTrips(this,dataName)
            tripsCellArray = this.getTrips();
            out = cell(1, length(tripsCellArray));
            for i = 1:length(tripsCellArray)
                currentTrip = tripsCellArray{i};
                out{i} = currentTrip.getAllEventOccurences(dataName);
            end
        end
    end
    
    methods (Access = private)
        %{
        Function:
        This function calculate the metaInformation object that describes the trips associated to the triSet.
        It updates both the "common properties", which is the intersection of all metainformation of the trips
        and the "possible properties", which is the union of all metainformation present in the trips.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function refreshTripProperties(this)
            this.calculateTripsProperties('intersection');
            this.calculateTripsProperties('union');
        end
        
        %{
        Function:
        This function is a wrapper for the <buildMetaElementInformation> function, called with the 'data' argument for operation on "data" types
        Using the information of the parameters, it creates <MetaData> objects, set their isBase attribute and add the corresponding <MetaDataVariables>.
        At the end, it update the MetaData part of the MetaInformation object given in parameters with the newly created objects.
        
        Arguments:
        this - optional, the object on which the function is called.
        metaInformations -  a <fr.lescot.bind.data.MetaInfomations> object
        elementsName - a 1xN cell array of String : the names of the N data to create
        isBaseElementList - a 1xN cell array of boolean : the value of the isBase attribute for each data to create
        elementsVariablesNames - a 1xN cell array of 1xM cell array : For each data of the N elementsName, 1 cell... in this cell, a cell array of string for the M names of the variables of the data
        
        Returns:
        metaInformations - the <fr.lescot.bind.data.MetaInfomations> input object with updated MetaData information
        %}
        function metaInformations = buildMetaDataInformation(this,metaInformations,elementsName,isBaseElementList,elementsVariables)
            metaInformations = this.buildMetaElementInformation('data',metaInformations,elementsName, elementsVariables);
        end
        
        %{
        Function:
        This function is a wrapper for the <buildMetaElementInformation> function, called with the 'event' argument for operation on "event" types
        Using the information of the parameters, it creates <MetaEvent> objects, set their isBase attribute and add the corresponding <MetaEventVariables>.
        At the end, it update the MetaEvent part of the MetaInformation object given in parameters with the newly created objects.
        
        Arguments:
        this - optional, the object on which the function is called.
        metaInformations -  a <fr.lescot.bind.data.MetaInfomations> object
        elementsName - a 1xN cell array of String : the names of the N event to create
        isBaseElementList - a 1xN cell array of boolean : the value of the isBase attribute for each data to create
        elementsVariablesNames - a 1xN cell array of 1xM cell array : For each data of the N elementsName, 1 cell... in this cell, a cell array of string for the M names of the variables of the event
        
        Returns:
        metaInformations - the <fr.lescot.bind.data.MetaInfomations> input object with updated MetaEvent information
        %}
        function metaInformations = buildMetaEventInformation(this,metaInformations,elementsName,isBaseElementList,elementsVariables)
            metaInformations = this.buildMetaElementInformation('event',metaInformations,elementsName,elementsVariables);
        end
        
        %{
        Function:
        This function is a wrapper for the <buildMetaElementInformation> function, called with the 'situation' argument for operation on "situation" types
        Using the information of the parameters, it creates <MetaSituation> objects, set their isBase attribute and add the corresponding <MetaSituationVariables>.
        At the end, it update the MetaSituation part of the MetaInformation object given in parameters with the newly created objects.
        
        Arguments:
        this - optional, the object on which the function is called.
        metaInformations -  a <fr.lescot.bind.data.MetaInfomations> object
        elementsName - a 1xN cell array of String : the names of the N situations to create
        isBaseElementList - a 1xN cell array of boolean : the value of the isBase attribute for each data to create
        elementsVariablesNames - a 1xN cell array of 1xM cell array : For each data of the N situations, 1 cell... in this cell, a cell array of string for the M names of the variables of the situations
        
        Returns:
        metaInformations - the <fr.lescot.bind.data.MetaInfomations> input object with updated MetaEvent information
        
        %}
        function metaInformations = buildMetaSituationInformation(this,metaInformations,elementsName,isBaseElementList,elementsVariables)
            metaInformations = this.buildMetaElementInformation('situation',metaInformations,elementsName,elementsVariables);
        end
        
        %{
        Function:
        This function build a metaObject (<MetaData>, <MetaEvent> or <MetaSituation>, set the isBase attribute and add <MetaDataVariable>, <MetaEventVariable> or <MetaSituationVariable> according to the parameters
        and it returns a <MetaInformations> object updated with this values.
        This method should not be called directly as it is better to use one of the wrapper
        
        Parameters:
        this - Optional, object on which the function is called
        type - String, necessary to specify the type of element to handle. Can be 'data', 'event' or 'situation'.
        metaInformations - Input <fr.lescot.bind.data.MetaInformations> object. According to the type parameters, the relevant MetaObject will be overwritten with a new one created from following input parameters.
        elementsName - cell array of string : The names of the elements to create and overwrite in the input <fr.lescot.bind.data.MetaInformations> object
        isBaseElementList - cell array of boolean : The isBase attribute value of the elements given in the elementsName parameter
        elementsVariablesNames - cell array of cell array of string : The names of the variables to add in the differents elements given in the elementsName parameter.
        
        Returns:
        metaInformations - the input <fr.lescot.bind.data.MetaInformations> object, with one of the metaObject overwritten.
        %}
        function metaInformations = buildMetaElementInformation(this,type,metaInformations,elements,elementsVariables)
            elementList = cell(1, length(elements));
            for i=1:1:length(elements)
                %{
                switch type
                    case 'data'
                        element = fr.lescot.bind.data.MetaData();
                    case 'event'
                        element =  fr.lescot.bind.data.MetaEvent();
                    case 'situation'
                        element = fr.lescot.bind.data.MetaSituation();
                end
                
                element.setName(elements{i}.getName());
                element.setIsBase(elements{i}.isBase());
                element.setComments(elements{i}.getComments());
                %}
                element = elements{i};
                %{
                metaElementVariables = cell(1, length(elementsVariables{i}));
                for j=1:1:length(elementsVariables{i})
                    switch type
                        case 'data'
                            variable = fr.lescot.bind.data.MetaDataVariable();
                        case 'event'
                            variable = fr.lescot.bind.data.MetaEventVariable();
                        case 'situation'
                            variable = fr.lescot.bind.data.MetaSituationVariable();
                    end
                    variable.setName(char(elementsVariablesNames{i}{j}));
                    metaElementVariables{j} = variable;
                end
                element.setVariables(metaElementVariables);
                %}
                element.setVariables(elementsVariables{i});
                elementList{i} = element;
            end
            switch type
                case 'data'
                    metaInformations.setDatasList(elementList);
                case 'event'
                    metaInformations.setEventsList(elementList);
                case 'situation'
                    metaInformations.setSituationsList(elementList);
            end
        end
        
        
        %{
        Function:
        This method looks in all the metaInformation available for the tripSet and determine if there are some common video file description (when called with 'intersection' mode parameter)
        or add all the description (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedVideoDescription - a cell array of string with the name of video description
        %}
        function aggregatedVideoDescription = aggregateVideoFiles(this,tripsMetaInformation,mode)
            % on cherche les scenes videos communes.
            aggregatedVideoDescription = {};
            videoDescriptions = {};
            for i=1:1:length(this.trips)
                tripMeta = tripsMetaInformation{i};
                % on verifie quelles sont les datas qu'on a en commun sur
                % tous les trips
                availableVideos = tripMeta.getVideoFiles();
                if i == 1
                    % pour le premier trip, on dit que tout fait référence
                    videoDescriptions = cell(1,length(availableVideos));
                    for j = 1:1:length(availableVideos)
                        videoDescriptions{j} = availableVideos{j}.getDescription();
                    end
                    aggregatedVideoDescription = videoDescriptions;
                else
                    % on compare la liste des datas de référence à la liste
                    % des datas de chaque trip.
                    videoDescriptions = cell(1,length(availableVideos));
                    for j = 1:1:length(availableVideos)
                        videoDescriptions{j} = availableVideos{j}.getDescription();
                    end
                    
                    switch mode
                        case 'intersection'
                            aggregatedVideoDescription = intersect(videoDescriptions, aggregatedVideoDescription);
                        case 'union'
                            aggregatedVideoDescription = union(videoDescriptions, aggregatedVideoDescription);
                    end
                end
            end
        end
        
        %{
        Function:
        This method looks in all the metaInformation available for the tripSet and determine if there are some common attributes (when called with 'intersection' mode parameter)
        or add all the trip attributes (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedAttributes - a cell array of string with the name list of trip attributes
        %}
        function aggregatedAttributes = aggregateAttributes(this,tripsMetaInformation,mode)
            aggregatedAttributes = {};
            for i=1:1:length(this.trips)
                tripMeta = tripsMetaInformation{i};
                % get the name of all the trip attributes
                availableAttributes = tripMeta.getTripAttributesList();
                if i == 1
                    % first step : all attributes are relevant
                    aggregatedAttributes = availableAttributes;
                else
                    % for all other steps, we have to test if the
                    % attributes are either in the union or in the
                    % intersection
                    switch mode
                        case 'intersection'
                            aggregatedAttributes = intersect(availableAttributes, aggregatedAttributes);
                        case 'union'
                            aggregatedAttributes = union(availableAttributes, aggregatedAttributes);
                    end
                end
            end
        end
        
        %{
        Function:
        This method looks in all the metaInformation available for the tripSet and determine if there are some common participant attributes (when called with 'intersection' mode parameter)
        or add all the trip attributes (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedAttributes - a cell array of string with the name list of trip attributes
        %} 
        function aggregatedParticipantAttributes = aggregateParticipantAttributes(this,tripsMetaInformation,mode)
        aggregatedParticipantAttributes = {};
            for i=1:1:length(this.trips)
                tripMeta = tripsMetaInformation{i};
                theParticipant = tripMeta.getParticipant();
                % get the name of all the trip attributes
                availableParticipantAttributes = theParticipant.getAttributesList();
                if i == 1
                    % first step : all attributes are relevant
                    aggregatedParticipantAttributes = availableParticipantAttributes;
                else
                    % for all other steps, we have to test if the
                    % attributes are either in the union or in the
                    % intersection
                    switch mode
                        case 'intersection'
                            aggregatedParticipantAttributes = intersect(availableParticipantAttributes, aggregatedParticipantAttributes);
                        case 'union'
                            aggregatedParticipantAttributes = union(availableParticipantAttributes, aggregatedParticipantAttributes);
                    end
                end
            end
        end
        
        
        
        %{
        Function:
        this function is a wrapper for the <aggregateInformation> method to work with data.
        This method looks in all the metaInformation available for the tripSet and determine if there are some common <Data>(when called with 'intersection' mode parameter)
        or add all the possible <Data> (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedDatas - a cell array of string with the aggregated <Data> names
        %}
        function aggregatedDatas = aggregateDatas(this,tripsMetaInformation,mode)
            aggregatedDatas = this.aggregateInformation('data',tripsMetaInformation,mode);
        end
        
        %{
        Function:
        this function is a wrapper for the <aggregateInformation> method to work with events.
        This method looks in all the metaInformation available for the tripSet and determine if there are some common <Event>(when called with 'intersection' mode parameter)
        or add all the possible <Event> (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedEvents - a cell array of string with the aggregated <Event> names
        %}
        function aggregatedEvents = aggregateEvents(this,tripsMetaInformation,mode)
            aggregatedEvents = this.aggregateInformation('event',tripsMetaInformation,mode);
        end
        
        %{
        Function:
        this function is a wrapper for the <aggregateInformation> method to work with Situations.
        This method looks in all the metaInformation available for the tripSet and determine if there are some common <Situation>(when called with 'intersection' mode parameter)
        or add all the possible <Situation> (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedSituations - a cell array of string with the aggregated <Situation> names
        %}
        function aggregatedSituations = aggregateSituations(this,tripsMetaInformation,mode)
            aggregatedSituations = this.aggregateInformation('situation',tripsMetaInformation,mode);
        end
        
        %{
        Function:
        This method looks in all the metaInformation available for the tripSet and determine if there are some common tables of <Data> <Event> or <Situation> (when called with 'intersection' mode parameter)
        or add all the tables (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        type - a string used to determine the table type : can be 'data', 'event' or 'situation'
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedInformation - a cell array of Meta objects of the
        appropriate type (MetaData / MetaEvent / MetaSituation.
        %}
        function out = aggregateInformation(this,type,tripsMetaInformation,mode)
            tripNumber = length(this.trips);
            aggregatedInformation = {};
            for i=1:tripNumber
                tripMeta = tripsMetaInformation{i};
                switch type
                    case 'data'
                        availableTables = tripMeta.getDatasList();
                    case 'event'
                        availableTables = tripMeta.getEventsList();
                    case 'situation'
                        availableTables =  tripMeta.getSituationsList();
                end
                hashCellArray = cell(1, length(availableTables));
                for j = 1:1:length(availableTables)
                    hashCellArray{j} = availableTables{j}.hash();
                end
                
                 if i == 1
                    % pour le premier trip, on dit que tout fait référence
                    aggregatedInformation = availableTables;
                    aggregatedInformationHashes = hashCellArray;
                else
                    % on compare la liste des datas de référence à la liste
                    % des datas de chaque trip.
                    switch mode
                        case 'intersection'
                            [aggregatedInformationHashes, intersectIndices, ~] = intersect(aggregatedInformationHashes, hashCellArray);
                            aggregatedInformation = aggregatedInformation(intersectIndices);
                        case 'union'
                            [aggregatedInformationHashes, intersectIndicesLeft, intersectIndicesRight] = union(aggregatedInformationHashes, hashCellArray);
                            aggregatedInformation = [aggregatedInformation(intersectIndicesLeft) ; availableTables(intersectIndicesRight)];
                    end
                end
            end
            out = aggregatedInformation;
        end
        
        %{
        Function:
        This method is a wrapper for the  aggregateTableVariables() function.
        It looks in all the metaInformation available for the tripSet and determine, for each of the table name given in the elementNames parameter
        if there are some common <DataVariable> (when called with 'intersection' mode parameter)
        or add all the variables (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        type - a string used to determine the table type : can be 'data', 'event' or 'situation'
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        elementNames - a 1xN cell array of Data name where to look for variables
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedDataVariables - a 1xN cell array of cell array of strings with the aggregated data variable names
        %}
        
        function aggregatedDataVariables = aggregateDataVariables(this,tripsMetaInformation,dataNames,mode)
            aggregatedDataVariables = this.aggregateTableVariables('data',tripsMetaInformation,dataNames,mode);
        end
        
        %{
        Function:
        This method is a wrapper for the  aggregateTableVariables() function.
        It looks in all the metaInformation available for the tripSet and determine, for each of the table name given in the elementNames parameter
        if there are some common <EventVariable> (when called with 'intersection' mode parameter)
        or add all the variables (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        type - a string used to determine the table type : can be 'data', 'event' or 'situation'
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        elementNames - a 1xN cell array of Event name where to look for variables
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedEventVariables - a 1xN cell array of cell array of strings with the aggregated event variable names
        %}
        function aggregatedEventVariables = aggregateEventVariables(this,tripsMetaInformation,dataNames,mode)
            aggregatedEventVariables = this.aggregateTableVariables('event',tripsMetaInformation,dataNames,mode);
        end
        
        %{
        Function:
        This method is a wrapper for the  aggregateTableVariables() function.
        It looks in all the metaInformation available for the tripSet and determine, for each of the table name given in the elementNames parameter
        if there are some common <SituationVariable> (when called with 'intersection' mode parameter)
        or add all the variables (when called with the 'union' mode parameter)
        
        Arguments:
        this - The object on which the function is called, optionnal.
        type - a string used to determine the table type : can be 'data', 'event' or 'situation'
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        elementNames - a 1xN cell array of Situations name where to look for variables
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedSituationVariables - a 1xN cell array of cell array of strings with the aggregated situation variable names
        %}
        function aggregatedSituationVariables = aggregateSituationVariables(this,tripsMetaInformation,dataNames,mode)
            aggregatedSituationVariables = this.aggregateTableVariables('situation',tripsMetaInformation,dataNames,mode);
        end
        
        %{
        Function:
        This method looks in all the metaInformation available for the tripSet and determine, for each of the table name given in the elementNames parameter
        if there are some common variables  <DataVariable> <EventVariable> or <SituationVariable> (when called with 'intersection' mode parameter)
        or add all the variables (when called with the 'union' mode parameter)
        This method should not be used directly. It is better to use one of the 3 wrappers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        type - a string used to determine the table type : can be 'data', 'event' or 'situation'
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        elementNames - a 1xN cell array of elements name where to look for variables
        mode - a String describing the functionin of the method : can be 'intersection' or 'union' according to the expected result
        
        Returns:
        aggregatedTableVariables - a 1xN cell array of cell array of strings with the aggregated table names
        %}
        function aggregatedTableVariables = aggregateTableVariables(this,type,tripsMetaInformation,elements,mode)
            aggregatedTableVariables = cell(1, length(elements));
            for i=1:1:length(elements)
                aggregatedVariable = {};
                availableTableVariables = {};
                for j=1:1:length(this.trips)
                    tripMeta = tripsMetaInformation{j};
                    % on verifie quelles sont les datas qu'on a en commun sur
                    % tous les trips
                    switch type
                        case 'data'
                            if tripMeta.existData(elements{i}.getName())
                                %availableTableVariablesNames =  tripMeta.getDataVariablesNamesList(elementNames{i});
                                availableTableVariables = tripMeta.getMetaData(elements{i}.getName()).getVariables();
                            end
                        case 'event'
                            if tripMeta.existEvent(elements{i}.getName())
                                %availableTableVariablesNames =  tripMeta.getEventVariablesNamesList(elementNames{i});
                                availableTableVariables = tripMeta.getMetaEvent(elements{i}.getName()).getVariables();
                            end
                        case 'situation'
                            if tripMeta.existSituation(elements{i}.getName())
                                %availableTableVariablesNames =  tripMeta.getSituationVariablesNamesList(elementNames{i});
                                availableTableVariables = tripMeta.getMetaSituation(elements{i}.getName()).getVariables();
                            end
                    end
                    hashCellArray = cell(1, length(availableTableVariables));
                    for k = 1:1:length(availableTableVariables)
                        hashCellArray{k} = availableTableVariables{k}.hash();
                    end
                    if j == 1
                        % pour le premier trip, on dit que tout fait
                        % référence
                        %aggregatedVariableName = availableTableVariablesNames;
                        aggregatedVariableHashes = hashCellArray;
                        aggregatedVariable = availableTableVariables;
                    else
                        switch mode
                            case 'intersection'
                            [aggregatedVariableHashes, intersectIndices, ~] = intersect(aggregatedVariableHashes, hashCellArray);
                            aggregatedVariable = aggregatedVariable(intersectIndices);
                        case 'union'
                            [aggregatedVariableHashes, intersectIndicesLeft, intersectIndicesRight] = union(aggregatedVariableHashes, hashCellArray);
                            leftPart = aggregatedVariable(intersectIndicesLeft);
                            rightPart = availableTableVariables(intersectIndicesRight);
                            aggregatedVariable = [leftPart(:) ; rightPart(:)];
                        end
                    end
                end
                % pour ce DATA, on a les variables de tous les trips
                aggregatedTableVariables{i} = aggregatedVariable;
            end
            % on a parcouru toutes les variables de toutes les data
        end
        
        %{
        Function:
        This method is a wrapper for the checkIsBaseElement method. It looks in all the metaInformation available for the tripSet and determine, for each of the Data Names given in the elementNames parameter
        if the different <Data> are declared as 'Base' in all the trips of the tripSet
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        elementNames - a 1xN cell array of Data name where to check for isBase status
        
        Returns:
        isBaseDataList - a 1xN cell array of cell array of boolean with the value of the isBase attribute
        %}
        function isBaseDataList = checkIsBaseData(this,tripsMetaInformation,elementsNames)
            isBaseDataList = this.checkIsBaseElement('data',tripsMetaInformation,elementsNames);
        end       
        
        %{
        Function:
        This method is a wrapper for the checkIsBaseElement method. It looks in all the metaInformation available for the tripSet and determine, for each of the Event Names given in the elementNames parameter
        if the different <Event> are declared as 'Base' in all the trips of the tripSet
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        elementNames - a 1xN cell array of Event name where to check for isBase status
        
        Returns:
        isBaseEventList - a 1xN cell array of cell array of boolean with the value of the isBase attribute
        %}
        function isBaseEventList = checkIsBaseEvent(this,tripsMetaInformation,elementsNames)
            isBaseEventList = this.checkIsBaseElement('event',tripsMetaInformation,elementsNames);
        end
        
        %{
        Function:
        This method is a wrapper for the checkIsBaseElement method. It looks in all the metaInformation available for the tripSet and determine, for each of the Situation Names given in the elementNames parameter
        if the different <Situation> are declared as 'Base' in all the trips of the tripSet
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        elementNames - a 1xN cell array of Situations name where to check for isBase status
        
        Returns:
        isBaseSituationList - a 1xN cell array of cell array of boolean with the value of the isBase attribute
        %}
        function isBaseSituationList = checkIsBaseSituation(this,tripsMetaInformation,elementsNames)
            isBaseSituationList = this.checkIsBaseElement('situation',tripsMetaInformation,elementsNames);
        end
        
        %{
        Function:
        This method looks in all the metaInformation available for the tripSet and determine, for each of the Names given in the elementNames parameter
        if the <Data> <Event> or <Situation> is declared as Based in all the trips of the tripSet
        This method should not be used directly. It is better to use one of the 3 wrappers.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        type - a string used to determine the table type : can be 'data', 'event' or 'situation'
        tripsMetaInformation - the cell array of <MetaInformation> for each trip available in the tripSet
        elementNames - a 1xN cell array of elements name where to check for isBase status
        
        Returns:
        isBaseElementList - a 1xN cell array of cell array of boolean with the value of the isBase attribute
        %}
        function isBaseElementList = checkIsBaseElement(this,type,tripsMetaInformation,elementNames)
            elementNumber = length(elementNames);
            isBaseElementList = cell(1,elementNumber);
            for i=1:elementNumber
                isBaseElementList{i} = true;
            end
            
            for i=1:1:length(this.trips)
                tripMeta = tripsMetaInformation{i};
                switch type
                    case 'data'
                        availableElementNamesList = tripMeta.getDatasNamesList();
                        availableElements = tripMeta.getDatasList();
                    case 'event'
                        availableElementNamesList = tripMeta.getEventsNamesList();
                        availableElements = tripMeta.getEventsList();
                    case 'situation'
                        availableElementNamesList = tripMeta.getSituationsNamesList();
                        availableElements = tripMeta.getSituationsList();
                end
                for j = 1:1:length(availableElementNamesList)
                    indice = strcmp(availableElementNamesList{j},elementNames);
                    if any(indice)
                        % on vient de trouver que la data (j) faisait partie des data communes
                        % du coup il faut mettre à jour le datacommune
                        % (indice) avec la valeur de base
                        isBaseElementList{indice} = isBaseElementList{indice} && availableElements{j}.isBase();
                    end
                end
            end
        end
        
        %{
        Function:
        This function use the <MetaInformations> of the trips available in the tripSet to calculate the
        a global <MetaInformations> object that describes the whole tripSet.
        This <MetaInformations> object can be the intersection of the tripSet <MetaInformations> object, this showing only what exists in all trips,
        or it can be the union of the tripSet <MetaInformations> object, this showing all possible information that exists in the trips.
        At this end, it modify one of the to attribute of the object, depending on the mode parameter
        
        The process is the following :
        - get all trip individual <MetaInformations>
        - aggregation of trip attributes
        - aggregation of video files
        - aggregation of Data / check if they are base / aggregation of dataVariables
        - aggregation of Event / check if they are base / aggregation of eventVariables
        - aggregation of Situations / check if they are base / aggregation of situationVariables
        - use of the results of the aggregations to create an adequate global <MetaInformations> object for the tripSet
        - update class properties
        
        Arguments:
        this - The object on which the function is called, optionnal.
        mode - The string that indicate the expected output
        
        %}
        function calculateTripsProperties(this,mode)
            tripNumber = length(this.trips);
            tripsMetaInformation = cell(tripNumber,1);
            for i=1:tripNumber
                tripsMetaInformation{i} = this.trips{i}.getMetaInformations();
            end
            
            commonParticipantAttributes = this.aggregateParticipantAttributes(tripsMetaInformation,mode);
            commonAttributesNames = this.aggregateAttributes(tripsMetaInformation,mode);
            commonVideoDescription = this.aggregateVideoFiles(tripsMetaInformation,mode);
            
            commonDatas = this.aggregateDatas(tripsMetaInformation,mode);
            % Les datas peuvent faire partie de la base, ou non. Pour
            % chaque trip, on va regarder si les data sont base, et on va
            % faire un ET logique : a la fin, une data sera base si elle
            % est base pour tous les trips.
            isBaseDataList = this.checkIsBaseData(tripsMetaInformation,commonDatas);
            % a partir des DATAS communes, on va vérifier que chaque
            % trip a bien toutes les variables communes.
            commonDataVariables = this.aggregateDataVariables(tripsMetaInformation,commonDatas,mode);
            
            commonEvents = this.aggregateEvents(tripsMetaInformation,mode);
            isBaseEventList = this.checkIsBaseEvent(tripsMetaInformation,commonEvents);
            commonEventVariables = this.aggregateEventVariables(tripsMetaInformation,commonEvents,mode);
            
            commonSituations = this.aggregateSituations(tripsMetaInformation,mode);
            isBaseSituationList = this.checkIsBaseSituation(tripsMetaInformation,commonSituations);
            commonSituationVariables = this.aggregateSituationVariables(tripsMetaInformation,commonSituations,mode);
            
            %construction de la structure pour stockage
            metaInformations = fr.lescot.bind.data.MetaInformations();
            metaInformations = this.buildMetaDataInformation(metaInformations,commonDatas,isBaseDataList,commonDataVariables);
            metaInformations = this.buildMetaEventInformation(metaInformations,commonEvents,isBaseEventList,commonEventVariables);
            metaInformations = this.buildMetaSituationInformation(metaInformations,commonSituations,isBaseSituationList,commonSituationVariables);
            
            %we forge new video description
            videoDescriptions = cell(1, length(commonVideoDescription));
            for i=1:1:length(commonVideoDescription)
                videoDescription = fr.lescot.bind.data.MetaVideoFile('toto',0,char(commonVideoDescription{i}));
                videoDescriptions{i} = videoDescription;
            end
            metaInformations.setVideoFiles(videoDescriptions);
            
            %we forge new attributes
            attributes = cell(1, length(commonAttributesNames));
            for i=1:1:length(commonAttributesNames)
                attribute =  commonAttributesNames{i};
                attributes{i} = attribute;
            end
            metaInformations.setTripAttributesList(attributes);
            
            %we forge new participant attributes
            commonParticipant = fr.lescot.bind.data.MetaParticipant();
            for i=1:1:length(commonParticipantAttributes)
               commonParticipant.setAttribute(commonParticipantAttributes{i},'dummy');
            end
            metaInformations.setParticipant(commonParticipant);
            
            switch mode
                case 'intersection'
                    this.tripsCommonProperties = metaInformations;
                case 'union'
                    this.tripPossibleProperties = metaInformations;
            end
        end
    end
    
end

