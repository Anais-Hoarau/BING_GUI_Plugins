%% sync_mopad_alone
% This function adds a new timecode column (called time_sync) that
% gives a reference timecode to the mopad data.
%
% If the timecode column 'time_sync' already exists, then a message is
% displayed (or an exception raised?) because it means the signal has
% already been synchronised with another source.
% 
% The synchronisation method is simple: the synchronised timecode
% (time_sync) is the number of seconds ellapsed since the begining of the
% experiment. It is calculated relatively to Mopad timecode (time in ms).
%
% input argument:
% mopad_struct:     a structure containing the UN-synchronised Mopad data.
%                   (typically, the output of import_mopad_struct funciton)
%
% output argument:
% sync_mopad:       a structure containing the synchronised Mopad data.
%

function sync_mopad = sync_mopad_alone(mopad_struct)

    % check if the META.synchronised field says that the data has been synchronised...
    % if so, there is a problem!
    if isfield(mopad_struct.META,'synchronised') && mopad_struct.META.synchronised
        exception = MException('SyncErr:SyncAlreadyExists', ...
                    ['The source META.synchronised field is set to true. Source is already synchronised.']);
        throw(exception);
    end

    sync_mopad = mopad_struct;

    % initialise offset_mopad to empty
    offset_mopad = [];
    
    % for each data source (one per mopad .txt file)
    source_names = fieldnames(sync_mopad);
    for i = 1:length(source_names)
        % if it is a data field (not the 'META' field)
        if ~strcmp(source_names{i},'META')
            record = getfield(sync_mopad,source_names{i});
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
            
            % add the time_sync field
            % check if offset_mopad has been defined
            if isempty(offset_mopad)
                offset_mopad = record.time.values(1);
            end
            record.time_sync.values = (record.time.values - offset_mopad)/1000 ;
            record.time_sync.unit = 's';
            record.time_sync.comments = 'Timecode calculated relatively to the start of the experiment (time_sync = 0 when the data collection starts).';
            sync_mopad = setfield(sync_mopad,source_names{i},record);
        end
    end
    
    sync_mopad.META.synchronised = true;
    
end