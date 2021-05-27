function BatchImportAtlas(dir_root,subject_scenario_cell)

    % TODO: log importation time

    previous_path = pwd;
    cd(dir_root);
    log_csv = fopen('LogImportAtlas.csv', 'a+');
    fprintf(log_csv, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Sujet', 'Scenario', 'DistractionType', 'StatutProcess', 'VAR', 'TRIP', 'VIDEO', 'CARDIO', 'OCULO', 'TRIP_CONVERSTION_TIME');
    
    % On boucle sur les scenarios
    for i = 1:length(subject_scenario_cell)
        % Initialise où on est.
        dossier_sujet = subject_scenario_cell{i,1};
        dossier_sc = subject_scenario_cell{i,2};
        num_sujet = subject_scenario_cell{i,3};
        num_scenario = subject_scenario_cell{i,4};
        type_distraction = subject_scenario_cell{i,5};
        path_trip_dir = [dir_root dossier_sujet filesep dossier_sc filesep];
        trip_file = [path_trip_dir dossier_sc '.trip'];
        disp(['Sujet ' num_sujet ', scenario ' num_scenario ' :']);
        lg_statut = '';
        lg_var = '';
        lg_trip = '';
        lg_video = '';
        lg_cardio = '';
        lg_oculo = '';
        lg_poi = '';
        lg_time = '';
        trip_needs_to_be_converted = false;
        try 
            % Cherche les fichiers TRIP. 
            if file_exists(trip_file)
            % Si le fichier trip existe
            % Charge le trip pour vérifier que la conversion a été correcte
                trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
                if check_trip_meta(trip,'import_trip','failed') || ~check_trip_meta(trip,'timecode_reference',0)
                    disp('Trip file exists, but the previous import had failed.');
                    trip_needs_to_be_converted = true;
                    disp('Deleting the trip file.');
                    delete(trip);
                    delete(trip_file);
                else
                    disp('Trip file was found.');
                    delete(trip);
                end
            else
                disp('Trip file does not exist...');
                trip_needs_to_be_converted = true;
            end
                
            if trip_needs_to_be_converted
            % Si le trip doit être créé, cherche les fichiers VAR
                disp('Looking for var files...');
                lg_var = 'failed';%log for crash
                var_files = find_file_with_extension(path_trip_dir,'.var');
                if length(var_files) < 1
                    % Pas de fichier VAR
                    lg_var = 'No file';
                    disp('No var file found');
                elseif length(var_files) > 1
                    % Plusieurs fichiers VAR
                    lg_var = [num2str(length(var_files)) ' files'];
                    disp([num2str(length(var_files))  'var files found']);
                else
                    % Si un seul VAR, converti le TRIP
                    var_file = var_files{1};
                    lg_var = 'Ok';
                    disp('var file found');
                                        
                    disp('creating the trip file');
                    lg_trip = 'failed';%log for crash
                    tic_trip_conv = tic;
                    %TODO: Copie le fichier en local pour faire le
                    %traitement et gagner du temps...                    
                    % Import des timecodes faits dans Atlast2BIND
                    % TODO: inclure la vidéo
                    % TODO: inclure les données cardio
                    % TODO: inclure les données facelab
                    Atlas2BIND(var_file, num_scenario);
                    initMeta(trip_file,num_sujet,num_scenario,type_distraction,tic_trip_conv); % now trip_file is a file;
                    lg_time = sprintf('%f',toc(tic_trip_conv));
                    toc(tic_trip_conv) % for display
                    % LOG: trip OK
                    lg_trip = 'Ok';
                    disp('trip file was created');                    
                end
            end          
            
            % Enrichissement du TRIP s'il a été converti
            if file_exists(trip_file)            
                % Si on est ici, soit il y a un pbm de nombre de fichiers VAR
                % et le trip n'a pas été converti, soit le trip existe et il a
                % été converti sans lancer d'exceptions.
    
                trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
                % Cherche dans les attributs du trip ce qui a déjà été fait
                import_video_needed = check_trip_meta(trip,'import_video','Non');
                import_cardio_needed = check_trip_meta(trip,'import_cardio','Non');
                import_facelab_needed = check_trip_meta(trip,'import_facelab','Non');
                calcul_POI_needed = check_trip_meta(trip,'calcul_POI','Non');
                % Calcule les valeurs de log pour ce qui a déjà été calculé
                if strcmp(lg_var,'')
                    lg_var = 'Ok';
                end
                if strcmp(lg_trip,'')
                    lg_trip = 'Ok';
                end
                if strcmp(lg_time,'')
                    lg_time = ['(' trip.getAttribute('converstion_time') ')'];
                end
                
                % Vidéo définie ?
                if import_video_needed
                    % Si pas définie
                    % Cherche la vidéo

                    disp('Looking for the video file...');
                    lg_video = 'Uncaught exception';%log for crash
                    video_files = find_file_with_extension(path_trip_dir,'.mpg');
                    if length(video_files) < 1
                        % Pas de fichier VAR
                        lg_video = 'No file';
                        disp('No var file found');
                    elseif length(video_files) > 1
                        % Plusieurs fichiers VAR
                        lg_video = [num2str(length(video_files)) ' files'];
                        disp([num2str(length(video_files))  'var files found']);
                    else
                        % Si un seul VAR, converti le TRIP
                        video_path = video_files{1};
                        lg_video = 'Ok';
                        disp('video file found');

                        disp('adding the video to the trip file');
                        [~, video_name, video_ext] = fileparts(video_path);
                        video_file = ['.' filesep video_name video_ext];
                        metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,0,'quadra');
                        trip.addVideoFile(metaVideo);
                        
                        trip.setAttribute('import_video','Ok');
                        
                        % LOG: trip OK
                        lg_video = 'Ok';
                        disp('video added to the trip!');                    
                    end
                else
                    disp('Video already imported.');
                    lg_video = 'Ok';
                end

                % FACELAB
                if import_facelab_needed
                else
                    disp('Facelab already imported.');
                    lg_oculo = 'Ok';
                end

                % CARDIAQUE
                if import_cardio_needed      
                    lg_cardio = 'Uncaught exception';
                    % Look for the Cardio (.mat) file exported from .acq
                    % Look for the Journal (.txt) file
                    cardio_data_file = [dir_root dossier_sujet filesep 'S' num_sujet '_cardiaque.mat'];
                    cardio_event_file = [dir_root dossier_sujet filesep 'S' num_sujet '_cardiaque_events.mat'];      
                    if ~file_exists(cardio_data_file) && ~file_exists(cardio_event_file)
                        disp('No data file, no event file for cardio.');
                        lg_cardio = 'No data file, no event file';
                    elseif file_exists(cardio_data_file) && ~file_exists(cardio_event_file)
                        disp('No event file for cardio.');
                        lg_cardio = 'No event file';
                    elseif ~file_exists(cardio_data_file) && file_exists(cardio_event_file)
                        disp('No data file for cardio.');
                        lg_cardio = 'No data file';
                    else
                        disp('Cardio file and event file were found.');
                        % Now check if event file was successfully parsed.
                        load(cardio_event_file);
                        if compliant % variable loaded from cardio_event_file
                            disp('Event file parsed correctly');
                            % TODO: décoder events
                            % Importer events
                            % Importer data cardio
                            
                            % look for relevant events:
                            indScenario = find(strcmp(scen_event_cell(:,1),num_scenario));
                            % import events:
                            eventsCell = scen_event_cell{indScenario,5};
                            
                            % decode cardio_start_time
                            % example: 'Fri Jul 22 09:36:03 2011'
                            date_cell = regexp(time_append_GMT, ' ', 'split');
                            cardio_time = decodeTimeHHMMSS2s(date_cell{4});
                            % decode scenario_start_time
                            record = trip.getAllDataOccurences('variables_simulateur');
                            heure_GMT_cell = record.getVariableValues('heureGMT');
                            var_start_time = heure_GMT_cell{1};
                            clear('heure_GMT_cell');
                            var_time = decodeTimeHHMMSS2s(var_start_time);
                            % decode scenario_top_offset (when the top
                            % event is recorded)
                            start_event_indices = strcmp(eventsCell(:,3),'User Type 1');
                            last_start_event_ind = find(start_event_indices,1,'last');
                            start_event_time_str = eventsCell(last_start_event_ind,2);
                            start_event_time = decodeCardioEventTime(start_event_time_str);
                            offset = var_time - cardio_time; % + start_sample/1000 ????
                            
                            % Load data file
                            %load(cardio_data_file);
                            % Access to file without loading in memory
                            matObj = matfile(cardio_data_file);
                            % find relevant column:
                            % raw data column
                            % post-processed column
                            labelCell = cellstr(matObj.labels);
                            data_ind = strcmp(labelCell,'C15 - Filter');
                            cardio_msg = '';
                            if any(data_ind)
                                %GET C15-FILTER DATA
                                disp('raw cardio data found ("C15 - Filter")');
                                raw_data_ind = find(data_ind,1,'first');
                            elseif any(strcmp(labelCell,'Analog input'))
                                %GET Analog input 
                                disp('raw cardio data found ("Analog input" instead of missing "C15 - Filter")');
                                cardio_msg = [cardio_msg '"C15 - Filter", replaced by "Analog input"; '];
                                raw_data_ind = find(strcmp(labelCell,'Analog input'),1,'first');
                            else
                                %ERROR
                                disp('No raw cardio data found');
                                cardio_msg = [cardio_msg 'no raw data; '];
                            end

                            % We use indScenario to find the correct label
                            % column in the cardio data as the scenario
                            % indice was used instead of the scenario
                            % number to define postprocessed cardio data.
                            indScenarioStr = num2str(indScenario);
                            scen_data_ind = find(cellfun(@(x) strcmp(x(end),indScenarioStr), labelCell));
                            if isempty(scen_data_ind)
                                cardio_msg = [cardio_msg 'no label for scenario ' num_scenario '(indice ' indScenarioStr '); '];
                            elseif length(scen_data_ind) ~= 1
                                cardio_msg = [cardio_msg 'several labels for scenario ' num_scenario '(indice ' indScenarioStr '); '];
                            end  
                            
                            if strcmp(cardio_msg,'')
                                %%%%%%%%%
                                % EVENTS
                                %%%%%%%%%
                                
                                % create meta events:
                                % '#%s Time: %s Type: %s Channel: %s Label: %s'
                                % event_number, time, type, channel, label
                                eventVariablesCell = { ...
                                    {'event_number', fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT } ...
                                    {'time', fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT } ...
                                    {'type', fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT } ...
                                    {'channel', fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT } ...
                                    {'label', fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT } ...
                                    };
                                createMetaEvent(trip,'Cardio_raw_events',eventVariablesCell);
                                
                                % building timecodes
                                lengthEvents = length(eventsCell(:,2));
                                timecodes = cell(1,lengthEvents);
                                for eventCount=1:lengthEvents
                                    eventTime = eventsCell{eventCount,2};
                                    timecodes{eventCount} = decodeCardioEventTime(eventTime) - offset;
                                end
                                
                                % Save events
                                trip.setBatchOfTimeEventVariablePairs('Cardio_raw_events','event_number',{ timecodes{:} ; eventsCell{:,1} });
                                trip.setBatchOfTimeEventVariablePairs('Cardio_raw_events','time',{ timecodes{:} ; eventsCell{:,2} });
                                trip.setBatchOfTimeEventVariablePairs('Cardio_raw_events','type',{ timecodes{:} ; eventsCell{:,3} });
                                trip.setBatchOfTimeEventVariablePairs('Cardio_raw_events','channel',{ timecodes{:} ; eventsCell{:,4} });
                                trip.setBatchOfTimeEventVariablePairs('Cardio_raw_events','label',{ timecodes{:} ; eventsCell{:,5} });

                                % TODO set that
                                %trip.setIsBaseEvent('Cardio_raw_events',true);

                                %%%%%%%%%
                                % DATA
                                %%%%%%%%%
                                
                                % create meta data:
                                dataVariablesCell = { ...
                                    {'raw', fr.lescot.bind.data.MetaDataVariable.TYPE_REAL } ...
                                    {'analysed', fr.lescot.bind.data.MetaDataVariable.TYPE_REAL } ...
                                    };
                                createMetaData(trip,'Cardio_data',dataVariablesCell);
                                 
                                % build cell arrays
%                                 [line_num, col_num] = size(matObj,'data');
                                
                                                              
                                % number of lines to read in the cardio file
                                % (first event to last event)
                                last_event_time_str = eventsCell{end,2};
                                last_event_time = decodeCardioEventTime(last_event_time_str);
                                scen_time_len = last_event_time - start_event_time;
                                scen_ind_len = round(scen_time_len*1000);
                                % indice where scenario starts (raw data only)
                                start_ind = round(start_event_time*1000);
                                
                                % create timecodes
                                generated_tc = zeros(scen_ind_len,1);
                                for j = 1:scen_ind_len
                                    generated_tc(j) = (j-1)/1000.;
                                end
                                % adding offset
                                generated_tc = generated_tc + (start_event_time - offset);
                                
                                % cell array for raw data
                                raw_cardio_cell = cell(2,scen_ind_len);
                                raw_cardio_cell(1,:) = num2cell(generated_tc);
                                raw_cardio_cell(2,:) = num2cell(matObj.data(start_ind:start_ind+scen_ind_len-1,raw_data_ind));
                                % save data
                                trip.setBatchOfTimeDataVariablePairs('Cardio_data','raw',raw_cardio_cell);
                                clear('raw_cardio_cell');
                                
                                % cell array for scenario data
                                scen_cardio_cell = cell(2,scen_ind_len);
                                scen_cardio_cell(1,:) = num2cell(generated_tc);
                                scen_cardio_cell(2,:) = num2cell(matObj.data(1:scen_ind_len,scen_data_ind));
                                % Save the data                            
                                trip.setBatchOfTimeDataVariablePairs('Cardio_data','analysed',scen_cardio_cell);
                                clear('scen_cardio_cell');
   
                                % TODO set that
                                %trip.setIsBaseData('Cardio_data',true);
                            
                                % TODO: set trip meta info to reflect the
                                % current status. (imported or not)
                                
                                % TODO: delete variables loaded with cardio
                                % matlab file
                                
                                lg_cardio = 'Ok';
                            else
                                lg_cardio = [ 'Failed: ' cardio_msg];
                            end
                            
                        else
                            disp('Event file has not been parsed correctly');
                            lg_cardio = 'Event file has not been parsed correctly';
                        end
                    end
                else
                    disp('Cardio already imported.');
                    lg_cardio = 'Ok';
                end

                % POI
                if calcul_POI_needed
                else
                    disp('POI already calculated.');
                    lg_poi = 'Ok';
                end

                % Vérifié
                
                delete(trip)
            end
        catch ME
            disp('Error caught, logging and skipping to next file');
            ME.getReport
            Errorlog = fopen('BatchImportAtlas.log', 'a+');
            fprintf(Errorlog, '%s\n', [datestr(now) ' : Error with this trip : ' trip_file]);
            fprintf(Errorlog, '%s\n', ME.getReport('extended', 'hyperlinks', 'off'));
            fprintf(Errorlog, '%s\n', '---------------------------------------------------------------------------------');
            fclose(Errorlog);
            
            % Clear big variables that can lead to out of memory errors:
            clear('raw_cardio_cell','scen_cardio_cell');
            
        end
        % unload variables loaded from file "cardio_event_file"
        clear('compliant','comment','scen_event_cell','time_append_GMT','time_append_relative');
        clear('matObj');
        % Clear all cardio variables
        clear('cardio_data_file','cardio_event_file','cardio_msg','cardio_time','dataVariablesCell','data_ind','date_cell',...
            'eventCount','eventTime','eventVariablesCell','eventsCell','generated_tc','j','indScenario','indScenarioStr',...
            'labelCell','last_event_time','last_event_time_str','last_start_event_ind','lengthEvents','offset','raw_data_ind',...
            'record','scen_data_ind','scen_ind_len','scen_time_len','start_event_indices','start_event_time','start_event_time_str',...
            'start_ind','timecodes','var_start_time','var_time');
        fprintf(log_csv, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', num_sujet, num_scenario, type_distraction, lg_statut, lg_var, lg_trip, lg_video, lg_cardio, lg_oculo, lg_time);
    end
    fclose(log_csv);

    % go back to previous path
    cd(previous_path);
end