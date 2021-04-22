%{
Class:
This aggregator is based on the SRR (Steering wheel Reverse Rate)
indicator, described in one of the deliverables of project aide
(http://aide-eu.org). The description of SRR can be found in this document: http://www.aide-eu.org/pdf/sp2_deliv_new/aide_d2_2_1.pdf.

It is not intended to be used on generic data, since the values
inputDataValues must have a specific semantic : They have to represent the
steering wheel angle in degrees. Similarly, the minimumGap value is a value
in degrees.

The first step to calculate the SRR is to find the local minimums and
maximums of the steering wheel angle during the situation . Once this is done, 
they are ordered by ascending timecode. This allows us to be sure we have an 
alternance of minis of maxis.

The next step is to calculate the gap in degrees between two adjacent
extremums ( abs(angle_t - angle_t-1)). Then if the calculated gap is above
or equal to the minimumGap, the counter is increased.

The final output is the number of gaps above the minimum gap during the
situation.

To give a small example of the results produced by this algorithm, here is
what it would give with the following inputs :
:timecode:  [1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10]
:values:    [1 | 6 | 5 | 4 | 8 | 1 | 7 | 5 | 10|  3]
the following situations
:startTimecode: [3 | 8]
:endTimecode:   [7 | 10]
and a minimumGap of 3 degrees
:startTimecode: [3 | 8]
:endTimecode:   [7 | 10]
:SRR:           [1 | 0]
%}
classdef SteeringWheelReversalRate < fr.lescot.bind.processing.SituationAggregator
    
    methods (Static)
        function out = process(inputSituationTimecodes, inputDataValues , minimumGap)
            situationsNumber = size(inputSituationTimecodes, 2);
            
            inputData = cell2mat(inputDataValues);
            swrr = cell(1,length(inputSituationTimecodes));
            for i = 1:1:situationsNumber
                startTime = inputSituationTimecodes{1,i};
                endTime = inputSituationTimecodes{2,i};
                
                startIndex = find(inputData(1,:) >= startTime, 1, 'first');
                endIndex = find(inputData(1,:) <= endTime, 1, 'last');
                
                localMinimas = cell2mat(fr.lescot.bind.processing.eventDiscoverers.LocalMinFinder.extract(inputDataValues(:, startIndex:endIndex )));
                localMaximas = cell2mat(fr.lescot.bind.processing.eventDiscoverers.LocalMaxFinder.extract(inputDataValues(:, startIndex:endIndex )));
                
                %By definition, local minis and local maxis alternates. We
                %can't have two local minis then a local max for instance.
                %We can only have min / max / min / max...
                %So we're going to proceed in two steps : first we will
                %aggregate the arrays, then we will sort them by timecode.
                %After that we will be able to calculate between two
                %adjacent points.
                localExtremums = sort([localMinimas localMaximas]);
                aboveGapChanges = 0;
                for j = 2:1:length(localExtremums)
                    currentItemIndex = find(inputData(1,:) == localExtremums(j), 1, 'first');
                    previousItemIndex = find(inputData(1,:) == localExtremums(j-1), 1, 'first');
                    gap = abs(inputData(2,currentItemIndex) - inputData(2,previousItemIndex));
                    if gap >= minimumGap
                        aboveGapChanges = aboveGapChanges + 1;
                    end
                end
                swrr{i} = aboveGapChanges;
            end
            out = [inputSituationTimecodes; swrr];
        end
    end
end