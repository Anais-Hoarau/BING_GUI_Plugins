function testECGLigneV2()
    %% Load data
    tripPath = ['\\vrlescot\MADISON\DATA2\Passation_08\rtmaps\Test\' ...
        '20190513_161348_RecFile_REC\RecFile_REC_20190513_161348.trip'];
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripPath, 0.04, false);
    ecgValues = cell2mat(trip.getAllDataOccurences('Biopac_MP150').getVariableValues('ecg'));
    
    %% Initialize variables
    init = 1;
    nb_stim = 0;
    display_mode = 0;
    startTime = cputime;
    bpm_all = [];
    RRintervals_all = [];
    
    %% Loop on ecg data
    for i = 1:length(ecgValues)
        ecgValue = ecgValues(i);
        %% normal mode
        if ~display_mode
            [RRinterval, bpm, stim, nb_errors] = RRIntervalsRealTime(ecgValue, init, 1.5, 0.8);
            if stim == 1
                disp(['RRinterval : ', num2str(RRinterval), ' | bpm : ', num2str(bpm), ' | nombre de stim = ', num2str(nb_stim), ' | nombre erreurs = ', num2str(nb_errors)]);
            end
        %% display mode
        else
%             profile on
            [RRinterval, bpm, stim, nb_errors, TCmax, peakValues, peakTC, peakValuesPredict, peakTCPredict, peakTCPredictDiff] = RRIntervalsRealTime(ecgValue, init, 1.5, 0.8, display_mode);
            RRintervals_all = [RRintervals_all, RRinterval];
            bpm_all = [bpm_all, bpm];
%             profile viewer
            % disp predicted values
            if or(stim == 1, i == length(ecgValues))
                disp(['nombre de stim = ' num2str(nb_stim) ' | nombre erreurs = ' num2str(nb_errors)]);
                disp(['timecode actuel = ' num2str(TCmax/1000) ' | temps écoulé = ' num2str(cputime - startTime) ' | écart de temps = ' num2str(cputime - startTime - TCmax/1000)]); 
                if ~isempty(peakTCPredictDiff)
                    disp(['PeakTCPredictedDiff : ', num2str(peakTCPredictDiff(end))]);
                    disp(['PeakTCPredictedDiffMoy : ', num2str(mean(peakTCPredictDiff))]);
                    disp(['PeakTCPredictedDiffStd : ', num2str(std(peakTCPredictDiff))]);
                    disp(['RRinterval : ', num2str(RRinterval)]);
                    disp(['bpm : ', num2str(bpm)]);
                end
                % plot predicted values
                if or(mod(nb_stim, 200) == 0 && nb_stim > 1 && ~isempty(peakTCPredict), i == length(ecgValues))
                    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
                    plot(gca, ecgValues(1:i), 'Color', 'b');
                    hold on
                    plot(gca, peakTC, peakValues, 'Marker', 'v', 'Color', 'r');
                    plot(gca, peakTCPredict, peakValuesPredict, 'Marker', 'v', 'Color', 'g');
                    f2 = figure('units','normalized','outerposition',[0 0 1 1]);
                    plot(RRintervals_all);
                    f3 = figure('units','normalized','outerposition',[0 0 1 1]);
                    plot(bpm_all);
                    pause(3);
                    close(f1);
                    close(f2);
                    close(f3);
                end
            end
        end
        nb_stim = nb_stim + stim;
        init = 0;
    end
end