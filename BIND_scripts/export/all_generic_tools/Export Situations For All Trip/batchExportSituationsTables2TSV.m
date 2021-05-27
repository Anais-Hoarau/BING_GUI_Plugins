function batchExportSituationsTables2TSV(fulldirectory)
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
if ~exist('fulldirectory', 'var')
    fulldirectory = uigetdir;
end
EXPORT_FOLDER = [fulldirectory filesep '~DATA_EXPORT' filesep 'SITUATIONS_TABLES_BACKUP' filesep HORODATAGE];
trip_files = dirrec(fulldirectory, '.trip');
mkdir(EXPORT_FOLDER);

%% GET SITUATIONS AND VARIABLES NAMES
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_files{1}, 0.04, false); % 2 | 7 | 2
situationsNames = trip.getMetaInformations().getSituationsNamesList();
for i_situation = 1:length(situationsNames)
    situation_name = cell2mat(regexprep(situationsNames(i_situation), ' ', '_'));
    variables_names.(situation_name) = trip.getMetaInformations().getSituationVariablesNamesList(situationsNames{i_situation});
end
delete(trip)

%% TSV FILES CREATION WITH HEADERS
for i_situation = 1:length(situationsNames)
    situation_name = cell2mat(regexprep(situationsNames(i_situation), ' ', '_'));
    header = buildHeader(situation_name, 1, variables_names.(situation_name));
    file_id.(situation_name) = fopen([EXPORT_FOLDER filesep situation_name '_' HORODATAGE '.tsv'], 'w');
    fprintf(file_id.(situation_name), '%s\t', header{:});
    fprintf(file_id.(situation_name), '\n');
    %% EXPORT TRIP SITUATIONS TO TSV FILES
    for i_trip = 1:length(trip_files)
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_files{i_trip}, 0.04, false);
%         if isempty(strfind(cell2mat(trip.getAllSituationOccurences('VRU_characteristics').getVariableValues('VRU_type')),'C'))
%             continue
%         end
        delete(trip)
        trip_file = trip_files{i_trip};
        disp(['exporting : ' trip_file])
        exportSituationTable2TSVBytrip(trip_file, file_id.(situation_name), situationsNames{i_situation})
    end
    fclose(file_id.(situation_name));
end
end

function out = buildHeader(situation_name, nb_occurrences, variables)
PRE_HEADER = {'trip_id'};
LENGTH_HEADER = length(variables);
HEADER = cell(1,LENGTH_HEADER);
i_HEADER = 1;
for i_variable = 1:length(variables)
    if nb_occurrences > 1
        HEADER(i_HEADER) = {[variables{i_variable} '_' situation_name num2str(i_occurrence)]};
    else
        HEADER(i_HEADER) = {[variables{i_variable}]};
    end
    i_HEADER = i_HEADER+1;
end
out = [PRE_HEADER, HEADER];
end