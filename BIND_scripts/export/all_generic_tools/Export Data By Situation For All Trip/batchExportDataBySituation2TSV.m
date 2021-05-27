function batchExportDataBySituation2TSV(fulldirectory, dataNames, variablesNames, situationsNames, subSampling)
    %% USER SELECTIONS (TO COMMENT IF ARGUMENT)
    dataNames = {'MP150_data','MP150_data'};
    variablesNames = {'HRinterp','Respiration'};
    situationsNames = {'feu_stop_on_before', 'feu_stop_on_after'};
    subSampling = 250;
    
    HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
    if ~exist('fulldirectory', 'var')
        fulldirectory = uigetdir;
    end
    trip_files = dirrec(fulldirectory, '.trip');
    EXPORT_FOLDER = [fulldirectory filesep '~DATA_EXPORT' filesep 'DATA_TABLES_EXPORT' filesep HORODATAGE];
    mkdir(EXPORT_FOLDER);
    
    %% OPEN FILE IDS
    for i_situation = 1:length(situationsNames)
        for i_var = 1:length(variablesNames)
            file_id.(situationsNames{i_situation}).(variablesNames{i_var}) = fopen([EXPORT_FOLDER filesep situationsNames{i_situation} '_' variablesNames{i_var} '_' HORODATAGE '.tsv'], 'w');
        end
    end
    
    %% EXPORT TRIP DATA ACCORDING TO SITUATIONS TO TSV FILES
    for i_trip = 1:length(trip_files)
        trip_file = trip_files{i_trip};
        trip_file_split = strsplit(trip_file, '\');
        id_participant = trip_file_split{end}(1:end-4);
        if ~contains(trip_file,'BL') && ~contains(trip_file,'~')
            for i_situation = 1:length(situationsNames)
                for i_var = 1:length(variablesNames)
                    disp(['exporting ' id_participant ' | ' dataNames{i_var}  ' | ' variablesNames{i_var} ' on situation : ' situationsNames{i_situation}]);
                    exportTripDataVariableBySituation2File(trip_file, file_id.(situationsNames{i_situation}).(variablesNames{i_var}), situationsNames{i_situation}, dataNames{i_var}, variablesNames{i_var}, subSampling);
                end
            end
        end
    end
    
    %% CLOSE FILE IDS
    for i_situation = 1:length(situationsNames)
        for i_var = 1:length(variablesNames)
            fclose(file_id.(situationsNames{i_situation}).(variablesNames{i_var}));
        end
    end
    disp([num2str(length(trip_files)) ' trips exportés.'])
end