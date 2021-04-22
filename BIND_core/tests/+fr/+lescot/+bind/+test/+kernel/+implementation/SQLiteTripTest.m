classdef SQLiteTripTest < TestCase
    
    properties(Access = private)
        emptyTrip;
        demoTrip;
    end
    
    methods
        function this = SQLiteTripTest(name)
            this = this@TestCase(name);
        end
        
        function setUp(this)
            global parameter_examplesPath;
            copyfile([parameter_examplesPath filesep 'empty.trip'], [getenv('TEMP') filesep 'emptyCopy.trip'],'f');
            copyfile([parameter_examplesPath filesep 'demoTrip.trip'], [getenv('TEMP') filesep 'demoTripCopy.trip'], 'f');
            this.emptyTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip([getenv('TEMP') filesep 'emptyCopy.trip'], 0.04, false);
            this.demoTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip([getenv('TEMP') filesep 'demoTripCopy.trip'], 0.04, false);
        end
        
        function tearDown(this)
            this.emptyTrip.delete();
            this.demoTrip.delete();
            delete([getenv('TEMP') filesep 'emptyCopy.trip'])
            delete([getenv('TEMP') filesep 'demoTripCopy.trip']);
        end
        
        function testAttributes(this)
            this.emptyTrip.setAttribute('testAttr', '42');
            assertEqual('42', this.emptyTrip.getAttribute('testAttr'));
            this.emptyTrip.setAttribute('testAttr', '45');
            assertEqual('45', this.emptyTrip.getAttribute('testAttr'));
            this.emptyTrip.removeAttribute('testAttr')
            f = @()this.emptyTrip.getAttribute('testAttr');
            assertExceptionThrown(f, 'SQLiteTrip:getAttribute:keyNotFound');
            
            f = @()this.emptyTrip.getAttribute('toto');
            assertExceptionThrown(f, 'SQLiteTrip:getAttribute:keyNotFound');
            f = @() this.emptyTrip.removeAttribute('bob');
            assertExceptionThrown(f, 'SQLiteTrip:removeAttribute:keyNotFound');
        end
        
        function testTransactions(this)
            %standard behaviour
            this.demoTrip.beginTransaction();
            this.demoTrip.setAttribute('toto', '42');
            this.demoTrip.commitTransaction();
            assertTrue(strcmp('42', this.demoTrip.getAttribute('toto')));
            %rollback behaviour
            this.demoTrip.beginTransaction();
            this.demoTrip.setAttribute('tata', '51');
            this.demoTrip.rollbackTransaction();
            f = @() this.emptyTrip.removeAttribute('tata');
            assertExceptionThrown(f, 'SQLiteTrip:removeAttribute:keyNotFound');
        end
        
        function testDataAndDataVariablesManagement(this)
            %Ok, first of all, let's test we're able to add a couple of Data to a
            %trip
            data1 = fr.lescot.bind.data.MetaData();
            data1.setName('data1');
            
            data2 = fr.lescot.bind.data.MetaData();
            data2.setName('data2');
            
            data1variable1 = fr.lescot.bind.data.MetaDataVariable();
            data1variable1.setName('d1v1');
            data1variable1.setType('TEXT');

            data1variable2 = fr.lescot.bind.data.MetaDataVariable();
            data1variable2.setName('d1v2');
            data1variable2.setType('REAL');
            
            data1variable3 = fr.lescot.bind.data.MetaDataVariable();
            data1variable3.setName('d1v3');
            %data1variable3 keep the default type value : REAL
            
            data1.setVariables({data1variable1 data1variable2 data1variable3});
            
            data2variable1 = fr.lescot.bind.data.MetaDataVariable();
            data2variable1.setName('d2v1');
            data2variable1.setType('TEXT');
            
            data2variable2 = fr.lescot.bind.data.MetaDataVariable();
            data2variable2.setName('d2v2');
            data2variable2.setType('TEXT');
            
            data2.setVariables({data2variable1 data2variable2});
            
            this.emptyTrip.addData(data1);
            this.emptyTrip.addData(data2);
            %Now the data, are set, let's check they've been properly
            %inserted
            metaInfos = this.emptyTrip.getMetaInformations();
            dataNamesList = metaInfos.getDatasNamesList();
            assertTrue(all(strcmp({'data1' 'data2'}, dataNamesList)));
            %Check if data1 is correct
            metaData = metaInfos.getMetaData('data1');
            metaVariables = metaData.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 'd1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'d1v2' 'd1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if data2 is correct
            metaData = metaInfos.getMetaData('data2');
            metaVariables = metaData.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'d2v1' 'd2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Now we remove d1v3 and retest
            this.emptyTrip.removeDataVariable('data1', 'd1v3');
            metaInfos = this.emptyTrip.getMetaInformations();
            dataNamesList = metaInfos.getDatasNamesList();
            assertTrue(all(strcmp({'data1' 'data2'}, dataNamesList)));
            %Check if data1 is correct
            metaData = metaInfos.getMetaData('data1');
            metaVariables = metaData.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 'd1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case 'd1v2'
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if data2 is correct
            metaData = metaInfos.getMetaData('data2');
            metaVariables = metaData.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'d2v1' 'd2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Now we add back variable 3 to the trip, and proceed to the
            %checks again
            this.emptyTrip.addDataVariable('data1', data1variable3);
            metaInfos = this.emptyTrip.getMetaInformations();
            dataNamesList = metaInfos.getDatasNamesList();
            assertTrue(all(strcmp({'data1' 'data2'}, dataNamesList)));
            %Check if data1 is correct
            metaData = metaInfos.getMetaData('data1');
            metaVariables = metaData.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 'd1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'d1v2' 'd1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if data2 is correct
            metaData = metaInfos.getMetaData('data2');
            metaVariables = metaData.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'d2v1' 'd2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Finally we test to remove the whole data2
            this.emptyTrip.removeData('data2');
            %And we check that data1 is left intact
            metaInfos = this.emptyTrip.getMetaInformations();
            dataNamesList = metaInfos.getDatasNamesList();
            assertEqual(length(dataNamesList), 1);
            assertTrue(all(strcmp({'data1'}, dataNamesList)));
            %Check if data1 is correct
            metaData = metaInfos.getMetaData('data1');
            metaVariables = metaData.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 'd1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'d1v2' 'd1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
        end
        
        function testEventAndEventVariablesManagement(this)
            %Ok, first of all, let's test we're able to add a couple of Data to a
            %trip
            event1 = fr.lescot.bind.data.MetaEvent();
            event1.setName('event1');
            
            event2 = fr.lescot.bind.data.MetaEvent();
            event2.setName('event2');
            
            event1variable1 = fr.lescot.bind.data.MetaEventVariable();
            event1variable1.setName('e1v1');
            event1variable1.setType('TEXT');

            event1variable2 = fr.lescot.bind.data.MetaEventVariable();
            event1variable2.setName('e1v2');
            event1variable2.setType('REAL');
            
            event1variable3 = fr.lescot.bind.data.MetaEventVariable();
            event1variable3.setName('e1v3');
            %event1variable3 keep the default type value : REAL
            
            event1.setVariables({event1variable1 event1variable2 event1variable3});
            
            event2variable1 = fr.lescot.bind.data.MetaEventVariable();
            event2variable1.setName('e2v1');
            event2variable1.setType('TEXT');
            
            event2variable2 = fr.lescot.bind.data.MetaEventVariable();
            event2variable2.setName('e2v2');
            event2variable2.setType('TEXT');
            
            event2.setVariables({event2variable1 event2variable2});
            
            this.emptyTrip.addEvent(event1);
            this.emptyTrip.addEvent(event2);
            %Now the events, are set, let's check they've been properly
            %inserted
            metaInfos = this.emptyTrip.getMetaInformations();
            eventNamesList = metaInfos.getEventsNamesList();
            assertTrue(all(strcmp({'event1' 'event2'}, eventNamesList)));
            %Check if event1 is correct
            metaEvent = metaInfos.getMetaEvent('event1');
            metaVariables = metaEvent.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 'e1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'e1v2' 'e1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if event2 is correct
            metaEvent = metaInfos.getMetaEvent('event2');
            metaVariables = metaEvent.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'e2v1' 'e2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Now we remove e1v3 and retest
            this.emptyTrip.removeEventVariable('event1', 'e1v3');
            metaInfos = this.emptyTrip.getMetaInformations();
            eventNamesList = metaInfos.getEventsNamesList();
            assertTrue(all(strcmp({'event1' 'event2'}, eventNamesList)));
            %Check if event1 is correct
            metaEvent = metaInfos.getMetaEvent('event1');
            metaVariables = metaEvent.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 'e1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case 'e1v2'
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if event2 is correct
            metaEvent = metaInfos.getMetaEvent('event2');
            metaVariables = metaEvent.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'e2v1' 'e2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Now we add back variable 3 to the trip, and proceed to the
            %checks again
            this.emptyTrip.addEventVariable('event1', event1variable3);
            metaInfos = this.emptyTrip.getMetaInformations();
            eventNamesList = metaInfos.getEventsNamesList();
            assertTrue(all(strcmp({'event1' 'event2'}, eventNamesList)));
            %Check if event1 is correct
            metaEvent = metaInfos.getMetaEvent('event1');
            metaVariables = metaEvent.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 'e1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'e1v2' 'e1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if event2 is correct
            metaEvent = metaInfos.getMetaEvent('event2');
            metaVariables = metaEvent.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'e2v1' 'e2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Finally we test to remove the whole event2
            this.emptyTrip.removeEvent('event2');
            %And we check that event1 is left intact
            metaInfos = this.emptyTrip.getMetaInformations();
            eventNamesList = metaInfos.getEventsNamesList();
            assertTrue(all(strcmp({'event1'}, eventNamesList)));
            
            metaEvent = metaInfos.getMetaEvent('event1');
            metaVariables = metaEvent.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 'e1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'e1v2' 'e1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Try to remove a non existent variable from an existent Event
            f = @() this.emptyTrip.removeEventVariable('event1', 'var666');
            assertExceptionThrown(f, 'SQLiteTrip:removeEventVariable:variableNotFound');
            %Try to remove a variable from a non existent Event
            f = @() this.emptyTrip.removeEventVariable('event007', 'var666');
            assertExceptionThrown(f, 'SQLiteTrip:removeEventVariable:eventNotFound');
            %Try to remove a non existent Event

        end
        
        function testSituationAndSituationVariablesManagement(this)
            %Ok, first of all, let's test we're able to add a couple of Situation to a
            %trip
            situation1 = fr.lescot.bind.data.MetaSituation();
            situation1.setName('situation1');
            
            situation2 = fr.lescot.bind.data.MetaSituation();
            situation2.setName('situation2');
            
            situation1variable1 = fr.lescot.bind.data.MetaSituationVariable();
            situation1variable1.setName('s1v1');
            situation1variable1.setType('TEXT');

            situation1variable2 = fr.lescot.bind.data.MetaSituationVariable();
            situation1variable2.setName('s1v2');
            situation1variable2.setType('REAL');
            
            situation1variable3 = fr.lescot.bind.data.MetaSituationVariable();
            situation1variable3.setName('s1v3');
            %situation1variable3 keep the default type value : REAL
            
            situation1.setVariables({situation1variable1 situation1variable2 situation1variable3});
            
            situation2variable1 = fr.lescot.bind.data.MetaSituationVariable();
            situation2variable1.setName('s2v1');
            situation2variable1.setType('TEXT');
            
            situation2variable2 = fr.lescot.bind.data.MetaSituationVariable();
            situation2variable2.setName('s2v2');
            situation2variable2.setType('TEXT');
            
            situation2.setVariables({situation2variable1 situation2variable2});
            
            this.emptyTrip.addSituation(situation1);
            this.emptyTrip.addSituation(situation2);
            %Now the events, are set, let's check they've been properly
            %inserted
            metaInfos = this.emptyTrip.getMetaInformations();
            situationNamesList = metaInfos.getSituationsNamesList();
            assertTrue(all(strcmp({'situation1' 'situation2'}, situationNamesList)));
            %Check if situation1 is correct
            metaSituation = metaInfos.getMetaSituation('situation1');
            metaVariables = metaSituation.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 's1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'s1v2' 's1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if situation2 is correct
            metaSituation = metaInfos.getMetaSituation('situation2');
            metaVariables = metaSituation.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'s2v1' 's2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Now we remove s1v3 and retest
            this.emptyTrip.removeSituationVariable('situation1', 's1v3');
            metaInfos = this.emptyTrip.getMetaInformations();
            situationNamesList = metaInfos.getSituationsNamesList();
            assertTrue(all(strcmp({'situation1' 'situation2'}, situationNamesList)));
            %Check if situation1 is correct
            metaSituation = metaInfos.getMetaSituation('situation1');
            metaVariables = metaSituation.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 's1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case 's1v2'
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if event2 is correct
            metaSituation = metaInfos.getMetaSituation('situation2');
            metaVariables = metaSituation.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'s2v1' 's2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Now we add back variable 3 to the trip, and proceed to the
            %checks again
            this.emptyTrip.addSituationVariable('situation1', situation1variable3);
            metaInfos = this.emptyTrip.getMetaInformations();
            situationNamesList = metaInfos.getSituationsNamesList();
            assertTrue(all(strcmp({'situation1' 'situation2'}, situationNamesList)));
            %Check if situation1 is correct
            metaSituation = metaInfos.getMetaSituation('situation1');
            metaVariables = metaSituation.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 's1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'s1v2' 's1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
            %Check if situation2 is correct
            metaSituation = metaInfos.getMetaSituation('situation2');
            metaVariables = metaSituation.getVariables();
            assertEqual(2, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case {'s2v1' 's2v2'}
                        assertEqual(metaVariable.getType(), 'TEXT');
                    otherwise
                        assertTrue(false);
                end
            end
            %Finally we test to remove the whole situation2
            this.emptyTrip.removeSituation('situation2');
            %And we check that situation1 is left intact
            metaInfos = this.emptyTrip.getMetaInformations();
            situationNamesList = metaInfos.getSituationsNamesList();
            assertTrue(all(strcmp({'situation1'}, situationNamesList)));
            
            metaSituation = metaInfos.getMetaSituation('situation1');
            metaVariables = metaSituation.getVariables();
            assertEqual(3, length(metaVariables))
            for i = 1:1:length(metaVariables)
                metaVariable = metaVariables{i};
                switch(metaVariable.getName())
                    case 's1v1'
                        assertEqual(metaVariable.getType(), 'TEXT');
                    case {'s1v2' 's1v3'}
                        assertEqual(metaVariable.getType(), 'REAL');
                    otherwise
                        assertTrue(false);
                end
            end
        end
        
        function testVideoFilesManagement(this)
            videoFile = fr.lescot.bind.data.MetaVideoFile('./toto.avi', 0, 'A video file');
            %Test adding the videoFile
            this.emptyTrip.addVideoFile(videoFile);
            metaInfos = this.emptyTrip.getMetaInformations();
            videoFilesFromTrip = metaInfos.getVideoFiles();
            assertEqual(1, length(videoFilesFromTrip));
            videoFileFromTrip = videoFilesFromTrip{1};
            [path, ~, ~] = fileparts(this.emptyTrip.getTripPath());
            assertEqual([path filesep './toto.avi'], videoFileFromTrip.getFileName());
            assertEqual(0, videoFileFromTrip.getOffset());
            assertEqual('A video file', videoFileFromTrip.getDescription());
            %Test removing it
            this.emptyTrip.removeVideoFile('./toto.avi');
            metaInfos = this.emptyTrip.getMetaInformations();
            videoFilesFromTrip = metaInfos.getVideoFiles();
            assertEqual(0, length(videoFilesFromTrip));
            %We try to add again the video file, in order to check some
            %post-deletion potential errors
            this.emptyTrip.addVideoFile(videoFile);
            metaInfos = this.emptyTrip.getMetaInformations();
            videoFilesFromTrip = metaInfos.getVideoFiles();
            assertEqual(1, length(videoFilesFromTrip));
            videoFileFromTrip = videoFilesFromTrip{1};
            [path, ~, ~] = fileparts(this.emptyTrip.getTripPath());
            assertEqual([path filesep './toto.avi'], videoFileFromTrip.getFileName());
            assertEqual(0, videoFileFromTrip.getOffset());
            assertEqual('A video file', videoFileFromTrip.getDescription());
            %TODO : test adding with absolute path
            videoFile.setFileName('c:\toto.avi');
            f = @()this.emptyTrip.addVideoFile(videoFile);
            assertExceptionThrown(f, 'SQLiteTrip:addVideoFile:IncorrectArgument');
        end
        
        
    end
end