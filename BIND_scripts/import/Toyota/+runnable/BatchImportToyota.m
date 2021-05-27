function BatchImportToyota()
%clear all;
%% PARTICIPANT FOLDERS LIST

MAIN_FOLDER = 'V:\Transfert_TOYOTA\Essai3\Donnee_simu';
CONFIG_FOLDER = [MAIN_FOLDER '\FICHIERS_CONFIG'];
full_directory = MAIN_FOLDER;

% identify needed files names
participant_id = 'SujetDemo_30091247';
trip_name = [participant_id '.trip'];
simu_var_name = [participant_id '.var'];
simu_xml_name = 'Toyota_Simu_Data_Mapping.xml';

% identify needed files full directories
trip_file = [full_directory filesep trip_name];
simu_var_file = [full_directory filesep simu_var_name];
simu_xml_file = [CONFIG_FOLDER filesep 'FICHIERS_XML' filesep simu_xml_name];

%% TRIP FILE CREATION

if ~exist(trip_file, 'file')
    disp(['Création du fichier trip : "' trip_name '"...' ])
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
    trip.setAttribute('MAIN_FOLDER', MAIN_FOLDER);
    trip.setAttribute('CONFIGURATION_FOLDER', CONFIG_FOLDER);
    trip.setAttribute('id_participant', participant_id);
    trip.setAttribute('id_groupe', '');
    trip.setAttribute('id_scenario', '');
    trip.setAttribute('session_date', '');
    trip.setAttribute('session_time', '');
    trip.setAttribute('import_simu', '');
    trip.setAttribute('import_cardio', '');
    trip.setAttribute('import_videos', '');
    trip.setAttribute('deltaTC_ref', '');
    trip.setAttribute('calcul_vitesseVehiculeKmh', '');
    trip.setAttribute('calcul_vitesseCibleKmh', '');
    trip.setAttribute('calcul_pourcentageFreinage', '');
    delete(trip);
else
    disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
end

disp(['Vérification du fichier "' trip_name '"...' ])
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
import_simu_needed = ~check_trip_meta(trip,'import_simu','OK');
import_cardio_needed = ~check_trip_meta(trip,'import_cardio','OK');
import_videos_needed = ~check_trip_meta(trip,'import_videos','OK');
delete(trip);

%% IMPORT SIMU DATA TO THE TRIP FILE
if import_simu_needed
    if ~exist(simu_var_file, 'file')
        disp(['Le fichier "' simu_var_name '" est absent du dossier...'])
    elseif ~exist(simu_xml_file, 'file')
        disp(['Le fichier "' simu_xml_file '" est absent du dossier...'])
    else
        disp('Import des données du simulateur...')
        Toyota_VAR2BIND(simu_xml_file, simu_var_file, full_directory, trip_file)
    end
else
    disp('Les données du simulateur ont déjà été importées...')
end

%% IMPORT CARDIAC DATA TO THE TRIP
if import_cardio_needed
    %disp('Import des données cardiques...')
    %Toyota_import_MP150_2bind(trip,full_directory,participant_name)
end

%% ADD VIDEO LINKS TO THE TRIP
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
if exist([full_directory 'clap.txt'], 'file')
    convertVideo2MJPEG_alone(full_directory)                                % convert simulator video if necessary
    if import_videos_needed
        disp('Vérification des fichiers vidéo et création des liens...')
        video_files = find_file_with_extension([full_directory filesep],'.avi');
        for i_video = 1:1:length(video_files)
            video_path = video_files{i_video};
            [~, video_name, video_ext] = fileparts(video_path);
            video_file = ['.' filesep video_name video_ext];
            REG_video = regexp(video_file,'_');
            video_description = video_file(REG_video(end-2)+1:REG_video(end)-1);
            metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,-5,video_description); % -5 correspond to the video offset
            trip.addVideoFile(metaVideo);
        end
        trip.setAttribute('import_videos','OK');
    end
else
    disp('Attention, pas de fichier clap, la vidéo du simulateur ne sera pas synchronisée, ni ajoutée...')
    trip.setAttribute('import_videos','');
end
delete(trip);

%% Calculate indicators
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);

if ~check_trip_meta(trip,'calcul_vitesseVehiculeKmh','OK')
    addKmhVehicleSpeed(trip)
    trip.setAttribute('calcul_vitesseVehiculeKmh', 'OK');
end

%if ~check_trip_meta(trip,'calcul_pourcentageFreinage','OK')
    addPourcentageBreak(trip)
    trip.setAttribute('calcul_pourcentageFreinage', 'OK');
%end

if ~check_trip_meta(trip,'calcul_vitesseCibleKmh','OK')
    addKmhTargetSpeed(trip)
    trip.setAttribute('calcul_vitesseCibleKmh', 'OK');
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