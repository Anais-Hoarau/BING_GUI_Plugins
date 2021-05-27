% Opens a cardio journal file (.jcq) and check its consistency with the
% scenario design.
function [compliant,comment,scen_event_cell,time_append_relative,time_append_GMT] = parseCardioEvents(cardioJournalFile,subjectPath)

    compliant = true;
    comment = '';        
    %rural_included = false;

    
    % Check the journalFile: found "Event Summary" in the first line?
    % Foreach line, import event type and number
   
    % Parse folders to know what were the situations (C, DV, or DVS) for
    % each scenario
    scenario_dirs = dir(subjectPath);
    scenario_cell = {}; % num_sc, type_distraction
    for i = 1:length(scenario_dirs)
        if scenario_dirs(i).isdir && ~any(strcmp(scenario_dirs(i).name,{'.' '..'}))
            num_scenario = regexp(scenario_dirs(i).name,'[0-9]+(?=_[CDVS]+)','match','once');
            scenario_cell{end+1,1} = num_scenario;
            type_distraction = regexp(scenario_dirs(i).name,'[CDVS]+$','match','once');
            scenario_cell{end,2} = type_distraction;
        end
    end
    
    % DON'T NEED TO KNOW ABOUT RURAL SCENARIO BEING PRESENT AS WE CAN PARSE
    % THE scenario_cell VARIABLE AND INDIRECTLY GET THE INFORMATION WE
    % NEED.
%     % Check if the rural scenarios where included (presence of scenario #3)
%     if any(strcmp(scenario_cell{:,1},'3')
%         rural_included = true;
%     end
    
    f = fopen(cardioJournalFile, 'r');
    line = fgetl(f);
    if ~strcmp(line,'Event Summary') && compliant
        compliant = false;
        comment = [comment 'Failed to detect "Event Summary" as the first line; '];
    end
    % Parse events
    % EventNumber, Time, Type, Channel, Label
    raw_events = textscan(f,'#%s Time: %s Type: %s Channel: %s Label: %s','Delimiter','\t');
    fclose(f);
    for i = 1:length(raw_events)
        events(:,i) = raw_events{i};
    end
  
    % EventNumber, Time, Type, Channel, Label
    % For event type "Append", look at the "Time" and "Label" to know starting time
    % For exent type "Default", "User Type N", just look at "Time"
    
    % Is there one and only one "Append" event?
    appendEventInd = strcmp(events(:,3),'Append');
    if ~any(appendEventInd) && compliant
        compliant = false;
        comment = [comment 'No event of type Append found (for time synchronisation); '];
    elseif sum(appendEventInd)>1 && compliant
        compliant = false;
        comment = [comment 'Too many events of type Append found; '];
    elseif appendEventInd(1) == 0 && compliant
        compliant = false;
        comment = [comment 'One event of type Append, but not detected as first event; '];
    end
    
    % get the information about time.
    time_append_relative = events{1,2};
    time_append_GMT = events{1,5};
    
    % Parse scenario_cell to match C/DV/DVS to what is observed in the
    % cardio file.
    sc_len = length(scenario_cell(:,1));
    eventInd = 2; % Start at 2 to avoid the first 'Append' event.
    scen_event_cell = cell(sc_len,5);
    reached_end = false;
    for scInd = 1:sc_len % for each scenario
        scen_num = scenario_cell{scInd,1};
        type_distract = scenario_cell{scInd,2};
        scen_compliant = true;
        scen_comment = '';
        scen_event_cell{scInd,1} = scen_num;
        scen_event_cell{scInd,2} = type_distract;
        scen_event_cell{scInd,3} = scen_compliant;    % did it work?
        scen_event_cell{scInd,4} = scen_comment;      % comments explaining problems
        scen_event_cell{scInd,5} = {};      % events cell array
        begin_event_found = false;
        eventType = events{eventInd,3};
        first_event_ind = eventInd;
        while(~reached_end && ~strcmp(eventType,'Default')) % while it is not the end of the scenario
            switch eventType
                % SITUATAION DV
                % "User Type 1" means "début"
                % "User Type 2" means "un mot mystère"
                % "User Type 3" means SHOULD NOT APPEAR
                % "Default" means "fin"

                % SITUATAION DVS
                % "User Type 1" means "début"
                % "User Type 2" means "déplacement"
                % "User Type 3" means "restitution"
                % "Default" means "fin"

                % SITUATAION C
                % "User Type 1" means "début"
                % "User Type 2" means SHOULD NOT APPEAR
                % "User Type 3" means SHOULD NOT APPEAR
                % "Default" means "fin"
                case 'User Type 1'
                    if begin_event_found
                        scen_comment = [scen_comment 'Begin event (User Type 1) found several times for the same scenario (event #' events{eventInd,1} '); '];
                    end
                    begin_event_found = true;
                case 'User Type 2'
                    if strcmp(type_distract,'C')
                        scen_compliant = false;
                        scen_comment = [scen_comment 'Event User Type 2 in a C scenario (event #' events{eventInd,1} '); '];
                    end
                case 'User Type 3'
                    if ~strcmp(type_distract,'DVS')
                        scen_compliant = false;
                        scen_comment = [scen_comment 'Event User Type 3 in a non-DVS scenario (event #' events{eventInd,1} '); '];
                    end
                otherwise
                    scen_compliant = false;
                    scen_comment = [scen_comment 'Unexpected event "' eventType '"found (event #' events{eventInd,1} '); '];          
            end
            eventInd = eventInd + 1;
            if eventInd > length(events(:,1))
                reached_end = true;
            else
                eventType = events{eventInd,3};
            end
        end
        
        if reached_end && ~strcmp(eventType,'Default')
            scen_compliant = false;
            scen_comment = [scen_comment 'Last event is not Default event (event #' events{eventInd,1} '); '];  
        end
        
        if ~begin_event_found
            scen_compliant = false;
            scen_comment = [scen_comment 'No User Type 1 event for scenario ' scenario_cell{scInd,1} '; '];  
        end
        
        % Deal with several 'Default' event in a row
        count_end = 0;
        while(~reached_end && strcmp(eventType,'Default'))
            last_event_ind = eventInd;
            count_end = count_end +1;
            if count_end>1
                scen_comment = [scen_comment 'End event (Default) found several times for the same scenario (event #' events{eventInd,1} '); '];
            end
            eventInd = eventInd + 1;
            if eventInd > length(events(:,1))
                reached_end = true;
            else
                eventType = events{eventInd,3};
            end
        end
        
        compliant = compliant && scen_compliant;
        comment = [comment scen_comment];
        scen_event_cell{scInd,3} = scen_compliant;    % did it work?
        scen_event_cell{scInd,4} = scen_comment;      % comments explaining problems
        scen_event_cell{scInd,5} = events(first_event_ind:last_event_ind,:);
    end
    
end