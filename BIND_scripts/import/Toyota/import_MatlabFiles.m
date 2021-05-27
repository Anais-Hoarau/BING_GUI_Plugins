% Import des fichiers matlab
function struct_matlab = import_MatlabFiles(matlab_file_name)
% MAIN_FOLDER = 'W:\PROJETS ACTUELS\TOYOTA\DEMO_VIDEO\Démo_02';
% DATA_FOLDER = [MAIN_FOLDER '\Données'];
% matlab_file_name = fullfile(DATA_FOLDER, 'AllData_timecoded.mat');

load(matlab_file_name);
vars = fieldnames(data_timecoded);

for i_vars = 1:length(vars)
    for i_data = 1:size(data_timecoded.(vars{i_vars}), 2)
        
        % création de la variable temps dans la strcuture
        struct_matlab.(vars{i_vars}).time_sync.values = data_timecoded.(vars{i_vars})(:,1);
        struct_matlab.(vars{i_vars}).time_sync.unit = 's';
        struct_matlab.(vars{i_vars}).time_sync.comments = 'Time recorded in s';
        
        % création des datas dans la structure
        struct_matlab.(vars{i_vars}).data.values = data_timecoded.(vars{i_vars})(:,2);
        struct_matlab.(vars{i_vars}).data.unit = '';
        struct_matlab.(vars{i_vars}).data.comments = '';
        
        %création de META
        struct_matlab.META.synchronised=true;
        %struct_matlab.META.frequenceDATA = 1/(isi/1000);
    end
end
end