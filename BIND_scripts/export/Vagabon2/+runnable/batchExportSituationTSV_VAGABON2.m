function batchExportSituationTSV_VAGABON2(MAIN_FOLDER)
%TODO : uigetdir -> MAIN_FOLDER et uiget pour le case
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
MAIN_FOLDER = 'E:\PROJETS ACTUELS\THESE_GUILLAUME\VAGABON\VAGABON2\DONNEES_PARTICIPANTS\TESTS';
EXPORT_FOLDER = [MAIN_FOLDER filesep '@FICHIERS_RESULTATS' filesep 'Tableaux_données' filesep HORODATAGE];
trip_files = dirrec(MAIN_FOLDER, '.trip');
mkdir(EXPORT_FOLDER);

%% HEADERS CONSTRUCTION
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_files{3}, 0.04, false);
metaInfos = trip.getMetaInformations();
situationsNames = metaInfos.getSituationsNamesList();
for i_situation = 1:length(situationsNames)
    situation_name = situationsNames{i_situation};
    situation_name_reduced = upper([situation_name(1), situation_name(regexp(situation_name,'_')+1)]);
    situation_occurences = trip.getAllSituationOccurences(situationsNames{i_situation}).getVariableValues('name');
    variables_names = metaInfos.getSituationVariablesNamesList(situationsNames(i_situation));
    HEADERS.(situationsNames{i_situation}) = buildHeader(situation_name_reduced, 1, variables_names(4:end));
end

%% TSV FILES CREATION WITH HEADERS
for i_situation = 1:length(situationsNames)
    file_id.(situationsNames{i_situation}) = [];
    file_id.(situationsNames{i_situation}) = fopen([EXPORT_FOLDER filesep situationsNames{i_situation} '_' HORODATAGE '.tsv'], 'w');
    fprintf(file_id.(situationsNames{i_situation}), '%s\t', HEADERS.(situationsNames{i_situation}){:});
    fprintf(file_id.(situationsNames{i_situation}), '\n');
end

%% EXPORT TRIP SITUATIONS TO TSV FILES
for i_trip = 1:length(trip_files)
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    if isempty(strfind(trip_file,'BL')) && isempty(strfind(trip_file,'@'))
        for i_situation = 1:length(situationsNames)
            if trip.getMetaInformations().existSituation(situationsNames{i_situation})
                if ~isempty(strfind(situationsNames{i_situation},'self_report'))
                    situations_to_get_TC = 'conduite_libre';
                elseif ~isempty(strfind(situationsNames{i_situation},'rep_stop'))
                    situations_to_get_TC = 'tache_prospective';
                else
                    situations_to_get_TC = 'scenario_complet';
                end
                disp(['exporting : ' trip_file])
                exportTripSituation2TSVByParticipant_VAGABON2(trip_file, file_id, situationsNames{i_situation}, situations_to_get_TC)
            end
        end
    end
    delete(trip);
end
for i_situation = 1:length(situationsNames)
    fclose(file_id.(situationsNames{i_situation}));
end
disp([num2str(length(trip_files)) ' trips exportés.'])
end

function out = buildHeader(situation_name, nb_occurrences, indicators)
PRE_HEADER = {'id_participant', 'id_scenario', 'id_situation' 'date', 'heure'};
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