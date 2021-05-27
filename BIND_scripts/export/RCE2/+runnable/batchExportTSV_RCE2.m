function batchExportTSV_RCE2(MAIN_FOLDER)
%TODO : uigetdir -> MAIN_FOLDER et uiget pour le case
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
MAIN_FOLDER = '\\vrlescot.ifsttar.fr\DKLESCOT\PROJETS ACTUELS\THESE_GUILLAUME\RCE2\DONNEES_PARTICIPANTS\TESTS';
EXPORT_FOLDER = [MAIN_FOLDER filesep 'FICHIERS_RESULTATS' filesep 'Tableaux_données' filesep HORODATAGE];
trip_files = dirrec(MAIN_FOLDER, '.trip');
mkdir(EXPORT_FOLDER);

%% HEADERS CONSTRUCTION
% AUDVSP : scénarios auditifs et visuo-spatials
NB_SITUATIONS_MAX_AUDVSP = 13;
%NB_SITUATIONS_MAX_AUDVSP = getSituationVariablesValuesForAllTrips
INDICATORS_AUDVSP = {'duree', 'nb_ech', 'freq', 'vit_moy', 'vit_var', 'accel_moy', 'decel_moy', 'nb_aCoups', 'frein_moy',  'frein_max', 'lat_var', 'angleVol_var'};
HEADERS.AUDVSP_SCENARIO = buildHeader('scenario', 1, INDICATORS_AUDVSP);
HEADERS.AUDVSP_STIM_AVANT = buildHeader('stim', NB_SITUATIONS_MAX_AUDVSP, INDICATORS_AUDVSP);
HEADERS.AUDVSP_STIM_APRES = buildHeader('stim', NB_SITUATIONS_MAX_AUDVSP, INDICATORS_AUDVSP);

% PILAUT : scénario pilote auto
NB_SITUATIONS_MAX_PILAUT = 1;
INDICATORS_PILAUT = {'duree', 'nb_ech', 'freq', 'reussite', 'arret', '1stRéac', 'TC_1stRéac', 'TR_1stRéac', 'TIV_min', 'vit_moy', 'vit_var', 'SV', 'dureeSV'};
HEADERS.PILAUT_PILOTE_AUTO = buildHeader('auto_Off', NB_SITUATIONS_MAX_PILAUT, INDICATORS_PILAUT);

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
    
    if check_trip_meta(trip, 'id_scenario', 'PILAUT')
        if trip.getMetaInformations().existSituation('pilote_auto')
            disp(['exporting : ' trip_file ' in file : ' situations{4}])
            exportTripSituation2TSVByParticipant_RCE2(trip_file, file_id.(situations{4}), 'pilote_auto')
        end
    else
        if trip.getMetaInformations().existSituation('scenario_complet')
            disp(['exporting : ' trip_file])
            exportTripSituation2TSVByParticipant_RCE2(trip_file, file_id.(situations{1}), 'scenario_complet')
        end
        if trip.getMetaInformations().existSituation('stimulation_avant')
            disp(['exporting : ' trip_file])
            exportTripSituation2TSVByParticipant_RCE2(trip_file, file_id.(situations{2}), 'stimulation_avant')
        end
        if trip.getMetaInformations().existSituation('stimulation_apres')
            disp(['exporting : ' trip_file])
            exportTripSituation2TSVByParticipant_RCE2(trip_file, file_id.(situations{3}), 'stimulation_apres')
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
PRE_HEADER = {'id_participant', 'id_groupe', 'id_scenario', 'date', 'heure'};
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