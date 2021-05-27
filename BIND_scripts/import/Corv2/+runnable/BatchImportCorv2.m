function BatchImportCorv2()
%% PARTICIPANT FOLDERS LIST
MAIN_FOLDER = 'E:\PROJETS ACTUELS\CORV2\DONNEES_PARTICIPANTS\TEST';
CONFIG_FOLDER = [MAIN_FOLDER '\FICHIERS_CONFIG'];

folders_list_colere = dir([MAIN_FOLDER '\GROUPE_COLERE']);
folders_list_neutre = dir([MAIN_FOLDER '\GROUPE_NEUTRE']);
folders_list_triste = dir([MAIN_FOLDER '\GROUPE_TRISTE']);
folders_list = {folders_list_colere(3:end).name, folders_list_neutre(3:end).name, folders_list_triste(3:end).name};

file_id = fopen([CONFIG_FOLDER '\CORV2_FOLDERS.tsv'], 'w');
fprintf(file_id, '%s\n', MAIN_FOLDER, CONFIG_FOLDER, folders_list{:});

%% LOOP ON FOLDERS
i_trip = 0;
for i = 1:1:length(folders_list)
    % check folder and create full directory by group
    if isdir([MAIN_FOLDER '\GROUPE_COLERE\' folders_list{i}]) && ~isempty(strncmp(folders_list{i}, '1', 1)) && isempty(strfind(folders_list{i}, '@'))
        full_directory = [MAIN_FOLDER '\GROUPE_COLERE\' folders_list{i}];
        groupe_id = 'GROUPE_COLERE';
    elseif isdir([MAIN_FOLDER '\GROUPE_TRISTE\' folders_list{i}]) && ~isempty(strncmp(folders_list{i}, '2', 1)) && isempty(strfind(folders_list{i}, '@'))
        full_directory = [MAIN_FOLDER '\GROUPE_TRISTE\' folders_list{i}];
        groupe_id = 'GROUPE_TRISTE';
    elseif isdir([MAIN_FOLDER '\GROUPE_NEUTRE\' folders_list{i}]) && ~isempty(strncmp(folders_list{i}, '3', 1)) && isempty(strfind(folders_list{i}, '@'))
        full_directory = [MAIN_FOLDER '\GROUPE_NEUTRE\' folders_list{i}];
        groupe_id = 'GROUPE_NEUTRE';
    else
        disp(['"' folders_list{i} '" ne sera pas pris en compte : nom de dossier non conforme ou nom de fichier ...'])
        continue
    end
    
    % identify participant (ex : C01)
    reg_directory = regexp(full_directory,'\');
    participant_id = full_directory(reg_directory(end)+1:end);
    reg_participant = regexp(participant_id, '_');
    participant_name = participant_id(1:reg_participant(1)-1);
    
    % identify scenario (ex : EXP)
    scenario_id = 'EXPERIMENTAL';
    scenario_case = 'EXP';
    
    % identify date and time
    scenario_start_date = participant_id(reg_participant(end)+1:reg_participant(end)+4);
    scenario_start_time = participant_id(reg_participant(end)+5:end);
    
    % identify needed files names
    trip_name = [participant_id '.trip'];
    simu_var_name = [participant_id '.var'];
    simu_xml_name = ['CORV2_' scenario_case '_Simu_Data_Mapping.xml'];
    
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
        trip.setAttribute('nom_participant', participant_name);
        trip.setAttribute('id_groupe', groupe_id);
        trip.setAttribute('id_scenario', scenario_id);
        trip.setAttribute('session_date', scenario_start_date);
        trip.setAttribute('session_time', scenario_start_time);
        trip.setAttribute('import_simu', '');
        trip.setAttribute('add_events', '');
        trip.setAttribute('add_situations', '');
        trip.setAttribute('add_indicators', '');
        delete(trip);
    else
        disp(['Le fichier "' trip_name '" est déjà présent dans le dossier...' ])
    end
    
    %% IMPORT SIMU DATA TO THE TRIP FILE
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    if ~check_trip_meta(trip,'import_simu','OK')
        if ~exist(simu_var_file, 'file')
            disp(['Le fichier "' simu_var_name '" est absent du dossier...'])
            continue
        elseif ~exist(simu_xml_file, 'file')
            disp(['Le fichier "' simu_xml_file '" est absent du dossier...'])
            continue
        else
            disp('Import des données du simulateur...')
            Corv2_VAR2BIND(simu_xml_file, simu_var_file, full_directory, trip_file)
        end
    else
        disp('Les données du simulateur ont déjà été importées...')
    end
    delete(trip);
    i_trip = i_trip+1;
end
disp([num2str(i_trip) ' trips générés.'])

%% ADD EVENTS, SITUATIONS AND INDICATORS
runnable.BatchIndicatorsCorv2(MAIN_FOLDER)

%% EXPORT SITUATIONS DATAS TO TSV FILE
% runnable.batchExportTSV_CORV2(MAIN_FOLDER)

% %% EXPORT PERFORMANCES TO FILE
% runnable.batchExportPerfConduiteBrookhuis(MAIN_FOLDER)

end