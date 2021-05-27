%% sync_kvaser_mopad
% This function adds a new timecode column (called time_sync) that
% synchronises the kvaser data to the mopad data.
% 
% If the timecode column 'time_sync' already exists, then an exception is
% raised because it means the signal has already been synchronised with
% another source.
% 
% There are several synchronisation methods. By default, the method used to
% synchronise takes the first and the last trigger points related to the
% LED signal (threshold up).
% 
% input argument:
% kvaser_struct:    a structure containing the UN-synchronised Kvaser data.
%                   (typically, the output of import_kvaser_struct funciton)
% mopad_struct:     a structure containing the synchronised Mopad data.
% full_directory:   location of the folder containing the clap file.
% sync_method:      a String describing the method used:
%                   '3brakes':      takes the first series of 3 consecutive
%                                   brakes (within a short time) and the
%                                   last series of 3 consecutive brakes.
%                   'default':      the same as '3brakes'
% data_name_mopad:  name of the Mopad data source containing the 
%                   synchronisation signal used for the synchronisation.
% variable_name_mopad : name of the Mopad variable (of the data 
%                   data_name_mopad) that is the synchronisation signal.
% data_name_kvaser:  name of the Kvaser data source containing the 
%                   synchronisation signal used for the synchronisation.
% variable_name_kvaser : name of the Kvaser variable (of the data 
%                   data_name_mopad) that is the synchronisation signal.
%
% output argument:
% sync_kvaser:       a structure containing the synchronised Kvaser data.
%

function sync_kvaser = sync_kvaser_mopad(kvaser_struct,mopad_struct,sync_method,data_name_mopad,variable_name_mopad,data_name_kvaser,variable_name_kvaser)

    % check if the META.synchronised field says that the data has been synchronised...
    % if so, there is a problem!
    if isfield(kvaser_struct.META,'synchronised') && kvaser_struct.META.synchronised
        exception = MException('SyncErr:SyncAlreadyExists', ...
                    'The source META.synchronised field is set to true. Source is already synchronised.');
        throw(exception);
    end
    
    % check if the META.synchronised field says that the data has been synchronised...
    % if so, there is a problem!
    if ~isfield(mopad_struct.META,'synchronised') || ~mopad_struct.META.synchronised
        exception = MException('SyncErr:SyncDoNotExist', ...
                    'The source META.synchronised of Mopad data does not exist or is set to false. Impossible to synchronised Kvaser data with unsynchronised Mopad data.');
        throw(exception);
    end

    sync_kvaser = kvaser_struct;

    %% DATA MOPAD
    % look for the top_mopad_start and top_mopad_end in the Mopad data
    % according to the selected synchronisation method.
    record = getfield(mopad_struct,data_name_mopad);
    switch sync_method
        case {'3brakes' 'default'}
            maximum_window_tc = 5; % 5s seems like a good value to 
                                   % detect the 3 pression on the brake.
            data_struct = getfield(record,variable_name_mopad);
            tops_sync = extract_seuils_frein_intelligent(record.time_sync.values,data_struct.values,maximum_window_tc);
            % begining of the first series of Brake
            top_mopad_start = tops_sync(1).appuis(1,1);
            % begining of the last series of Brake
            top_mopad_end = tops_sync(end).appuis(1,1);
        otherwise
            exception = MException('FuncParam:Unknown', ...
                        ['Unknown sync_method: ' sync_method]);
            throw(exception);
    end
    
    %% DATA KVASER
    % look for the top_kvaser_start and top_kvaser_end in the Kvaser data
    % according to the selected synchronisation method.
    record = getfield(sync_kvaser,data_name_kvaser);
    switch sync_method
        case {'3brakes' 'default'}
            maximum_window_tc = 5; % 5s seems like a good value to 
                                   % detect the 3 pression on the brake.
            data_struct = getfield(record,variable_name_kvaser);
            tops = extract_seuils_frein_intelligent(record.time.values,data_struct.values,maximum_window_tc);
            % begining of the first series of Brake
            top_kvaser_start = tops(1).appuis(1,1);
            % begining of the last series of Brake
            top_kvaser_end = tops(end).appuis(1,1);
        otherwise
            exception = MException('FuncParam:Unknown', ...
                        ['Unknown sync_method: ' sync_method]);
            throw(exception);
    end
    
    %% OFFSET AND TIME SHIFTING
    % calculate the offset and time shifting by comparing information about
    % the tops found in kvaser file and in the mopad data (comparing
    % top_mopad_start and top_mopad_end to top_kvaser_start and
    % top_kvaser_end).
    offset_kvaser = top_kvaser_start - top_mopad_start;
    delta_kvaser = top_kvaser_end - top_kvaser_start;
    delta_mopad = top_mopad_end - top_mopad_start;
    
    disp(['Temps Mopad (resync) = ' num2str(delta_mopad) 's . Temps Kvaser = ' num2str(delta_kvaser) 's .']);
            
    if abs( delta_kvaser - delta_mopad ) <= 0.04
        % if the time ellapsed between the two tops from Mopad data
        % timecodes and from the kvaser data is less than two records (40 ms)
        % then there is no time shifting (the difference is due to the
        % measurement imprecision)
        derive_kvaser = 1;
    else
        % Otherwise, there is a time shifting
        disp('Warning: Time shifting of data detected.');
        disp(['mopad = ' num2str(delta_mopad) 's, ' ...
              'kvaser = ' num2str(delta_kvaser) 's.']);
        disp(['Difference of ' num2str(delta_mopad - delta_kvaser) ...
              ' seconds during this trip.']);
        derive_kvaser = delta_mopad / delta_kvaser;
    end
    
    disp(['Offset and Derive between Mopad (resync) and Kvaser are : ' num2str(offset_kvaser) ' s and ' num2str(derive_kvaser)]);
    
    %% SYNCHRONISATION
    % for each data source (one per mopad .txt file)
    source_names = fieldnames(sync_kvaser);
    for i = 1:length(source_names)
        % if it is a data field (not the 'META' field)
        if ~strcmp(source_names{i},'META')
            record = getfield(sync_kvaser,source_names{i});
            subnames = fieldnames(record);
            
            % check if 'time_sync' already exists... if so, there is a
            % problem!
            if any(strcmp(subnames,'time_sync'))
                exception = MException('SyncErr:SyncAlreadyExists', ...
                            ['synchronised time already exists in data group ''' source_names{i} '''']);
                throw(exception);
            end
            
            % remove possible timecode = 0
            ind_tcNotEq0 = record.time.values~=0;
            for j = 1:length(subnames)
                data = getfield(record,subnames{j});
                data.values = data.values(ind_tcNotEq0);
                record = setfield(record,subnames{j},data);
            end
            
            %% Bloc formule Sync Sébastian
            offset_kvaser_derive = top_kvaser_start*(derive_kvaser-1)+offset_kvaser;                 
            record.time_sync.values =  (record.time.values * derive_kvaser) - offset_kvaser_derive ;   
            record.time_sync.unit = 's';
            record.time_sync.comments = 'Timecode calculated relatively to the Mopad synchronised data.';
            sync_kvaser = setfield(sync_kvaser,source_names{i},record);
            
            sync_kvaser.META.kvaser_top_kvaser_start = top_kvaser_start;
            sync_kvaser.META.kvaser_mopad_offset = offset_kvaser;
            sync_kvaser.META.kvaser_mopad_shift  = derive_kvaser;
            sync_kvaser.META.kvaser_mopad_sync_formula = '( (time/1000) * derive_kvaser) - top_kvaser_start*(derive_kvaser-1)+offset_kvaser';
            
                          
            %% Bloc ancienne formule de time sync 
%             record.time_sync.values =  (record.time.values - offset_kvaser)* derive_kvaser ;   
%             record.time_sync.unit = 's';
%             record.time_sync.comments = 'Timecode calculated relatively to the Mopad synchronised data.';
%             sync_kvaser = setfield(sync_kvaser,source_names{i},record);
%             
%             sync_kvaser.META.kvaser_mopad_offset = offset_kvaser;
%             sync_kvaser.META.kvaser_mopad_shift  = derive_kvaser;
%             sync_kvaser.META.kvaser_mopad_sync_formula = '( (time/1000) - kvaser_mopad_offset ) * kvaser_mopad_shift';

        end
    end
       
    sync_kvaser.META.synchronised = true;
end