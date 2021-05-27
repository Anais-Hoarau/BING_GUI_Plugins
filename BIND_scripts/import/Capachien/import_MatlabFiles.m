% Import des fichiers matlab
function struct_matlab = import_MatlabFiles(data_timecoded)

% load(matlab_file_name);
vars = fieldnames(data_timecoded);
%offset = 0;

for i_vars = 1:length(vars)
    
    % création de la variable temps dans la strcuture
    struct_matlab.(vars{i_vars}).time_sync.values = data_timecoded.(vars{i_vars})(:,1); %+offset; %+0.320 pour 04F3 %+0.16 pour 6A07
    struct_matlab.(vars{i_vars}).time_sync.unit = 's';
    struct_matlab.(vars{i_vars}).time_sync.comments = 'Time recorded in s';
    
    for i_data = 1:size(data_timecoded.(vars{i_vars}), 2)-1
        
        % création des data dans la structure
        if size(data_timecoded.(vars{i_vars}),2) > 2
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).values = data_timecoded.(vars{i_vars})(:,i_data+1);
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).unit = '';
            struct_matlab.(vars{i_vars}).([num2str(vars{i_vars}) '_' num2str(i_data)]).comments = '';
            
        elseif size(data_timecoded.(vars{i_vars}),2) <= 2
            
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).values = data_timecoded.(vars{i_vars})(:,i_data+1);
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).unit = '';
            struct_matlab.(vars{i_vars}).(num2str(vars{i_vars})).comments = '';
        end
        %création de META
        struct_matlab.META.synchronised=true;
        %struct_matlab.META.frequenceDATA = 1/(isi/1000);
    end
end