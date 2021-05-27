function batchExportTSV_CCOMPOTE(MAIN_FOLDER)
%TODO : uigetdir -> MAIN_FOLDER et uiget pour le case
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
MAIN_FOLDER = 'E:\PROJETS ACTUELS\THESE_FRANCK\CCOMPOTE\DONNEES_PARTICIPANTS\TESTS';
EXPORT_FOLDER = [MAIN_FOLDER filesep 'FICHIERS_EXPORT' filesep 'Tableaux_données'];
trip_files = dirrec(MAIN_FOLDER, '.trip');
if exist(EXPORT_FOLDER, 'dir') ~= 7
    mkdir(EXPORT_FOLDER);
end

%% HEADERS CONSTRUCTION
%NB_SITUATIONS_MAX_EXP = 90;
%NB_SITUATIONS_MAX_EXP = getSituationVariablesValuesForAllTrips
PRE_HEADER_EXP_SCENARIO = {'participant', 'groupe', 'date', 'heure'};
PRE_HEADER_EXP_ESSAIS = {'participant', 'groupe', 'date', 'heure', 'n°_essai', 'type_essai'};
INDICATORS_EXP_SCENARIO = {'duree', 'nb_ech', 'freq', 'TIV_min', 'TIV_moy', 'TIV_var', 'DIV_min', 'DIV_moy', 'DIV_var', 'posLatG_moy', 'posLatD_moy', 'lat_var', 'angleVolant_var', 'nb_SV', 'dureeSV_moy', 'nb_freinages', 'freq_freinage'};
INDICATORS_EXP_ESSAIS = {'duree', 'nb_ech', 'freq', 'TCdecel', 'TRdecel', 'anticip', 'TIV_min', 'TIV_moy', 'TIV_var', 'TIV_levPed', 'DIV_min', 'DIV_moy', 'DIV_var', 'DIV_levPed', 'posLatG_moy', 'posLatD_moy', 'lat_var', 'angleVolant_var'};
HEADERS.EXP_SCENARIO = [PRE_HEADER_EXP_SCENARIO INDICATORS_EXP_SCENARIO]; %buildHeader('scenario', 1, INDICATORS_EXP);
HEADERS.EXP_ESSAIS = [PRE_HEADER_EXP_ESSAIS INDICATORS_EXP_ESSAIS]; %buildHeader('essais', NB_SITUATIONS_MAX_EXP, INDICATORS_EXP);
%HEADERS.EXP_FEUX_STOP = [PRE_HEADER INDICATORS_EXP_SCENARIO]; %buildHeader('feux_stop', NB_SITUATIONS_MAX_EXP, INDICATORS_EXP);

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
        if trip.getMetaInformations().existSituation('scenario_complet')
            disp(['exporting : ' trip_file])
            exportTripSituation2TSVByParticipant_CCOMPOTE(trip_file, file_id.(situations{1}), 'scenario_complet')
        end
        if trip.getMetaInformations().existSituation('essais')
            disp(['exporting : ' trip_file])
            exportTripSituation2TSVByParticipant_CCOMPOTE(trip_file, file_id.(situations{2}), 'essais')
        end
%         if trip.getMetaInformations().existSituation('essais_A')
%             disp(['exporting : ' trip_file])
%             exportTripSituation2TSVByParticipant_CCOMPOTE(trip_file, file_id.(situations{2}), 'essais_A')
%         end
%         if trip.getMetaInformations().existSituation('essais_B')
%             disp(['exporting : ' trip_file])
%             exportTripSituation2TSVByParticipant_CCOMPOTE(trip_file, file_id.(situations{2}), 'essais_B')
%         end
%         if trip.getMetaInformations().existSituation('essais_C')
%             disp(['exporting : ' trip_file])
%             exportTripSituation2TSVByParticipant_CCOMPOTE(trip_file, file_id.(situations{2}), 'essais_C')
%         end        
%         if trip.getMetaInformations().existSituation('feux_stop')
%             disp(['exporting : ' trip_file])
%             exportTripSituation2TSVByParticipant_CCOMPOTE(trip_file, file_id.(situations{3}), 'feux_stop')
%         end
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