function batchExportSituationTSV_PROSPECT_STATIC(MAIN_FOLDER)
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
MAIN_FOLDER = 'Y:\CODAGE\TRIPS3';
EXPORT_FOLDER = [MAIN_FOLDER filesep '@FICHIERS_EXPORT' filesep 'Tableaux_codage_statique' filesep HORODATAGE];
trip_files = dirrec(MAIN_FOLDER, '.trip');
if exist(EXPORT_FOLDER, 'dir') ~= 7
    mkdir(EXPORT_FOLDER);
end

%% HEADERS CONSTRUCTION
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_files{3}, 0.04, false);
metaInfos = trip.getMetaInformations();
situationsNames = [metaInfos.getEventsNamesList(), metaInfos.getSituationsNamesList()];
for i_situation = 1:length(situationsNames)
    situation_name = situationsNames{i_situation};
    situation_name = regexprep(situation_name, ' ', '_'); % to uncoment if separator is ' '
    situation_name_reduced = upper([situation_name(1), situation_name(regexp(situation_name,'_')+1)]);
    if metaInfos.existSituation(situationsNames{i_situation})
        variables_names = metaInfos.getSituationVariablesNamesList(situationsNames{i_situation});
        HEADERS.(situation_name) = buildHeader(situation_name_reduced, 1, variables_names(3:end));
    elseif metaInfos.existEvent(situationsNames{i_situation})
        variables_names = metaInfos.getEventVariablesNamesList(situationsNames{i_situation});
        HEADERS.(situation_name) = buildHeader(situation_name_reduced, 1, variables_names(2:end));
    end
end

%% TSV FILES CREATION WITH HEADERS
for i_situation = 1:length(situationsNames)
    situation_name = situationsNames{i_situation};
    situation_name = regexprep(situation_name, ' ', '_'); % to uncoment if separator is ' '
    file_id.(situation_name) = [];
    file_id.(situation_name) = fopen([EXPORT_FOLDER filesep situation_name '_' HORODATAGE '.tsv'], 'w');
    fprintf(file_id.(situation_name), '%s\t', HEADERS.(situation_name){:});
    fprintf(file_id.(situation_name), '\n');
end

%% EXPORT TRIP SITUATIONS TO TSV FILES
for i_trip = 1:length(trip_files)
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    if isempty(strfind(trip_file,'@'))
        for i_situation = 1:length(situationsNames)
            if trip.getMetaInformations().existSituation(situationsNames{i_situation})
                disp(['exporting : ' trip_file])
                situation_name = situationsNames{i_situation};
                situation_name = regexprep(situation_name, ' ', '_'); % to uncoment if separator is ' '
                exportTripSituation2TSVByParticipant_PROSPECT_STATIC(trip_file, file_id, HEADERS.(situation_name), situationsNames{i_situation})
            end
        end
    end
    delete(trip);
end
for i_situation = 1:length(situationsNames)
    situation_name = situationsNames{i_situation};
    situation_name = regexprep(situation_name, ' ', '_'); % to uncoment if separator is ' '
    fclose(file_id.(situation_name));
end
disp([num2str(length(trip_files)) ' trips exportés.'])
end

function out = buildHeader(situation_name, nb_occurrences, indicators)
PRE_HEADER = {'id_situation', 'date', 'heure'};
LENGTH_HEADER = length(indicators);
HEADER = cell(1,LENGTH_HEADER);
i_HEADER = 1;
for i_indicators = 1:length(indicators)
    if nb_occurrences > 1
        HEADER(i_HEADER) = {[indicators{i_indicators} '_' situation_name num2str(i_occurrence)]};
    else
        HEADER(i_HEADER) = {[indicators{i_indicators}]};
    end
    i_HEADER = i_HEADER+1;
end

out = [PRE_HEADER, HEADER];
end