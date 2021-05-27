function batchParseCardioEvents(dir_root,subject_scenario_cell)

    log_csv = fopen([dir_root 'LogCardioEvents.csv'], 'a+');
    fprintf(log_csv, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Sujet', 'CardioSujetOk', 'Scenario', 'TypeDistraction', 'CardioScenarioOk', 'NombreEventScenario','Comment');
        
    previous_parsed_subjects = cell(length(subject_scenario_cell),1);
    % On boucle sur les scenarios
    for i = 1:length(subject_scenario_cell)
        % Initialise où on est.
        dossier_sujet = subject_scenario_cell{i,1};
        num_sujet = subject_scenario_cell{i,3};
        % If not already parsed...
        if ~any(strcmp(previous_parsed_subjects,dossier_sujet))
            subjectPath = [dir_root dossier_sujet];
            cardioJournalFile = [subjectPath filesep 'S' num_sujet '.txt'];
            if file_exists(cardioJournalFile)
                [compliant,comment,scen_event_cell,time_append_relative,time_append_GMT] = parseCardioEvents(cardioJournalFile,subjectPath);
                saved_event_file = [subjectPath filesep 'S' num_sujet '_cardiaque_events.mat'];

                if compliant
                    str_compliant = 'Ok';
                else
                    str_compliant = 'Failed';
                end

                for j = 1:length(scen_event_cell(:,1))
                    scenario = scen_event_cell{j,1};
                    distraction = scen_event_cell{j,2};
                    if scen_event_cell{j,3}
                        scn_compliant = 'Ok';
                    else
                        scn_compliant = 'Failed';
                    end
                    scn_comment = scen_event_cell{j,4};
                    num_events = num2str(length(scen_event_cell{j,5}(:,1)));
                    fprintf(log_csv, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', num_sujet, str_compliant, scenario, distraction, scn_compliant, num_events,scn_comment);
                end
                fprintf(log_csv, '%s\n',comment);
                            
                save(saved_event_file,'compliant','comment','scen_event_cell','time_append_relative','time_append_GMT');
            else % cardio file doesn't exist
                fprintf(log_csv, '%s\n',[cardioJournalFile ' does not exist.']);
            end
        end
        previous_parsed_subjects{i} = dossier_sujet;
    end
    
    fclose(log_csv);
end