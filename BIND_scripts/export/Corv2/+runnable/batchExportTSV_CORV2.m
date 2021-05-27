function batchExportTSV_CORV2(MAIN_FOLDER)
%TODO : uigetdir -> MAIN_FOLDER et uiget pour le case
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
if ~exist('MAIN_FOLDER', 'var')
    MAIN_FOLDER = uigetdir();
end
EXPORT_FOLDER = [MAIN_FOLDER filesep 'FICHIERS_EXPORT' filesep 'Tableaux_données'];
trip_files = dirrec(MAIN_FOLDER, '.trip');
if exist(EXPORT_FOLDER, 'dir') ~= 7
    mkdir(EXPORT_FOLDER);
end

%% HEADERS CONSTRUCTION
HEADER_EXP = {'participant', 'groupe', 'date', 'heure', 'type_essai', 'nom_essai', 'duree', 'nb_ech', 'freq', 'tps_detection'};
HEADERS.EXP_detection_centre = HEADER_EXP;
HEADERS.EXP_detection_periph = HEADER_EXP;

%% TSV FILES CREATION WITH HEADERS
situations = fieldnames(HEADERS);
for i_situation = 1:length(situations)
    file_id.(situations{i_situation}) = [];
    file_id.(situations{i_situation}) = fopen([EXPORT_FOLDER filesep situations{i_situation} '_' HORODATAGE '.tsv'], 'w');
    fprintf(file_id.(situations{i_situation}), '%s\t', HEADERS.(situations{i_situation}){:});
    fprintf(file_id.(situations{i_situation}), '\n');
end

%% EXPORT TRIP SITUATIONS TO TSV FILES
for i_trip = 1:length(trip_files)
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    
    if check_trip_meta(trip, 'id_scenario', 'EXPERIMENTAL')
        if trip.getMetaInformations().existSituation('detection_centre')
            disp(['exporting : ' trip_file])
            exportTripSituation2TSVByParticipant_CORV2(trip_file, file_id.(situations{1}), 'detection_centre')
        end
        if trip.getMetaInformations().existSituation('detection_periph')
            disp(['exporting : ' trip_file])
            exportTripSituation2TSVByParticipant_CORV2(trip_file, file_id.(situations{2}), 'detection_periph')
        end
    end
    delete(trip);
end
for i_situation = 1:length(situations)
    fclose(file_id.(situations{i_situation}));
end
disp([num2str(length(trip_files)) ' trips exportés.'])
end

function out = buildHeader(event_name, nb_events, indicators)
PRE_HEADER = {'participant', 'groupe', 'essai', 'date', 'heure'};
LENGTH_HEADER = nb_events * length(indicators);
HEADER = cell(1,LENGTH_HEADER);
i_HEADER = 1;
for i_events = 1:nb_events
    for i_indicators = 1:length(indicators)
        if nb_events > 1
            HEADER(i_HEADER) = {[indicators{i_indicators} '_' event_name num2str(i_events)]};
        else
            HEADER(i_HEADER) = {[indicators{i_indicators}]};
        end
        i_HEADER = i_HEADER+1;
    end
end
out = [PRE_HEADER, HEADER];
end