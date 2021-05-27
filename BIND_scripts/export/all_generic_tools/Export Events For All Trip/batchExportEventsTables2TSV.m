function batchExportEventsTables2TSV(fulldirectory)
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
if ~exist('fulldirectory', 'var')
    fulldirectory = uigetdir;
end
EXPORT_FOLDER = [fulldirectory filesep '@DATA_EXPORT' filesep 'EVENTS_TABLES_BACKUP' filesep HORODATAGE];
trip_files = dirrec(fulldirectory, '.trip');
mkdir(EXPORT_FOLDER);

%% GET SITUATIONS AND VARIABLES NAMES
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_files{2}, 0.04, false); % 2 | 7 | 2
eventsNames = trip.getMetaInformations().getEventsNamesList();
for i_event = 1:length(eventsNames)
    event_name = cell2mat(regexprep(eventsNames(i_event), ' ', '_'));
    variables_names.(event_name) = trip.getMetaInformations().getEventVariablesNamesList(eventsNames{i_event});
end
delete(trip)

%% TSV FILES CREATION WITH HEADERS
for i_event = 1:length(eventsNames)
    event_name = cell2mat(regexprep(eventsNames(i_event), ' ', '_'));
    header = buildHeader(event_name, 1, variables_names.(event_name));
    file_id.(event_name) = fopen([EXPORT_FOLDER filesep event_name '_' HORODATAGE '.tsv'], 'w');
    fprintf(file_id.(event_name), '%s\t', header{:});
    fprintf(file_id.(event_name), '\n');
    %% EXPORT TRIP SITUATIONS TO TSV FILES
    for i_trip = 1:length(trip_files)
        trip_file = trip_files{i_trip};
        disp(['exporting : ' trip_file])
        exportEventTable2TSVBytrip(trip_file, file_id.(event_name), eventsNames{i_event})
    end
    fclose(file_id.(event_name));
end
end

function out = buildHeader(event_name, nb_occurrences, variables)
PRE_HEADER = {'trip_folder'};
LENGTH_HEADER = length(variables);
HEADER = cell(1,LENGTH_HEADER);
i_HEADER = 1;
for i_variable = 1:length(variables)
    if nb_occurrences > 1
        HEADER(i_HEADER) = {[variables{i_variable} '_' event_name num2str(i_occurrence)]};
    else
        HEADER(i_HEADER) = {[variables{i_variable}]};
    end
    i_HEADER = i_HEADER+1;
end
out = [PRE_HEADER, HEADER];
end