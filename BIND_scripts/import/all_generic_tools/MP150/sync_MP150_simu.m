% Cette function permet de faire la synchro entre la structure
% "atlas_MP150" crée dans le cadre de la manip atlas et la structure "safemove/atlas" créer lors de l'import des des données dans le trip.
function [sync_MP150, IDs_tops] = sync_MP150_simu(MP150_struct, trip_file, data_name_MP150, variable_name_MP150)
sync_MP150 = MP150_struct;

%% GET DELTA_TC_REFERENCE
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
deltaTC_ref = trip.getAttribute('deltaTC_ref');
deltaTC_ref2 = trip.getAttribute('deltaTC_simu_initial');
if ~isempty(deltaTC_ref)
    deltaRef = cell2mat(textscan(deltaTC_ref,'%f'));
elseif ~isempty(deltaTC_ref2)
    deltaRef = cell2mat(textscan(deltaTC_ref2,'%f'));
end
delete(trip);

%% DATA MP150
record = getfield(sync_MP150,data_name_MP150);
data_struct = getfield(record,variable_name_MP150);
IDs_tops = find(diff(data_struct.values)==5)+1;
tops = sync_MP150.data.time.values(IDs_tops);
top_MP150_start = tops(1);
top_MP150_end = tops(end);

%% OFFSET AND TIME SHIFTING
offset_MP150 = top_MP150_start;
delta_MP150 = top_MP150_end - top_MP150_start;
disp(['Temps simu = ' num2str(deltaRef) ' | Temps MP150 = ' num2str(delta_MP150)]);
disp('Warning: Time shifting of data detected.');
disp(['simu = ' num2str(deltaRef) 's, MP150 = ' num2str(delta_MP150) 's.']);
disp(['Difference of ' num2str(deltaRef - delta_MP150) ' seconds during this trip.']);
derive_MP150 = deltaRef / delta_MP150;
disp(['Offset and Derive between simu and MP150 are : ' num2str(offset_MP150) ' s and ' num2str(derive_MP150)]);

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
    offset_MP150_derive = top_MP150_start*(derive_MP150-1)+offset_MP150;
    sync_MP150.data.time_sync.values =  (record.time.values * derive_MP150) - offset_MP150_derive ;
    sync_MP150.data.time_sync.unit = 's';
    sync_MP150.data.time_sync.comments = 'Timecode calculated relatively to the simu synchronised data.';
    
    sync_MP150.META.MP150_top_MP150_start = top_MP150_start;
    sync_MP150.META.MP150_mopad_offset = offset_MP150;
    sync_MP150.META.MP150_mopad_delta = delta_MP150;
    sync_MP150.META.MP150_mopad_shift  = derive_MP150;
    sync_MP150.META.MP150_mopad_sync_formula = '( (time/1000) * derive_MP150) - top_MP150_start*(derive_MP150-1)+offset_MP150';
end
if round(derive_MP150) == 1
    sync_MP150.META.synchronised=true;
end
end