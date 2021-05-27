function MadisonBatchIndicators()
    %% Define dateTime, folders, situations, indicators
    dateTime = char(datetime('now','Format','yyMMdd_HHmm')); tic; processed_trip = 0;
    mainFolder = 'I:\MADISON\DATA2';  % '\\vrlescot\MADISON\DATA2'
%     SaveTrip(mainFolder);
    figures_path = [mainFolder filesep '~DATA_EXPORT' filesep 'FIGURES' filesep dateTime];
    tripList = dirrec(mainFolder, '.trip');
    outputIndicators.context = {'duration', 'situation', 'level', 'disconfort'};
    outputIndicators.ecg = {'RRint_min', 'RRint_max', 'RRint_moy', 'SDNN', 'RMSSD'}; % , 'RRint_std'
    outputIndicators.driving = {'SDLP', 'SDWA', 'SRR'};
    outputIndicators.pupil = {'nb_fix', 'duree_fix_tot', 'duree_fix_moy', 'duree_fix_std', 'nb_sac', 'duree_sac_tot', 'duree_sac_moy', 'duree_sac_std', 'ampli_sac_tot', 'ampli_sac_moy', 'ampli_sac_std'};
    
    %% Loop on trips
    trips2select = {'18'}; %{'05 16 18 35 37 39 40 54 69'}; % 03, 05, 14, 16, 17, 18, 25, 27, 31, 35, 37, 39, 40, 42, 43, 45, 54, 55, 56, 61, 64, 67, 69
    for i_trip = 1:length(tripList)
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripList{i_trip}, 0.04, false);
        outputSituationsNames = trip.getMetaInformations().getSituationsNamesList();
        part_split = strsplit(trip.getAttribute('participant_id'),'_');
        scenario = trip.getAttribute('scenario');
        if length(part_split)>1 && contains(trips2select, part_split{2})
            try
                disp(['------------------------------------ ' tripList{i_trip} ' ------------------------------------']);
                if strcmpi(scenario,'BASELINE')
                    % TODO ?
                elseif strcmpi(scenario,'TEST')
                    %% Off-loop processing
                    RRIntervalsV2(trip, 'BIOPAC_MP150', {'ecg'}, 'ECG_processed', {'ecg', 'RRIntervals', 'RRIntCorr'}, figures_path, 0, 'MPH', -inf, 'MPD', 400, 'MPP', 0.8); % ECG
                    HRInterp(trip, 'ECG_processed', {'RRIntervals'}, 'ECG_processed', {'HRInterp'}, 0); % ECG
                    % MadisonExtractEDA() % EDA
                    MadisonPupilDeltaGazePoint(trip, 'PUPIL_GLASSES_gaze', {'confidence', 'norm_pos_X', 'norm_pos_Y'}, 'PUPIL_GLASSES_processed', {'confidence', 'norm_pos_X', 'norm_pos_Y', 'delta_gaze_point'}, 0); % GAZE
                    MadisonPupilFixation(trip, 'PUPIL_GLASSES_processed', {'confidence', 'norm_pos_X', 'norm_pos_Y', 'delta_gaze_point'}, 'PUPIL_GLASSES_processed', {'fixation'}, 0); % GAZE
                    
                    %% In-loop processing (indicators by situation)
                    for i_table = 1:length(outputSituationsNames)
                        % Remove situation variables
%                         removeSituationVariables(trip, outputSituationsNames{i_table}, outputIndicators.context, 1)
%                         removeSituationVariables(trip, outputSituationsNames{i_table}, outputIndicators.ecg, 1)
%                         removeSituationVariables(trip, outputSituationsNames{i_table}, outputIndicators.driving, 1)
%                         removeSituationVariables(trip, outputSituationsNames{i_table}, outputIndicators.pupil, 1)
                        % Get situation table timecodes
                        record = trip.getAllSituationOccurences(outputSituationsNames{i_table});
                        startTimecodes = cell2mat(record.getVariableValues('startTimecode'));
                        endTimecodes = cell2mat(record.getVariableValues('endTimecode'));
                        for i_line = 1:length(startTimecodes)
                            startTime = startTimecodes(i_line);
                            endTime = endTimecodes(i_line);
                            %% Calculate indicators
                            trip.setIsBaseSituation(outputSituationsNames{i_table}, 0)
                            MadisonIndicatorsContext(trip, 'CADISP', {'scale_level'}, startTime, endTime, outputSituationsNames{i_table}, outputIndicators.context, 1); % CONTEXT (situation, level, discomfort)
                            MadisonIndicatorsECG(trip, 'ECG_processed', {'ecg', 'RRIntervals', 'RRIntCorr', 'HRInterp'}, startTime, endTime, outputSituationsNames{i_table}, outputIndicators.ecg, 1); % ECG
                            % MadisonIndicatorsEDA(trip, 'BIOPAC_MP150', {''}, startTime, endTime, outputSituationsNames{i_table}, outputIndicators.ecg); % EDA
                            MadisonIndicatorsDriving(trip, 'DR2_Vehicule_VHS_vp', {'Voie', 'Cab.Volant'}, startTime, endTime, outputSituationsNames{i_table}, outputIndicators.driving, 1); % DRIVING
                            MadisonIndicatorsPupil(trip, 'PUPIL_GLASSES_processed', {'norm_pos_X', 'norm_pos_Y', 'delta_gaze_point', 'fixation'}, startTime, endTime, outputSituationsNames{i_table}, outputIndicators.pupil, 1); % GAZE
                        end
                    end
                end
                processed_trip = processed_trip + 1;
            catch ME
                disp('Error caught, logging and skipping to next file');
                log = fopen([mainFolder 'MadisonBatchIndicators.log'], 'a+');
                fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' tripList{i_trip}]);
                fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
                fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
                fclose(log);
            end
        end
        delete(trip);
    end
    disp([num2str(processed_trip) ' trip processed in ' num2str(toc) 's']);
end