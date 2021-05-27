% Import des fichiers matlab
function struct_matlab = CapadynImportMatlabFiles(matlab_file_name)

load(matlab_file_name);
vars = fieldnames(data_timecoded);

for i_vars = 1:length(vars)
    
    % cr�ation de la variable temps dans la strcuture
    struct_matlab.(vars{i_vars}).time_sync.values = data_timecoded.(vars{i_vars})(:,end);
    struct_matlab.(vars{i_vars}).time_sync.unit = 's';
    struct_matlab.(vars{i_vars}).time_sync.comments = 'Time recorded in s';
    
    for i_data = 1:size(data_timecoded.(vars{i_vars}), 2)-1
        
        % cr�ation des data dans la structure
        if size(data_timecoded.(vars{i_vars}),2) > 2
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).values = data_timecoded.(vars{i_vars})(:,i_data);
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).unit = '';
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).comments = '';
            
        elseif size(data_timecoded.(vars{i_vars}),2) <= 2
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).values = data_timecoded.(vars{i_vars})(:,i_data);
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).unit = '';
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).comments = '';
        end
        %cr�ation de META
        struct_matlab.META.synchronised=true;
        %struct_matlab.META.frequenceDATA = 1/(isi/1000);
    end
end