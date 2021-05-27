% calcul de la labilité électro-dermale
function EDASpontaneousResponse(trip, trip_file, startTime, endTime, cas_situation)
    participant_id = strsplit(trip_file, '\'); participant_id = participant_id{end}(1:end-5);
    %% Get data
    if trip.getMetaInformations().existDataVariable('MP150_data','EDA')
        EDA_data = cell2mat(trip.getDataOccurencesInTimeInterval('MP150_data', startTime, endTime).getVariableValues('EDA'));
    end
    
    %% Smooth data
    EDA_data_smooth = smooth(EDA_data,100);
    plot(EDA_data_smooth);
    
    %% Detrend data
    detrend_EDA_data_smooth = detrend(EDA_data_smooth);
    plot(detrend_EDA_data_smooth);
    
    %% Find spontaneous fluctuations
    MinPP = 0.01; %old value = 0.02
%     MAXW = 5000; %old value = --
    WR = 'halfprom';
    figure('units','normalized','outerposition',[0 0 1 1]);
    findpeaks(detrend_EDA_data_smooth,'MinPeakProminence',MinPP,'WidthReference',WR) %,'MaxPeakWidth',MAXW)
    title(strrep(participant_id, '_', '__')); xlabel('Durée (ms)'); ylabel('EDA_smooth (uS)');
    
    
    [PKS,LOCS] = findpeaks(detrend_EDA_data_smooth,'MinPeakProminence',MinPP,'WidthReference',WR) %,'MaxPeakWidth',MAXW);
    nbEDASpontRep = length(PKS);
    
    trip.setSituationVariableAtTime(cas_situation, 'nb_EDAFluctSpont', startTime, endTime, nbEDASpontRep);
    
    %% Save figure
    EXPORT_FOLDER = ['\\vrlescot\THESE_GUILLAUME\VORTEX\Data\TESTS\~DATA_EXPORT\FIGURES' filesep 'EDA'];
    if ~exist(EXPORT_FOLDER,'dir')
        mkdir(EXPORT_FOLDER);
    end
    savefig([EXPORT_FOLDER filesep participant_id '.fig'])
    saveas(gcf,[EXPORT_FOLDER filesep participant_id '.png']);
    
end