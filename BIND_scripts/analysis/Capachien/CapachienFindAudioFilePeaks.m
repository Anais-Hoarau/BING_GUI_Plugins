function CapachienFindAudioFilePeaks(Path)
%% Find trip and media files
%Path = 'D:\LESCOT\PROJETS DE RECHERCHE\THESE_CAROLINE\P07_06DT2AO_20150929_AM';
trip_file = cell2mat(dirrec(Path, '.trip'));
media_file = cell2mat(dirrec(Path, '.mp3'));

%% Find peaks, draw and save graph
audio_file = audioread(media_file);
audio_file_smooth = smooth(audio_file(:,1),20);

% find peaks
[pks,locs] = findpeaks(audio_file_smooth,'minpeakheight',0.04,'maxpeakheight',0.09,'MinPeakProminence',0.1,'MaxPeakProminence',0.25,'MinPeakDistance',60000,'MinPeakWidth',50);
findpeaks(audio_file_smooth,'minpeakheight',0.04,'maxpeakheight',0.09,'MinPeakProminence',0.1,'MaxPeakProminence',0.25,'MinPeakDistance',60000,'MinPeakWidth',50);
pause(2)
close
% [pks_1,locs_1] = findpeaks(audio_file_smooth,'minpeakheight',0.20,'maxpeakheight',0.30,'MinPeakProminence',0.7,'MaxPeakProminence',1.2,'MinPeakDistance',70000,'MinPeakWidth',60);
% [pks_D,locs_D] = findpeaks(audio_file_smooth,'minpeakheight',0.40,'maxpeakheight',0.50,'MinPeakProminence',0.7,'MaxPeakProminence',1.2,'MinPeakDistance',70000,'MinPeakWidth',60);
% pks_locs(:,1) = cat(1,pks_1, pks_D);
% pks_locs(:,2) = cat(1,locs_1, locs_D);
% pks_locs_sorted = sortrows(pks_locs,2);
% pks = pks_locs_sorted(:,1);
% locs = pks_locs_sorted(:,2);

%% VERIFY PEAKS
mean_pks = 0;
mean_pks_1 = 0;
mean_pks_D = 0;
std_pks_1 = 0;
std_pks_D = 0;
nb_std_inf = 3;
nb_std_sup = 3;
% draw & save graph
if ~isempty(strfind(Path, 'DT1'))
    mean_pks_1 = mean(pks);
    std_pks_1 = std(pks);
    ylim manual
    hold on
    ylim([(mean_pks_1-std_pks_1*nb_std_inf) (mean_pks_1+std_pks_1*nb_std_sup)])
    plot(mean_pks_1*ones(length(audio_file_smooth),1))
    plot((mean_pks_1+std_pks_1*nb_std_sup)*ones(length(audio_file_smooth),1))
    plot((mean_pks_1-std_pks_1*nb_std_inf)*ones(length(audio_file_smooth),1))
    findpeaks(audio_file_smooth,'minpeakheight',0.04,'maxpeakheight',0.09,'MinPeakProminence',0.1,'MaxPeakProminence',0.25,'MinPeakDistance',60000,'MinPeakWidth',50,'autoScale','false');
    hold off
elseif ~isempty(strfind(Path, 'DT2'))
    mean_pks = mean(pks);
    mask_pks_1 = pks<mean_pks(1);
    mean_pks_1 = mean(pks(mask_pks_1));
    std_pks_1 = std(pks(mask_pks_1));
    mask_pks_D = pks>mean_pks(1);
    mean_pks_D = mean(pks(mask_pks_D));
    std_pks_D = std(pks(mask_pks_D));
    ylim manual
    hold on
    ylim([(mean_pks_1-std_pks_1*nb_std_inf) (mean_pks_D+std_pks_D*nb_std_sup)])
    plot(mean_pks*ones(length(audio_file_smooth),1))
    plot(mean_pks_1*ones(length(audio_file_smooth),1))
    plot((mean_pks_1+std_pks_1*nb_std_sup)*ones(length(audio_file_smooth),1))
    plot((mean_pks_1-std_pks_1*nb_std_inf)*ones(length(audio_file_smooth),1))
    plot(mean_pks_D*ones(length(audio_file_smooth),1))
    plot((mean_pks_D+std_pks_D*nb_std_sup)*ones(length(audio_file_smooth),1))
    plot((mean_pks_D-std_pks_D*nb_std_inf)*ones(length(audio_file_smooth),1))
    findpeaks(audio_file_smooth,'minpeakheight',0.05,'maxpeakheight',0.145,'MinPeakProminence',0.2,'MaxPeakProminence',0.22,'MinPeakDistance',70000,'MinPeakWidth',50,'autoScale','false'); %0.05 et 0.2
    hold off
end
splitPath = strsplit(Path, '\');
saveas(gcf, [Path filesep splitPath{end} '.png'])
close

%% Add event_stim_audio if necessary
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
eventList = {'stim_audio'};
removeEventsTables(trip, eventList)
meta_info = trip.getMetaInformations();
if ~meta_info.existEvent('stim_audio')
    bindEventName = 'stim_audio';
    bindEventComment = 'Stimulations auditives (1 ou D)';
    
    bindVariableName = 'Modalities';
    bindVariableType = 'TEXT';
    bindVariableUnit = '';
    bindVariableComments = '';
    
    bindVariable = fr.lescot.bind.data.MetaEventVariable();
    bindVariable.setName(bindVariableName);
    bindVariable.setType(bindVariableType);
    bindVariable.setUnit(bindVariableUnit);
    bindVariable.setComments(bindVariableComments);
    bindVariables = {bindVariable};
    
    bindEvent = fr.lescot.bind.data.MetaEvent();
    bindEvent.setName(bindEventName);
    bindEvent.setComments(bindEventComment);
    bindEvent.setVariables(bindVariables);
    
    trip.addEvent(bindEvent);
end

%% Fill event_stim_audio
nb_stim = 0;
nb_stim_1 = 0;
nb_stim_D = 0;
for i_pks = 1:length(pks)
    %     near_locs = sum(abs(locs-locs(i_pks))<10000); % near_locs is used to find if 2 peaks (low and hight) are detected for the same stimulation
    if any(~isempty(strfind(Path, 'DT1')) & pks(i_pks)<(mean_pks_1+(std_pks_1*nb_std_sup)) & pks(i_pks)>(mean_pks_1-(std_pks_1*nb_std_inf))) % for DT1
        modality = '1';
        nb_stim = nb_stim+1;
        nb_stim_1 = nb_stim_1+1;
        trip.setBatchOfTimeEventVariablePairs('stim_audio', 'Modalities', [num2cell((locs(i_pks)-1600)/44100), modality]'); % 1600 samples between peak detected and begining of sound with fs = 44100Hz
    elseif any(~isempty(strfind(Path, 'DT2')) & pks(i_pks)<mean_pks & pks(i_pks)<(mean_pks_1+(std_pks_1*nb_std_sup)) & pks(i_pks)>(mean_pks_1-(std_pks_1*nb_std_inf))) % for DT2
        modality = '1';
        nb_stim = nb_stim+1;
        nb_stim_1 = nb_stim_1+1;
        trip.setBatchOfTimeEventVariablePairs('stim_audio', 'Modalities', [num2cell((locs(i_pks)-1600)/44100), modality]'); % 1600 samples between peak detected and begining of sound with fs = 44100Hz
    elseif any(~isempty(strfind(Path, 'DT2')) & pks(i_pks)>mean_pks & pks(i_pks)<(mean_pks_D+(std_pks_D*nb_std_sup)) & pks(i_pks)>(mean_pks_D-(std_pks_D*nb_std_inf))) % for DT2
        modality = 'D';
        nb_stim = nb_stim+1;
        nb_stim_D = nb_stim_D+1;
        trip.setBatchOfTimeEventVariablePairs('stim_audio', 'Modalities', [num2cell((locs(i_pks)-1400)/44100), modality]'); % 1400 samples between peak detected and begining of sound with fs = 44100Hz
    end
end
attributeList = {'nb_stim','nb_stim_1','nb_stim_D'};
removeAttributes(trip,attributeList)
trip.setAttribute('import_stim','OK');
trip.setAttribute('nb_stim',num2str(nb_stim));
trip.setAttribute('nb_stim_1',num2str(nb_stim_1));
trip.setAttribute('nb_stim_D',num2str(nb_stim_D));
end

% remove events tables from trip file
function removeEventsTables(trip, eventList)
meta_info = trip.getMetaInformations;
for i_event = 1:length(eventList)
    if meta_info.existEvent(eventList{i_event}) && ~isBase(meta_info.getMetaEvent(eventList{i_event}))
        trip.removeEvent(eventList{i_event});
    else
        disp([eventList{i_event} ' event is locked by "isBase" protocole']);
    end
end
end

% remove attributes from trip file
function removeAttributes(trip, attributeList)
meta_info = trip.getMetaInformations;
for i_attribute = 1:length(attributeList)
    if meta_info.existAttribute(attributeList{i_attribute})
        trip.removeAttribute(attributeList{i_attribute});
    else
        disp([attributeList{i_attribute} ' attribute doesn''t exist']);
    end
end
end