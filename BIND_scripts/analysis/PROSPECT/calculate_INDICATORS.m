function calculate_indicators(trip, full_directory)
    trip_id = trip.getAttribute('TRIP_NAME'); trip_id = trip_id(1:end-5);
    
    dataNames = { ...
        'CAR_trajectories2', ...
        'VRU_trajectories2', ...
        };
    
    data_variables = { ...
        'T0','TimeWindowBeforeT0', ...
        'speed_T0','speed_max_5sBeforeT0','speed_max_5sBeforeT0_gap2T0','speed_mean_BeforeT0', ...
        'accel_T0','accel_max_5sBeforeT0','accel_max_5sBeforeT0_gap2T0','accel_mean_BeforeT0','decel_case' ...
        };
    
    data_variables_units = { ...
        's','s', ...
        'km/h','km/h','s','km/h', ...
        'm/s2','m/s2','s','m/s2','1' ...
        };
    
    data_variables_comments = {...
        'T0 value', 'Available time window before T0 to search indicators', ...
        'Speed at T0', 'Maximum speed up to 5 secondes before T0', 'Interval time for maximum speed up to 5 secondes before T0', 'Mean speed before T0' ...
        'Accel at T0', 'Maximum accel up to 5 secondes before T0', 'Interval time for maximum accel up to 5 secondes before T0', 'Mean accel before T0', 'If case is a decel, booleen is true (1)', ...
        };
    
    % remove situation if necessary
    removeSituationsTables(trip,{'Indicators'});
    
    speed_ratio = 3.6; % to convert speed in m/s to km/h
    T0_codage = cell2mat(trip.getAllEventOccurences('interaction').getVariableValues('timecode'));
    timecodes_video = cell2mat(trip.getAllDataOccurences('timecode_data').getVariableValues('timecode'));
    
    for i_data = 2:length(dataNames)
        dataName = dataNames{i_data};
        dataName_reduced = dataName(1:3);
        
        %% INITIALISE VARIABLES
        trajX.(dataName_reduced) = NaN;
        trajY.(dataName_reduced) = NaN;
        data_out.TimeWindowBeforeT0 = NaN;
        data_out.T0 = NaN;
        data_out.speed_T0 = NaN;
        data_out.speed_max_5sBeforeT0 = NaN;
        data_out.speed_max_5sBeforeT0_gap2T0 = NaN;
        data_out.speed_mean_BeforeT0 = NaN;
        data_out.accel_T0 = NaN;
        data_out.accel_max_5sBeforeT0 = NaN;
        data_out.accel_max_5sBeforeT0_gap2T0 = NaN;
        data_out.accel_mean_BeforeT0 = NaN;
        data_out.decel_case = NaN;
        data_out.TTC_T0 = NaN;
        data_out.TTC_min = NaN;
        data_out.TTC_min_gap2T0 = NaN;
        data_out.PET_T0 = NaN;
        data_out.PET_min = NaN;
        data_out.PET_min_gap2T0 = NaN;
        data_out.RelatPosX_T0 = NaN;
        data_out.RelatPosY_T0 = NaN;

        
        %% add indicators table and variables
        T0 = cell2mat(trip.getDataOccurenceNearTime(dataName,T0_codage).getVariableValues('timecode'));
        addSituationTable2Trip(trip,'Indicators');
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','name',[num2cell(max(0,T0-5)),num2cell(T0),{'Indicators'}]')
        for i_variable = 1:length(data_variables)
            addSituationVariable2Trip(trip,'Indicators',[data_variables{i_variable} '_' dataNames{i_data}(1:3)],'REAL','unit',data_variables_units{i_variable},'comment',data_variables_comments{i_variable})
        end
        
        %% CALCULATE INDICATORS
        if and(and(T0_codage >= min(cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('timecode'))), T0_codage <= max(cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('timecode')))), ~isempty(T0_codage))
            
            % get data
            timecodes2T0 = cell2mat(trip.getDataOccurencesInTimeInterval(dataName,max(0,T0-5),T0).getVariableValues('timecode'));
            trajX.(dataName_reduced) = cell2mat(trip.getDataOccurencesInTimeInterval(dataName,max(0,T0-5),T0).getVariableValues([dataName '_1']));
            trajY.(dataName_reduced) = cell2mat(trip.getDataOccurencesInTimeInterval(dataName,max(0,T0-5),T0).getVariableValues([dataName '_2']));
            speeds_beforeT0 = cell2mat(trip.getDataOccurencesInTimeInterval(dataName,max(0,T0-5),T0).getVariableValues('speed')); % speed between T0-5 and T0 or between 0 and T0
            accels_beforeT0 = cell2mat(trip.getDataOccurencesInTimeInterval(dataName,max(0,T0-5),T0).getVariableValues('accel')); % accel between T0-5 and T0 or between 0 and T0
            data_out.TimeWindowBeforeT0 = T0-max(0,T0-5);
            data_out.T0 = T0;
            
            %% speeds
            data_out.speed_T0 = cell2mat(trip.getDataOccurenceAtTime(dataName, T0).getVariableValues('speed'))*speed_ratio;
            [data_out.speed_max_5sBeforeT0, speed_max_5sBeforeT0_index] = max(abs(speeds_beforeT0*speed_ratio));
            data_out.speed_max_5sBeforeT0_gap2T0 = T0-timecodes2T0(speed_max_5sBeforeT0_index);
            data_out.speed_mean_BeforeT0 = mean(speeds_beforeT0)*speed_ratio;
            
            % disp speed values
            disp(['speed_T0 = ' num2str(data_out.speed_T0) ' km/h'])
            disp(['speed_max_5sBeforeT0 = ' num2str(data_out.speed_max_5sBeforeT0) ' km/h'])
            disp(['speed_max_5sBeforeT0_gap2T0 = ' num2str(data_out.speed_max_5sBeforeT0_gap2T0) ' s'])
            disp(['speed_mean_BeforeT0 = ' num2str(data_out.speed_mean_BeforeT0) ' km/h'])
            
            % plot speed
            timecodes = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('timecode'));
            speed = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('speed'));
            %         speed_smooth = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('speed_smooth'));
            %         hold on
            plot(timecodes,speed);
            xlim([0,timecodes_video(end)]);
            ylim([0,24]);
            savefig([full_directory filesep 'Figures' filesep trip_id '_Speed_' dataName_reduced '.fig'])
            saveas(gcf,[full_directory filesep 'Figures' filesep trip_id '_Speed_' dataName_reduced '.png']);
            %         plot_speed_smooth = plot(speed_smooth);
            %         saveas(plot_speed_smooth, [full_directory filesep dataName_reduced '_Speed_smoothed.png']);
            %         hold off
            
            %% accels
            %         MPP = 0.5;
            data_out.accel_T0 = cell2mat(trip.getDataOccurenceAtTime(dataName, T0).getVariableValues('accel'));
            [~, accel_max_5sBeforeT0_index] = max(abs(accels_beforeT0));
            data_out.accel_max_5sBeforeT0 = accels_beforeT0(accel_max_5sBeforeT0_index);
            data_out.accel_max_5sBeforeT0_gap2T0 = T0-timecodes2T0(accel_max_5sBeforeT0_index);
            %         findpeaks(abs(accels_beforeT0),'MinPeakProminence', MPP);
            %         [PKS,LOCS] = findpeaks(abs(accels_beforeT0),'MinPeakProminence', MPP);
            %         [~, accel_max_5sBeforeT0_index] = max(PKS);
            %         data_out.accel_max_5sBeforeT0 = accels_beforeT0(LOCS(accel_max_5sBeforeT0_index));
            %         data_out.accel_max_5sBeforeT0_gap2T0 = T0-timecodes(LOCS(accel_max_5sBeforeT0_index));
            data_out.accel_mean_BeforeT0 = mean(accels_beforeT0);
            data_out.decel_case = 0;
            if data_out.accel_max_5sBeforeT0 < 0
                data_out.decel_case = 1;
            end
            
            % disp accel values
            disp(['accel_T0 = ' num2str(data_out.accel_T0) ' m/s²'])
            disp(['accel_max_5sBeforeT0 = ' num2str(data_out.accel_max_5sBeforeT0) ' m/s²'])
            disp(['accel_max_5sBeforeT0_gap2T0 = ' num2str(data_out.accel_max_5sBeforeT0_gap2T0) ' s'])
            disp(['accel_mean_BeforeT0 = ' num2str(data_out.accel_mean_BeforeT0) ' m/s²'])
            disp(['decel_case = ' num2str(data_out.decel_case)])
            
            % plot accel
            accel = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('accel'));
            %         accel_smooth = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('accel_smooth'));
            %         hold on
            plot(timecodes,accel);
            xlim([0,timecodes_video(end)]);
            ylim([-10,10]);
            savefig([full_directory filesep 'Figures' filesep trip_id '_Accel_' dataName_reduced '.fig'])
            saveas(gcf,[full_directory filesep 'Figures' filesep trip_id '_Accel_' dataName_reduced '.png']);
            %         plot_accel_smooth = plot(accel_smooth);
            %         saveas(plot_accel_smooth, [full_directory filesep dataName_reduced '_Accel_smoothed.png']);
            %         hold off
            
            
        end
        %% add indicators variables
        for i_variable = 1:length(data_variables)
            trip.setBatchOfTimeSituationVariableTriplets('Indicators',[data_variables{i_variable} '_' dataNames{i_data}(1:3)],[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.(data_variables{i_variable}))]')
        end
    end
    
    %% TTC : 'TTC_T0','TTC_min','TTC_min_gap2T0', 'TTC at T0', 'Minimum TTC', 'Interval time for minimum TTC'
    addSituationVariable2Trip(trip,'Indicators','TTC_T0','REAL','unit','s','comment','TTC at T0');
    addSituationVariable2Trip(trip,'Indicators','TTC_min','REAL','unit','s','comment','Minimum TTC');
    addSituationVariable2Trip(trip,'Indicators','TTC_min_gap2T0','REAL','unit','s','comment','Interval time for minimum TTC up to 5 secondes before T0');
    addSituationVariable2Trip(trip,'Indicators','PET_T0','REAL','unit','s','comment','PET at T0');
    addSituationVariable2Trip(trip,'Indicators','PET_min','REAL','unit','s','comment','Minimum PET');
    addSituationVariable2Trip(trip,'Indicators','PET_min_gap2T0','REAL','unit','s','comment','Interval time for minimum PET up to 5 secondes before T0');
    
    if ~isempty(T0_codage) && ...
            existData(trip.getMetaInformations(),'TTC_PET') && ...
            ~isempty(trip.getAllDataOccurences('TTC_PET').getVariableValues('TTC_PET_1')) && ...
            ~isempty(find(cell2mat(trip.getAllDataOccurences('TTC_PET').getVariableValues('TTC_PET_1')) ~= inf,1)) && ...
            T0_codage >= min(cell2mat(trip.getAllDataOccurences('TTC_PET').getVariableValues('timecode'))) && ...
            T0_codage <= max(cell2mat(trip.getAllDataOccurences('TTC_PET').getVariableValues('timecode')))
        
        T0 = cell2mat(trip.getDataOccurenceNearTime('TTC_PET',T0_codage).getVariableValues('timecode'));
        timecodes_ttc = cell2mat(trip.getDataOccurencesInTimeInterval('TTC_PET',max(0,T0-5),T0).getVariableValues('timecode'));
        TTC = cell2mat(trip.getDataOccurencesInTimeInterval('TTC_PET',max(0,T0-5),T0).getVariableValues('TTC_PET_1'));
        data_out.TTC_T0 = TTC(end);
        [data_out.TTC_min,idx_TTC] = min(TTC);
        data_out.TTC_min_gap2T0 = T0-timecodes_ttc(idx_TTC);
        PET = cell2mat(trip.getDataOccurencesInTimeInterval('TTC_PET',max(0,T0-5),T0).getVariableValues('TTC_PET_2'));
        data_out.PET_T0 = PET(end);
        [data_out.PET_min,idx_PET] = min(abs(PET));
        data_out.PET_min_gap2T0 = T0-timecodes_ttc(idx_PET);  
        
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','TTC_T0',[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.TTC_T0)]');
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','TTC_min',[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.TTC_min)]');
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','TTC_min_gap2T0',[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.TTC_min_gap2T0)]');
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','PET_T0',[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.PET_T0)]');
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','PET_min',[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.PET_min)]');
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','PET_min_gap2T0',[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.PET_min_gap2T0)]');
        
    end

    %% Relative position delta_x et delta_y
    addSituationVariable2Trip(trip,'Indicators','RelatPosX_T0','REAL','unit','m','comment','Relative position at T0');
    addSituationVariable2Trip(trip,'Indicators','RelatPosY_T0','REAL','unit','m','comment','Relative position at T0');
    trajX_data = trajX.(dataName_reduced);
    
    if exist('trajX_data','var') && exist('T0','var') && ~isempty(T0_codage) && length(fieldnames(trajX)) == 2 && length(fieldnames(trajY)) == 2
        data_out.RelatPosX_T0 = trajX.CAR(end)-trajX.VRU(end);
        data_out.RelatPosY_T0 = trajY.CAR(end)-trajY.VRU(end);
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','RelatPosX_T0',[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.RelatPosX_T0)]');
        trip.setBatchOfTimeSituationVariableTriplets('Indicators','RelatPosY_T0',[num2cell(max(0,T0-5)),num2cell(T0),num2cell(data_out.RelatPosY_T0)]');
    end
    
end