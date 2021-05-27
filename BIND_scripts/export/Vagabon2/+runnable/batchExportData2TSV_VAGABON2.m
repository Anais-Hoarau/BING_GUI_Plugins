function batchExportData2TSV_VAGABON2(MAIN_FOLDER)
%TODO : uigetdir -> MAIN_FOLDER et uiget pour le case
HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
MAIN_FOLDER = '\\vrlescot.ifsttar.fr\DKLESCOT\PROJETS ACTUELS\THESE_GUILLAUME\VAGABON\VAGABON2\DONNEES_PARTICIPANTS\TESTS';
EXPORT_FOLDER = [MAIN_FOLDER filesep '@FICHIERS_RESULTATS' filesep 'Tableaux_données' filesep HORODATAGE];
trip_files = dirrec(MAIN_FOLDER, '.trip');
mkdir(EXPORT_FOLDER);

situations_to_complete = {'self_report','rep_stop'}; %,'obstacle'};
situations_to_get_TC = {'conduite_libre','tache_prospective'}; %,'obstacle_before'};
BindDataNames = {'tobii','tobii'}; %,'tobii','vitesse','trajectoire','trajectoire'};
BindDataVariablesNames = {'axeRegard_X','axeRegard_Y'}; %,'fixite_regard_60','vitesse','voie','angle_volant'};

%% OPEN FILE IDS
for i_situation = 1:length(situations_to_complete)
    for i_var = 1:length(BindDataVariablesNames)
        file_id.(situations_to_complete{i_situation}).(BindDataVariablesNames{i_var}) = fopen([EXPORT_FOLDER filesep situations_to_complete{i_situation} '_' BindDataVariablesNames{i_var} '_' HORODATAGE '.tsv'], 'w');
    end
end

%% EXPORT TRIP DATA ACCORDING TO SITUATIONS TO TSV FILES
tic
for i_trip = 1:length(trip_files)
    tic
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    scenario_id = trip.getAttribute('id_scenario');
    if isempty(strfind(trip_file,'BL')) && isempty(strfind(trip_file,'@'))
        nbRSFiltr = 0;
        for i_situation = 1:length(situations_to_complete)
            if ~strcmp(situations_to_get_TC{i_situation},'obstacle_before') || and(strcmp(situations_to_get_TC{i_situation},'obstacle_before'), strcmp(scenario_id,'AVEC_OBSTACLE'))
                for i_var = 1:length(BindDataVariablesNames)
                    nbRSFiltr_situation = exportTripData2TSVByParticipant_VAGABON2(trip_file, file_id.(situations_to_complete{i_situation}).(BindDataVariablesNames{i_var}), situations_to_complete{i_situation},situations_to_get_TC{i_situation}, BindDataNames{i_var}, BindDataVariablesNames{i_var});
                end
            end
            if strcmp(situations_to_get_TC{i_situation},'tache_prospective')
                nbRSFiltr = nbRSFiltr_situation;
            end
        end
    trip.setAttribute('nbRSFiltr',num2str(nbRSFiltr));
    disp([trip_file ' | le nombre de rep_stop filtrees est de : ',num2str(nbRSFiltr)]);
    end
    delete(trip);
    toc
end
toc
%% CLOSE FILE IDS
for i_situation = 1:length(situations_to_complete)
    for i_var = 1:length(BindDataVariablesNames)
        fclose(file_id.(situations_to_complete{i_situation}).(BindDataVariablesNames{i_var}));
    end
end

disp([num2str(length(trip_files)) ' trips exportés.'])
end