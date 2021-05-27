function out = test_magic_import_cardio(trip,dir_root,dossier_sujet,num_sujet)

    % Look for the Cardio (.mat) file exported from .acq
    % Look for the Journal (.txt) file
    cardio_data_file = [dir_root dossier_sujet filesep 'S' num_sujet '_cardiaque.mat'];
    cardio_event_file = [dir_root dossier_sujet filesep 'S' num_sujet '_cardiaque_events.mat'];      
    if ~file_exists(cardio_data_file) && ~file_exists(cardio_event_file)
        disp('No data file, no event file for cardio.');
        out = 'No data file, no event file';
    elseif file_exists(cardio_data_file) && ~file_exists(cardio_event_file)
        disp('No event file for cardio.');
        out = 'No event file';
    elseif ~file_exists(cardio_data_file) && file_exists(cardio_event_file)
        disp('No data file for cardio.');
        out = 'No data file';
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

                out = 'Ok';
            else
                out = [ 'Failed: ' cardio_msg];
            end

        else
            disp('Event file has not been parsed correctly');
            out = 'Event file has not been parsed correctly';
        end
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
    % Clear big variables that can lead to out of memory errors:
    clear('raw_cardio_cell','scen_cardio_cell');
            
end