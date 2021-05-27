% Cette function permet de faire la synchro entre la structure
% "atlas_MP150" crée dans le cadre de la manip atlas et la structure "safemove/atlas" créer lors de l'import des des données dans le trip.
% Cette fonction est complétement inspiré de la fonction
% "sync_kvaser_mopad"

function sync_MP150 = sync_MP150_mopad(MP150_struct,mopad_struct,sync_method,data_name_mopad,variable_name_mopad,data_name_MP150,variable_name_MP150)
    sync_MP150 = MP150_struct;
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
    
    %% DATA MP150
    % look for the top_kvaser_start and top_kvaser_end in the Kvaser data
    % according to the selected synchronisation method.
    record = getfield(sync_MP150,data_name_MP150);
    switch sync_method
        case {'3brakes' 'default'}
            maximum_window_tc = 5; % 5s seems like a good value to 
                                   % detect the 3 pression on the brake.
            data_struct = getfield(record,variable_name_MP150);
            tops = extract_seuils_frein_intelligent(record.time.values,data_struct.values,maximum_window_tc);
            % begining of the first series of Brake
            top_MP150_start = tops(1).appuis(1,1);
            % begining of the last series of Brake
            top_MP150_end = tops(end).appuis(1,1);
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
    offset_MP150 = (top_MP150_start) - top_mopad_start;
    delta_MP150 = (top_MP150_end - top_MP150_start);
    delta_mopad = top_mopad_end - top_mopad_start;
    
    disp(['Temps mopad (resync) = ' num2str(delta_mopad) '. Temps MP150 = ' num2str(delta_MP150)]);
    
    if abs( delta_MP150 - delta_mopad ) <= 0.04
        % if the time ellapsed between the two tops from Mopad data
        % timecodes and from the kvaser data is less than two records (40 ms)
        % then there is no time shifting (the difference is due to the
        % measurement imprecision)
        derive_MP150= 1;
    else
        % Otherwise, there is a time shifting
        
        disp('Warning: Time shifting of data detected.');
        disp(['mopad = ' num2str(delta_mopad) 's, ' ...
              'MP150 = ' num2str(delta_MP150) 's.']);
        disp(['Difference of ' num2str(delta_mopad - delta_MP150) ...
              ' seconds during this trip.']);
        derive_MP150 = delta_mopad / delta_MP150;   
    end
        disp(['Offset and Derive between Mopad and MP150 are : ' num2str(offset_MP150) ' s and ' num2str(derive_MP150)]);
    
    %% SYNCHRONISATION
    
    % The structure is a bit different than for the kvaser structure since
    % there is only one reference time for all the data: struct_MP150.data.time
    


        % Check if the structure has already been synchronized
        if ~sync_MP150.META.synchronised
            
            % check if 'time_sync' already exists... if so, there is a problem!
            subnames = fieldnames(record);
            if any(strcmp(subnames,'time_sync'))
                exception = MException('SyncErr:SyncAlreadyExists', ...
                            'synchronised time already exists in data group');
                throw(exception);
            end
            

                  %% Bloc formule Sync Sébastian
            offset_MP150_derive = top_MP150_start*(derive_MP150-1)+offset_MP150;                 
            sync_MP150.data.time_sync.values =  (record.time.values * derive_MP150) - offset_MP150_derive ;   
            sync_MP150.data.time_sync.unit = 's';
            sync_MP150.data.time_sync.comments = 'Timecode calculated relatively to the Mopad synchronised data.';
            
            
            sync_MP150.META.MP150_top_MP150_start = top_MP150_start;
            sync_MP150.META.MP150_mopad_offset = offset_MP150;
            sync_MP150.META.MP150_mopad_shift  = derive_MP150;
            sync_MP150.META.MP150_mopad_sync_formula = '( (time/1000) * derive_MP150) - top_MP150_start*(derive_MP150-1)+offset_MP150';

        end
 
    
    sync_MP150.META.synchronised=true;
    
    % delete TopCons data of the MP150 synchronized structure to speed up
    % bind import
    %sync_MP150=rmfield(sync_MP150.data,'TopCons');

end



