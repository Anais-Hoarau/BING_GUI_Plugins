function file_path_out = Toyota_add_timecode(matlab_file_path)
% MAIN_FOLDER = 'W:\PROJETS ACTUELS\TOYOTA\DEMO_VIDEO\Démo_02';
% DATA_FOLDER = [MAIN_FOLDER '\Données'];
% file_path_in = fullfile(DATA_FOLDER, 'AllData');

data = load(matlab_file_path);
vars = fieldnames(data);
reg_directory = regexp(matlab_file_path,'\');
matlab_file_name = matlab_file_path(reg_directory(end)+1:end-4);

for i_data=1:length(vars)
    data_name = vars{i_data};
    if ~isempty(strfind(data_name, 'ECG')) || ~isempty(strfind(data_name, 'EEG'))
        Fe = 512;
    elseif ~isempty(strfind(data_name, 'EDA'))
        Fe = 2000;
    elseif ~isempty(strfind(data_name, 'VIT'))
        Fe = 25;
    end
    data = CreateTimeCodeColumn(data, data_name, Fe);
end
data_timecoded = data;
file_path_out = fullfile(matlab_file_path(1:reg_directory(end)), [matlab_file_name '_timecoded.mat']);
save(file_path_out, 'data_timecoded');
end

function out = CreateTimeCodeColumn(data, data_name, Fe)
if size(data.(data_name),2)<2
    data.(data_name)(:,2) = data.(data_name)(:,1);
    data.(data_name)(:,1) = 0;
    for i_line = 1:length(data.(data_name))-1
        data.(data_name)(i_line+1,1) = data.(data_name)(i_line,1)+(1/Fe);
    end
end
out = data;
end