function calculate_PSD_withoutConflicts(trip)
    
    dataName = 'VRU_trajectories2';
    situationName = 'pedalling';
    VRU_type = cell2mat(trip.getAllSituationOccurences('vru_characteristics').getVariableValues('VRU_type'));
    
    % get data
    timecodes_video = cell2mat(trip.getAllDataOccurences('timecode_data').getVariableValues('timecode'));
    timecodes = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('timecode'));
    traj_x = cell2mat(trip.getAllDataOccurences(dataName).getVariableValues('VRU_trajectories2_1'));
    pedalling = trip.getAllSituationOccurences(situationName).buildCellArrayWithVariables({'startTimecode', 'endTimecode', 'Modalities'})';
    
    %% CALCULATE PEDALLING STOP DISTANCE
    
    BCP_C1 = 15; %beginning_crossing_pos_C1 = 15m
    ECP_C1 = 31; %ending_crossing_pos_C1 = 31m
    BCP_C2 = 19; %beginning_crossing_pos_C2 = 19m
    ECP_C2 = 11; %ending_crossing_pos_C2 = 11m
    data_out.PSD = NaN;
    data_out.PBD = NaN;
    data_out.PSPB_delta_speed = NaN;
    data_out.PSPB_accel = NaN;
    pedalling_case = 'beginning'; %'stop';
    for i = 1:length(pedalling)
        %% STOP PEDALING
        if strcmp(pedalling(i,3),'yes') && strcmp(pedalling(i+1,3),'no') && strcmp(pedalling_case, 'stop')
            if strcmp(VRU_type, 'C1')
                PSD_abs_x = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('VRU_trajectories2_1'));
                PSD_abs_y = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('VRU_trajectories2_2'));
                PSD_timecode = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('timecode'));
                PSD_startTimecode = max(0, PSD_timecode-3);
                PSD_endTimecode = min(PSD_timecode+3, timecodes(end));
                speed_before = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_timecode).getVariableValues('speed'));
                speed_after = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_timecode, PSD_endTimecode).getVariableValues('speed'));
                accel_before = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_timecode).getVariableValues('accel'));
                accel_after = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_timecode, PSD_endTimecode).getVariableValues('accel'));
                accel_beforeAfter = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_endTimecode).getVariableValues('accel'));
                timecodes_beforeAfter = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_endTimecode).getVariableValues('timecode'));
                data_out.PSD = BCP_C1 - PSD_abs_x;
                data_out.PSPB_delta_speed = mean(speed_after) ...
                                            - mean(speed_before);
                data_out.PSPB_accel = mean(accel_after);
                BCP_C1_line(:,1) = ones(41,1)*BCP_C1';
                BCP_C1_line(:,2) = PSD_abs_y-2:0.1:PSD_abs_y+2';
                ECP_C1_line(:,1) = ones(41,1)*ECP_C1';
                ECP_C1_line(:,2) = PSD_abs_y-2:0.1:PSD_abs_y+2';
                plot(timecodes_beforeAfter-PSD_timecode, accel_beforeAfter); title('STOP__PEDALING__ACCEL'); xlabel('Time (s)'); ylabel('Accel (m/s²)')
                hold on
                xlim([-3.2 3.2]);
                ylim([-3 3]);
                savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'STOP_PEDALING_ACCEL.fig'])
                saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'STOP_PEDALING_ACCEL.png']);
%                 plot(BCP_C1_line(:,1),BCP_C1_line(:,2))
%                 hold on
%                 plot(ECP_C1_line(:,1),ECP_C1_line(:,2))
%                 plot(PSD_abs_x, PSD_abs_y, 'Marker', 'o', 'MarkerFaceColor', 'red')
%                 xlim([0 55]);
%                 ylim([-15 0]);
%                 set(gca,'Ydir','reverse')
%                 savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'STOP_PEDALING.fig'])
%                 saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'STOP_PEDALING.png']);
                break
            elseif strcmp(VRU_type, 'C2')
                PSD_abs_x = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('VRU_trajectories2_1'));
                PSD_abs_y = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('VRU_trajectories2_2'));
                PSD_timecode = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('timecode'));
                PSD_startTimecode = max(0, PSD_timecode-3);
                PSD_endTimecode = min(PSD_timecode+3, timecodes(end));
                speed_before = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_timecode).getVariableValues('speed'));
                speed_after = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_timecode, PSD_endTimecode).getVariableValues('speed'));
                accel_before = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_timecode).getVariableValues('accel'));
                accel_after = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_timecode, PSD_endTimecode).getVariableValues('accel'));
                accel_beforeAfter = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_endTimecode).getVariableValues('accel'));
                timecodes_beforeAfter = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_endTimecode).getVariableValues('timecode'));
                data_out.PSD = PSD_abs_x - BCP_C2;
                data_out.PSPB_delta_speed = mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_timecode, PSD_endTimecode).getVariableValues('speed'))) ...
                                            - mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_startTimecode, PSD_timecode).getVariableValues('speed')));
                data_out.PSPB_accel = mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PSD_timecode, PSD_endTimecode).getVariableValues('accel')));
                BCP_C2_line(:,1) = ones(41,1)*BCP_C2';
                BCP_C2_line(:,2) = PSD_abs_y-2:0.1:PSD_abs_y+2';
                ECP_C2_line(:,1) = ones(41,1)*ECP_C2';
                ECP_C2_line(:,2) = PSD_abs_y-2:0.1:PSD_abs_y+2';
                plot(timecodes_beforeAfter-PSD_timecode, accel_beforeAfter); title('STOP__PEDALING__ACCEL'); xlabel('Time (s)'); ylabel('Accel (m/s²)')
                hold on
                xlim([-3.2 3.2]);
                ylim([-3 3]);
                savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'STOP_PEDALING_ACCEL.fig'])
                saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'STOP_PEDALING_ACCEL.png']);
%                 plot(BCP_C2_line(:,1),BCP_C2_line(:,2))
%                 hold on
%                 plot(ECP_C2_line(:,1),ECP_C2_line(:,2))
%                 plot(PSD_abs_x, PSD_abs_y, 'Marker', 'o', 'MarkerFaceColor', 'red')
%                 xlim([0 55]);
%                 ylim([-15 0]);
%                 set(gca,'Ydir','reverse')
%                 savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'STOP_PEDALING.fig'])
%                 saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'STOP_PEDALING.png']);
                break
            end
        %% BEGINING PEDALING
        elseif strcmp(pedalling(i,3),'no') && strcmp(pedalling(i+1,3),'yes') && strcmp(pedalling_case, 'beginning')
            if strcmp(VRU_type, 'C1')
                PBD_abs_x = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('VRU_trajectories2_1'));
                PBD_abs_y = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('VRU_trajectories2_2'));
                PBD_timecode = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('timecode'));
                PBD_startTimecode = max(0, PBD_timecode-3);
                PBD_endTimecode = min(PBD_timecode+3, timecodes(end));
                speed_before = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_timecode).getVariableValues('speed'));
                speed_after = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_timecode, PBD_endTimecode).getVariableValues('speed'));
                accel_before = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_timecode).getVariableValues('accel'));
                accel_after = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_timecode, PBD_endTimecode).getVariableValues('accel'));
                accel_beforeAfter = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_endTimecode).getVariableValues('accel'));
                timecodes_beforeAfter = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_endTimecode).getVariableValues('timecode'));
                data_out.PBD = PBD_abs_x - ECP_C1;
                data_out.PSPB_delta_speed = mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_timecode, PBD_endTimecode).getVariableValues('speed'))) ...
                                            - mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_timecode).getVariableValues('speed')));
                data_out.PSPB_accel = mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_timecode, PBD_endTimecode).getVariableValues('accel')));
                BCP_C1_line(:,1) = ones(41,1)*BCP_C1';
                BCP_C1_line(:,2) = PBD_abs_y-2:0.1:PBD_abs_y+2';
                ECP_C1_line(:,1) = ones(41,1)*ECP_C1';
                ECP_C1_line(:,2) = PBD_abs_y-2:0.1:PBD_abs_y+2';
                plot(timecodes_beforeAfter-PBD_timecode, accel_beforeAfter); title('BEGINNING__PEDALING__ACCEL'); xlabel('Time (s)'); ylabel('Accel (m/s²)')
                hold on
                xlim([-3.2 3.2]);
                ylim([-3 3]);
                savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'BEGINNING_PEDALING_ACCEL.fig'])
                saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'BEGINNING_PEDALING_ACCEL.png']);
%                 plot(BCP_C1_line(:,1),BCP_C1_line(:,2))
%                 hold on
%                 plot(ECP_C1_line(:,1),ECP_C1_line(:,2))
%                 plot(PBD_abs_x, PBD_abs_y, 'Marker', 'o', 'MarkerFaceColor', 'green')
%                 xlim([0 55]);
%                 ylim([-15 0]);
%                 set(gca,'Ydir','reverse')
%                 savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'BEGINNING_PEDALING.fig'])
%                 saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'BEGINNING_PEDALING.png']);
                break
            elseif strcmp(VRU_type, 'C2')
                PBD_abs_x = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('VRU_trajectories2_1'));
                PBD_abs_y = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('VRU_trajectories2_2'));
                PBD_timecode = cell2mat(trip.getDataOccurenceNearTime(dataName, pedalling{i+1,1}).getVariableValues('timecode'));
                PBD_startTimecode = max(0, PBD_timecode-3);
                PBD_endTimecode = min(PBD_timecode+3, timecodes(end));
                speed_before = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_timecode).getVariableValues('speed'));
                speed_after = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_timecode, PBD_endTimecode).getVariableValues('speed'));
                accel_before = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_timecode).getVariableValues('accel'));
                accel_after = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_timecode, PBD_endTimecode).getVariableValues('accel'));
                accel_beforeAfter = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_endTimecode).getVariableValues('accel'));
                timecodes_beforeAfter = cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_endTimecode).getVariableValues('timecode'));
                data_out.PBD = ECP_C2 - PBD_abs_x;
                data_out.PSPB_delta_speed = mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_timecode, PBD_endTimecode).getVariableValues('speed'))) ...
                                            - mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_startTimecode, PBD_timecode).getVariableValues('speed')));
                data_out.PSPB_accel = mean(cell2mat(trip.getDataOccurencesInTimeInterval(dataName, PBD_timecode, PBD_endTimecode).getVariableValues('accel')));
                BCP_C2_line(:,1) = ones(41,1)*BCP_C2';
                BCP_C2_line(:,2) = PBD_abs_y-2:0.1:PBD_abs_y+2';
                ECP_C2_line(:,1) = ones(41,1)*ECP_C2';
                ECP_C2_line(:,2) = PBD_abs_y-2:0.1:PBD_abs_y+2';
                plot(timecodes_beforeAfter-PBD_timecode, accel_beforeAfter); title('BEGINNING__PEDALING__ACCEL'); xlabel('Time (s)'); ylabel('Accel (m/s²)')
                hold on
                xlim([-3.2 3.2]);
                ylim([-3 3]);
                savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'BEGINNING_PEDALING_ACCEL.fig'])
                saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'BEGINNING_PEDALING_ACCEL.png']);
%                 plot(BCP_C2_line(:,1),BCP_C2_line(:,2))
%                 hold on
%                 plot(ECP_C2_line(:,1),ECP_C2_line(:,2))
%                 plot(PBD_abs_x, PBD_abs_y, 'Marker', 'o', 'MarkerFaceColor', 'green')
%                 xlim([0 55]);
%                 ylim([-15 0]);
%                 set(gca,'Ydir','reverse')
%                 savefig(['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'BEGINNING_PEDALING.fig'])
%                 saveas(gcf,['\\vrlescot\PROSPECT\CODAGE\TRIPSALL_WithoutConflicts\@DATA_EXPORT\FIGURES\PEDALING' filesep 'BEGINNING_PEDALING.png']);
                break
            end
        end
    end
    
%     %% add PSD variable and value to the trip
%     addSituationVariable2Trip(trip,'Indicators','PSD','REAL','unit','m')
%     addSituationVariable2Trip(trip,'Indicators','PBD','REAL','unit','m')
%     addSituationVariable2Trip(trip,'Indicators','PSPB_delta_speed','REAL','unit','')
%     addSituationVariable2Trip(trip,'Indicators','PSPB_accel','REAL','unit','')
%     trip.setBatchOfTimeSituationVariableTriplets('Indicators','PSD',[num2cell(timecodes(1)),num2cell(timecodes(end)),num2cell(data_out.PSD)]')
%     trip.setBatchOfTimeSituationVariableTriplets('Indicators','PBD',[num2cell(timecodes(1)),num2cell(timecodes(end)),num2cell(data_out.PBD)]')
%     trip.setBatchOfTimeSituationVariableTriplets('Indicators','PSPB_delta_speed',[num2cell(timecodes(1)),num2cell(timecodes(end)),num2cell(data_out.PSPB_delta_speed)]')
%     trip.setBatchOfTimeSituationVariableTriplets('Indicators','PSPB_accel',[num2cell(timecodes(1)),num2cell(timecodes(end)),num2cell(data_out.PSPB_accel)]')
    
end