%% import_struct_as_data_in_bind_trip

function import_data_struct_in_bind_trip_MP150_2Simax(struct_to_import, trip, bind_prefix, IDs_tops)

% check that the data is synchronised
if ~isfield(struct_to_import.META,'synchronised') || ~struct_to_import.META.synchronised
    exception = MException('SyncErr:SyncDoNotExist', ...
        'The source META.synchronised does not exist or is set to false. Impossible to import data in BIND if not synchronised.');
    throw(exception);
end

% add the meta informations to the trip
% and check if synchronised to a video
disp('Creating Trip MetaAttributes...');
meta_names = fieldnames(struct_to_import.META);
for i=1:length(meta_names)
    switch meta_names{i}
        case {'video_offset', 'video_description', 'video_path'}
            % information about video, skipped...
            % is handled later
        otherwise
            meta_value = getfield(struct_to_import.META,meta_names{i});
            if isnumeric(meta_value)
                meta_value = sprintf('%f',meta_value);
            elseif islogical(meta_value)
                meta_value = sprintf('%d',meta_value);
            elseif isstruct(meta_value)
                meta_value = 'Unparsed structure';
            end
            disp(['MetaAttribute ' meta_names{i} ': ' meta_value]);
            trip.setAttribute(meta_names{i},meta_value);
    end
    % if a video file has been found and information is available
    % adds the video to the trip
    if isfield(struct_to_import.META,'video_offset') ...
            && isfield(struct_to_import.META,'video_description') ...
            && isfield(struct_to_import.META,'video_path')
        % get the infos about the video
        video_offset = struct_to_import.META.video_offset;
        video_description = struct_to_import.META.video_description;
        video_path = struct_to_import.META.video_path;
        % add video to the triip
        meta_video = fr.lescot.bind.data.MetaVideoFile(video_path, video_offset, video_description);
        trip.addVideoFile(meta_video);
    end
end

tic
% add the data to the trip
data_names = fieldnames(struct_to_import);
for i=1:length(data_names)
    % remove data table if necessary
    meta_info = trip.getMetaInformations;
    if meta_info.existData(data_names{i})
        removeDataTables(trip, data_names(i))
    end
    % META is a special field
    % we want to parse only the other fields
    if ~strcmp(data_names{i},'META')
        if isempty(bind_prefix)
            bind_data_name = data_names{i};
        else
            bind_data_name = [bind_prefix '_' data_names{i}];
        end
        disp(['Parsing data ' bind_data_name ':']);
        disp('Creating Trip MetaData and MetaDataVariables...');
        record = getfield(struct_to_import,data_names{i});
        var_names = fieldnames(record);
        
        % build the meta data and meta variables
        meta_data = fr.lescot.bind.data.MetaData();
        meta_data.setName(bind_data_name);
        if isfield(struct_to_import.META,'frequenceData')
            meta_data.setFrequency(struct_to_import.META.frequenceData);
        end
        % build the meta variables
        cell_array_meta_variables = cell(1,length(var_names));
        for j=1:length(var_names)
            variable_struct = getfield(record,var_names{j});
            meta_variable = fr.lescot.bind.data.MetaDataVariable();
            if strcmp(var_names{j},'time_sync')
                bind_variable_name = 'timecode';
            else
                % test if the name contains a 'POURCENT_' that needs to be
                % replaced with '%'
                bind_variable_name = var_names{j};
                bind_variable_name = strrep(bind_variable_name,'POURCENT_','%');
            end
            meta_variable.setName(bind_variable_name);
            meta_variable.setUnit(variable_struct.unit);
            meta_variable.setComments(variable_struct.comments);
            
            % Modifacation SG : utilisation des metas données pour définir le type.
            % This test is used to define the type of the metadata variable.
            % It is defined only if the META infos 'typ' is present in the struct. The type has to be the same for all the data table.
            if isfield(struct_to_import.META,'type')
                if strcmp(meta_variable.getName,'timecode')
                    meta_variable.setType('REAL');
                else
                    meta_variable.setType(struct_to_import.META.type);
                end
            end
            
            % fill up the cell array of meta variables
            cell_array_meta_variables{j} = meta_variable;
        end
        meta_data.setVariables(cell_array_meta_variables);
        meta_data.setComments(['generated ' date]);
        % record the meta_data in the TRip
        trip.addData(meta_data);
        
        % fill up the data
        disp('Filling up data...');
        % find the timecode variable
        timecodes_sync = record.time_sync.values;
%         timecodes_sync_usefull = timecodes_sync(IDs_tops(1):IDs_tops(end));
        timecodes_sync_usefull = timecodes_sync(1:IDs_tops(16));
        bind_timecode = num2cell(timecodes_sync_usefull');
        % for each variable
        for j=1:length(var_names)
            if ~strcmp(var_names{j},'time_sync')
                variable_struct = getfield(record,var_names{j});
                
                % do not covert to cell if the type is TEXT
                meta_variable = cell_array_meta_variables{j};
                if ~strcmp(meta_variable.getType(),'TEXT')
                    bind_variable_values = num2cell(variable_struct.values');
                else
                    bind_variable_values = variable_struct.values';
                end
                
                % test if the name contains a 'POURCENT_' that needs to be
                % replaced with '%'
                bind_variable_name = var_names{j};
                bind_variable_name = strrep(bind_variable_name,'POURCENT_','%');
                
                disp(['Importing variable ' bind_data_name '.' bind_variable_name ]);
                % 1st method:
                % import the data all at once
%                 trip.setBatchOfTimeDataVariablePairs(bind_data_name,bind_variable_name,[bind_timecode ; bind_variable_values]);
                % 2nd method:
                % import the data by 10000 lines batches
                number_of_lines_in_a_batch = 10000;
%                 bind_variable_values_usefull = bind_variable_values(IDs_tops(1):IDs_tops(end));
                bind_variable_values_usefull = bind_variable_values(1:IDs_tops(16));
                total_number_of_lines = length(bind_variable_values_usefull);
                number_of_batches = floor(total_number_of_lines / number_of_lines_in_a_batch);
%                 indiceClapDeb = IDs_tops(1);
%                 indiceClapFin = IDs_tops(end);
%                 slicesStartingIndexes = indiceClapDeb:number_of_lines_in_a_batch:indiceClapFin;
                for batch_num=0:(number_of_batches-1)
                    disp(['Inserting ' bind_variable_name ' : ' num2str(batch_num*number_of_lines_in_a_batch) ' lines / ' num2str(total_number_of_lines) ' lines']);
                    index_batch = batch_num*number_of_lines_in_a_batch + 1 : (batch_num+1)* number_of_lines_in_a_batch;
                    batch_time_value_cell = [bind_timecode(index_batch) ; bind_variable_values_usefull(index_batch)];
                    trip.setBatchOfTimeDataVariablePairs(bind_data_name,bind_variable_name,batch_time_value_cell);
                end
                index_batch = number_of_batches*number_of_lines_in_a_batch + 1 : total_number_of_lines;
                batch_time_value_cell = [bind_timecode(index_batch) ; bind_variable_values_usefull(index_batch)];
                trip.setBatchOfTimeDataVariablePairs(bind_data_name,bind_variable_name,batch_time_value_cell);
            end
        end
    end
end
disp(toc);

end
%% remove data tables from trip file
function removeDataTables(trip, dataList)
meta_info = trip.getMetaInformations;
for i_data = 1:length(dataList)
    if meta_info.existData(dataList{i_data}) && ~isBase(meta_info.getMetaData(dataList{i_data}))
        trip.removeData(dataList{i_data});
    else
        disp([dataList{i_data} ' event is locked by "isBase" protocole']);
    end
end
end