classdef MetaInformationsTest < TestCase
    
    properties(Access = private)
        aMetaData;
        aMetaDataVariable;
        aMetaEvent;
        aMetaEventVariable;
        aMetaSituation;
        aMetaSituationVariable;
        aParticipant;
        aVideoFile;
        anAttributeKey;
        testMetaInformationsObject;
    end

    methods
        
        function setUp(this)
            %%%%%% first create all relevant objects
            % metadatas
            this.aMetaData = fr.lescot.bind.data.MetaData();
            this.aMetaData.setName('testMetaData1');
            this.aMetaData.setIsBase(true);
            this.aMetaData.setComments('LOL');
            this.aMetaDataVariable = fr.lescot.bind.data.MetaDataVariable();
            this.aMetaDataVariable.setName('testMetaDataVariable1');
            this.aMetaDataVariable.setType('real');
            this.aMetaData.setVariables({this.aMetaDataVariable});
            
            % metaEvent
            this.aMetaEvent = fr.lescot.bind.data.MetaEvent();
            this.aMetaEvent.setName('testMetaEvent1');
            this.aMetaEvent.setIsBase(true);
            this.aMetaEvent.setComments('LOL');
            this.aMetaEventVariable = fr.lescot.bind.data.MetaEventVariable();
            this.aMetaEventVariable.setName('testMetaEventVariable1');
            this.aMetaEventVariable.setType('real');
            this.aMetaEvent.setVariables({this.aMetaEventVariable});
            
            % metaSituation
            this.aMetaSituation = fr.lescot.bind.data.MetaSituation();
            this.aMetaSituation.setName('testMetaSituation1');
            this.aMetaSituation.setIsBase(true);
            this.aMetaSituation.setComments('LOL');
            this.aMetaSituationVariable = fr.lescot.bind.data.MetaSituationVariable();
            this.aMetaSituationVariable.setName('testMetaSituationVariable1');
            this.aMetaSituationVariable.setType('real');
            this.aMetaSituation.setVariables({this.aMetaSituationVariable});
            
            %participant
            this.aParticipant = fr.lescot.bind.data.MetaParticipant();
            this.aParticipant.setAttribute('name','LOL');            
                        
            %videoFile
            this.aVideoFile = fr.lescot.bind.data.MetaVideoFile('c:\toto.avi',0,'le chat');
            
            %attributes
            this.anAttributeKey = 'Name';       
            
            this.testMetaInformationsObject = fr.lescot.bind.data.MetaInformations();
        end
        
        function tearDown(~)
            clear('this.aMetaData');
            clear('this.aMetaDataVariable');
            clear('this.aMetaEvent');
            clear('this.aMetaEventVariable');
            clear('this.aMetaSituation');
            clear('this.aMetaSituationVariable');
            clear('this.aParticipant');
            clear('this.aVideoFile');
            clear('this.anAttributeKey');
            clear('this.testMetaInformationsObject');
        end
        
        function this = MetaInformationsTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(this)

            %%%%%%%% beginning of the test
            % with Data
          
            assertFalse(this.testMetaInformationsObject.existData('testMetaData1'));
            %assertFalse(testMetaInformationsObject.existDataVariable('testMetaData1','testMetaEventVariable1'));
            result = this.testMetaInformationsObject.getDatasList();
            assertTrue(isempty(result));
            result = this.testMetaInformationsObject.getDatasNamesList();
            assertTrue(isempty(result));
            
            this.testMetaInformationsObject.setDatasList({this.aMetaData});
            
            assertTrue(this.testMetaInformationsObject.existData('testMetaData1'));
            assertTrue(this.testMetaInformationsObject.existDataVariable('testMetaData1','testMetaDataVariable1'));
            
            testDatasList = this.testMetaInformationsObject.getDatasList();
            assertTrue(length(testDatasList)==1);
            testData = testDatasList{1};
            assertTrue(isa(testData,'fr.lescot.bind.data.MetaData'));
            assertTrue(strcmp(testData.getName(),'testMetaData1'));
            
            testDatasNamesList = this.testMetaInformationsObject.getDatasNamesList();
            assertTrue(length(testDatasNamesList)==1);
            assertTrue(strcmp(testDatasNamesList{1},'testMetaData1'));
            
            noMeta = @()this.testMetaInformationsObject.getMetaData('dummyMetaData1');
            assertExceptionThrown(noMeta, 'MetaInformations:getMetaData:dataNotFound'); 
            this.aMetaData = this.testMetaInformationsObject.getMetaData('testMetaData1');
            assertTrue(isa(this.aMetaData,'fr.lescot.bind.data.MetaData'));
            assertTrue(strcmp(this.aMetaData.getName,'testMetaData1'));

            wrongData = @()this.testMetaInformationsObject.getDataVariablesNamesList('dummyMetaData1');
            assertExceptionThrown(wrongData, 'MetaInformations:getMetaData:dataNotFound'); 
            variablesNames = this.testMetaInformationsObject.getDataVariablesNamesList('testMetaData1');
            assertTrue(length(variablesNames) == 2);
            assertTrue(any(strcmp(variablesNames,'testMetaDataVariable1')));
            
            % with Event
          
            assertFalse(this.testMetaInformationsObject.existEvent('testMetaEvent1'));
            %assertFalse(testMetaInformationsObject.existEventVariable('testMetaEvent1','testMetaEventVariable1'));
            result = this.testMetaInformationsObject.getEventsList();
            assertTrue(isempty(result));
            result = this.testMetaInformationsObject.getEventsNamesList();
            assertTrue(isempty(result));

            
            this.testMetaInformationsObject.setEventsList({this.aMetaEvent});
            
            assertTrue(this.testMetaInformationsObject.existEvent('testMetaEvent1'));
            assertTrue(this.testMetaInformationsObject.existEventVariable('testMetaEvent1','testMetaEventVariable1'));
            
            testEventsList = this.testMetaInformationsObject.getEventsList();
            assertTrue(length(testEventsList)==1);
            testEvent = testEventsList{1};
            assertTrue(isa(testEvent,'fr.lescot.bind.data.MetaEvent'));
            assertTrue(strcmp(testEvent.getName(),'testMetaEvent1'));
            
            testEventsNamesList = this.testMetaInformationsObject.getEventsNamesList();
            assertTrue(length(testEventsNamesList)==1);
            assertTrue(strcmp(testEventsNamesList{1},'testMetaEvent1'));
            
            noMeta = @()this.testMetaInformationsObject.getMetaEvent('dummyMetaEvent1');
            assertExceptionThrown(noMeta, 'MetaInformations:getMetaEvent:eventNotFound'); 
            this.aMetaEvent = this.testMetaInformationsObject.getMetaEvent('testMetaEvent1');
            assertTrue(isa(this.aMetaEvent,'fr.lescot.bind.data.MetaEvent'));
            assertTrue(strcmp(this.aMetaEvent.getName,'testMetaEvent1'));
            
            wrongEvent = @()this.testMetaInformationsObject.getEventVariablesNamesList('dummyMetaEvent1');
            assertExceptionThrown(wrongEvent, 'MetaInformations:getMetaEvent:eventNotFound'); 

            variablesNames = this.testMetaInformationsObject.getEventVariablesNamesList('testMetaEvent1');
            assertTrue(length(variablesNames) == 2);
            assertTrue(any(strcmp(variablesNames,'testMetaEventVariable1')));
            
            % with Situation
          
            assertFalse(this.testMetaInformationsObject.existSituation('testMetaSituation1'));
            %assertFalse(testMetaInformationsObject.existSituationVariable('testMetaSituation1','testMetaSituationVariable1'));
            
            this.testMetaInformationsObject.setSituationsList({this.aMetaSituation});
            
            assertTrue(this.testMetaInformationsObject.existSituation('testMetaSituation1'));
            assertTrue(this.testMetaInformationsObject.existSituationVariable('testMetaSituation1','testMetaSituationVariable1'));
            
            testSituationsList = this.testMetaInformationsObject.getSituationsList();
            assertTrue(length(testSituationsList)==1);
            testSituation = testSituationsList{1};
            assertTrue(isa(testSituation,'fr.lescot.bind.data.MetaSituation'));
            assertTrue(strcmp(testSituation.getName(),'testMetaSituation1'));
            
            testSituationsNamesList = this.testMetaInformationsObject.getSituationsNamesList();
            assertTrue(length(testSituationsNamesList)==1);
            assertTrue(strcmp(testSituationsNamesList{1},'testMetaSituation1'));
            
            noMeta = @()this.testMetaInformationsObject.getMetaSituation('dummyMetaSituation1');
            assertExceptionThrown(noMeta, 'MetaInformations:getMetaSituation:situationNotFound'); 
            this.aMetaSituation = this.testMetaInformationsObject.getMetaSituation('testMetaSituation1');
            assertTrue(isa(this.aMetaSituation,'fr.lescot.bind.data.MetaSituation'));
            assertTrue(strcmp(this.aMetaSituation.getName,'testMetaSituation1'));
            
            wrongSituation = @()this.testMetaInformationsObject.getSituationVariablesNamesList('dummyMetaSituation1');
            assertExceptionThrown(wrongSituation, 'MetaInformations:getMetaSituation:situationNotFound'); 
            variablesNames = this.testMetaInformationsObject.getSituationVariablesNamesList('testMetaSituation1');
            assertTrue(length(variablesNames) == 3);
            assertTrue(any(strcmp(variablesNames,'testMetaSituationVariable1')));

            
            % test for participant
            testParticipant = this.testMetaInformationsObject.getParticipant();
            assertTrue(isempty(testParticipant));
            this.testMetaInformationsObject.setParticipant(this.aParticipant);
            testParticipant = this.testMetaInformationsObject.getParticipant();
            assertTrue(strcmp(testParticipant.getAttribute('name'),'LOL'));
            
            % test for videoFile
            testVideoFile = this.testMetaInformationsObject.getVideoFiles();
            assertTrue(isempty(testVideoFile));
            this.testMetaInformationsObject.setVideoFiles({this.aVideoFile});
            testVideoFile = this.testMetaInformationsObject.getVideoFiles();
            assertTrue(length(testVideoFile)==1)
            assertTrue(isa(testVideoFile{1},'fr.lescot.bind.data.MetaVideoFile'));
            assertTrue(strcmp(testVideoFile{1}.getFileName(),'c:\toto.avi'));
            
            %test for attributes
            testAttributes = this.testMetaInformationsObject.getTripAttributesList();
            assertTrue(isempty(testAttributes));
            this.testMetaInformationsObject.setTripAttributesList({this.anAttributeKey});
            testAttributes = this.testMetaInformationsObject.getTripAttributesList();
            assertTrue(length(testAttributes)==1)
            assertTrue(strcmp(testAttributes{1},'Name'));
        end
        
        function testDemande106(this)
            this.testMetaInformationsObject.setDatasList({this.aMetaData});
            assertTrue(this.testMetaInformationsObject.existDataVariable('testMetaData1', 'testMetaDataVariable1'));
            assertFalse(this.testMetaInformationsObject.existDataVariable('testMetaData2', 'testMetaDataVariable1'));
            
            this.testMetaInformationsObject.setEventsList({this.aMetaEvent});
            assertTrue(this.testMetaInformationsObject.existEventVariable('testMetaEvent1', 'testMetaEventVariable1'));
            assertFalse(this.testMetaInformationsObject.existDataVariable('testMetaEvent2', 'testMetaEventVariable1'));
            
            this.testMetaInformationsObject.setSituationsList({this.aMetaSituation});
            assertTrue(this.testMetaInformationsObject.existSituationVariable('testMetaSituation1', 'testMetaSituationVariable1'));
            assertFalse(this.testMetaInformationsObject.existSituationVariable('testMetaSituation2', 'testMetaSituationVariable1'));
        end
    end
    
end

