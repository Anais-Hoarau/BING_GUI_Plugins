%{
Class:
This class requires total refactoring before being used. It stays here
only as a placeholder for the moment.*
%}
classdef SteeringEntropy < fr.lescot.bind.processing.SituationAggregator
    % We consider that :
    % Each EntryIntersection is an increasing linear relationship Y = aX + b
    % Each ExitIntersection is an decreasing linear relationship Y = ax - b
    
    methods (Static)
        function processedValues = process(inputSituationTimecodes, inputDataValues , ~)
            %inputSituationTimecodes - A 2*n cell array. The first line contains the timecode of the beginning of each occurence, and the second line contains the matching end timecode in the same column.
            %inputDataValues - A 2*n cell array with the timecode of the data in the first line, and the matching value in the second.
            %parametersValues - A cell array of strings containing the values of the parameters, in the order described by <getParametersList()>.
            entropy = zeros(1,length(inputSituationTimecodes));
            inputTimeData = cell2mat(inputDataValues(1,:));
            inputData = cell2mat(inputDataValues(2,:));
            for i = 1:length(inputSituationTimecodes)
                starttime = inputSituationTimecodes{1,i};
                endtime = inputSituationTimecodes{2,i};
                % Look for the beginpoint
                beginpoint = find(inputTimeData >= starttime,1,'first');
                % Look for the endpoint
                endpoint = find(inputTimeData >= endtime,1,'first');
                
                selectedTimeValue = inputTimeData(beginpoint:endpoint);
                selectedDataValue = inputData(beginpoint:endpoint);
                
                % Calculate the average of the rate from the first three data
                a1 = (selectedDataValue(1) - selectedDataValue(2))/(selectedTimeValue(1) - selectedTimeValue(2));
                a2 = (selectedDataValue(2) - selectedDataValue(3))/(selectedTimeValue(2) - selectedTimeValue(3));
                a = a1 + a2;
                
                tableError = zeros(1,length(selectedDataValue)-3);
                % Calculation of the incertitudes
                for j = 4:length(selectedDataValue)
                    tableError(j-3) = abs(selectedDataValue(j-1) - a*(selectedTimeValue(j-1) - selectedTimeValue(j)) - selectedDataValue(j));
                end
                    
                % Calculate the percent of each error
                tableErrorUnique = unique(tableError); % To find all the different error
                tableErrorOccSum = zeros(size(tableErrorUnique));
                tableErrorPercent = zeros(size(tableErrorUnique));
                for j = 1:length(tableErrorUnique)
                    tableErrorOccSum(j) = length(find(ismember(tableError,tableErrorUnique(j)),1));
                    tableErrorPercent(j) = tableErrorOccSum(j)/length(tableError);  
                end
                
                % Calculate the entropy
                sum = 0;
                for j = 1:length(tableErrorUnique)
                    %sum = sum + tableErrorPercent(j)^tableErrorOccSum(j) * log(tableErrorPercent(j));
                    sum = sum - tableErrorPercent(j) *  log(tableErrorPercent(j));
                end
                entropy(i) = sum;
                
            end
            processedValues = [inputSituationTimecodes; num2cell(entropy)];
        end
    end
end