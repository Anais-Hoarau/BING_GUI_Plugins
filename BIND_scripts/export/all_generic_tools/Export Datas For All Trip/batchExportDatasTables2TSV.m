function batchExportDatasTables2TSV(fulldirectory)
    HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
    if ~exist('fulldirectory', 'var')
        fulldirectory = uigetdir;
    end
    EXPORT_FOLDER = [fulldirectory filesep '@DATA_EXPORT' filesep 'DATA_TABLES_BACKUP' filesep HORODATAGE];
    trip_files = dirrec(fulldirectory, '.trip');
    mkdir(EXPORT_FOLDER);
    
    %% GET SITUATIONS AND VARIABLES NAMES
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_files{2}, 0.04, false); % 2 | 7 | 2
    datasNames = trip.getMetaInformations().getDatasNamesList();
    for i_data = 1:length(datasNames)
        data_name = cell2mat(regexprep(datasNames(i_data), ' ', '_'));
        variables_names.(data_name) = trip.getMetaInformations().getDataVariablesNamesList(datasNames{i_data});
    end
    delete(trip)
    
    %% TSV FILES CREATION WITH HEADERS
    for i_data = 1:length(datasNames)
        data_name = cell2mat(regexprep(datasNames(i_data), ' ', '_'));
        header = buildHeader(data_name, 1, variables_names.(data_name));
        file_id.(data_name) = fopen([EXPORT_FOLDER filesep data_name '_' HORODATAGE '.tsv'], 'w');
        fprintf(file_id.(data_name), '%s\t', header{:});
        fprintf(file_id.(data_name), '\n');
        %% EXPORT TRIP SITUATIONS TO TSV FILES
        for i_trip = 1:length(trip_files)
            trip_file = trip_files{i_trip};
            disp(['exporting : ' trip_file])
            exportTripDataTable2File(trip_file, file_id.(data_name), datasNames{i_data})
        end
        fclose(file_id.(data_name));
    end
end

function out = buildHeader(data_name, nb_occurrences, variables)
    PRE_HEADER = {'trip_id'};
    LENGTH_HEADER = length(variables);
    HEADER = cell(1,LENGTH_HEADER);
    i_HEADER = 1;
    for i_variable = 1:length(variables)
        if nb_occurrences > 1
            HEADER(i_HEADER) = {[variables{i_variable} '_' data_name num2str(i_occurrence)]};
        else
            HEADER(i_HEADER) = {[variables{i_variable}]};
        end
        i_HEADER = i_HEADER+1;
    end
    out = [PRE_HEADER, HEADER];
end