% Cette function permet de faire la synchro entre la structure
% "atlas_MP150" crée dans le cadre de la manip atlas et la structure "safemove/atlas" créer lors de l'import des des données dans le trip.
function [sync_MP150, IDs_tops] = Vortex_sync_MP150_simu(MP150_struct, trip_file, data_name_MP150, variable_name_MP150)
sync_MP150 = MP150_struct;

%% GET DELTA_TC_REFERENCE
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
simu_var_table = trip.getAllDataOccurences('variables_simulateur');
timecodes = cell2mat(simu_var_table.getVariableValues('timecode'));
comments = simu_var_table.getVariableValues('commentaires');
mask_comments = ~cellfun(@isempty, comments);
mask_comments_FSO = contains(comments, '__feu_stop_on');
if sum(mask_comments_FSO) ~= 15
    warning('Pas le bon nombre de commentaires __feu_stop_on')
end
timecode_first_FSO = timecodes(find(mask_comments_FSO,1));
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
% if top_MP150_end < deltaRef
    delta_correction = timecode_first_FSO - top_MP150_start;
    time_sync = sync_MP150.data.time.values + delta_correction;
    IDs_tops = find(diff(data_struct.values)==5)+1;
    tops = time_sync(IDs_tops);
    top_MP150_end = tops(16);
    top_MP150_start = 0;
% else
%     disp('MP150 data duration >= deltaRef')
% end
offset_MP150 = - delta_correction;
delta_MP150 = top_MP150_end - top_MP150_start;
disp(['Temps simu = ' num2str(deltaRef) ' | Temps MP150 = ' num2str(delta_MP150)]);
disp('Warning: Time shifting of data detected.');
disp(['simu = ' num2str(deltaRef) 's, MP150 = ' num2str(delta_MP150) 's.']);
disp(['Difference of ' num2str(deltaRef - delta_MP150) ' seconds during this trip.']);
derive_MP150 = deltaRef / delta_MP150;
disp(['Offset and Derive between simu and MP150 are : ' num2str(offset_MP150) ' s and ' num2str(derive_MP150)]);

%% CHECK SYNCHRONISATION
comments_list = comments(mask_comments);
timecodes_list = timecodes(mask_comments);
cmpt = 0;
for i = 1:length(comments_list)
    timecode = timecodes_list(i);
    comment = comments_list{i};
    if contains(comment, 'feu_stop_on')
        cmpt = cmpt + 1;
        disp(['delta time between comment and trigger sync n°' num2str(cmpt) ' : ' num2str(tops(cmpt) - timecode)]);
        disp(['delta time between comment and trigger sync n°' num2str(cmpt) ' with derive correction : ' num2str(tops(cmpt)*derive_MP150 - timecode)]);
        if isempty(find(abs(tops - timecode) <= 0.02, 1))
            disp(['error with : ' trip_file]);
            disp('Error caught, logging and skipping to next file');
            log = fopen('Vortex_sync_MP150_simu.log', 'a+');
            fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' trip_file]);
            fprintf(log, '%s\n', ['delta sync on trigger "brake light"  = ' num2str(min(abs(tops - timecode)))]);
            fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
            fclose(log);
            return
        end
    end
end

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
    sync_MP150.data.time_sync.values = (record.time.values * derive_MP150) - offset_MP150_derive;
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