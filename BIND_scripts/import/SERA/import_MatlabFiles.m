% Import des fichiers matlab
function struct_matlab = import_MatlabFiles(matlab_file_name)

vars = fieldnames(matlab_file_name);

for i_vars = 1:length(vars)
    
    % création de la variable temps dans la strcuture
    struct_matlab.(vars{i_vars}).time_sync.values = matlab_file_name.(vars{i_vars})(:,end);
    struct_matlab.(vars{i_vars}).time_sync.unit = 's';
    struct_matlab.(vars{i_vars}).time_sync.comments = 'Time recorded in s';
    
    for i_data = 1:size(matlab_file_name.(vars{i_vars}), 2)-1
        
        % création des data dans la structure
        if size(matlab_file_name.(vars{i_vars}),2) > 2
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).values = matlab_file_name.(vars{i_vars})(:,i_data);
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).unit = '';
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).comments = '';
            
        elseif size(matlab_file_name.(vars{i_vars}),2) <= 2
            
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).values = matlab_file_name.(vars{i_vars})(:,i_data);
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).unit = 's';
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).comments = 'Time recorded in s';
            
            %création de META
            struct_matlab.META.synchronised=true;
            %struct_matlab.META.frequenceDATA = 1/(isi/1000);
        end
    end
end