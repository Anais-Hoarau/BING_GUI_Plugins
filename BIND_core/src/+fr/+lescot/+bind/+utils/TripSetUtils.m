%{
Class:
This class contains some static methods concerning TripSets.
%}

classdef TripSetUtils
    
    methods(Static)
        
        %Function: loadAllTripsInSubdirectory()
        %This function allow to load recursivley all the SQLite trips from
        %the given directory. It will basically attempt to open any *.trip
        %file found.
        %
        %Arguments:
        %directory - the folder containing all the trips
        %
        %Returns:
        %A <kernel.TripSet> object.
        %
        %Modifiers:
        %- Static
        function out = loadAllSQLiteTripsInSubdirectory(directory)
            filesList = fr.lescot.bind.utils.DirUtils.recursiveFileListing(directory,'.*\.trip$');
            trips = cell(1, length(filesList));
            for i = 1:1:length(filesList)
                    trips{i} = fr.lescot.bind.kernel.implementation.SQLiteTrip(filesList{i}, 0.04, false);
            end
            out = fr.lescot.bind.kernel.TripSet();
            out.setTrips(trips);
        end
        
        
        %Function: export2Excel()
        %This function allow to making exports to Excel
        %Each Event/Situation will be an Excel file and each variable will be a sheet
        %
        %Arguments:
        %tripSet - an object TripSet containing all the trips
        %tripsAttributesList - a 1*m cell array containing the attributes requested, each in the format: NameOfAttribute
        %participantAttributesList - a 1*n cell array containing the
        %participantAttributesList to insert for each trip, each in the format : NameOfParticipanAttribute
        %eventsVariablesList - a 1*n cell array containing the events variables requested, each in the format: NameOfEvent.NameOfEventVariable
        %eventVariablesForOccurenceLabel - a 1*n cell array containing the events variables used to name the colonnes in Excel, each in the format: NameOfEvent.NameOfEventVariable
        %situationsVariablesList - a 1*k cell array containing the situations variables requested, each in the format: NameOfSituation.NameOfSituationVariable
        %situationVariablesForOccurenceLabel - a 1*k cell array containing the situations variables requested, each in the format: NameOfSituation.NameOfSituationVariable
        %outputFolder - a string of the routine where to save the file Excel
        %
        %Modifiers:
        %- Static
%         function export2Excel(tripSet,tripsAttributesList,participantAttributesList,eventsVariablesList,eventVariablesForOccurenceLabel,situationsVariablesList,situationVariablesForOccurenceLabel,outputFolder)
%             
%             attributesQuantity = size(tripsAttributesList , 2);
%             
%             if ~isempty(eventsVariablesList)
%                 for i = 1:length(eventsVariablesList)
%                     element = eventsVariablesList{i};
%                     eventName = element(1:strfind(eventsVariablesList{i},'.')-1);
%                     eventExcel = [outputFolder '\' eventName '.xls'];
%                     variableName = element(strfind(eventsVariablesList{i},'.')+1 : length(element));
%                     variableValue = tripSet.getEventVariableValuesForAllTrips(eventsVariablesList{i});
%                     colonnesNames = tripSet.getEventVariableValuesForAllTrips(eventVariablesForOccurenceLabel{i});
%                     names = [tripsAttributesList colonnesNames{1,:}];
%                     xlswrite(eventExcel,{names{1,:}},variableName);
%                     values = cell2mat(variableValue);
%                     ind = 2;
%                     for j = 1:size(tripsAttributesList,1)
%                         xlswrite(eventExcel,{tripsAttributesList{j,:}},variableName,[fr.lescot.bind.utils.TripSetUtils.generateExcelColumnNameFromIndex(1),num2str(ind)]);
%                         xlswrite(eventExcel,values(j,:),variableName,[fr.lescot.bind.utils.TripSetUtils.generateExcelColumnNameFromIndex(1+attributesQuantity),num2str(ind)]);
%                         ind = ind + 1;
%                     end
%                 end
%             end
%             if ~isempty(situationsVariablesList)
%                 for i = 1:length(situationsVariablesList)
%                     element = situationsVariablesList{i};
%                     situationName = element(1:strfind(situationsVariablesList{i},'.')-1);
%                     situationExcel = [outputFolder '\' situationName '.xls'];
%                     variableName = element(strfind(situationsVariablesList{i},'.')+1 : length(element));
%                     variableValue = tripSet.getSituationVariableValuesForAllTrips(situationsVariablesList{i});
%                     colonnesNames = tripSet.getSituationVariableValuesForAllTrips(situationVariablesForOccurenceLabel{i});
%                     names = [tripsAttributesList colonnesNames{1,:}];
%                     xlswrite(situationExcel,{names{1,:}},variableName);
%                     values = cell2mat(variableValue);
%                     ind = 2;
%                     for j = 1:size(tripsAttributesList,1)
%                         xlswrite(situationExcel,{tripsAttributesList{j,:}},variableName,[fr.lescot.bind.utils.TripSetUtils.generateExcelColumnNameFromIndex(1),num2str(ind)]);
%                         xlswrite(situationExcel,values(j,:),variableName,[fr.lescot.bind.utils.TripSetUtils.generateExcelColumnNameFromIndex(1+attributesQuantity),num2str(ind)]);
%                         ind = ind + 1;
%                     end
%                 end
%             end
%         end
        
            
        function export2Excel(tripSet,tripsAttributesList,participantAttributesList,eventsVariablesList, eventVariablesAsColumnId, situationsVariablesList,situationVariablesAsColumnId, outputFolder, rootName)
            %todo : vérifier que le nombre de variables et celui d'ID
            %concordent
            
            %For each variable identifier, we create a sheet in the Excel spreadsheet
            if ~isempty(eventsVariablesList)
                
                splittedEvents = cell(length(eventsVariablesList), 2);
                for i = 1:1:length(eventsVariablesList)
                    [splittedEvents(i, 1) remain] = strtok(eventsVariablesList(i), '.');
                    splittedEvents(i, 2) = strtok(remain, '.');
                end


                tripsAttributesCellArray = tripSet.getAttributesValuesForAllTrips(tripsAttributesList);
                participantAttributesCellArray = tripSet.getParticipantAttributesValuesForAllTrips(participantAttributesList);
                    
                arrayOfArraysToWrite = fr.lescot.bind.utils.TripSetUtils.generateArrayForEventVariables(tripSet, splittedEvents, eventVariablesAsColumnId, tripsAttributesCellArray, participantAttributesCellArray);
 
                %Writing events
                xlsFile = [outputFolder filesep rootName '_event.xls'];
                disp(['Writing events in ' xlsFile]);
                for i = 1:1:length(arrayOfArraysToWrite)
                   xlswrite(xlsFile, arrayOfArraysToWrite{i}, eventsVariablesList{i}); 
                end
            end
        end
        
    end
    

    methods(Access = private, Static)
        
        function out = generateArrayForEventVariables(tripSet, splittedEvents, eventVariablesAsColumnId, tripsAttributesCellArray, participantAttributesCellArray)
            %TODO : optim en itérant que sur les events uniques pour
            %limiter les appels à getEventVariablesValuesForAllTrips (pas
            %sur que ca soit faisable)
            numberOfEvents = size(splittedEvents, 1);
            out = cell(1, numberOfEvents);
            for i = 1:1:numberOfEvents
                eventName = char(splittedEvents{i, 1});
                variableName = char(splittedEvents{i, 2});
                variableValuesCellArray = tripSet.getEventVariablesValuesForAllTrips(eventName);
                eventVariableAsColumnId = eventVariablesAsColumnId{i};
                out{i} = fr.lescot.bind.utils.TripSetUtils.generateSheetForEventVariable(variableName, variableValuesCellArray, eventVariableAsColumnId, tripsAttributesCellArray, participantAttributesCellArray);
            end
        end
        
        function out = generateSheetForEventVariable(variableName, variableValuesCellArray, variableAsColumnId, tripsAttributesCellArray, participantAttributesCellArray)
            disp(['Generating sheet for variable "' variableName '" with id column "' variableAsColumnId '"']);
           
            %We search the unique ids for the events
            idsList = {};
            for j = 1:1:length(variableValuesCellArray)
                ids = variableValuesCellArray{j}.getVariableValues(variableAsColumnId);
                idsList = [idsList ids];
            end
            idsList = unique(idsList);
            
            numberOfIds = length(idsList);  
            numberOfAttributes = length(tripsAttributesCellArray);
            numberOfParticipantAttributes = length(participantAttributesCellArray);
            numberOfLines = length(variableValuesCellArray);
            
            sheet = cell(numberOfLines , numberOfAttributes + numberOfParticipantAttributes + numberOfIds );
            
            %We add the trip attributes
            for j = 1:1:numberOfLines
                for k = 1:1:numberOfAttributes
                    sheet{j + 1, k} =  tripsAttributesCellArray{k};
                end
            end
            
            %We add the attributes of the participant
            for j = 1:1:numberOfLines
                for k = 1:1:numberOfParticipantAttributes
                    sheet{j + 1, numberOfAttributes + k} =  participantAttributesCellArray{k};
                end
            end
            
            
            
            %We add the unique ids as header for the columns
            for j = 1:1:length(idsList)
                sheet{1, numberOfAttributes + numberOfParticipantAttributes + j} = idsList{j};
            end

            %Filling with the data
            for j = 1:1:numberOfLines
                dataRecord = variableValuesCellArray{j};
                eventOccurences  = dataRecord.getVariableValues(variableName);
                eventIds = dataRecord.getVariableValues(variableAsColumnId);
                for k = 1:1:length(eventOccurences)
                   eventId = eventIds{k};
                   eventOccurence = eventOccurences{k};
                   logicalIndex = strcmpi(eventId, sheet(1, 1:numberOfAttributes + numberOfParticipantAttributes + numberOfIds));
                   sheet{j+1, logicalIndex} = eventOccurence;
                end
            end
            
            out = sheet;
        end
        
        function out = generateExcelColumnNameFromIndex(index)
            
            if index <= 26
                out = char(64 + index);%65 is the code for A, so 65 is the code for B and so on
            else
                remainingIndex = rem(index,26);
                divisionIndex = (index - rem(index,26))/26;
                if remainingIndex == 0
                    out = [fr.lescot.bind.utils.TripSetUtils.generateExcelColumnNameFromIndex(divisionIndex - 1) 'Z'];
                else
                    out = [fr.lescot.bind.utils.TripSetUtils.generateExcelColumnNameFromIndex(divisionIndex) fr.lescot.bind.utils.TripSetUtils.generateExcelColumnNameFromIndex(remainingIndex)];
                end
            end
        end
        
    end
end