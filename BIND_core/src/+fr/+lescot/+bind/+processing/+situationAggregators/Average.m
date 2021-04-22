%{
Class:
This aggregator calculates the average of the values on the given situations.
For example, with an input situations cell array like this :
:startTimeCode: [3 | 8]
:endTimeCode:   [7 | 9]
and a signal looking like this :
:timecodes: [1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10]
:signal:    [1 | 6 | 5 | 4 | 8 | 1 | 7 | 5 | 10| 3 ]
The result will be ;
:startTimeCode:     [3 | 8  ]
:endTimeCode:       [7 | 9  ]
:aggregatedValue:   [5 | 7.5]
%}
classdef Average < fr.lescot.bind.processing.SituationAggregator
   
    methods (Static)
        function out = process(inputSituationTimecodes, inputDataValues , ~)
            inputData = cell2mat(inputDataValues);
            average = cell(1,size(inputSituationTimecodes, 2));
            for i = 1:size(inputSituationTimecodes, 2)
                startTime = inputSituationTimecodes{1,i};
                endTime = inputSituationTimecodes{2,i};
                
                startIndex = find(inputData(1,:) >= startTime, 1, 'first');
                endIndex = find(inputData(1,:) <= endTime, 1, 'last');
                
                average{i} = mean(inputData(2, startIndex:endIndex));
            end
            out = [inputSituationTimecodes; average];
        end
    end
end

