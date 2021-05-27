% calculate cardiac RRintervals
function [RRinterval, bpm, stim, nb_errors] = RRIntervalsRealTime(ecgValue, init, correctionThreshold, MPP)
% function [RRinterval, bpm, stim, nb_errors, varargout] = RRIntervalsRealTime(ecgValue, init, correctionThreshold, MPP, display_mode)

    persistent windowSize
    persistent idxBuffer
    persistent subStep
    persistent ecgValues
    persistent TCMax
    persistent bufferPeakValues
    persistent bufferPeakTC
    persistent RRintervals
    persistent newPeakValue
    persistent newPeakTC
    persistent lastPeakTC
    persistent peakTCPredictDiff
    persistent bufferPeakTCPredicted
    persistent bufferPeakValueCorrect
    persistent cmpt_error
    
    %% init
    if init
        windowSize = 400;
        idxBuffer = 1;
        subStep = 4;
        ecgValues = ecgValue;
        TCMax = 1;
        bufferPeakValues = [];
        bufferPeakTC = [];
        RRintervals = [];
        newPeakValue = 0;
        newPeakTC = 0;
        lastPeakTC = 0;
        peakTCPredictDiff = [];
        bufferPeakTCPredicted = [];
        bufferPeakValueCorrect = [];
        cmpt_error = 0;
        RRinterval = 0;
        bpm = 0;
        stim = 0;
        nb_errors = 0;
%         varargout = cell(1, 6);
        return
    end
    
    %% Get and initialize variables
    if length(ecgValues) < windowSize
        ecgValues = [ecgValues, ecgValue];
    else
        ecgValues = [ecgValues(end-398:end), ecgValue];
    end
    TCMax = TCMax + 1;
    RRinterval = 0;
    bpm = 0;
    stim = 0;
    nb_errors = cmpt_error;
%     varargout = cell(1, 6);
    peakValueChanged = 0;
    
    %% Correction step
    if ~isempty(RRintervals) && diff([bufferPeakTC(end), TCMax]) > correctionThreshold*RRintervals(end)
        newPeakValue = bufferPeakValues(end);
        newPeakTC = bufferPeakTC(end) + RRintervals(end);
    end
    
    %% Find peaks step
    if mod(TCMax, windowSize/subStep) == 0 && TCMax >= 400
        [peakValue,peakTC] = findpeaks(ecgValues,'MinPeakHeight',-inf,'NPeaks',1,'MinPeakDistance',250,'WidthReference','halfprom','MinPeakProminence',MPP,'SortStr','ascend');
        if ~isempty(peakValue)
            newPeakValue = peakValue;
            newPeakTC = peakTC + (idxBuffer-1)*windowSize/subStep;
        end
        if newPeakTC ~= lastPeakTC && newPeakTC - lastPeakTC > 400
            peakValueChanged = 1;
            bufferPeakValues = [bufferPeakValues, newPeakValue];
            bufferPeakTC = [bufferPeakTC, newPeakTC];
            if length(bufferPeakTC) > 1
                RRintervals = [RRintervals, diff([bufferPeakTC(end-1), bufferPeakTC(end)])];
                if ~isempty(bufferPeakTCPredicted)
                    peakTCPredictDiff = [peakTCPredictDiff, diff([bufferPeakTC(end), bufferPeakTCPredicted(end)])];
                    if peakTCPredictDiff(end) > 200
                        cmpt_error = cmpt_error+1;
                    end
                end
            end
            lastPeakTC = newPeakTC;
        end
        idxBuffer = idxBuffer+1;
    end

    if ~isempty(RRintervals) && peakValueChanged
        bufferPeakValueCorrect = [bufferPeakValueCorrect, bufferPeakValues(end)];
        bufferPeakTCPredicted = [bufferPeakTCPredicted, bufferPeakTC(end) + RRintervals(end)];
    end
    if ~isempty(RRintervals)
        RRinterval = RRintervals(end)/1000;
        bpm = 60/RRinterval;
    end
    if ~isempty(RRintervals) && TCMax == bufferPeakTC(end) + RRintervals(end)
        stim = 1;
    end
end
% 
%     % debug & display mode
%     if display_mode
%         varargout = fillVarargout(TCMax, bufferPeakValues, bufferPeakTC, bufferPeakValueCorrect, bufferPeakTCPredicted, peakTCPredictDiff);
%     end
%     
% end
% 
% function outputs = fillVarargout(TCMax, bufferPeakValues, bufferPeakTC, bufferPeakValueCorrect, bufferPeakTCPredicted, peakTCPredictDiff)
%     outputs{1} = TCMax;
%     outputs{2} = bufferPeakValues;
%     outputs{3} = bufferPeakTC;
%     outputs{4} = bufferPeakValueCorrect;
%     outputs{5} = bufferPeakTCPredicted;
%     outputs{6} = peakTCPredictDiff;
% end