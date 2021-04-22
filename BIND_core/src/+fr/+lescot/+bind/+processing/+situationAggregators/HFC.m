%{
Class:
This class requires total refactoring before being used. It stays here
only as a placeholder for the moment.
%}
classdef HFC < fr.lescot.bind.processing.SituationAggregator
    
    methods (Static)
        function processedValues = process(inputSituationTimecodes, inputDataValues , parametersValues)
            %inputSituationTimecodes - A 2*n cell array. The first line contains the timecode of the beginning of each occurence, and the second line contains the matching end timecode in the same column.
            %inputDataValues - A 2*n cell array with the timecode of the data in the first line, and the matching value in the second.
            %parametersValues - A cell array of strings containing the values of the parameters, in the order described by <getParametersList()>.
            lowThreshold = str2double(parametersValues{1});
            highThreshold = str2double(parametersValues{2});
            
            inputData = cell2mat(inputDataValues);
            stdev = zeros(1,length(inputSituationTimecodes));
            for i = 1:length(inputSituationTimecodes)
                starttime = inputSituationTimecodes{1,i};
                endtime = inputSituationTimecodes{2,i};
                % Look for the beginpoint
                for j = 1:length(inputData)
                    if inputData(1,j) > starttime
                        beginpoint = j-1;
                        break;
                    end
                end
                % Look for the endpoint
                for j = beginpoint:length(inputData)
                    if inputData(1,j) > endtime
                        endpoint = j-1;
                        break;
                    end
                end
                
                
                a = inputData(beginpoint:endpoint);
                
                L = length(a);
                
                NFFT = 2^nextpow2(L);
                
                Y = fft(a,NFFT)/L;
                
                Fs = 50;
                
                f = Fs/2*linspace(0,1,NFFT/2+1);
                
                B = 2*abs(Y(1:NFFT/2+1));
                
                %plot(f,B);
                
                seuilBas = 0.3;
                seuilHaut = 2;
                indiceDebut = find(f>lowThreshold,1,'first');
                
                indiceFin = find(f<highThreshold,1,'last');
                
                trucInteressant = B(indiceDebut:indiceFin);
                
                moyenne = mean(trucInteressant);
                sums = 0;
                for j=1:length(trucInteressant)
                    sums = sums + (trucInteressant(j) - moyenne)^2;
                end
                
                stdev(i) = sqrt(sums / L);
                
                %stdev(i) = moyenne; %sqrt(sums / length(trucInteressant));
                
                
                %stdev
            end
            processedValues = [inputSituationTimecodes; num2cell(stdev)];
        end
    end
end