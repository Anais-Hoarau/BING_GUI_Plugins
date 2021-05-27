function batchExportTSV_RCE2_breathing(MAIN_FOLDER)
%TODO : uigetdir -> MAIN_FOLDER et uiget pour le case
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
MAIN_FOLDER = '\\vrlescot.ifsttar.fr\DKLESCOT\PROJETS ACTUELS\THESE_GUILLAUME\RCE2\DONNEES_PARTICIPANTS\TESTS';
EXPORT_FOLDER = [MAIN_FOLDER filesep 'FICHIERS_RESULTATS' filesep 'Tableaux_données' filesep HORODATAGE];
trip_files = dirrec(MAIN_FOLDER, '.trip');
mkdir(EXPORT_FOLDER);

%% TSV FILES CREATION WITH HEADERS
situations = {'stimulation'};
for i_situation = 1:length(situations)
    file_id.(situations{i_situation}) = [];
    file_id.(situations{i_situation}) = fopen([EXPORT_FOLDER filesep 'breathing_' HORODATAGE '.tsv'], 'w');
end

%% EXPORT TRIP SITUATIONS TO TSV FILES
for i_trip = 1:length(trip_files)
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    
    if ~check_trip_meta(trip, 'id_scenario', 'PILAUT')
        if trip.getMetaInformations().existEvent('stimulation')
            disp(['exporting : ' trip_file])
            exportTripSituation2TSVByParticipant_RCE2_breathing(trip_file, file_id.(situations{1}), 'stimulation')
        end
    end
    delete(trip);
end
for i_situation = 1:length(situations)
    fclose(file_id.(situations{i_situation}));
end
disp([num2str(length(trip_files)) ' trips exportés.'])
end