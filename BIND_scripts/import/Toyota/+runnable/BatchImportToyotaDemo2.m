function BatchImportToyotaDemo2()
%% PARTICIPANT FOLDERS LIST

MAIN_FOLDER = 'W:\PROJETS ACTUELS\TOYOTA\DEMO_VIDEO\Demo_02';
DATA_FOLDER = [MAIN_FOLDER '\Donnees'];
VIDEO_FOLDER = [MAIN_FOLDER '\Videos'];

files_list = dirrec(DATA_FOLDER, '.mat');

for i = 1:1:length(files_list)
    if strfind(files_list{i}, 'timecoded')
        continue;
    end
    % identify participant (ex : C01)
    full_directory = files_list{i};
    reg_directory = regexp(full_directory,'\');
    participant_id = full_directory(reg_directory(end)+1:end-4);
    
    % identify scenario (ex : EXP)
    if strfind(participant_id, 'Base')~=0
        scenario_id = 'BASE';
    elseif strfind(participant_id, 'Expe')~=0
        scenario_id = 'EXPE';
    end
    
    % identify needed files names
    trip_name = [participant_id '.trip'];
    data_name = [participant_id '.mat'];
    
    % identify needed files full directories
    trip_file = [MAIN_FOLDER filesep trip_name];
    data_file = [DATA_FOLDER filesep data_name];
    
    %% TRIP FILE CREATION
    
    if ~exist(trip_file, 'file')
        disp(['Cr?ation du fichier trip : "' trip_name '"...' ])
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        trip.setAttribute('MAIN_FOLDER', MAIN_FOLDER);
        trip.setAttribute('DATA_FOLDER', DATA_FOLDER);
        trip.setAttribute('VIDEO_FOLDER', VIDEO_FOLDER);
        trip.setAttribute('id_participant', participant_id);
        trip.setAttribute('id_scenario', scenario_id);
        trip.setAttribute('id_groupe', '');
        trip.setAttribute('import_data', '');
        trip.setAttribute('import_videos', '');
        %     trip.setAttribute('deltaTC_ref', '');
        %     trip.setAttribute('calcul_vitesseVehiculeKmh', '');
        %     trip.setAttribute('calcul_vitesseCibleKmh', '');
        %     trip.setAttribute('calcul_pourcentageFreinage', '');
        delete(trip);
    else
        disp(['Le fichier "' trip_name '" est d?j? pr?sent dans le dossier...' ])
    end
    
    disp(['V?rification du fichier "' trip_name '"...' ])
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    import_data_needed = ~check_trip_meta(trip,'import_data','OK');
    import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
    delete(trip);
    
    %% IMPORT DATA TO THE TRIP FILE
    if import_data_needed
        if ~exist(data_file, 'file')
            disp(['Le fichier "' data_name '" est absent du dossier...'])
        else
            disp('Import des donn?es en cours...')
            [data_file_timecoded] = Toyota_add_timecode(data_file);
            struct_matlab = import_MatlabFiles(data_file_timecoded);
            trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
            import_data_struct_in_bind_trip(struct_matlab, trip, '');
            trip.setAttribute('import_data', 'OK');
            delete(trip);
        end
    else
        disp('Les donn?es ont d?j? ?t? import?es...')
    end
    
    %% ADD VIDEO LINKS TO THE TRIP
    % trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    % if exist([full_directory 'clap.txt'], 'file')
    %     convertVideo2MJPEG_alone(full_directory)                                % convert simulator video if necessary
    %     if import_videos_needed
    %         disp('V?rification des fichiers vid?o et cr?ation des liens...')
    %         video_files = find_file_with_extension([full_directory filesep],'.avi');
    %         for i_video = 1:1:length(video_files)
    %             video_path = video_files{i_video};
    %             [~, video_name, video_ext] = fileparts(video_path);
    %             video_file = ['.' filesep video_name video_ext];
    %             REG_video = regexp(video_file,'_');
    %             video_description = video_file(REG_video(end-2)+1:REG_video(end)-1);
    %             metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,-5,video_description); % -5 correspond to the video offset
    %             trip.addVideoFile(metaVideo);
    %         end
    %         trip.setAttribute('import_videos','OK');
    %     end
    % else
    %     disp('Attention, pas de fichier clap, la vid?o du simulateur ne sera pas synchronis?e, ni ajout?e...')
    %     trip.setAttribute('import_videos','');
    % end
    % delete(trip);
    
    %% Calculate indicators
    % trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    %
    % if ~check_trip_meta(trip,'calcul_vitesseVehiculeKmh','OK')
    %     addKmhVehicleSpeed(trip)
    %     trip.setAttribute('calcul_vitesseVehiculeKmh', 'OK');
    % end
    %
    % %if ~check_trip_meta(trip,'calcul_pourcentageFreinage','OK')
    %     addPourcentageBreak(trip)
    %     trip.setAttribute('calcul_pourcentageFreinage', 'OK');
    % %end
    %
    % if ~check_trip_meta(trip,'calcul_vitesseCibleKmh','OK')
    %     addKmhTargetSpeed(trip)
    %     trip.setAttribute('calcul_vitesseCibleKmh', 'OK');
    % end
end
end

% calcul des valeurs de vitesse en km/h
function addKmhVehicleSpeed(trip)

% get values
record = trip.getAllDataOccurences('vitesse');
timecodes = record.getVariableValues('timecode');
values = cell2mat(record.getVariableValues('vehicle_speed_ms'));
trip.setIsBaseData('vitesse', 0);

% create vehicle_speed_kmh column if necessary
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable('vitesse', 'vehicle_speed_kmh')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('vehicle_speed_kmh');
    bindVariable.setType('REAL');
    bindVariable.setUnit('km/h');
    bindVariable.setComments('vitesse du VP recalculee en km/h');
    trip.addDataVariable('vitesse', bindVariable);
end

% add speed values
for i_occurence = 1:1:length(timecodes)
    value = values(i_occurence)*3.6;
    trip.setDataVariableAtTime('vitesse', 'vehicle_speed_kmh', timecodes{i_occurence}, value);
end
trip.setIsBaseData('vitesse', 1);

end

% calcul des valeurs de freinage en pourcentage
function addPourcentageBreak(trip)

% get values
record = trip.getAllDataOccurences('vitesse');
timecodes = record.getVariableValues('timecode');
values = cell2mat(record.getVariableValues('vehicle_break_val'));
trip.setIsBaseData('vitesse', 0);

% create target_speed_kmh column if necessary
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable('vitesse', 'vehicle_break_percentage')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('vehicle_break_percentage');
    bindVariable.setType('REAL');
    bindVariable.setUnit('%');
    bindVariable.setComments('freinage du VP recalculee en %');
    trip.addDataVariable('vitesse', bindVariable);
end

% add speed values
for i_occurence = 1:1:length(timecodes)
    value = values(i_occurence)/2.55;
    trip.setDataVariableAtTime('vitesse', 'vehicle_break_percentage', timecodes{i_occurence}, value);
end
trip.setIsBaseData('vitesse', 1);

end

% calcul des valeurs de vitesse en km/h
function addKmhTargetSpeed(trip)

% get values
record = trip.getAllDataOccurences('cible');
timecodes = record.getVariableValues('timecode');
values = cell2mat(record.getVariableValues('target_speed_ms'));
trip.setIsBaseData('cible', 0);

% create target_speed_kmh column if necessary
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable('cible', 'target_speed_kmh')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('target_speed_kmh');
    bindVariable.setType('REAL');
    bindVariable.setUnit('km/h');
    bindVariable.setComments('vitesse de la cible recalculee en km/h');
    trip.addDataVariable('cible', bindVariable);
end

% add speed values
for i_occurence = 1:1:length(timecodes)
    value = values(i_occurence)*3.6;
    if value < 0
        value = 0;
    end
    trip.setDataVariableAtTime('cible', 'target_speed_kmh', timecodes{i_occurence}, value);
end
trip.setIsBaseData('cible', 1);

end