classdef RecordTest < TestCase
    
    methods
        function this = RecordTest(name)
            this = this@TestCase(name);
        end
        
        function testCompleteScenario(~)
          names = {'toto' 'titi' 'tata'};
          types = {'varchar' 'varchar' 'varchar' };
          frequencies = {50 50 50};
          comments = { '' '' 'lol'};
          isBase = { true true true};
          myStructure = struct('name',names, 'type',types, 'frequency', frequencies, 'comments', comments, 'isBase', isBase);
          
          % constructor
          f = @()fr.lescot.bind.data.Record(isBase);
          assertExceptionThrown(f, 'Record:Record:IncorrectArgument');
          
          testRecordObject  = fr.lescot.bind.data.Record(myStructure);
          assertFalse(testRecordObject.isEmpty());
          
          % getters
          
          variableNames = testRecordObject.getVariableNames();
          assertTrue(length(variableNames) == 5);
          assertTrue(strcmp(variableNames{1},'name'));
          assertTrue(strcmp(variableNames{2},'type'));
          assertTrue(strcmp(variableNames{3},'frequency'));
          assertTrue(strcmp(variableNames{4},'comments'));
          assertTrue(strcmp(variableNames{5},'isBase'));
          
          f = @()testRecordObject.getVariableValues('plumo');
          assertExceptionThrown(f, 'Record:getVariableValues:VariableNotFound');
          
          variableValues = testRecordObject.getVariableValues('name');
          assertTrue(length(variableValues) == 3);
          assertTrue(strcmp(variableValues{1},'toto'));
          assertTrue(strcmp(variableValues{2},'titi'));
          assertTrue(strcmp(variableValues{3},'tata'));
          
          
          % builder
          cellArray = testRecordObject.buildCellArrayWithVariables({'name' 'isBase'});
          [elements records] = size(cellArray);
          assertTrue(elements == 2);
          assertTrue(records == 3);
          
          
          
        end
        
    end
    
end

