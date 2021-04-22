%{
Class:

This class implements the abstract methods of <kernel.Trip> as a set of
data stored in an SQLite database.

Database access is provide through sqlite4m, a dll that provides matlab /
sqlite interface. See http://developer.berlios.de/projects/sqlite4m/ for
more about this library.

The only pre requisite for most of this class to work properly is for each
table of the database to get a 'timecode' column. Situation tables require
two columns : a 'startTimecode' and an 'endTimecode'.

%}
classdef SQLiteTrip < fr.lescot.bind.kernel.Trip
    
    properties (Access = private)
        %{
        Property:
        The variable containing the database connection identifier.
        
        %}
        connection;
        
        %{
        Property:
        The path of the db file.
        
        %}
        pathToFile;
        
        %{
        Property:
        The single quote symbol
        %}
        SQ = '''';
    end
    
    methods
        
        %{
        Function:
        This contructor builds a SQLiteTrip object linked to a sqlite
        file.
        
        Arguments:
        dataBasePath - The path to the file containning the sqlite db
        with all the data for this trip - if the *create* argument is set to true, it can
        also be an empty path.
        period - The initial value for the period of the timer embedded in the trip.
        create - If this boolean's value is true, then if the file does
        not exist, the constructor will attempt to create a new database
        containing all the necessary tables to be opened as a new trip,
        and will return a trip connected to this empty database. If the
        boolean is false and the file does not exist, an exception will be
        raised.
        
        
        Throws:
        FILE_EXCEPTION - If the connection to the database
        file fails but the database is here or if the database is not found
        and *create* is set to false
       
        Returns:
        this - a new SQLiteTrip object.
        %}
        function this = SQLiteTrip(dataBasePath, period, create)
            import fr.lescot.bind.exceptions.ExceptionIds;
            this@fr.lescot.bind.kernel.Trip(period);
            if(exist(dataBasePath, 'file') && ~exist(dataBasePath, 'dir'));
                % before making the connection, we ensure that the db is
                % not a 0 byte file
                fileListing = dir(dataBasePath);
                fileSize = fileListing.bytes;
                if fileSize == 0
                    throw(MException(ExceptionIds.FILE_EXCEPTION.getId(), 'The file passed to the constructor is an empty file. Cannot instanciate trip.'));
                else
                    this.connection = sqlite4m(0, 'open', dataBasePath);
                    %To ensure an exception is thrown if the file is not a
                    %valid db
                    try
                        sqlite4m(this.connection, 'SELECT * FROM sqlite_master');
                    catch ME
                        throw(MException(ExceptionIds.FILE_EXCEPTION.getId(), 'The file passed to the constructor is not a valid SQLite database'));
                    end
                    
                    %%%%%%%%%%%%%%%% File format update management code %%%%%%%%%%%%%%%%
                    import fr.lescot.bind.utils.StringUtils;
                    import fr.lescot.bind.data.Record;
                    %If the file is a valid DB, we check if it's a current
                    %spec file (with units and comments fot the variables),
                    %or a previous version. If it's a previous version, we
                    %update the file and issue a warning message.
                    columnsListRecord = Record(sqlite4m(this.connection,  'PRAGMA table_info(MetaDataVariables)'));
                    columnsList = columnsListRecord.getVariableValues('name');
                    if ~ StringUtils.checkIfStringIsInArray(columnsList, 'unit')%Then it's an older version and we update it
                        warning('This file corresponds to obsoletes specifications of the SQLite trip file format, and will be updated. Your data won''t be changed, only the structure will, and this message won''t appear again for this trip.');
                        sqlite4m(this.connection, 'SAVEPOINT SQLiteTrip');
                        try
                            sqlite4m(this.connection,'ALTER TABLE MetaDataVariables ADD COLUMN "unit" TEXT NULL');
                            sqlite4m(this.connection,'ALTER TABLE MetaDataVariables ADD COLUMN "comments" TEXT NULL');
                            sqlite4m(this.connection,'ALTER TABLE MetaSituationVariables ADD COLUMN "unit" TEXT NULL');
                            sqlite4m(this.connection,'ALTER TABLE MetaSituationVariables ADD COLUMN "comments" TEXT NULL');
                            sqlite4m(this.connection,'ALTER TABLE MetaEventVariables ADD COLUMN "unit" TEXT NULL');
                            sqlite4m(this.connection,'ALTER TABLE MetaEventVariables ADD COLUMN "comments" TEXT NULL');
                        catch ME
                            sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT SQLiteTrip');
                            rethrow(ME)
                        end
                        sqlite4m(this.connection, 'RELEASE SAVEPOINT SQLiteTrip');
                    end
                    %%%%%%%%%%%%%%%% End of file format update management code %%%%%%%%%%%%%%%%
                end
            else
                if create
                    this.connection = sqlite4m(0, 'open', dataBasePath);
                    %The tables that contains the informations about the
                    %trip context
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaTripDatas" (  "key" TEXT NOT NULL ,  "value" TEXT NOT NULL ,  PRIMARY KEY ("key") )');
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaParticipantDatas" (  "key" TEXT NOT NULL ,  "value" TEXT NULL ,  PRIMARY KEY ("key") )');
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaTripVideos" (  "filename" TEXT NOT NULL ,  "offset" DOUBLE NOT NULL DEFAULT 0, "description" TEXT, PRIMARY KEY ("filename") )');
                    %The tables that contains the informations about the
                    %temporal datas ans its subdivisions
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaDatas" (  "name" TEXT NOT NULL ,  "type" TEXT NOT NULL ,  "frequency" INT NOT NULL DEFAULT -1 ,  "comments" TEXT NULL ,  "isBase" BOOL NOT NULL DEFAULT 0,  PRIMARY KEY ("name") )');
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaDataVariables" (  "data_name" TEXT NOT NULL ,  "name" TEXT NOT NULL ,  "type" TEXT NOT NULL DEFAULT "REAL", "unit" TEXT NULL, "comments" TEXT NULL, PRIMARY KEY ("name", "data_name") )');
                    %The tables that contains the informations about the
                    %instantaneous events
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaEvents" (  "name" TEXT NOT NULL ,  "comments" TEXT NULL ,  "isBase" BOOL NOT NULL DEFAULT 1,  PRIMARY KEY ("name") )');
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaEventVariables" (  "event_name" TEXT NOT NULL ,  "name" TEXT NOT NULL ,  "type" TEXT NOT NULL DEFAULT "REAL", "unit" TEXT NULL, "comments" TEXT NULL, PRIMARY KEY ("name", "event_name") )');
                    %The tables that contains the informations about the
                    %situations (events with a start and end time).
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaSituations" (  "name" TEXT NOT NULL ,  "comments" TEXT NULL ,  "isBase" BOOL NOT NULL DEFAULT 1,  PRIMARY KEY ("name") )');
                    sqlite4m(this.connection, 'CREATE  TABLE "MetaSituationVariables" (  "situation_name" TEXT NOT NULL ,  "name" TEXT NOT NULL ,  "type" TEXT NOT NULL DEFAULT "REAL", "unit" TEXT NULL, "comments" TEXT NULL, PRIMARY KEY ("name", "situation_name") )');
                else
                    throw(MException(ExceptionIds.FILE_EXCEPTION.getId(), 'The file passed to the constructor was not found, and the create argument is set to false, so we were unable to instanciate the SQLiteTrip'));
                end
            end
            % if the trip does not permit the calculation of "max time",
            % which is needed for the timer, it will not be possible to
            % instanciate the trip, BUT it is required to close the
            % sqlite4m connection to free sqlite4m handlers.
            try
                maxTime = this.getMaxTimeInDatas();
            catch ME
                sqlite4m(this.connection,'close');
                throw(MException(ExceptionIds.FILE_EXCEPTION.getId(), 'Impossible to obtain "max time" from data : impossible to instanciate the SQLiteTrip. Check data and metadata structure and verify it is compliant with the BIND specifications. DB connection was closed.'));
            end
            this.setMaxTimeInSeconds(maxTime);
            this.pathToFile = dataBasePath;
        end
        
        %{
        Function:
        Returns the name of the underlying sqlite file. *Warning : this function is not part of <kernel.Trip> interface
        and should not be used, except on some very special case where the code have to be implementation dependant.*
        
        Arguments:
        this - The object on which the method is called. Optionnal.
        
        Returns:
        out - A string.
        %}
        function out = getTripName(this)
            [~,out,~] = fileparts(getTripPath(this));
        end
        
        %{
        Function:
        Returns the path of the underlying sqlite file. *Warning : this function is not part of <kernel.Trip> interface
        and should not be used, except on some very special case where the code have to be implementation dependant.*
        
        Arguments:
        this - The object on which the method is called. Optionnal.
        
        Returns:
        out - A string.
        %}
        function out = getTripPath(this)
            out = this.pathToFile;
        end
        
        %{
        Function: removeAllDataOccurences()
        %}
        function removeAllDataOccurences(this, dataName)
            this.removeTableContent(['data_' dataName]);
        end
        
        %{
        Function: removeAllEventOccurences()
        %}
        function removeAllEventOccurences(this, eventName)
            this.removeTableContent(['event_' eventName]);
        end
        
        %{
        Function: removeAllSituationOccurences()
        %}
        function removeAllSituationOccurences(this, situationName)
            this.removeTableContent(['situation_' situationName]);
        end
        
        %{
        Function: getAllDataOccurences()
        %}
        function out = getAllDataOccurences(this, dataName)
            out = this.getTableContent(['data_' dataName]);
        end
        
        %{
        Function: getAllEventOccurences()
        %}
        function out = getAllEventOccurences(this, eventName)
            out = this.getTableContent(['event_' eventName]);
        end
        
        %{
        Function: getAllSituationOccurences()
        %}
        function out = getAllSituationOccurences(this, situationName)
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT * FROM "situation_' situationName '" ORDER BY "startTimecode" ASC, "endTimecode" ASC']));
        end
        
        %{
        Function: getDataOccurenceNearTime()
        %}
        function out = getDataOccurenceNearTime(this, dataName, time)
            out = this.getLineNearTime(['data_' dataName], time);
        end
        
        %{
        Function: getEventOccurenceNearTime
        %}
        function out = getEventOccurenceNearTime(this, eventName, time)
            out = this.getLineNearTime(['event_' eventName], time);
        end
        
        %{
        Function: getDataOccurenceAtTime()
        %}
        function out = getDataOccurenceAtTime(this, dataName, time)
            out = this.getLineAtTime(['data_' dataName], time);
        end
        
        %{
        Function: getEventOccurenceAtTime()
        %}
        function out = getEventOccurenceAtTime(this, eventName, time)
            out = this.getLineAtTime(['event_' eventName], time);
        end
        
        %{
        Function: getSituationOccurenceAtTime()
        %}
        function out = getSituationOccurenceAtTime(this, situationName, startTime, endTime)
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT * FROM "situation_' situationName '" WHERE "startTimecode" = ' this.SQ sprintf('%.12f', startTime) this.SQ ' AND endTimecode = ' this.SQ sprintf('%.12f', endTime) this.SQ]));
        end
        
        %{
        Function: getSituationOccurencesAroundTime()
        %}
        function out = getSituationOccurencesAroundTime(this, situationName, timecode)
            request = ['SELECT * FROM "situation_' situationName '" WHERE "startTimecode" <= ' this.SQ sprintf('%.12f', timecode) this.SQ ' AND ' this.SQ sprintf('%.12f', timecode) this.SQ ' <= "endTimecode" ORDER BY "startTimecode" ASC, "endTimecode" ASC'];
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
        end
        
        %{
        Function: getDataOccurencesInTimeInterval()
        %}
        function out = getDataOccurencesInTimeInterval(this, dataName, startTime, endTime)
            out = this.getLinesInTimeInterval(['data_' dataName], startTime, endTime);
        end
        
        %{
        Function: getEventOccurencesInTimeInterval()
        %}
        function out = getEventOccurencesInTimeInterval(this, eventName, startTime, endTime)
            out = this.getLinesInTimeInterval(['event_' eventName], startTime, endTime);
        end
        
        %{
        Function: getSituationOccurencesInTimeInterval()
        %}
        function out = getSituationOccurencesInTimeInterval(this, situationName, startTime, endTime)
            request = ['SELECT * FROM "situation_' char(situationName) '" WHERE ' this.SQ sprintf('%.12f', startTime) this.SQ ' <= "startTimecode" AND ' this.SQ sprintf('%.12f', endTime) this.SQ ' >= "endTimecode" ORDER BY "startTimecode" ASC, "endTimecode" ASC'];
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
        end
        
        %{
        Function: getDataVariableMinimum()
        %}
        function out = getDataVariableMinimum(this, dataName, variableName)
            out = this.getColumnMinimum(['data_' dataName], variableName);
        end
        
        %{
        Function: getEventVariableMinimum()
        %}
        function out = getEventVariableMinimum(this, eventName, variableName)
            out = this.getColumnMinimum(['event_' eventName], variableName);
        end
        
        %{
        Function: getSituationVariableMinimum()
        %}
        function out = getSituationVariableMinimum(this, situationName, variableName)
            out = this.getColumnMinimum(['situation_' situationName], variableName);
        end
        
        %{
        Function: getDataVariableMaximum()
        %}
        function out = getDataVariableMaximum(this, dataName, variableName)
            out = this.getColumnMaximum(['data_' dataName], variableName);
        end
        
        %{
        Function: getEventVariableMaximum()
        %}
        function out = getEventVariableMaximum(this, eventName, variableName)
            out = this.getColumnMaximum(['event_' eventName], variableName);
        end
        
        %{
        Function: getSituationVariableMaximum()
        %}
        function out = getSituationVariableMaximum(this, situationName, variableName)
            out = this.getColumnMaximum(['situation_' situationName], variableName);
        end
        
        %{
        Function: getDataVariableOccurencesInTimeInterval()
        %}
        function out = getDataVariableOccurencesInTimeInterval(this, dataName, variableName, startTime, endTime)
            out = this.getColumnInTimeInterval(['data_' dataName], variableName, startTime, endTime);
        end
        
        %{
        Function: getEventVariableOccurencesInTimeInterval()
        %}
        function out = getEventVariableOccurencesInTimeInterval(this, eventName, variableName, startTime, endTime)
            out = this.getColumnInTimeInterval(['event_' eventName], variableName, startTime, endTime);
        end
        
        %{
        Function: getSituationVariableOccurencesInTimeInterval()
        %}
        function out = getSituationVariableOccurencesInTimeInterval(this, situationName, variableName, startTime, endTime)
            request = ['SELECT "' variableName '", "startTimecode", "endTimecode" FROM "situation_' situationName '" WHERE ' this.SQ sprintf('%.12f', startTime) this.SQ ' <= "startTimecode" AND ' this.SQ sprintf('%.12f', endTime) this.SQ ' >= "endTimecode" ORDER BY "startTimecode" ASC, "endTimecode ASC"'];
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
        end
        
        %{
        Function: getMetaInformations()
        
        In this implementation, the path to the videos which is returned is
        the concatenation of the db path and the relative path passed as
        argument when using <addVideoFiles>.
        %}
        function out = getMetaInformations(this)
            import fr.lescot.bind.data.*;
            metaInformations = MetaInformations();
            
            %Generates the list of datas and their properties.
            datasFromSQL = Record(sqlite4m(this.connection, 'SELECT * FROM "MetaDatas"'));
            datasList = cell(length(datasFromSQL.getVariableValues('name')),1);
            
            names = datasFromSQL.getVariableValues('name');
            types = datasFromSQL.getVariableValues('type');
            frequencies = datasFromSQL.getVariableValues('frequency');
            comments = datasFromSQL.getVariableValues('comments');
            isBaseArray = datasFromSQL.getVariableValues('isBase');
            
            variablesFromSQLStatement = sqlite4m(this.connection, 'prepare', 'SELECT * FROM "MetaDataVariables" WHERE "Data_Name" = ?1');
            for indiceData = 1:1:length(names)
                
                metadata = MetaData();
                metadata.setName(names{indiceData});
                metadata.setType(types{indiceData});
                metadata.setFrequency(frequencies{indiceData});
                metadata.setComments(comments{indiceData});
                metadata.setIsBase(isBaseArray{indiceData});
                
                variablesFromSQL = Record(sqlite4m(variablesFromSQLStatement, {metadata.getName()}));
                variablesList = {};
                
                variableNames = variablesFromSQL.getVariableValues('name');
                variableTypes = variablesFromSQL.getVariableValues('type');
                variableUnits = variablesFromSQL.getVariableValues('unit');
                variableComments = variablesFromSQL.getVariableValues('comments');
                
                for indiceVariables = 1:1:length(variableNames)
                    %We ignore the timecode variables when rebuilding the
                    %meta infos. They are always automatically added to the
                    %MetaBase object.
                    if ~any(strcmpi(variableNames{indiceVariables}, fr.lescot.bind.kernel.Trip.RESERVED_VARIABLE_NAMES))
                        variable = MetaDataVariable();
                        variable.setName(variableNames{indiceVariables});
                        variable.setType(variableTypes{indiceVariables});
                        variable.setUnit(variableUnits{indiceVariables});
                        variable.setComments(variableComments{indiceVariables});
                        variablesList{end + 1} = variable;
                    end
                end
                metadata.setVariables(variablesList);
                datasList{indiceData} = metadata;
            end
            sqlite4m(variablesFromSQLStatement, 'finalize');
            metaInformations.setDatasList(datasList);
            
            %Generates the list of events and their properties.
            eventsFromSQL = Record(sqlite4m(this.connection, 'SELECT * FROM "MetaEvents"'));
            eventsList = cell(length(eventsFromSQL.getVariableValues('name')),1);
            
            names = eventsFromSQL.getVariableValues('name');
            comments = eventsFromSQL.getVariableValues('comments');
            isBaseArray = eventsFromSQL.getVariableValues('isBase');
            variablesFromSQLStatement = sqlite4m(this.connection, 'prepare', 'SELECT * FROM "MetaEventVariables" WHERE "event_name" = ?1');
            for indiceEvent = 1:1:length(names)
                
                metaEvent = MetaEvent();
                metaEvent.setName(names{indiceEvent});
                metaEvent.setComments(comments{indiceEvent});
                metaEvent.setIsBase(isBaseArray{indiceEvent});
                
                variablesFromSQL = Record(sqlite4m(variablesFromSQLStatement, {metaEvent.getName()}));
                variablesList = {};
                
                variableNames = variablesFromSQL.getVariableValues('name');
                variableTypes = variablesFromSQL.getVariableValues('type');
                variableUnits =  variablesFromSQL.getVariableValues('unit');
                variableComments =  variablesFromSQL.getVariableValues('comments');
                
                for indiceVariables = 1:1:length(variableNames)
                    %We ignore the timecode variables when rebuilding the
                    %meta infos. They are always automatically added to the
                    %MetaBase object.
                    if ~any(strcmpi(variableNames{indiceVariables}, fr.lescot.bind.kernel.Trip.RESERVED_VARIABLE_NAMES))
                        variable = MetaEventVariable();
                        variable.setName(variableNames{indiceVariables});
                        variable.setType(variableTypes{indiceVariables});
                        variable.setUnit(variableUnits{indiceVariables});
                        variable.setComments(variableComments{indiceVariables});
                        variablesList{end + 1} = variable;
                    end
                end
                metaEvent.setVariables(variablesList);
                eventsList{indiceEvent} = metaEvent;
            end
            sqlite4m(variablesFromSQLStatement, 'finalize');
            metaInformations.setEventsList(eventsList);
            %Generates the list of situations and their properties.
            situationsFromSQL = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT * FROM "MetaSituations"'));
            situationsList = cell(length(situationsFromSQL.getVariableValues('name')),1);
            
            names = situationsFromSQL.getVariableValues('name');
            comments = situationsFromSQL.getVariableValues('comments');
            isBaseArray = situationsFromSQL.getVariableValues('isBase');
            variablesFromSQLStatement = sqlite4m(this.connection, 'prepare', 'SELECT * FROM "MetaSituationVariables" WHERE "situation_name" = ?1');
            for indiceSituation = 1:1:length(names)
                
                metaSituation = fr.lescot.bind.data.MetaSituation();
                metaSituation.setName(names{indiceSituation});
                metaSituation.setComments(comments{indiceSituation});
                metaSituation.setIsBase(isBaseArray{indiceSituation});
                
                variablesFromSQL = Record(sqlite4m(variablesFromSQLStatement, {metaSituation.getName()}));
                variablesList = {};
                
                variableNames = variablesFromSQL.getVariableValues('name');
                variableTypes = variablesFromSQL.getVariableValues('type');
                variableUnits = variablesFromSQL.getVariableValues('unit');
                variableComments = variablesFromSQL.getVariableValues('comments');
                
                for indiceVariables = 1:1:length(variableNames)
                    %We ignore the timecode variables when rebuilding the
                    %meta infos. They are always automatically added to the
                    %MetaBase object.
                    if ~any(strcmpi(variableNames{indiceVariables}, fr.lescot.bind.kernel.Trip.RESERVED_VARIABLE_NAMES))
                        variable = MetaSituationVariable();
                        variable.setName(variableNames{indiceVariables});
                        variable.setType(variableTypes{indiceVariables});
                        variable.setUnit(variableUnits{indiceVariables});
                        variable.setComments(variableComments{indiceVariables});
                        variablesList{end + 1} = variable;
                    end
                end
                metaSituation.setVariables(variablesList);
                situationsList{indiceSituation} = metaSituation;
            end
            sqlite4m(variablesFromSQLStatement, 'finalize');
            metaInformations.setSituationsList(situationsList);
            %Generates the datas about the participant;
            participant = MetaParticipant();
            participantRecords = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT * FROM "MetaParticipantDatas"'));
            keys = participantRecords.getVariableValues('key');
            values = participantRecords.getVariableValues('value');
            for i = 1:1:length(keys)
                participant.setAttribute(keys{i}, values{i});
            end
            metaInformations.setParticipant(participant);
            %Generates the datas about the videos
            videoRecords = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT * FROM "MetaTripVideos"'));
            descriptions = videoRecords.getVariableValues('description');
            filenames = videoRecords.getVariableValues('filename');
            offsets = videoRecords.getVariableValues('offset');
            files = cell(1, length(filenames));
            for i = 1:1:length(filenames)
                %When the MetaVideoFile is generated, we append the path to
                %the db file (minus the filename itself) to the relative path stored in the database.
                videoFile = MetaVideoFile([fileparts(this.pathToFile) filesep filenames{i}],  offsets{i}, descriptions{i});
                files{i} = videoFile;
            end
            metaInformations.setVideoFiles(files);
            %Generates the datas about the attributes of the trip
            request = 'SELECT * FROM "MetaTripDatas"';
            attributesRecord = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            if ~attributesRecord.isEmpty()
                values = attributesRecord.getVariableValues('key');
            end
            metaInformations.setTripAttributesList(values);
            %Return
            out = metaInformations;
        end
        
        %{
        Function: setDataVariableAtTime()
        %}
        function setDataVariableAtTime(this, dataName, variableName, time, value)
            this.checkIfIsBaseData(dataName);
            type = this.getDataVariableType(dataName, variableName);
            value = this.checkInputTypeAndConvert(value, type);
            this.setColumnValueAtTime(['data_' dataName], variableName, time, value);
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: setDataVariableOccurencesInTimeInterval()
        %}
        function out = setDataVariableOccurencesInTimeInterval(this, dataName, variableName, startTime, endTime, values)
            out = this.setColumnInTimeInterval(['data_' dataName], variableName, startTime, endTime, values);
        end
        
        %{
        Function: setEventVariableAtTime()
        %}
        function setEventVariableAtTime(this, eventName, variableName, time, value)
            this.checkIfIsBaseEvent(eventName);
            type = this.getEventVariableType(eventName, variableName);
            value = this.checkInputTypeAndConvert(value, type);
            this.setColumnValueAtTime(['event_' eventName], variableName, time, value);
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('EVENT_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: setSituationVariableAtTime()
        %}
        function setSituationVariableAtTime(this, situationName, variableName, startTime, endTime, value)
            import fr.lescot.bind.exceptions.ExceptionIds;
            this.checkIfIsBaseSituation(situationName);
            if startTime >= endTime
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(),'endTimecode must be superior and different from startTimecode. A situation with startTimecode == endTimecode is an event.'));
            end
            type = this.getSituationVariableType(situationName, variableName);
            value = this.checkInputTypeAndConvert(value, type);
            sqlite4m(this.connection, 'SAVEPOINT setSituationVariableAtTime');
            try
                %We try to insert the timecodes / value triplet. If the
                %timecode pair already exist, we perform an update, else it is
                %an insert. This test is to make up for the lack of INSERT
                %OR UPDATE in SQLite.
                existTimecodes = ~fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT "startTimecode" FROM "situation_' char(situationName) '" WHERE "startTimecode" = ' this.SQ sprintf('%.12f', startTime) this.SQ ' AND "endTimecode" = ' this.SQ sprintf('%.12f', endTime) this.SQ])).isEmpty();
                if existTimecodes
                    sqlite4m(this.connection, ['UPDATE "situation_' situationName '" SET "' variableName '" = ' this.SQ num2str(value) this.SQ ' WHERE "startTimecode" = ' this.SQ sprintf('%.12f', startTime) this.SQ ' AND "endTimecode" = ' this.SQ sprintf('%.12f', endTime) this.SQ '']);
                else
                    sqlite4m(this.connection, ['INSERT INTO "situation_' situationName '"("startTimecode", "endTimeCode", "' variableName '") VALUES(' this.SQ sprintf('%.12f', startTime) this.SQ ', ' this.SQ sprintf('%.12f', endTime) this.SQ ', ' this.SQ num2str(value) this.SQ ')']);
                end
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setSituationVariableAtTime');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT setSituationVariableAtTime');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('SITUATION_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeDataOccurenceAtTime()
        %}
        function removeDataOccurenceAtTime(this, dataName, timecode)
            this.removeLineFromTable(['data_' dataName], timecode);
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeDataOccurencesInTimeInterval()
        %}
        function removeDataOccurencesInTimeInterval(this, dataName, startTime, endTime)
            this.removeLinesFromTable(['data_' dataName], startTime, endTime);
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeEventOccurenceAtTime()
        %}
        function removeEventOccurenceAtTime(this, eventName, timecode)
            this.removeLineFromTable(['event_' eventName], timecode);
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('EVENT_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeSituationOccurenceAtTime()
        %}
        function removeSituationOccurenceAtTime(this, situationName, startTimecode, endTimecode)
            sqlite4m(this.connection, 'SAVEPOINT removeSituationOccurenceAtTime');
            try
                sqlite4m(this.connection, ['DELETE FROM "situation_' situationName '" WHERE "startTimecode"=' this.SQ sprintf('%.12f', startTimecode) this.SQ ' AND "endTimecode"=' this.SQ sprintf('%.12f', endTimecode) this.SQ]);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeSituationOccurenceAtTime');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT removeSituationOccurenceAtTime');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('SITUATION_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: setBatchOfTimeDataVariablePairs()
        %}
        function setBatchOfTimeDataVariablePairs(this, dataName, variableName, timeValueCellArray)
            this.checkIfIsBaseData(dataName);
            type = this.getDataVariableType(dataName, variableName);
            [~,numberOfPairs] = size(timeValueCellArray);
            
            for i = 1:1:numberOfPairs
                timeValueCellArray{2,i} = this.checkInputTypeAndConvert(timeValueCellArray{2,i}, type);
            end
            this.setBatchOfTimeValuePairs(['data_' dataName], variableName, timeValueCellArray);
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: setBatchOfTimeEventVariablePairs()
        %}
        function setBatchOfTimeEventVariablePairs(this, eventName, variableName, timeValueCellArray)
            this.checkIfIsBaseEvent(eventName);
            type = this.getEventVariableType(eventName, variableName);
            [~,numberOfPairs] = size(timeValueCellArray);
            for i = 1:1:numberOfPairs
                timeValueCellArray{2,i} = this.checkInputTypeAndConvert(timeValueCellArray{2,i}, type);
            end
            this.setBatchOfTimeValuePairs(['event_' eventName], variableName, timeValueCellArray);
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('EVENT_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: setBatchOfTimeSituationVariableTriplets()
        %}
        function setBatchOfTimeSituationVariableTriplets(this, situationName, variableName, timeValueCellArray)
            import fr.lescot.bind.exceptions.ExceptionIds;
            this.checkIfIsBaseSituation(situationName);
            type = this.getSituationVariableType(situationName, variableName);
            [~,numberOfTriplets] = size(timeValueCellArray);
            for i = 1:1:numberOfTriplets
                timeValueCellArray{3,i} = this.checkInputTypeAndConvert(timeValueCellArray{3,i}, type);
                if timeValueCellArray{1, i} >= timeValueCellArray{2, i}
                    throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'endTimecode must be superior and different from startTimecode. A situation with startTimecode == endTimecode is an event.'));
                end
            end
            try
                [~, columns] = size(timeValueCellArray);
                sqlite4m(this.connection, 'SAVEPOINT setBatchOfTimeSituationVariableTriplets');
                for l=1:1:columns
                    %We try to insert the timecode / value pair. If we catch an
                    %exception, we assume that the timecode already exist, and
                    %we perform an update instead of an insert. There's no
                    %cleaner way to do it.
                    value = timeValueCellArray{3,l};
                    
                    requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT "startTimecode" FROM "situation_' char(situationName) '" WHERE "startTimecode"=' this.SQ sprintf('%.12f', timeValueCellArray{1,l}) this.SQ ' AND "endTimecode"=' this.SQ sprintf('%.12f', timeValueCellArray{2,l}) this.SQ]));
                    if ~requestResult.isEmpty()
                        sqlite4m(this.connection, ['UPDATE "situation_' char(situationName) '" SET "' char(variableName) '"=' this.SQ value this.SQ ' WHERE "startTimecode"=' this.SQ sprintf('%.12f', timeValueCellArray{1,l}) this.SQ ' AND "endTimecode"=' this.SQ sprintf('%.12f', timeValueCellArray{2,l}) this.SQ]);
                    else
                        sqlite4m(this.connection, ['INSERT INTO "situation_' char(situationName) '"("startTimecode", "endTimecode","' char(variableName) '") VALUES(' this.SQ sprintf('%.12f', timeValueCellArray{1,l}) this.SQ ',' this.SQ sprintf('%.12f', timeValueCellArray{2,l}) this.SQ ',' this.SQ value this.SQ ')']);
                    end
                end
                %Commits the transaction
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setBatchOfTimeSituationVariableTriplets');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT setBatchOfTimeSituationVariableTriplets');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('SITUATION_CONTENT_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: setEventAtTime()
        %}
        function setEventAtTime(this, eventName, timecode)
            this.setBatchOfEventsAtTime(eventName, {timecode});
        end
        
        %{
        Function: setSituationAtTime()
        %}
        function setSituationAtTime(this, situationName, startTime, endTime)
            this.setBatchOfSituationsAtTime(situationName, {startTime; endTime});
        end
        
        %{
        Function: setBatchOfEventsAtTime()
        %}
        function setBatchOfEventsAtTime(this, eventName, timecodeCellArray)
            this.checkIfIsBaseEvent(eventName);
            sqlite4m(this.connection, 'SAVEPOINT setBatchOfEventsAtTime');
            try
                %We try to insert the timecode. If the timecode already exist,
                %the event is just ignored.
                preparedStatement = sqlite4m(this.connection, 'prepare', ['INSERT OR IGNORE INTO "event_' char(eventName) '" ("timecode") VALUES (?1)']);
                for i = 1:1:length(timecodeCellArray)
                    sqlite4m(preparedStatement, {sprintf('%.12f', timecodeCellArray{i})});
                end
                sqlite4m(preparedStatement, 'finalize');
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setBatchOfEventsAtTime');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT setBatchOfEventsAtTime');
        end
        
        %{
        Function: setBatchOfSituationsAtTime()
        %}
        function setBatchOfSituationsAtTime(this, situationName, timecodesPairsCellArray)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseSituation(situationName);
            sqlite4m(this.connection, 'SAVEPOINT setBatchOfSituationsAtTime');
            try
                %We try to insert the timecode pair. If the
                %timecodes already exist, the situation is just ignored.
                preparedStatement = sqlite4m(this.connection, 'prepare', ['INSERT OR IGNORE INTO "situation_' char(situationName) '" ("startTimecode", "endTimecode") VALUES (?1, ?2)']);
                [~, numberOfPairs] = size(timecodesPairsCellArray);
                for i = 1:1:numberOfPairs
                    if timecodesPairsCellArray{1,i} >= timecodesPairsCellArray{2,i}
                        throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'endTimecode must be superior and different from startTimecode. A situation with startTimecode == endTimecode is an event.'));
                    end
                    sqlite4m(preparedStatement, {sprintf('%.12f', timecodesPairsCellArray{1,i}) sprintf('%.12f', timecodesPairsCellArray{2,i})});
                end
                sqlite4m(preparedStatement, 'finalize');
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setBatchOfSituationsAtTime');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT setBatchOfSituationsAtTime');
        end
        
        %{
        Function: getMaxTimeInDatas()
        %}
        function out = getMaxTimeInDatas(this)
            requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT Name FROM MetaDatas'));
            tableNames = requestResult.getVariableValues('name');
            for i = 1:1:length(tableNames)
                tableNames{i} = ['data_' tableNames{i}];
            end
            out = this.getMaxValueOfVariableInTablesList(tableNames, 'timecode');
        end
        
        %{
        Function: getMaxTimeInEvents()
        %}
        function out = getMaxTimeInEvents(this)
            requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT Name FROM MetaEvents'));
            tableNames = requestResult.getVariableValues('name');
            for i = 1:1:length(tableNames)
                tableNames{i} = ['event_' tableNames{i}];
            end
            out = this.getMaxValueOfVariableInTablesList(tableNames, 'timecode');
        end
        
        %{
        Function: getMaxEndTimeInSituations()
        %}
        function out = getMaxEndTimeInSituations(this)
            requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT Name FROM MetaEvents'));
            tableNames = requestResult.getVariableValues('name');
            for i = 1:1:length(tableNames)
                tableNames{i} = ['situation_' tableNames{i}];
            end
            out = this.getMaxValueOfVariableInTablesList(tableNames, 'endTimecode');
        end
        
        %{
        Function: getMinTimeInDatas()
        %}
        function out = getMinTimeInDatas(this)
            requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT Name FROM MetaDatas'));
            tableNames = requestResult.getVariableValues('name');
            for i = 1:1:length(tableNames)
                tableNames{i} = ['data_' tableNames{i}];
            end
            out = this.getMinValueOfVariableInTablesList(tableNames, 'timecode');
        end
        
        %{
        Function: getMinTimeInEvents()
        %}
        function out = getMinTimeInEvents(this)
            requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT Name FROM MetaEvents'));
            tableNames = requestResult.getVariableValues('name');
            for i = 1:1:length(tableNames)
                tableNames{i} = ['event_' tableNames{i}];
            end
            out = this.getMinValueOfVariableInTablesList(tableNames, 'timecode');
        end
        
        %{
        Function: getMinEndTimeInSituations()
        %}
        function out = getMinStartTimeInSituations(this)
            requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, 'SELECT Name FROM MetaEvents'));
            tableNames = requestResult.getVariableValues('name');
            for i = 1:1:length(tableNames)
                tableNames{i} = ['situation_' tableNames{i}];
            end
            out = this.getMinValueOfVariableInTablesList(tableNames, 'startTimecode');
        end
        
        %{
        Function: addData()
        %}
        function addData(this, metaData)
            sqlite4m(this.connection, 'SAVEPOINT addData');
            try
                %Creating the table for the data
                this.createStorageTableFromMetaBase(metaData, 'data');
                
                variables = metaData.getVariablesAndFrameworkVariables();
                %Creating the SQL entries in the metadatas table
                sqlite4m(this.connection, ['INSERT INTO "MetaDatas" VALUES(' this.SQ char(metaData.getName()) this.SQ ','  this.SQ char(metaData.getType()) this.SQ ',' this.SQ char(metaData.getFrequency()) this.SQ ',' this.SQ char(metaData.getComments()) this.SQ ',' this.SQ char(sprintf('%d', metaData.isBase())) this.SQ ')']);
                for i = 1:1:length(variables)
                    variable = variables{i};
                    sqlite4m(this.connection, ['INSERT INTO "MetaDataVariables" VALUES(' this.SQ char(metaData.getName()) this.SQ ',' this.SQ char(variable.getName()) this.SQ ',' this.SQ char(variable.getType()) this.SQ ',' this.SQ char(variable.getUnit()) this.SQ ',' this.SQ char(variable.getComments()) this.SQ ')']);
                end
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT addData');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT addData');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: addEvent()
        %}
        function addEvent(this, metaEvent)
            sqlite4m(this.connection, 'SAVEPOINT addEvent');
            try
                this.createStorageTableFromMetaBase(metaEvent, 'event');
                %Creating the SQL entries in the metaEvent table
                sqlite4m(this.connection, ['INSERT INTO "MetaEvents" VALUES(' this.SQ char(metaEvent.getName()) this.SQ ',' this.SQ char(metaEvent.getComments()) this.SQ ',' this.SQ char(sprintf('%d', metaEvent.isBase())) this.SQ ')']);
                variables = metaEvent.getVariablesAndFrameworkVariables();
                for i = 1:1:length(variables)
                    variable = variables{i};
                    sqlite4m(this.connection, ['INSERT INTO "MetaEventVariables" VALUES(' this.SQ char(metaEvent.getName()) this.SQ ',' this.SQ char(variable.getName()) this.SQ ',' this.SQ char(variable.getType()) this.SQ ',' this.SQ char(variable.getUnit()) this.SQ ',' this.SQ char(variable.getComments()) this.SQ ')']);
                end
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT addEvent');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT addEvent');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('EVENT_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: addSituation()
        %}
        function addSituation(this, metaSituation)
            sqlite4m(this.connection, 'SAVEPOINT addSituation');
            try
                this.createStorageTableFromMetaBase(metaSituation, 'situation');
                %Creating the SQL entries in the metaSituation table
                sqlite4m(this.connection, ['INSERT INTO "MetaSituations" VALUES(' this.SQ char(metaSituation.getName()) this.SQ ',' this.SQ char(metaSituation.getComments()) this.SQ ',' this.SQ char(sprintf('%d', metaSituation.isBase())) this.SQ ')']);
                variables = metaSituation.getVariablesAndFrameworkVariables();
                for i = 1:1:length(variables)
                    variable = variables{i};
                    sqlite4m(this.connection, ['INSERT INTO "MetaSituationVariables" VALUES(' this.SQ char(metaSituation.getName()) this.SQ ',' this.SQ char(variable.getName()) this.SQ ',' this.SQ char(variable.getType()) this.SQ ',' this.SQ char(variable.getUnit()) this.SQ ',' this.SQ char(variable.getComments()) this.SQ ')']);
                end
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT addSituation');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT addSituation');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('SITUATION_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: addDataVariable()
        %}
        function addDataVariable(this, dataName, metaVariable)
            this.checkIfIsBaseData(dataName);
            sqlite4m(this.connection, 'SAVEPOINT addDataVariable');
            try
                this.addColumnFromMetaVariableBase(dataName, metaVariable, 'data')
                sqlite4m(this.connection, ['INSERT INTO "MetaDataVariables" VALUES(' this.SQ dataName this.SQ ',' this.SQ metaVariable.getName() this.SQ ',' this.SQ metaVariable.getType() this.SQ ',' this.SQ char(metaVariable.getUnit()) this.SQ ',' this.SQ char(metaVariable.getComments()) this.SQ ')']);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT addDataVariable');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT addDataVariable');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_VARIABLE_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: addEventVariable()
        %}
        function addEventVariable(this, eventName, eventVariable)
            this.checkIfIsBaseEvent(eventName);
            sqlite4m(this.connection, 'SAVEPOINT addEventVariable');
            try
                this.addColumnFromMetaVariableBase(eventName, eventVariable, 'event');
                sqlite4m(this.connection, ['INSERT INTO "MetaEventVariables" VALUES(' this.SQ eventName this.SQ ',' this.SQ eventVariable.getName() this.SQ ',' this.SQ eventVariable.getType() this.SQ ',' this.SQ char(eventVariable.getUnit()) this.SQ ',' this.SQ char(eventVariable.getComments()) this.SQ ')']);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT addEventVariable');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT addEventVariable');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('EVENT_VARIABLE_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: addSituationVariable()
        %}
        function addSituationVariable(this, situationName, situationVariable)
            this.checkIfIsBaseSituation(situationName);
            sqlite4m(this.connection, 'SAVEPOINT addSituationVariable');
            try
                this.addColumnFromMetaVariableBase(situationName, situationVariable, 'situation');
                sqlite4m(this.connection, ['INSERT INTO "MetaSituationVariables" VALUES(' this.SQ situationName this.SQ ',' this.SQ situationVariable.getName() this.SQ ',' this.SQ situationVariable.getType() this.SQ  ',' this.SQ char(situationVariable.getUnit()) this.SQ ',' this.SQ char(situationVariable.getComments()) this.SQ ')']);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT addSituationVariable');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT addSituationVariable');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('SITUATION_VARIABLE_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeDataVariable()
        %}
        function removeDataVariable(this, dataName, variableName)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseData(dataName);
            request = ['SELECT "name" FROM "MetaDataVariables" WHERE "data_name" = ' this.SQ dataName this.SQ ' AND "name" = '  this.SQ variableName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            values = record.getVariableValues('name');
            if ~isempty(values)
                sqlite4m(this.connection, 'SAVEPOINT removeDataVariable');
                %First step : we delete the meta-informations related to the
                %variable.
                variableRequest = ['DELETE FROM "MetaDataVariables" WHERE "data_name" = ' this.SQ dataName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
                try
                    sqlite4m(this.connection, variableRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeDataVariable');
                    rethrow(ME);
                end
                %Second step : we delete the variable column itself (VERY
                %LONG)
                this.dropColumn(['data_' dataName], variableName);
                sqlite4m(this.connection, 'RELEASE SAVEPOINT removeDataVariable');
            else
                throw(MException(ExceptionIds.DATA_EXCEPTION.getId(), 'The variable couldn''t be found in the designated data in this database and couldn''t be deleted'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_VARIABLE_REMOVED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeEventVariable()
        %}
        function removeEventVariable(this, eventName, variableName)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseEvent(eventName);
            request = ['SELECT "name" FROM "MetaEventVariables" WHERE "event_name" = ' this.SQ eventName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            values = record.getVariableValues('name');
            if ~isempty(values)
                sqlite4m(this.connection, 'SAVEPOINT removeEventVariable');
                %First step : we delete the meta-informations related to the
                %variable.
                variableRequest = ['DELETE FROM "MetaEventVariables" WHERE "event_name" = ' this.SQ eventName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
                try
                    sqlite4m(this.connection, variableRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeEventVariable');
                    rethrow(ME);
                end
                %Second step : we delete the variable column itself (VERY
                %LONG)
                this.dropColumn(['event_' eventName], variableName);
                sqlite4m(this.connection, 'RELEASE SAVEPOINT removeEventVariable');
            else
                throw(MException(ExceptionIds.EVENT_EXCEPTION.getId(), 'The variable couldn''t be found in the designated event in this database and couldn''t be deleted'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('EVENT_VARIABLE_REMOVED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeSituationVariable()
        %}
        function removeSituationVariable(this, situationName, variableName)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseSituation(situationName);
            request = ['SELECT "name" FROM "MetaSituationVariables" WHERE "situation_name" = ' this.SQ situationName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            values = record.getVariableValues('name');
            if ~isempty(values)
                sqlite4m(this.connection, 'SAVEPOINT removeSituationVariable');
                %First step : we delete the meta-informations related to the
                %variable.
                variableRequest = ['DELETE FROM "MetaSituationVariables" WHERE "situation_name" = ' this.SQ situationName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
                try
                    sqlite4m(this.connection, variableRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeSituationVariable');
                    rethrow(ME);
                end
                %Second step : we delete the variable column itself (VERY
                %LONG)
                this.dropColumn(['situation_' situationName], variableName);
                sqlite4m(this.connection, 'RELEASE SAVEPOINT removeSituationVariable');
            else
                throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'The variable couldn''t be found in the designated event in this database and couldn''t be deleted'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('SITUATION_VARIABLE_REMOVED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeData()
        %}
        function removeData(this, dataName)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseData(dataName);
            request = ['SELECT "name" FROM "MetaDatas" WHERE "name" = ' this.SQ dataName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                %The first step is to delete the reference to the table in the
                %metadatas. As cascading deletion does not work in SQLite (even
                %if the syntax allows it, it is ignored ...), we have to
                %perform it manually. The second step is to drop the table
                %itself.
                dataRequest = ['DELETE FROM "MetaDatas" WHERE "name" = ' this.SQ dataName this.SQ];
                variableRequest = ['DELETE FROM "MetaDataVariables" WHERE "data_name" = ' this.SQ dataName this.SQ];
                dropRequest = ['DROP TABLE "data_' dataName '"'];
                sqlite4m(this.connection, 'SAVEPOINT removeData');
                try
                    sqlite4m(this.connection, dataRequest);
                    sqlite4m(this.connection, variableRequest);
                    sqlite4m(this.connection, dropRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeData');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT removeData');
            else
                throw(MException(ExceptionIds.DATA_EXCEPTION.getId(), 'The data was not found in this database and couldn''t be deleted'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_REMOVED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeEvent()
        %}
        function removeEvent(this, eventName)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseEvent(eventName);
            request = ['SELECT "name" FROM "MetaEvents" WHERE "name" = ' this.SQ eventName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                %The first step is to delete the reference to the table in the
                %metadatas. As cascading deletion does not work in SQLite (even
                %if the syntax allows it, it is ignored ...), we have to
                %perform it manually. The second step is to drop the table
                %itself.
                dataRequest = ['DELETE FROM "MetaEvents" WHERE "name" = ' this.SQ eventName this.SQ];
                variableRequest = ['DELETE FROM "MetaEventVariables" WHERE "event_name" = ' this.SQ eventName this.SQ];
                dropRequest = ['DROP TABLE "event_' eventName '"'];
                sqlite4m(this.connection, 'SAVEPOINT removeEvent');
                try
                    sqlite4m(this.connection, dataRequest);
                    sqlite4m(this.connection, variableRequest);
                    sqlite4m(this.connection, dropRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeEvent');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT removeEvent');
            else
                throw(MException(ExceptionIds.EVENT_EXCEPTION.getId(), 'The event was not found in this database and couldn''t be deleted'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('EVENT_REMOVED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeSituation()
        %}
        function removeSituation(this, situationName)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseSituation(situationName);
            request = ['SELECT "name" FROM "MetaSituations" WHERE "name" = ' this.SQ situationName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                %The first step is to delete the reference to the table in the
                %metadatas. As cascading deletion does not work in SQLite (even
                %if the syntax allows it, it is ignored ...), we have to
                %perform it manually. The second step is to drop the table
                %itself.
                dataRequest = ['DELETE FROM "MetaSituations" WHERE "name" = ' this.SQ situationName this.SQ];
                variableRequest = ['DELETE FROM "MetaSituationVariables" WHERE "situation_name" = ' this.SQ situationName this.SQ];
                dropRequest = ['DROP TABLE "situation_' situationName '"'];
                sqlite4m(this.connection, 'SAVEPOINT removeSituation');
                try
                    sqlite4m(this.connection, dataRequest);
                    sqlite4m(this.connection, variableRequest);
                    sqlite4m(this.connection, dropRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeSituation');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT removeSituation');
            else
                throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'The situation was not found in this database and couldn''t be deleted'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('SITUATION_REMOVED');
            this.notifyAll(message);
        end
        
        %{
        Function: getAttribute()
        %}
        function out = getAttribute(this, attributeName)
            import fr.lescot.bind.exceptions.ExceptionIds
            request = ['SELECT "value" FROM "MetaTripDatas" WHERE key = ' this.SQ attributeName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            if record.isEmpty()
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'The requested attribute wasn''t found in the database'));
            else
                values = record.getVariableValues('value');
                out = values{1};
            end
        end
        
        %{
        Function: setAttribute()
        %}
        function setAttribute(this, attributeName, attributeValue)
            checkRequest = ['SELECT * FROM "MetaTripDatas" WHERE key = ' this.SQ attributeName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, checkRequest));
            values = record.getVariableValues('key');
            if(isempty(values))
                request = ['INSERT INTO "MetaTripDatas" VALUES(' this.SQ attributeName this.SQ ', ' this.SQ attributeValue this.SQ ')'];
            else
                request = ['UPDATE "MetaTripDatas" SET "value" = ' this.SQ attributeValue this.SQ ' WHERE "key" = ' this.SQ attributeName this.SQ];
            end
            sqlite4m(this.connection, 'SAVEPOINT setAttribute');
            try
                sqlite4m(this.connection, request);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setAttribute');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT setAttribute');
            
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('TRIP_META_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: removeAttribute()
        %}
        function removeAttribute(this, attributeName)
            import fr.lescot.bind.exceptions.ExceptionIds
            checkRequest = ['SELECT * FROM "MetaTripDatas" WHERE "key" = ' this.SQ attributeName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, checkRequest));
            values = record.getVariableValues('key');
            if(~isempty(values))
                sqlite4m(this.connection, 'SAVEPOINT removeAttribute');
                try
                    request = ['DELETE FROM "MetaTripDatas" WHERE "key" = ' this.SQ attributeName this.SQ];
                    sqlite4m(this.connection, request);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeAttribute');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT removeAttribute');
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'Can''t remove the requested attribute as it doesn''t exist in the database'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('TRIP_META_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function:
        For this implementation, you have to pass the MetaVideoFile. The offset will be modified
        according to the description of the video. The filenames are unchanged.
        %}
        function updateVideoFileOffset(this, videoFile)
            request = ['UPDATE "MetaTripVideos" SET "offset" = ' this.SQ sprintf('%.12f', videoFile.getOffset()) this.SQ ' WHERE "description" = ' this.SQ videoFile.getDescription() this.SQ];
            sqlite4m(this.connection, 'SAVEPOINT updateVideoFileOffset');
            try
                sqlite4m(this.connection, request);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT updateVideoFileOffset');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT updateVideoFileOffset');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('TRIP_META_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function:
        For this implementation, you have to pass only the path of the
        video relative to the emplacement of the db file. This way, if the
        relative position of the video is preserved, you can access it
        from any computer.
        You should not use this method to modify a VideoFile retrieved with trip.getMetaInformation as
        this method modify the filenames, thus prevent the SQL request to work.
        
        Throws:
        ARGUMENT_EXCEPTION - if the path is absolute.
        %}
        function addVideoFile(this, videoFile)
            import fr.lescot.bind.exceptions.ExceptionIds
            fileName = videoFile.getFileName();
            if ~strcmp(fileName(1), '.')
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'This implementation of Trip supports only adding videos whose path is relative to the path of the .db file. No absolute path is allowed.'));
            end
            checkRequest = ['SELECT * FROM "MetaTripVideos" WHERE "filename" = ' this.SQ fileName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, checkRequest));
            values = record.getVariableValues('filename');
            if(isempty(values))
                request = ['INSERT INTO "MetaTripVideos" VALUES(' this.SQ char(fileName) this.SQ ',' this.SQ sprintf('%.12f', videoFile.getOffset()) this.SQ ',' this.SQ char(videoFile.getDescription()) this.SQ ')'];
            else
                request = ['UPDATE "MetaTripVideos" SET "offset" = ' this.SQ sprintf('%.12f', videoFile.getOffset()) this.SQ ', "description" = ' this.SQ videoFile.getDescription() this.SQ ' WHERE "filename" = ' this.SQ videoFile.getFileName() this.SQ];
            end
            sqlite4m(this.connection, 'SAVEPOINT addVideoFile');
            try
                sqlite4m(this.connection, request);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT addVideoFile');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT addVideoFile');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('TRIP_META_CHANGED');
            this.notifyAll(message);
        end
        
        
        %{
        Function: updateMetaDataVariable(this, dataName, metaDataVariable)
        See fr.lescot.bind.kernel.Trip.updateMetaDataVariable
        %}
        function updateMetaDataVariable(this, dataName, metaDataVariable)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseData(dataName);
            % check if data name exists
            request = ['SELECT "name" FROM "MetaDatas" WHERE "name" = ' this.SQ dataName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                variableName = metaDataVariable.getName();
                % check if variable name exists
                request = ['SELECT "name" FROM "MetaDataVariables" WHERE "data_name" = ' this.SQ dataName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
                record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
                variableNameValues = record.getVariableValues('name');
                if ~isempty(variableNameValues)
                    request = ['UPDATE MetaDataVariables SET type=' this.SQ metaDataVariable.getType() this.SQ ', unit=' this.SQ metaDataVariable.getUnit() this.SQ ', comments=' this.SQ metaDataVariable.getComments() this.SQ ' WHERE data_name=' this.SQ dataName this.SQ ' AND name=' this.SQ variableName this.SQ ];
                    sqlite4m(this.connection, request);
                else
                    throw(MException(ExceptionIds.DATA_EXCEPTION.getId(), 'The variable was not found in this database and couldn''t be updated'));
                end
            else
                throw(MException(ExceptionIds.DATA_EXCEPTION.getId(), 'The data was not found in this database and couldn''t be updated'));
            end
        end
        
        %{
        Function: updateMetaData(this, metaData)
        See fr.lescot.bind.kernel.Trip.updateMetaData
        %}
        function updateMetaData(this, metaData)
            import fr.lescot.bind.exceptions.ExceptionIds
            dataName = metaData.getName();
            this.checkIfIsBaseData(dataName);
            request = ['SELECT "name" FROM "MetaDatas" WHERE "name" = ' this.SQ dataName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                %The first step is to updates the values associated to the
                %metadata.
                updateRequest = ['UPDATE MetaDatas SET type=' this.SQ metaData.getType() this.SQ ', frequency=' this.SQ metaData.getFrequency() this.SQ ', comments=' this.SQ metaData.getComments() this.SQ ' WHERE name=' this.SQ dataName this.SQ ];
                sqlite4m(this.connection, 'SAVEPOINT updateData');
                try
                    sqlite4m(this.connection, updateRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT updateData');
                    rethrow(ME);
                end
                %then update all MetaDataVariables
                metaVariablesToUpdate = metaData.getVariables();
                for i=1:length(metaVariablesToUpdate)
                    try
                        this.updateMetaDataVariable(dataName,metaVariablesToUpdate{i});
                    catch ME
                        sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT updateData');
                        rethrow(ME);
                    end
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT updateData');
            else
                throw(MException(ExceptionIds.DATA_EXCEPTION.getId(), 'The data was not found in this database and couldn''t be updated'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('DATA_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: updateMetaEventVariable(this, eventName, metaEventVariable)
        %}
        function updateMetaEventVariable(this, eventName, metaEventVariable)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseEvent(eventName);
            % check if event name exists
            request = ['SELECT "name" FROM "MetaEvents" WHERE "name" = ' this.SQ eventName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                variableName = metaEventVariable.getName();
                % check if variable name exists
                request = ['SELECT "name" FROM "MetaEventVariables" WHERE "event_name" = ' this.SQ eventName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
                record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
                variableNameValues = record.getVariableValues('name');
                if ~isempty(variableNameValues)
                    request = ['UPDATE MetaEventVariables SET type=' this.SQ metaEventVariable.getType() this.SQ ', unit=' this.SQ metaEventVariable.getUnit() this.SQ ', comments=' this.SQ metaEventVariable.getComments() this.SQ ' WHERE event_name=' this.SQ eventName this.SQ ' AND name=' this.SQ variableName this.SQ ];
                    sqlite4m(this.connection, request);
                else
                    throw(MException(ExceptionIds.EVENT_EXCEPTION.getId(), 'The variable was not found in this database and couldn''t be updated'));
                end
            else
                throw(MException(ExceptionIds.EVENT_EXCEPTION.getId(), 'The event was not found in this database and couldn''t be updated'));
            end
        end
        
        %{
        Function: updateMetaEvent(this, metaEvent)
        See fr.lescot.bind.kernel.Trip.updateMetaEvent
        %}
        function updateMetaEvent(this, metaEvent)
            import fr.lescot.bind.exceptions.ExceptionIds
            eventName = metaEvent.getName();
            this.checkIfIsBaseEvent(eventName);
            request = ['SELECT "name" FROM "MetaEvents" WHERE "name" = ' this.SQ eventName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                %The first step is to updates the values associated to the
                %metadata.
                updateRequest = ['UPDATE MetaEvents SET comments=' this.SQ metaEvent.getComments() this.SQ ' WHERE name=' this.SQ eventName this.SQ ];
                sqlite4m(this.connection, 'SAVEPOINT updateEvent');
                try
                    sqlite4m(this.connection, updateRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT updateEvent');
                    rethrow(ME);
                end
                %then update all MetaEventVariables
                metaVariablesToUpdate = metaEvent.getVariables();
                for i=1:length(metaVariablesToUpdate)
                    try
                        this.updateMetaEventVariable(eventName,metaVariablesToUpdate{i});
                    catch ME
                        sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT updateEvent');
                        rethrow(ME);
                    end
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT updateEvent');
            else
                throw(MException(ExceptionIds.EVENT_EXCEPTION.getId(), 'The event was not found in this database and couldn''t be updated'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('EVENT_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: updateMetaSituationVariable(this, situationName, metaSituationVariable)
        %}
        function updateMetaSituationVariable(this, situationName, metaSituationVariable)
            import fr.lescot.bind.exceptions.ExceptionIds
            this.checkIfIsBaseSituation(situationName);
            % check if situation name exists
            request = ['SELECT "name" FROM "MetaSituations" WHERE "name" = ' this.SQ situationName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                variableName = metaSituationVariable.getName();
                % check if variable name exists
                request = ['SELECT "name" FROM "MetaSituationVariables" WHERE "situation_name" = ' this.SQ situationName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
                record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
                variableNameValues = record.getVariableValues('name');
                if ~isempty(variableNameValues)
                    request = ['UPDATE MetaSituationVariables SET type=' this.SQ metaSituationVariable.getType() this.SQ ', unit=' this.SQ metaSituationVariable.getUnit() this.SQ ', comments=' this.SQ metaSituationVariable.getComments() this.SQ ' WHERE situation_name=' this.SQ situationName this.SQ ' AND name=' this.SQ variableName this.SQ ];
                    sqlite4m(this.connection, request);
                else
                    throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'The variable was not found in this database and couldn''t be updated'));
                end
            else
                throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'The situation was not found in this database and couldn''t be updated'));
            end
        end
        
        
        %{
        Function: updateMetaSituation(this, metaSituation)
        See fr.lescot.bind.kernel.Trip.updateMetaSituation
        %}
        function updateMetaSituation(this, metaSituation)
            import fr.lescot.bind.exceptions.ExceptionIds
            situationName = metaSituation.getName();
            this.checkIfIsBaseSituation(situationName);
            request = ['SELECT "name" FROM "MetaSituations" WHERE "name" = ' this.SQ situationName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            nameValues = record.getVariableValues('name');
            if ~isempty(nameValues)
                %The first step is to updates the values associated to the
                %metadata.
                updateRequest = ['UPDATE MetaSituations SET comments=' this.SQ metaSituation.getComments() this.SQ ' WHERE name=' this.SQ situationName this.SQ ];
                sqlite4m(this.connection, 'SAVEPOINT updateSituation');
                try
                    sqlite4m(this.connection, updateRequest);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT updateSituation');
                    rethrow(ME);
                end
                %then update all MetaSituationVariables
                metaVariablesToUpdate = metaSituation.getVariables();
                for i=1:length(metaVariablesToUpdate)
                    try
                        this.updateMetaSituationVariable(situationName,metaVariablesToUpdate{i});
                    catch ME
                        sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT updateSituation');
                        rethrow(ME);
                    end
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT updateSituation');
            else
                throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'The situation was not found in this database and couldn''t be updated'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('SITUATION_ADDED');
            this.notifyAll(message);
        end
        
        %{
        Function: updateSituationVariableOccurenceTimecodes()
        %}
        function updateSituationVariableOccurenceTimecodes(this, situationName, initialTimeCodesCellArray, newTimeCodesCellArray)
            import fr.lescot.bind.exceptions.ExceptionIds;
            this.checkIfIsBaseSituation(situationName);
            [~,initialNumberOfTriplets] = size(initialTimeCodesCellArray);
            [~,newNumberOfTriplets] = size(newTimeCodesCellArray);
            if newNumberOfTriplets == initialNumberOfTriplets
                for i = 1:1:newNumberOfTriplets
                    if newTimeCodesCellArray{1, i} >= newTimeCodesCellArray{2, i}
                        throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'endTimecode must be superior and different from startTimecode. A situation with startTimecode == endTimecode is an event.'));
                    end
                end
                try
                    [~, columns] = size(newTimeCodesCellArray);
                    sqlite4m(this.connection, 'SAVEPOINT updateSituationVariableOccurenceTimecodes');
                    for l=1:1:columns
                        %We try to insert the timecode / value pair. If we catch an
                        %exception, we assume that the timecode already exist, and
                        %we perform an update instead of an insert. There's no
                        %cleaner way to do it.
                        initialRequestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT "startTimecode" FROM "situation_' char(situationName) '" WHERE "startTimecode"=' this.SQ sprintf('%.12f', initialTimeCodesCellArray{1,l}) this.SQ ' AND "endTimecode"=' this.SQ sprintf('%.12f', initialTimeCodesCellArray{2,l}) this.SQ]));
                        %if and(~initialRequestResult.isEmpty(), or(newTimeCodesCellArray{1,l}~=initialTimeCodesCellArray{1,l}, newTimeCodesCellArray{2,l}~=initialTimeCodesCellArray{2,l}))
                        if ~initialRequestResult.isEmpty()
                            sqlite4m(this.connection, ['UPDATE "situation_' char(situationName) '" SET "startTimecode"=' this.SQ sprintf('%.12f', newTimeCodesCellArray{1,l}) this.SQ ', "endTimecode"=' this.SQ sprintf('%.12f', newTimeCodesCellArray{2,l}) this.SQ ' WHERE "startTimecode"=' this.SQ sprintf('%.12f', initialTimeCodesCellArray{1,l}) this.SQ ' AND "endTimecode"=' this.SQ sprintf('%.12f', initialTimeCodesCellArray{2,l}) this.SQ]);
                        end
                    end
                    %Commits the transaction
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT updateSituationVariableOccurenceTimecodes');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT updateSituationVariableOccurenceTimecodes');
                message = fr.lescot.bind.kernel.TripMessage();
                message.setCurrentMessage('SITUATION_CONTENT_CHANGED');
                this.notifyAll(message);
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'Can''t update situation timecodes as initial and new cell arrays have not the same size'));
            end
        end
        
        %{
        Function: removeVideoFile()
        %}
        function removeVideoFile(this, fileName)
            import fr.lescot.bind.exceptions.ExceptionIds
            checkRequest = ['SELECT * FROM "MetaTripVideos" WHERE "filename" = ' this.SQ fileName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, checkRequest));
            values = record.getVariableValues('filename');
            if(~isempty(values))
                request = ['DELETE FROM "MetaTripVideos" WHERE "filename" = ' this.SQ fileName this.SQ];
                sqlite4m(this.connection, 'SAVEPOINT removeVideoFile');
                try
                    sqlite4m(this.connection, request);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeVideoFile');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT removeVideoFile');
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'Can''t remove video file as it doesn''t exist in the database'));
            end
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('TRIP_META_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: setParticipant()
        %}
        function setParticipant(this, participant)
            attributesList = participant.getAttributesList();
            
            sqlite4m(this.connection, 'SAVEPOINT setParticipant');
            try
                for i = 1:1:length(attributesList)
                    attributeName = attributesList{i};
                    attributeValue = participant.getAttribute(attributeName);
                    requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT "key" FROM "MetaParticipantDatas" WHERE "key" = ' this.SQ attributeName this.SQ]));
                    if ~requestResult.isEmpty()
                        sqlite4m(this.connection, ['UPDATE "MetaParticipantDatas" SET "value" = ' this.SQ attributeValue this.SQ ' WHERE "key" = ' this.SQ attributeName this.SQ]);
                    else
                        sqlite4m(this.connection, ['INSERT INTO "MetaParticipantDatas"("key", "value") VALUES(' this.SQ attributeName this.SQ ',' this.SQ attributeValue this.SQ ')']);
                    end
                end
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setParticipant');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT setParticipant');
            message = fr.lescot.bind.kernel.TripMessage();
            message.setCurrentMessage('TRIP_META_CHANGED');
            this.notifyAll(message);
        end
        
        %{
        Function: setFrequencyData()
        %}
        function setFrequencyData(this, dataName, frequency)
            import fr.lescot.bind.exceptions.ExceptionIds
            checkRequest = ['SELECT "frequency" FROM "MetaDatas" WHERE name = ' this.SQ dataName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, checkRequest));
            values = record.getVariableValues('frequency');
            if(~isempty(values))
                request = ['UPDATE "MetaDatas" SET "frequency" = ' this.SQ sprintf('%d', frequency) this.SQ ' WHERE "name" = ' this.SQ dataName this.SQ];
                sqlite4m(this.connection, 'SAVEPOINT setFrequencyData');
                try
                    sqlite4m(this.connection, request);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setFrequencyData');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT setFrequencyData');
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'Can''t set frequency value as the data doesn''t exist in the database'));
            end
        end
        
        %{
        Function: setIsBaseData()
        %}
        function setIsBaseData(this, dataName, isBase)
            import fr.lescot.bind.exceptions.ExceptionIds
            checkRequest = ['SELECT "isBase" FROM "MetaDatas" WHERE name = ' this.SQ dataName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, checkRequest));
            values = record.getVariableValues('isBase');
            if(~isempty(values))
                request = ['UPDATE "MetaDatas" SET "isBase" = ' this.SQ sprintf('%d', isBase) this.SQ ' WHERE "name" = ' this.SQ dataName this.SQ];
                sqlite4m(this.connection, 'SAVEPOINT setIsBaseData');
                try
                    sqlite4m(this.connection, request);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setIsBaseData');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT setIsBaseData');
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'Can''t set isBase value as the data doesn''t exist in the database'));
            end
        end
        
        %{
        Function: setIsBaseEvent()
        %}
        function setIsBaseEvent(this, eventName, isBase)
            import fr.lescot.bind.exceptions.ExceptionIds
            checkRequest = ['SELECT "isBase" FROM "MetaEvents" WHERE name = ' this.SQ eventName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, checkRequest));
            values = record.getVariableValues('isBase');
            if(~isempty(values))
                request = ['UPDATE "MetaEvents" SET "isBase" = ' this.SQ sprintf('%d', isBase) this.SQ ' WHERE "name" = ' this.SQ eventName this.SQ];
                sqlite4m(this.connection, 'SAVEPOINT setIsBaseEvent');
                try
                    sqlite4m(this.connection, request);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setIsBaseEvent');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT setIsBaseEvent');
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'Can''t set isBase value as the event doesn''t exist in the database'));
            end
        end
        
        %{
        Function: setIsBaseSituation()
        %}
        function setIsBaseSituation(this, situationName, isBase)
            import fr.lescot.bind.exceptions.ExceptionIds
            checkRequest = ['SELECT "isBase" FROM "MetaSituations" WHERE "name" = ' this.SQ situationName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, checkRequest));
            values = record.getVariableValues('isBase');
            if(~isempty(values))
                request = ['UPDATE "MetaSituations" SET "isBase" = ' this.SQ sprintf('%d', isBase) this.SQ ' WHERE "name" = ' this.SQ situationName this.SQ];
                sqlite4m(this.connection, 'SAVEPOINT setIsBaseSituation');
                try
                    sqlite4m(this.connection, request);
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setIsBaseSituation');
                    rethrow(ME);
                end
                sqlite4m(this.connection, 'RELEASE SAVEPOINT setIsBaseSituation');
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'Can''t set isBase value as the situation doesn''t exist in the database'));
            end
        end
        
        %{
        Function:
        Function automatically called when the object is removed or
        overwritten. Used to close the connection.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function delete(this)
            %The following line is not necessary, as the superclass
            %destructor is automatically called. Uncommenting the line
            %would cause a second call.
            %delete@Trip(this);
            sqlite4m(this.connection, 'close');
        end
        
        %{
        Function: beginTransaction()
        %}
        function beginTransaction(this)
            sqlite4m(this.connection, 'BEGIN TRANSACTION');
        end
        
        %{
        Function: rollbackTransaction()
        %}
        function rollbackTransaction(this)
            sqlite4m(this.connection, 'ROLLBACK TRANSACTION');
        end
        
        %{
        Function: commitTransaction()
        %}
        function commitTransaction(this)
            sqlite4m(this.connection, 'COMMIT TRANSACTION');
        end
        
        %Function: getDataVariableValuesInterpolatedAccordingToTimecode()
        function out = getDataVariableValuesInterpolatedAccordingToTimecode(this,timeValueCellArray, dataName, variableName)
            import fr.lescot.bind.data.Record;
            
            newvalues = cell(1,length(timeValueCellArray));
            
            try
                equalStatement = sqlite4m(this.connection, 'prepare', ['SELECT * FROM "data_' dataName '" WHERE "TimeCode" = ?1']);
                lesserStatement = sqlite4m(this.connection, 'prepare', ['SELECT * FROM "data_' dataName '" WHERE "TimeCode" < ?1 GROUP BY "TimeCode" HAVING COUNT("TimeCode") = 1 ORDER BY "TimeCode" DESC']);
                greaterStatement = sqlite4m(this.connection, 'prepare', ['SELECT * FROM "data_' dataName '" WHERE "TimeCode" > ?1 GROUP BY "TimeCode" HAVING COUNT("TimeCode") = 1 ORDER BY "TimeCode" ASC']);
                for i = 1:length(timeValueCellArray)
                    record = Record(sqlite4m(equalStatement, {sprintf('%.12f', timeValueCellArray{i})}));
                    if isempty(record.getVariableValues('TimeCode'))
                        record = Record(sqlite4m(lesserStatement, {sprintf('%.12f', timeValueCellArray{i})}));
                        valuetable = cell2mat(record.getVariableValues(variableName));
                        valueBeforeTime = valuetable(length(valuetable));
                        record = Record(sqlite4m(greaterStatement, {sprintf('%.12f', timeValueCellArray{i})}));
                        valuetable = cell2mat(record.getVariableValues(variableName));
                        valueAfterTime = valuetable(1);
                        newvalues{i} = (valueBeforeTime + valueAfterTime)/2 ;
                    else
                        value = record.getVariableValues(variableName);
                        newvalues{i} = value{1};
                    end
                end
                out = newvalues;
                sqlite4m(equalStatement, 'finalize');
                sqlite4m(equalStatement, 'lesserStatement');
                sqlite4m(equalStatement, 'greaterStatement');
            catch ME
                rethrow(ME);
            end
        end
        
        %{
        Function: getDataVariableType()
        %}
        function out =  getDataVariableType(this, dataName, variableName)
            request = ['SELECT "type" FROM "MetaDataVariables" WHERE "data_name" = ' this.SQ dataName this.SQ ' AND "name" = ' this.SQ variableName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            type = record.getVariableValues('type');
            out = type{1};
        end
        
        %{
        Function: getEventVariableType()
        %}
        function out =  getEventVariableType(this, dataName, eventName)
            request = ['SELECT "type" FROM "MetaEventVariables" WHERE "event_name" = ' this.SQ dataName this.SQ ' AND "name" = ' this.SQ eventName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            type = record.getVariableValues('type');
            out = type{1};
        end
        
        %{
        Function: getSituationVariableType()
        %}
        function out =  getSituationVariableType(this, dataName, situationName)
            request = ['SELECT "type" FROM "MetaSituationVariables" WHERE "situation_name" = ' this.SQ dataName this.SQ ' AND name= ' this.SQ situationName this.SQ];
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, request));
            type = record.getVariableValues('type');
            out = type{1};
        end
        
    end
    %======================================================================================================%
    methods(Access = private, Static)
        %{
        Function:
        Check if the value is compatible with the type passed as argument.
        If not, it throws an exception. If the type is REAL and the
        argument is a string, if it is found convertible via str2double,
        the ',' characters are replaced with a '.'. Then it is converted to
        a string with a 0.0001 precision.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        value - The value to check.
        type - The type against which to check the value. It is on of the
        accepted type for the type attribute of the <data.MetaVariableBase>
        class.
        functionName - The name of the calling function, to customize
        exception messages.
        
        Throws:
        ARGUMENT_EXCEPTION - If the value is not convertible to the type.
        %}
        function out = checkInputTypeAndConvert(value, type)
            import fr.lescot.bind.exceptions.ExceptionIds
            isConvertible = true;
            switch type
                case 'REAL'
                    if ~isnumeric(value)
                        attemptedConversion = str2double(value);
                        if isnan(attemptedConversion)
                            isConvertible = false;
                        else
                            out = sprintf('%.12f', attemptedConversion);
                        end
                    else
                        out = sprintf('%.12f', value);
                    end
                case 'TEXT'
                    if ~ischar(value)
                        try
                            value = num2str(value);
                            %Replacing simple quotes by double simple quotes to
                            %avoid injection type bugs
                            out = strrep(value, '''', '''''');
                        catch ME %#ok<NASGU>
                            isConvertible = false;
                        end
                    else
                        %Replacing simple quotes by double simple quotes to
                        %avoid injection type bugs
                        out = strrep(value, '''', '''''');
                    end
                    
            end
            if ~isConvertible
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The value is not compatible with the chosen variable type'));
            end
        end
        
        
        %{
        Function:
        Get the default rule for the sqlite column for the given type.
        
        Arguments:
        type - Type of the column.
        %}
%         function out = getDefaultRule(type)
%             switch type
%                 case ('REAL', 'INTEGER')
%                     out = 'NOT NULL DEFAULT ""';
%                 case 'TEXT'
%                     out = '';
%             end
%         end
        
    end
    
    methods(Access = private)
        
        %{
        Function:
        Removes a line from a table, based on the timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - The name of the table.
        %}
        function removeLineFromTable(this, tableName, timecode)
            sqlite4m(this.connection, 'SAVEPOINT removeLineFromTable');
            try
                sqlite4m(this.connection, ['DELETE FROM "' tableName '" WHERE "timecode" = ' this.SQ sprintf('%.12f', timecode) this.SQ]);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeLineFromTable');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT removeLineFromTable');
        end
        
        %{
        Function:
        Removes a batch of line from a table, based on the timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - The name of the table.
        %}
        function removeLinesFromTable(this, tableName, startTime, endTime)
            sqlite4m(this.connection, 'SAVEPOINT removeLinesFromTable');
            try
                sqlite4m(this.connection, ['DELETE FROM "' tableName '" WHERE "TimeCode" BETWEEN ' this.SQ sprintf('%.12f', startTime) this.SQ ' AND ' this.SQ sprintf('%.12f', endTime) this.SQ]);
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT removeLinesFromTable');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT removeLinesFromTable');
        end
        
        %{
        Function:
        Adds a column to a table, based on the informations provided by
        a <data.MetaVariableBase> object.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data table on which to add a column, as
        a String.
        metaVariableBase - The <data.MetaVariableBase> (or extension of
        this class) that contains all the informations required to add a
        column.
        
        %}
        function addColumnFromMetaVariableBase(this, dataName, metaVariableBase, prefix)
            sqlite4m(this.connection, 'SAVEPOINT addColumnFromMetaVariableBase');
            type = metaVariableBase.getType();
            try
                sqlite4m(this.connection, ['ALTER TABLE "' prefix '_' dataName '" ADD COLUMN "' metaVariableBase.getName() '" ' type]); % if error occures, add : ' NOT NULL DEFAULT 0'
                this.createIndex([ prefix '_' dataName], metaVariableBase.getName());
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT addColumnFromMetaVariableBase');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT addColumnFromMetaVariableBase');
        end
        
        %{
        Function:
        Adds a full data table to the database, based on the informations provided by
        a <data.MetaBase> object.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        metaBase - The <data.MetaBase> (or extension of
        this class) that contains all the informations required to add a
        column.
        
        %}
        function createStorageTableFromMetaBase(this, metaBase, prefix)
            import fr.lescot.bind.exceptions.ExceptionIds;
            sqlite4m(this.connection, 'SAVEPOINT createStorageTableFromMetaBase');
            if isempty(metaBase.getName())
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(),'MetaBase object name musn''t be empty.'));
            end
            try
                %Creating the table for the data
                createRequest = ['CREATE TABLE "' prefix '_' char(metaBase.getName()) '" ('];
                variables = metaBase.getVariablesAndFrameworkVariables();
                for i = 1:1:length(variables)
                    variable = variables{i};
                    type = variable.getType();
                    createRequest = [createRequest '"' char(variable.getName()) '" ' type]; %#ok<AGROW> % if error occures, add : ' NOT NULL DEFAULT 0'
                    %if i < length(variables)
                    createRequest = [createRequest ', ']; %#ok<AGROW>
                    %end
                end
                
                %Creating the primary key
                keyVariables = metaBase.getFrameworkVariables();
                createRequest = [createRequest 'PRIMARY KEY('];
                for i = 1:1:length(keyVariables)
                    createRequest = [createRequest keyVariables{i}.getName()];
                    if i < length(keyVariables)
                        createRequest = [createRequest ', ']; %#ok<AGROW>
                    end
                end
                createRequest = [createRequest ')'];
                
                %Closing and executing the request
                createRequest = [createRequest ')'];
                sqlite4m(this.connection, createRequest);
                
                %Creating indexes on each column
                for i = 1:1:length(variables)
                    variable = variables{i};
                    this.createIndex([prefix '_' char(metaBase.getName())], char(variable.getName()));
                end
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT createStorageTableFromMetaBase');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT createStorageTableFromMetaBase');
        end
        
        %{
        Function:
        Insert some pairs of timecodes and values in a table. The time
        codes are inserted in the *timecode* column, while the values are
        inserted in the column passed in parameter. If the timecode
        already exist, the value of the column for this timecode is
        erased.
        To improve performances, some parameters tweaks are used is the scope of this method, which
        make the database integrity slightly less resistant to crashes
        and power cuts. But considering that BIND is not intended to treat
        critical data, the tradeoff is acceptable.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table in which to do the
        insertion.
        columnName - A string that contains the name of the column in
        which to insert the values.
        timeValueCellArray - A 2*n cell array with the timecodes on the
        first line and the associated values on the second line.
        
        %}
        function setBatchOfTimeValuePairs(this, tableName, columnName, timeValueCellArray)
            sqlite4m(this.connection, 'PRAGMA synchronous = OFF');
            sqlite4m(this.connection, 'PRAGMA journal_mode = MEMORY');
            
            sqlite4m(this.connection, 'SAVEPOINT setBatchOfTimeValuePairs');
            try
                checkExistenceStatement = sqlite4m(this.connection, 'prepare', ['SELECT "rowid" FROM "' char(tableName) '" WHERE "timecode" = ?1']);
                updateStatement = sqlite4m(this.connection, 'prepare', ['UPDATE "' char(tableName) '" SET "' char(columnName) '" = ?1 WHERE "timecode" = ?2']);
                insertStatement = sqlite4m(this.connection, 'prepare', ['INSERT INTO "' char(tableName) '"(timecode,"' char(columnName) '") VALUES(?1, ?2)']);
                [~, columns] = size(timeValueCellArray);
                for i=1:1:columns
                    time = sprintf('%.12f', timeValueCellArray{1,i});
                    value = timeValueCellArray{2,i};
                    requestResult = fr.lescot.bind.data.Record(sqlite4m(checkExistenceStatement, {time}));
                    if ~requestResult.isEmpty()
                        sqlite4m(updateStatement, {value, time});
                    else
                        sqlite4m(insertStatement, {time, value});
                    end
                end
                sqlite4m(checkExistenceStatement, 'finalize');
                sqlite4m(updateStatement, 'finalize');
                sqlite4m(insertStatement, 'finalize');
            catch ME
                sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT setBatchOfTimeValuePairs');
                rethrow(ME);
            end
            sqlite4m(this.connection, 'RELEASE SAVEPOINT setBatchOfTimeValuePairs');
            
            sqlite4m(this.connection, 'PRAGMA synchronous = ON');
            sqlite4m(this.connection, 'PRAGMA journal_mode = DELETE');
        end
        
        %{
        Function:
        Set the value of a given column for a timecode. If the timecode
        already exist, the value of the column for this timecode is
        erased, else, the timecode is created.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table in which to do the
        insertion.
        columnName - A string that contains the name of the column in
        which to insert the values.
        time - The timecode in seconds, as a number
        value - The value as a String.
        
        %}
        function setColumnValueAtTime(this, tableName, columnName, time, value)
            this.setBatchOfTimeValuePairs(tableName, columnName, {time; value});
        end
        
        
        %{
        Function:
        Return the list of values for a column in a given interval of
        time.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table in which to do the
        insertion.
        columnName - A string that contains the name of the column in
        which to insert the values.
        startTime - The starting timecode in seconds, as a number
        endTime - The end timecode in seconds, as a number
        
        Returns
        A cell array of values
        
        %}
        function out = getColumnInTimeInterval(this, tableName, columnName, startTime, endTime)
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT "' columnName '", "TimeCode" FROM "' tableName '" WHERE "TimeCode" BETWEEN ' this.SQ sprintf('%.12f', startTime) this.SQ ' AND ' this.SQ sprintf('%.12f', endTime) this.SQ ' ORDER BY "timecode" ASC']));
        end
        
        %{
        Function:
        Returns the max value of a list of column in a set of tables.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        cellArrayOfTableNames - A cell array of Strings containing the
        names of the tables in which to search the column.
        columnName - the name of the column to search in the tables.
        
        Returns:
        A numeric value.
        
        %}
        function out = getMaxValueOfVariableInTablesList(this, cellArrayOfTableNames, columnName)
            maxis = [];
            for i = 1:1:length(cellArrayOfTableNames)
                maxi = this.getColumnMaximum(cellArrayOfTableNames{i}, columnName);
                %if the value returned is empty, we don't count it in our
                %potential candidates for maximumness.
                if ~isempty(maxi)
                    maxis = [maxis maxi]; %#ok<AGROW>
                end
            end
            out = max(maxis);
        end
        
        %{
        Function:
        Returns the min value of a list of column in a set of tables.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        cellArrayOfTableNames - A cell array of Strings containing the
        names of the tables in which to search the column.
        columnName - the name of the column to search in the tables.
        
        Returns:
        A numeric value.
        
        %}
        function out = getMinValueOfVariableInTablesList(this, cellArrayOfTableNames, columnName)
            minis = [];
            for i = 1:1:length(cellArrayOfTableNames)
                mini = this.getColumnMinimum(cellArrayOfTableNames{i}, columnName);
                %if the value returned is empty, we don't count it in our
                %potential candidates for maximumness.
                if ~isempty(mini)
                    minis = [minis mini]; %#ok<AGROW>
                end
            end
            out = min(minis);
        end
        
        %{
        Function:
        Return the maximum value contained in a column, and NaN if the
        column is empty.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table in which the
        column is located.
        columnName - A string that contains the name of the column to
        search.
        
        Returns
        A value
        
        %}
        function out = getColumnMaximum(this, tableName, columnName)
            %The result field is renamed via AS clause to avoid a problem
            %with agreggates functions and sqlite4m (see
            %http://developer.berlios.de/forum/forum.php?forum_id=30244).
            request = ['SELECT max("' columnName '") AS "' columnName '" FROM "' tableName '" WHERE "' columnName '" <> "NaN"'];
            values = fr.lescot.bind.data.Record(sqlite4m(this.connection, request)).getVariableValues(columnName);
            % when no data are available, values contains {[]}. This lines
            % deals with error handling
            if ~isempty(values)
                value = values{1};
                if(isempty(value))
                    out = NaN;
                else
                    out = value;
                end
            else
                out = NaN;
            end
        end
        
        %{
        Function:
        Return the minimum value contained in a column, and NaN if the
        column is empty.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table in which the
        column is located.
        columnName - A string that contains the name of the column to
        search.
        
        Returns
        A value
        
        %}
        function out = getColumnMinimum(this, tableName, columnName)
            %The result field is renamed via AS clause to avoid a problem
            %with agreggates functions and sqlite4m (see
            %http://developer.berlios.de/forum/forum.php?forum_id=30244).
            request = ['SELECT min("' columnName '") AS "' columnName '" FROM "' tableName '" WHERE "' columnName '" <> "NaN"'];
            values = fr.lescot.bind.data.Record(sqlite4m(this.connection, request)).getVariableValues(columnName);
            % when no data are available in the trip, values becomes egal
            % to {[]}, this lines deals with it
            if ~isempty(values)
                value = values{1};
                if isempty(value)
                    out = NaN;
                else
                    out = value;
                end
            else
                out = NaN;
            end
        end
        
        %{
        Function:
        Return the lines contained in a time interval.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table to search.
        startTime - The starting timecode in seconds, as a number
        endTime - The end timecode in seconds, as a number
        
        Returns
        A <Record> object.
        
        %}
        function out = getLinesInTimeInterval(this, tableName, startTime, endTime)
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT * FROM "' tableName '" WHERE "TimeCode" BETWEEN ' this.SQ sprintf('%.12f', startTime) this.SQ ' AND ' this.SQ sprintf('%.12f', endTime) this.SQ ' ORDER BY "timecode" ASC']));
        end
        
        %{
        Function:
        Return the full line corresponding to the timecode
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table to search.
        time - The timecode in seconds, as a number
        
        Returns
        A <Record> object.
        
        %}
        function out = getLineAtTime(this, tableName, time)
            import fr.lescot.bind.exceptions.ExceptionIds;
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT * FROM "' tableName '" WHERE "TimeCode" = ' this.SQ sprintf('%.12f', time) this.SQ]));
            if(isempty(record.getVariableValues('TimeCode')))
                throw(MException(ExceptionIds.CONTENT_EXCEPTION.getId(), 'The time code was not found in the table'));
            else
                out = record ;
            end
        end
        
        %{
        Function:
        Return the full line corresponding which time code is the nearest
        of the given timecode.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table to search.
        time - The timecode in seconds, as a number
        
        Returns
        A <Record> object.
        
        %}
        function out = getLineNearTime(this, tableName, time)
            %The request is composed ....
            req = ['SELECT "TimeCode" FROM "' tableName '" ORDER BY ABS("TimeCode" - ' sprintf('%.12f', time) ') ASC LIMIT 1'];
            requestResult = fr.lescot.bind.data.Record(sqlite4m(this.connection, req));
            closerTimecode = requestResult.getVariableValues('TimeCode');
            closerTimecode = closerTimecode{1};
            
            req = ['SELECT * FROM "' tableName '"'];
            req = [req ' WHERE "TimeCode" = '];
            req = [req this.SQ sprintf('%.12f', closerTimecode) this.SQ];
            result = fr.lescot.bind.data.Record(sqlite4m(this.connection, req));
            
            out = result;
        end
        
        %{
        Function:
        Return the full content of a table ordered by increasing values of "timecode"
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table where to get the data.
        
        Returns
        A <Record> object.
        
        %}
        function out = getTableContent(this, tableName)
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT * FROM "' tableName '" ORDER BY "timecode" ASC']));
        end
        
        %{
        Function:
        Remove all the content of a table
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table where to delete the data.
        
        Returns
        A <Record> object.
        
        %}
        function out = removeTableContent(this, tableName)
            out = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['DELETE FROM "' tableName '"']));
        end
        
        %{
        Function:
        This methods throws an exception if the data identified by dataName
        is a base one, which means it is read only. The
        methodRequiringCheckName argument is used only for exception
        message customisation purpose.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        dataName - The name of the data to check.
        methodRequiringCheckName - The name of the methods that calls the
        check.
        
        
        Throws:
        DATA_EXCEPTION - if the data is marked as base.
        %}
        function checkIfIsBaseData(this, dataName)
            import fr.lescot.bind.exceptions.ExceptionIds;
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT isBase FROM MetaDatas WHERE name = ' this.SQ dataName this.SQ]));
            values = record.getVariableValues('isBase');
            if values{1}
                throw(MException(ExceptionIds.DATA_EXCEPTION.getId(), 'Modification of data could not be performed because this data is marked as base'));
            end
        end
        
        %{
        Function:
        This methods throws an exception if the event identified by
        eventName
        is a base one, which means it is read only. The
        methodRequiringCheckName argument is used only for exception
        message customisation purpose.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        eventName - The name of the event to check.
        methodRequiringCheckName - The name of the methods that calls the
        check.
        
        
        Throws:
        EVENT_EXCEPTION - if the event is marked as base.
        %}
        function checkIfIsBaseEvent(this, eventName)
            import fr.lescot.bind.exceptions.ExceptionIds;
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT isBase FROM MetaEvents WHERE name = ' this.SQ eventName this.SQ]));
            values = record.getVariableValues('isBase');
            if values{1}
                throw(MException(ExceptionIds.EVENT_EXCEPTION.getId(), 'Modification of event could not be performed because this event is marked as base'));
            end
        end
        
        %{
        Function:
        This methods throws an exception if the situation identified by
        situationName is a base one, which means it is read only. The
        methodRequiringCheckName argument is used only for exception
        message customisation purpose.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        situationName - The situation of the event to check.
        methodRequiringCheckName - The name of the methods that calls the
        check.
        
        
        Throws:
        SITUATION_EXCEPTION - if the data is marked as
        base.
        %}
        function checkIfIsBaseSituation(this, situationName)
            import fr.lescot.bind.exceptions.ExceptionIds;
            record = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['SELECT isBase FROM MetaSituations WHERE name = ' this.SQ situationName this.SQ]));
            values = record.getVariableValues('isBase');
            if values{1}
                throw(MException(ExceptionIds.SITUATION_EXCEPTION.getId(), 'Modification of situation could not be performed because this situation is marked as base'));
            end
        end
        
        %{
        Function:
        This function deletes a column from a table. As this function does
        not exist in sqlite, we have to create a new table with one less
        column, and copy all the data except the column to delete from the
        previous table.
        
        *Warning :* Very very long execution time ! It is advised to warn the
        user before the execution of a method based on dropColumn !
        %}
        function dropColumn(this, tableName, columnName)
            import fr.lescot.bind.exceptions.ExceptionIds;
            %First step : generate the list of the columns minus the column to drop
            %rowid = -1 never exist, but it allows us to get the list of
            %the columns
            variablesListRequest = fr.lescot.bind.data.Record(sqlite4m(this.connection, ['PRAGMA table_info("' tableName '")']));
            variablesList = variablesListRequest.getVariableValues('name');
            isUniqueList = variablesListRequest.getVariableValues('pk');
            typesList = variablesListRequest.getVariableValues('type');
            indicesToDelete = strcmp(columnName, variablesList);
            if any(indicesToDelete)
                variablesList(indicesToDelete) = [];
                isUniqueList(indicesToDelete) = [];
                typesList(indicesToDelete) = [];
                sqlite4m(this.connection, 'SAVEPOINT dropColumn');
                try
                    %Second step : generate a temporary table with a dump of the
                    %current table (always minus the column to drop)
                    createRequest = ['CREATE TABLE "' tableName '_temp" ('];
                    insertRequest = ['INSERT INTO "' tableName '_temp" SELECT '];
                    for i = 1:1:length(variablesList)
                        variable = variablesList{i};
                        type = typesList{i};
                        if  isUniqueList{i}
                            isUniqueString = 'UNIQUE ';
                        else
                            isUniqueString = '';
                        end
                        createRequest = [createRequest '"' variable '" ' type ' ' isUniqueString]; %#ok<AGROW> % if error occures, add : ' NOT NULL DEFAULT 0'
                        insertRequest = [insertRequest '"' variable '"']; %#ok<AGROW>
                        if i < length(variablesList)
                            createRequest = [createRequest ', ']; %#ok<AGROW>
                            insertRequest = [insertRequest ', ']; %#ok<AGROW>
                        end
                    end
                    createRequest = [createRequest ')'];
                    insertRequest = [insertRequest ' FROM "' tableName '"'];
                    sqlite4m(this.connection, createRequest);
                    sqlite4m(this.connection, insertRequest);
                    %Third step : drop the current table
                    dropRequest = ['DROP TABLE "' tableName '"'];
                    sqlite4m(this.connection, dropRequest);
                    %Fourth step : Rename temp table to tableName
                    renameRequest = ['ALTER TABLE "' tableName '_temp" RENAME TO "' tableName '"'];
                    sqlite4m(this.connection, renameRequest);
                    %Last step : recreate the indexes on all the columns
                    for i = 1:1:length(variablesList)
                        variableName = variablesList{i};
                        this.createIndex(tableName, variableName);
                    end
                catch ME
                    sqlite4m(this.connection, 'ROLLBACK TRANSACTION TO SAVEPOINT dropColumn');
                    rethrow(ME);
                end
            else
                throw(MException(ExceptionIds.SQL_EXCEPTION.getId(), 'The column was not found in the specified table'));
            end
            
            %Commits the transaction
            sqlite4m(this.connection, 'RELEASE SAVEPOINT dropColumn');
        end
        
        %{
        Function:
        Creates an index on the column, respecting the naming conventions
        of BIND (index_tableName_columnName).
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table in which the
        column is located.
        columnName - A string containing the name of the column to index.
        %}
        function createIndex(this, tableName, columnName)
            request = ['CREATE INDEX "index_' tableName '_' columnName '" ON "' tableName '"("' columnName '")'];
            sqlite4m(this.connection, request);
        end
        
        %{
        Function:
        Removes the index on the column, respection the naming conventions
        of BIND (index_tableName_columnName).
        
        Arguments:
        this - The object on which the function is called, optionnal.
        tableName - A string with the name of the table in which the
        column is located.
        columnName - A string containing the name of the column on which to remove the index.
        %}
        function removeIndex(this, tableName, columnName)
            request = ['DROP INDEX index_' tableName '_' columnName];
            sqlite4m(this.connection, request);
        end
        
    end
end