function batchExportPerfConduiteBrookhuis(MAIN_FOLDER)
%TODO : uigetdir -> MAIN_FOLDER et uiget pour le case
MAIN_FOLDER = 'E:\PROJETS ACTUELS\COCORICO\DONNEES_PARTICIPANTS';
EXPORT_FOLDER = [MAIN_FOLDER filesep 'FICHIERS_EXPORT' filesep 'Performance_Brookhuis'];
oldFolder = cd(EXPORT_FOLDER);
folder_name = char(datetime('now','Format','yyMMdd_HHmm'));
mkdir(folder_name);
trip_files = dirrec(MAIN_FOLDER, '.trip');
%% LOOP ON FOLDERS
for i_trip = 1:length(trip_files)
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    
    if check_trip_meta(trip, 'id_scenario', 'BASELINE') || check_trip_meta(trip, 'id_scenario', 'EXPERIMENTAL')
        disp(['exporting : ' trip_file])
        id_participant = trip.getAttribute('id_participant');
        id_scenario = trip.getAttribute('id_scenario');
        
        situationOccurences = trip.getAllSituationOccurences('suivi_cible');
        startTimes = situationOccurences.getVariableValues('startTimecode');
        endTimes = situationOccurences.getVariableValues('endTimecode');
        deltaTC2Remove = startTimes{2} - endTimes{1};
        
        for i_suivi = 1:length(startTimes)
            startTime = startTimes{i_suivi};
            endTime = endTimes{i_suivi};
            
            vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
            timecodes = cell2mat(vitesseVPOccurences.getVariableValues('timecode'));
            vVP = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));
            vitesseCibleOccurences = trip.getDataOccurencesInTimeInterval('cible', startTime, endTime);
            vCible = cell2mat(vitesseCibleOccurences.getVariableValues('vitesseCible'));
            firstColumn = zeros(1, length(timecodes));
            
            if i_suivi==1
                firstColumn(1) = 1;
                file_id_perf = fopen([EXPORT_FOLDER filesep folder_name filesep id_participant '_' id_scenario '.ev1'], 'w');
                HEADER_BASEXP_PERF = ([id_participant '_' id_scenario '_perf']);
                fprintf(file_id_perf, '%s\t', HEADER_BASEXP_PERF);
                fprintf(file_id_perf, '\n');
                for i_line = 1:length(timecodes)
                    fprintf(file_id_perf, '%f\t', firstColumn(i_line), timecodes(i_line), vCible(i_line), vVP(i_line));
                    fprintf(file_id_perf, '\n');
                end
            elseif i_suivi==2
                firstColumn(end) = 2;
                for i_line = 1:length(timecodes)
                    fprintf(file_id_perf, '%f\t', firstColumn(i_line), timecodes(i_line)-deltaTC2Remove, vCible(i_line), vVP(i_line));
                    fprintf(file_id_perf, '\n');
                end
            end
        end
        
    end
delete(trip);
end
fclose(file_id_perf);
disp([num2str(length(trip_files)) ' export performance traités.'])
cd(oldFolder);
end