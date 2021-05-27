% calculate cardiac RRintervals
function RRIntervalsV2(trip, inputDataName, inputVariablesNames, outputDataName, ouputVariablesNames, figures_path, forceProcess, varargin)

    if or(~check_trip_meta(trip,['calcul_' mfilename],'OK'), forceProcess == 1) && trip.getMetaInformations.existData(inputDataName) && ~trip.getAllDataOccurences(inputDataName).isEmpty
        
        disp(['Calculating ' mfilename ' for trip : ' trip.getTripPath]);
        
        %% get data
        participant_id = trip.getAttribute('participant_id');
        scenario = trip.getAttribute('scenario');
        record = trip.getAllDataOccurences(inputDataName);
        timecodes = cell2mat(record.getVariableValues('timecode'));
        ecg = cell2mat(record.getVariableValues(inputVariablesNames{1}));
        timecodes = timecodes(1:length(ecg)); % to delete last line if only timecode is present
        
        %% initilise parameters
        MPH = -inf;
        MPD = 400;
        MPP = 1.3;

        %% get parameters
        p = inputParser;
        addParameter(p,'MPH','');
        addParameter(p,'MPD','');
        addParameter(p,'MPP','');
        parse(p,varargin{:});
        MPH = p.Results.MPH;
        MPD = p.Results.MPD;
        MPP = p.Results.MPP;
        
        %% find RR intervals
        [~,LOCS] = findpeaks(ecg,'MinPeakHeight',MPH,'MinPeakDistance',MPD,'MinPeakProminence',MPP,'SortStr','descend');
        timecodesPKS = timecodes(sort(LOCS));
        RRintervals = diff(timecodesPKS);
        
        %% plot figure
        figure('units','normalized','outerposition',[0 0 1 1]);
        findpeaks(ecg,'MinPeakHeight',MPH,'MinPeakDistance',MPD,'MinPeakProminence',MPP,'SortStr','descend');
        title(strrep(participant_id, '_', '__')); xlabel('Durée (ms)'); ylabel('ECG (V)');
        
        %% RR intervals correction if needed (when RRinterval > RRintervals_mean + (nb_std * RRintervals_std))
%         nb_std = 2;
%         RRintervals_mean = mean(RRintervals);
%         RRintervals_std = std(RRintervals);
%         RRintervals_limits = [RRintervals_mean-nb_std*RRintervals_std,RRintervals_mean+nb_std*RRintervals_std];
%         RRintervals2Correct = [0, RRintervals>RRintervals_limits(2)];
%         
%         if RRintervals_std > 0.075 && sum(RRintervals2Correct) > 0
%             RRintervals2Correct_idx = find(diff(RRintervals2Correct));
%             timecodesPKSCorrected = timecodesPKS(1:RRintervals2Correct_idx(1));
%             timecodesPKSAdded = zeros(RRintervals2Correct_idx(1),1)';
%             
%             for i_idx = 1:length(RRintervals2Correct_idx)
%                 if mod(i_idx,2) == 0
%                     timecodesPKS2Correc = timecodesPKS(RRintervals2Correct_idx(i_idx-1:i_idx));
%                     deltaTimecodesPKS2Correc = timecodesPKS2Correc(2) - timecodesPKS2Correc(1);
%                     nbTimecodesPKS2Correc = round(deltaTimecodesPKS2Correc/RRintervals_mean)-1;
%                     if nbTimecodesPKS2Correc == 0
%                         timecodesPKSAdded = zeros(length(timecodesPKS),1)';
%                         break
%                     end
%                     timecodesPKS2Add = [];
%                     for i_nb2Correct = 1:nbTimecodesPKS2Correc
%                         timecodesPKS2Add(i_nb2Correct) = timecodesPKS2Correc(1)+i_nb2Correct*(deltaTimecodesPKS2Correc/(nbTimecodesPKS2Correc+1));
%                         timecodesPKSAdded = [timecodesPKSAdded, 1];
%                     end
%                     if i_idx == length(RRintervals2Correct_idx) && RRintervals2Correct_idx(end) < length(RRintervals2Correct)
%                         RRintervals2Correct_idx(i_idx+1) = length(RRintervals2Correct);
%                     end
%                     timecodesPKSCorrected = [timecodesPKSCorrected, timecodesPKS2Add, timecodesPKS(RRintervals2Correct_idx(i_idx):RRintervals2Correct_idx(i_idx+1))];
%                     timecodesPKSAdded = [timecodesPKSAdded, 1, zeros(length(timecodesPKS(RRintervals2Correct_idx(i_idx):RRintervals2Correct_idx(i_idx+1)))-1,1)'];
%                     hold on
%                     plot((timecodesPKS2Add-timecodes(1))*1000,zeros(length(timecodesPKS2Add),1),'Marker','v','color','red','MarkerFaceColor','red','LineStyle','none','tag','Peak');
%                     hold off
%                 end
%             end
%             if length(timecodesPKSCorrected) > length(timecodesPKS)
%                 timecodesPKS = timecodesPKSCorrected;
%                 RRintervals = diff(timecodesPKSCorrected);
%             end
%         else
%             timecodesPKSAdded = zeros(length(timecodesPKS),1)';
%         end

        %% add indicators to the trip
        removeDataTables(trip, {outputDataName});
        addDataTable2Trip(trip, outputDataName);
        addDataVariable2Trip(trip,outputDataName,ouputVariablesNames{1},'REAL','unit','V','comment','ecg_values');
        addDataVariable2Trip(trip,outputDataName,ouputVariablesNames{2},'REAL','unit','s','comment','Cardiac_RRintervals_calculated');
        addDataVariable2Trip(trip,outputDataName,ouputVariablesNames{3},'REAL','unit','boolean','comment','Cardiac_RRintervals_corrected_state');
        trip.setBatchOfTimeDataVariablePairs(outputDataName, ouputVariablesNames{1}, [num2cell(timecodes(:)), num2cell(ecg(:))]');
        for i_pks = 2:length(timecodesPKS)
            trip.setDataVariableAtTime(outputDataName, ouputVariablesNames{2},timecodesPKS(i_pks), RRintervals(i_pks-1));
%             trip.setDataVariableAtTime(outputDataName, ouputVariablesNames{3},timecodesPKS(i_pks), timecodesPKSAdded(i_pks))
        end
        
        %% save figure
        if ~exist(figures_path,'dir')
            mkdir(figures_path);
        end
        savefig([figures_path filesep participant_id '_' scenario '.fig'])
        saveas(gcf,[figures_path filesep participant_id '_' scenario '.png']);
       
    elseif check_trip_meta(trip,['calcul_' mfilename],'OK') && forceProcess == 0
        disp(['Process "' mfilename '" already calculated for trip : ' trip.getTripPath]);
    elseif trip.getMetaInformations.existData(inputDataName) || trip.getAllDataOccurences(inputDataName).isEmpty
        disp([inputDataName ' is empty or missing from trip : ' trip.getTripPath]);
    end
    trip.setAttribute(['calcul_' mfilename], 'OK');
end