function batchExportTSV_CAPADYN(MAIN_FOLDER)
%TODO : uigetdir -> MAIN_FOLDER et uiget pour le case
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
EXPORT_FOLDER = [MAIN_FOLDER filesep '@FICHIERS_EXPORT' filesep 'Tableaux_codage'];
trip_files = dirrec(MAIN_FOLDER, '.trip');
if exist(EXPORT_FOLDER, 'dir') ~= 7
    mkdir(EXPORT_FOLDER);
end
indicators = {};
i_trip = 1;
%% HEADERS CONSTRUCTION
while isempty(indicators)
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    if ~isempty(strfind(trip_file, 'DT'))
        indicators = trip.getAllSituationOccurences('essai_complet').getVariableNames;
    end
    i_trip = i_trip + 1;
    delete(trip)
end
headers.essai_complet = buildHeader('essai_complet', 1, indicators);

%% TSV FILES CREATION WITH HEADERS
situations = fieldnames(headers);
for i_situation = 1:length(situations)
    file_id.(situations{i_situation}) = fopen([EXPORT_FOLDER filesep situations{i_situation} '_' HORODATAGE '.tsv'], 'w');
    fprintf(file_id.(situations{i_situation}), '%s\t', headers.(situations{i_situation}){:});
    fprintf(file_id.(situations{i_situation}), '\n');
end

%% EXPORT TRIP SITUATIONS TO TSV FILES
for i_trip = 1:length(trip_files)
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    
    if trip.getMetaInformations().existSituation('essai_complet')
        disp(['exporting : ' trip_file])
        exportTripSituation2TSVByTrip_CAPADYN(trip_file, file_id.(situations{1}), 'essai_complet')
    end
    
    delete(trip);
end
for i_situation = 1:length(situations)
    fclose(file_id.(situations{i_situation}));
end
disp([num2str(length(trip_files)) ' trips exportés.'])
end

function out = buildHeader(event_name, nb_events, indicators)
pre_header = {'id_participant', 'id_groupe', 'id_scenario'};
length_header = nb_events * length(indicators);
header = cell(1,length_header);
i_header = 1;
for i_events = 1:nb_events
    for i_indicators = 4:length(indicators)
        if nb_events > 1
            header(i_header) = {[indicators{i_indicators} '_' event_name num2str(i_events)]};
        else
            header(i_header) = {[indicators{i_indicators}]};
        end
        i_header = i_header+1;
    end
end

out = [pre_header, header];
end