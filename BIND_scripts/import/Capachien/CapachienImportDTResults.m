function [error] = CapachienImportDTResults(trip_file)
filename = [trip_file(1:end-5) '.csv'];
fileID = fopen(filename,'r');
dataArray = textscan(fileID, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]', 'Delimiter', ',', 'HeaderLines' ,1, 'ReturnOnError', false);
fclose(fileID);

%% Allocate imported array to column variable names
data_out.resp_expect = cellfun(@str2num,strrep(dataArray{:, 8},'None','0'));
data_out.resp_collect = cellfun(@str2num,strrep(dataArray{:, 12},'None','0'));
data_out.resp_evaluat = cellfun(@str2num,dataArray{:, 7});
data_out.resp_time = cellfun(@str2num,strrep(dataArray{:, 14},'NA','0'));
data_out.ISI_expect = cellfun(@str2num,dataArray{:, 1})/1000;

%% Get event_stim and compare to correct_corr
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
data_out.resp_expect_stim = cellfun(@str2num,strrep(trip.getAllEventOccurences('stim_audio').getVariableValues('Modalities')','D','0'));
data_out.timecodes = trip.getAllEventOccurences('stim_audio').getVariableValues('timecode')';
data_out.ISI_collect = diff(cell2mat(data_out.timecodes));
if length(data_out.resp_expect_stim) > length(data_out.resp_expect)
    data_out.resp_expect_stim = data_out.resp_expect_stim(1:length(data_out.resp_expect));
    data_out.ISI_collect = data_out.ISI_collect(1:length(data_out.resp_expect));
elseif length(data_out.resp_expect_stim) == length(data_out.resp_expect)
    data_out.ISI_collect(length(data_out.resp_expect)) = 0;
end
if all(data_out.resp_expect == data_out.resp_expect_stim)
    bindEventName = 'stim_audio';
    var_list_to_import = {'resp_expect','resp_collect','resp_evaluat','resp_time','ISI_expect','ISI_collect'};
    for i_var = 1:length(var_list_to_import)
        bindVariableName = var_list_to_import{i_var};
        addEventVariable_stim(trip,bindEventName,bindVariableName);
        for i_stim = 1:length(data_out.resp_expect)
            trip.setEventVariableAtTime(bindEventName,bindVariableName,data_out.timecodes{i_stim},data_out.(bindVariableName)(i_stim));
        end
    end
    error = 0;
else
    trip_name = strsplit(trip_file,'\');
    disp(['Le fichier "' trip_name(end) '" présente une incohérence dans les stimulations...']);
    error = 1;
end
trip.setAttribute('import_DT_results', 'OK');
delete(trip)
end

%% SUBFUNCTIONS
% add stim event variable
function addEventVariable_stim(trip,bindEventName,bindVariableName)
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existEventVariable(bindEventName,bindVariableName)
    bindVariable = fr.lescot.bind.data.MetaEventVariable();
    bindVariable.setName(bindVariableName);
    bindVariable.setType('REAL');
    bindVariable.setUnit('');
    bindVariable.setComments('');
    trip.addEventVariable(bindEventName,bindVariable);
end
end

%% variables du tableau exclues
% acc = cellfun(@str2num,dataArray{:, 2});
% acc_corr = cellfun(@str2num,dataArray{:, 3});
% avg_rt = cellfun(@str2num,dataArray{:, 4});
% avr_rt_corr = cellfun(@str2num,dataArray{:, 5});
% correct = cellfun(@str2num,dataArray{:, 6});
% nb_essais = cellfun(@str2num,dataArray{:, 11});
% nb_correct_corr = cellfun(@str2num,dataArray{:, 10});
% subject_nr = cellfun(@str2num,dataArray{:, 16});
% duree_inter_si_rt = cellfun(@str2num,dataArray{:, 9});
% response_time = cellfun(@str2num,dataArray{:, 13});
% somme_rt_corr = cellfun(@str2num,dataArray{:, 15});
