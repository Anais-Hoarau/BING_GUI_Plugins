function [data_timecoded] = SERA_add_timecode(matlab_file)

data = matlab_file;
vars = fieldnames(data);
% reg_directory = regexp(matlab_file_path,'\');
% matlab_file_name = matlab_file_path(reg_directory(end)+1:end-4);

%% N_values put in time if necessary

if isempty(cell2mat(strfind(vars, 'distance_pas'))) || isempty(cell2mat(strfind(vars, 'rythme_pas'))) || isempty(cell2mat(strfind(vars, 'vitesse_pas')))
    i_pic = 1;
    data.rythme_pas = zeros(1,length(data.distance_f))';
    data.vitesse_pas = zeros(1,length(data.distance_f))';
    data.distance_pas = zeros(1,length(data.distance_f))';
    for i_value = 1:data.N_pic(end)
        if i_value < data.N_pic(i_pic)
            data.rythme_pas(i_value) = data.N_rythme(i_pic);
            data.vitesse_pas(i_value) = data.N_vitesse(i_pic);
            data.distance_pas(i_value) = data.N_distance_max(i_pic);
        elseif i_value == data.N_pic(i_pic)
            data.rythme_pas(i_value) = data.N_rythme(i_pic);
            data.vitesse_pas(i_value) = data.N_vitesse(i_pic);
            data.distance_pas(i_value) = data.N_distance_max(i_pic);
            i_pic = i_pic+1;
        end
    end
    clearvars i_pic i_value
end

vars = fieldnames(data);
for i_data=1:length(vars)
    data_name = vars{i_data};
    if isempty(strfind(data_name, 'N_'))
        Fe = 100;
    elseif ~isempty(strfind(data_name, 'N_'))
        continue;
    end
    data = CreateTimeCodeColumn(data, data_name, Fe);
end
data_timecoded = data;
% file_path_out = fullfile(matlab_file_path(1:reg_directory(end)), [matlab_file_name '_timecoded.mat']);
% save(file_path_out, 'data_timecoded');
end

function out = CreateTimeCodeColumn(data, data_name, Fe)
num_time_column = size(data.(data_name),2)+1;
data.(data_name)(:,num_time_column) = 0;
for i_line = 1:length(data.(data_name))-1
    data.(data_name)(i_line+1,num_time_column) = data.(data_name)(i_line,num_time_column)+(1/Fe);
end
out = data;
end