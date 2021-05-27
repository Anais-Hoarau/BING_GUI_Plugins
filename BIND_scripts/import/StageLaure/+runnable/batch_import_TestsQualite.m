function batch_import_TestsQualite()
clear all;

%% LISTAGE DES DOSSIERS DES PARTICIPANTS

MAIN_FOLDER = 'D:\LESCOT\STAGE_LAURE\ESSAIS_11sept2015\';
listing = dir(MAIN_FOLDER);
i=1;
while i <= length(listing)
    if listing(i,1).isdir && ~isempty(strfind(listing(i,1).name, 'Etal'))
        if  strfind(listing(i,1).name, 'Etal')==1
            folder_lists(i) = {[MAIN_FOLDER listing(i,1).name]};
        end
    end
    i=i+1;
end

%folder_lists = {'\\vrlescot.ifsttar.fr\SAFEMOVE SP2\DATA route\Idp289_140520_09h45'};

%     log_csv = fopen('log_import_TestsQualite.csv', 'a+');
%     log_write(log_csv, 'Dossier', 'Mopad2Struct', 'Kvaser2Struct', 'SynchroMopad', 'SynchroKvaser', 'StructMopad2BIND', 'Time Mopad2BIND','StructKvaser2BIND', 'Time Kvaser2BIND');

%% BOUCLAGE SUR CHAQUE DOSSIER

i_list=1;
for i = 3:length(folder_lists)
    %% Création d'un fichier trip vide dans le dossier en cours
    full_directory = folder_lists{i};                                       % chemin de dossier du participant
    
    REG = regexp(full_directory,'\\');
%     REG2 = regexp(full_directory,'_');
    participant_name = full_directory(REG(end)+1:end);                % identification participant (ex : Id914)
    trip_name = [participant_name '.trip'];                                 % nom du fichier trip (ex : Id914.trip)
    
    if strfind(participant_name, '@')
        continue
    end
    
    disp(['Processing trip : ' trip_name ' ...' ])                          % affichage de l'action en cours
    
    trip_file = [full_directory filesep trip_name];                         % chemin complet du trip
    
    % open the trip (create the trip if it doesn't exist)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
    
    %      Metas = trip.getMetaInformations;
    %      if Metas.existData('Kvaser_ABR')
    %         trip.removeData('Kvaser_ABR')
    %      end
    %      if Metas.existData('Kvaser_ACCEL')
    %         trip.removeData('Kvaser_ACCEL')
    %      end
    %      if Metas.existData('Kvaser_ARS1')
    %         trip.removeData('Kvaser_ARS1')
    %      end
    %% Structuration des données Mopad et Kvaser
    [proc_mopad2struct, ~, ~] = magic_process('TestsQualite_mopad2struct',trip,full_directory,participant_name);
%     [proc_kvaser2struct, ~, ~] = magic_process('TestsQualite_kvaser2struct',trip,full_directory,participant_name);
    
    %% Synchro des données Mopad et Kvaser
%     [proc_syncMopad, ~, ~] = magic_process('TestsQualite_sync_mopad_video',trip,full_directory,participant_name,'3brakes');
%     [proc_syncKvaser, ~, ~] = magic_process('TestsQualite_sync_kvaser_mopad',trip,full_directory,participant_name,'3brakes');
    
    %% Import des données Mopad et Kvaser dans le fichier trip
    [proc_import_mopad, time_import_mopad, ~] = magic_process('TestsQualite_import_mopad2bind',trip,full_directory,participant_name);
%     [proc_import_kvaser, time_import_kvaser, ~] = magic_process('TestsQualite_import_kvaser2bind',trip,full_directory,participant_name);
    %[proc_import_kvaser_1, time_import_kvaser_1, ~] = magic_process('TestsQualite_import_partiel_kvaser2bind_1',trip,full_directory,participant_name);
    
    % try
    %         visu_synchro(full_directory,'trip');
    %         hgsave(['visu_synchro_' participant_name '_trip']);
    %         close all
    % catch
    % end
    
    i_list=i_list+1;
    delete(trip)
    
    %% Creation des tracés KML à partir des données brutes
    %Trace_GPS(full_directory)
    
    %log_write(log_csv, full_directory, proc_mopad2struct, proc_kvaser2struct, proc_syncMopad, ...
    %           proc_syncKvaser, proc_import_mopad, time_import_mopad, proc_import_kvaser_1, time_import_kvaser_1,proc_MP150_2struct,proc_syncMP150);
end

disp([num2str(i_list) ' trips are processed.'])                          % affichage du nombre de trip traités

%fclose(log_csv);
end