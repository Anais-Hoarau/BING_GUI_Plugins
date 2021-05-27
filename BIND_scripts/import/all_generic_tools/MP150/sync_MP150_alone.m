% Cette function permet de faire la synchro entre la structure
% "atlas_MP150" crée dans le cadre de la manip atlas et la structure "safemove/atlas" créer lors de l'import des des données dans le trip.
function [sync_MP150, IDs_tops] = sync_MP150_alone(MP150_struct, data_name_MP150)
sync_MP150 = MP150_struct;

%% DATA MP150
record = getfield(sync_MP150,data_name_MP150);

%% SYNCHRONISATION
if ~sync_MP150.META.synchronised
    % check if 'time_sync' already exists... if so, there is a problem!
    subnames = fieldnames(record);
    if any(strcmp(subnames,'time_sync'))
        exception = MException('SyncErr:SyncAlreadyExists', ...
            'synchronised time already exists in data group');
        throw(exception);
    end
    
    %% Bloc formule Sync Sébastian
    sync_MP150.data.time_sync.values =  record.time.values;
    sync_MP150.data.time_sync.unit = 's';
    sync_MP150.data.time_sync.comments = 'Timecode calculated relatively to the simu synchronised data.';
    
    sync_MP150.META.MP150_top_MP150_start = 0;
    sync_MP150.META.MP150_mopad_offset = 0;
    sync_MP150.META.MP150_mopad_delta = length(record.time.values)/1000;
    sync_MP150.META.MP150_mopad_shift  = 1;
    sync_MP150.META.MP150_mopad_sync_formula = '( (time/1000) * derive_MP150) - top_MP150_start*(derive_MP150-1)+offset_MP150';
end

sync_MP150.META.synchronised=true;

end