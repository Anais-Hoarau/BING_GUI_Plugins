% batchBind2Mat('Z:\ManipSimulateur_new\Sujet_18\S18_sc1_DVS','Z:\ManipSimulateur_new\ExportMatlab',true)
% TODO tester cette version sur un seul sujet. déboguer. Puis ajouter
% l'enregistrement.
function batchBind2Mat(input_dir,output_dir,overwrite)

    listing = dirrec(input_dir,'.trip');
    
    for i = 1:length(listing)
        trip_file = listing{i};
        [~, trip_name, ~] = fileparts(trip_file);
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        file_name = [output_dir filesep trip_name]; % name of the exported file
        
        % If the trip is valid (properly imported), then try to export
        if ~check_trip_meta(trip,'import_trip','failed')   
            % If the trip has not been exported or overwrite = true
            if overwrite || ~file_exists([file_name '.mat'])
                disp(['Exporting ' trip_file]);
                metaInfos = trip.getMetaInformations();
                dataList = metaInfos.getDatasList();
                for d = 1:length(dataList)
                    metaData = dataList{d};
                    dataName = metaData.getName();
                    if strcmp(dataName(1),'-')
                        % The data is skipped (in order to avoir -1, -100 type of
                        % data names that are not supported as matlab structure
                        % names.
                    else
                        variableList = metaData.getVariables();

                        dataRecord = trip.getAllDataOccurences(dataName);

                        for v = 1:length(variableList)
                            variableMeta = variableList{v};
                            variableName = variableMeta.getName();
                            variableNewName = strrep(variableName,' ','_');
                            variableNewName = strrep(variableNewName,'é','e');
                            variableNewName = strrep(variableNewName,'è','e');
                            variableNewName = strrep(variableNewName,'à','a');
                            variableNewName = strrep(variableNewName,'.','');
             %               if strcmp('REAL',variableMeta.getType())
                                cell_values = dataRecord.getVariableValues(variableName);
                                values = cell2mat(cell_values);
                                eval(['data_struct.' dataName '.' variableNewName '= values;']);
             %               end
                        end
                    end
                end

                eval([trip_name '= data_struct;']);
                % TODO: save variable trip_name in file trip_name.mat
                save(file_name,trip_name);

                clear data_struct;
            end
        end
        delete(trip);
    end

end