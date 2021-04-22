%{
Class:
This aggregator calculates the maximum of the values on the given situations.
For example, with an input situations cell array like this :
:startTimeCode: [3 | 8]
:endTimeCode:   [7 | 9]
and a signal looking like this :
:timecodes: [1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10]
:signal:    [1 | 6 | 5 | 4 | 8 | 1 | 7 | 5 | 10| 3 ]
The result will be ;
:startTimeCode:     [3 | 8  ]
:endTimeCode:       [7 | 9  ]
:aggregatedValue:   [8 | 10]
%}
classdef Max < fr.lescot.bind.processing.SituationAggregator
   
    methods (Static)
        function processedValues = process(inputSituationTimecodes, inputDataValues , ~)
            inputData = cell2mat(inputDataValues);
            maxis = cell(1,length(inputSituationTimecodes));
            for i = 1:length(inputSituationTimecodes)
                startTime = inputSituationTimecodes{1,i};
                endTime = inputSituationTimecodes{2,i};
                                
                startIndex = find(inputData(1,:) >= startTime, 1, 'first');
                endIndex = find(inputData(1,:) <= endTime, 1, 'last');
                
                maxis{i}= max(inputData(2,startIndex:endIndex));
            end
            processedValues = [inputSituationTimecodes; maxis];
        end
    end
end

