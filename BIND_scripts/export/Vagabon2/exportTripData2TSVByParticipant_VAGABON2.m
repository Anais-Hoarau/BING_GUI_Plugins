function [nbRSFiltr_situation] = exportTripData2TSVByParticipant_VAGABON2(trip_file, file_id, situations_to_complete, situations_to_get_TC, BindDataName, BindVariableName)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
id_participant = trip.getAttribute('id_participant');
id_scenario = trip.getAttribute('id_scenario');

% get timecodes around data occurrences to export by situation
startTC_occurences = trip.getAllSituationOccurences(situations_to_get_TC).getVariableValues('startTimecode');
endTC_occurences = trip.getAllSituationOccurences(situations_to_get_TC).getVariableValues('endTimecode');
names_occurences = trip.getAllSituationOccurences(situations_to_get_TC).getVariableValues('name');

nbRSFiltr_situation = 0;
for i_occurrence = 1:length(startTC_occurences)
    %% GET SITUATIONS DATA AND FILTER DATA UNUSABLE
    % situation before
    situation_occurences_before = trip.getSituationOccurencesInTimeInterval([situations_to_complete '_before'],startTC_occurences{i_occurrence},endTC_occurences{i_occurrence});
    situation_occurences_before_startTimecodes = situation_occurences_before.getVariableValues('startTimecode');
    situation_occurences_before_endTimecodes = situation_occurences_before.getVariableValues('endTimecode');
    situation_occurences_before_names = situation_occurences_before.getVariableValues('name');
    % filtering of response stop which overlap in the interval of 15 sec before the end of the situation
    if strcmp(situations_to_get_TC,'tache_prospective') && ~isempty(situation_occurences_before_endTimecodes)
        if endTC_occurences{i_occurrence} - (cell2mat(situation_occurences_before_endTimecodes)+1) < 15
            situation_occurences_before_startTimecodes = {};
            situation_occurences_before_endTimecodes = {};
            situation_occurences_before_names = {};
            nbRSFiltr_situation = nbRSFiltr_situation + 1;
        end
        % filtering of obstacles on which a self-report overlap in the interval of 12 sec before the begining of the situation
    elseif strcmp(situations_to_get_TC,'obstacle_before')
        event_occurences = trip.getEventOccurencesInTimeInterval('self_report',situation_occurences_before_endTimecodes{:}-11.5,situation_occurences_before_endTimecodes{:}+0.5).getVariableValues('name');
        event_occurences = [event_occurences, trip.getEventOccurencesInTimeInterval('self_report_filtre',situation_occurences_before_endTimecodes{:}-11.5,situation_occurences_before_endTimecodes{:}+0.5).getVariableValues('name')];
        if ~isempty(event_occurences)
            situation_occurences_before_startTimecodes = {};
            situation_occurences_before_endTimecodes = {};
            situation_occurences_before_names = {};
        end
    end
    
    %situation after
    if ~strcmp(situations_to_get_TC,'obstacle_before')
        situation_occurences_after = trip.getSituationOccurencesInTimeInterval([situations_to_complete '_after'],startTC_occurences{i_occurrence},endTC_occurences{i_occurrence});
        situation_occurences_after_startTimecodes = situation_occurences_after.getVariableValues('startTimecode');
        situation_occurences_after_endTimecodes = situation_occurences_after.getVariableValues('endTimecode');
        situation_occurences_after_names = situation_occurences_after.getVariableValues('name');
        % filtering of response stop which overlap in the interval of 15 sec before the end of the situation
        if strcmp(situations_to_get_TC,'tache_prospective') && ~isempty(situation_occurences_before_endTimecodes)
            if endTC_occurences{i_occurrence} - (cell2mat(situation_occurences_before_endTimecodes)+1) < 15
                situation_occurences_after_startTimecodes = {};
                situation_occurences_after_endTimecodes = {};
                situation_occurences_after_names = {};
            end
        end
    else
        situation_occurences_after_startTimecodes = {1};
        situation_occurences_after_endTimecodes = {1};
        situation_occurences_after_names = {1};
    end
    
    % filtering of self-resport which are not consistent (not the same number of self-responses before and after)
    if ~strcmp(situations_to_get_TC,'obstacle_before') && ~isempty(situation_occurences_before_names) && ~isempty(situation_occurences_after_names) && situation_occurences_before_names{1}(end) ~= situation_occurences_after_names{1}(end)
        situation_occurences_after_startTimecodes = situation_occurences_after_startTimecodes(2:end);
        situation_occurences_after_endTimecodes = situation_occurences_after_endTimecodes(2:end);
        situation_occurences_after_names = situation_occurences_after_names(2:end);
    end
    
    %% EXPORT SITUATION DATA
    for i_occurence = 1:min([length(situation_occurences_before_names),length(situation_occurences_after_names)])
        
        % situation before
        fprintf(file_id, '%s\t', id_participant);
        fprintf(file_id, '%s\t', id_scenario);
        fprintf(file_id, '%s\t', names_occurences{i_occurrence});
        fprintf(file_id, '%f\t', situation_occurences_before_startTimecodes{i_occurence});
        fprintf(file_id, '%f\t', situation_occurences_before_endTimecodes{i_occurence});
        fprintf(file_id, '%s\t', situation_occurences_before_names{i_occurence});
        if trip.getMetaInformations().existData('tobii')
            variable_data = trip.getDataOccurencesInTimeInterval(BindDataName,situation_occurences_before_startTimecodes{i_occurence},situation_occurences_before_endTimecodes{i_occurence}).getVariableValues(BindVariableName);
            for i_data = 1:length(variable_data)
                if strcmp(BindVariableName,'axeRegard_X') || strcmp(BindVariableName,'axeRegard_Y')
                    fprintf(file_id, '%f\t', variable_data{i_data});
                elseif strcmp(BindVariableName,'vitesse')
                    fprintf(file_id, '%f\t', variable_data{i_data}*3.6);
                elseif strcmp(BindVariableName,'voie')
                    fprintf(file_id, '%f\t', (variable_data{i_data}-1750)/1000);
                elseif strcmp(BindVariableName,'angle_volant')
                    fprintf(file_id, '%f\t', variable_data{i_data}/7500*360);
                end
            end
            fprintf(file_id, '\n');
            clear 'variable_data'
            
            if ~strcmp(situations_to_get_TC,'obstacle_before')
                % situation after
                fprintf(file_id, '%s\t', id_participant);
                fprintf(file_id, '%s\t', id_scenario);
                fprintf(file_id, '%s\t', names_occurences{i_occurrence});
                fprintf(file_id, '%f\t', situation_occurences_after_startTimecodes{i_occurence});
                fprintf(file_id, '%f\t', situation_occurences_after_endTimecodes{i_occurence});
                fprintf(file_id, '%s\t', situation_occurences_after_names{i_occurence});
                variable_data = trip.getDataOccurencesInTimeInterval(BindDataName,situation_occurences_after_startTimecodes{i_occurence},situation_occurences_after_endTimecodes{i_occurence}).getVariableValues(BindVariableName);
                for i_data = 1:length(variable_data)
                    if strcmp(BindVariableName,'axeRegard_X') || strcmp(BindVariableName,'axeRegard_Y')
                        fprintf(file_id, '%f\t', variable_data{i_data});
                    elseif strcmp(BindVariableName,'vitesse')
                        fprintf(file_id, '%f\t', variable_data{i_data}*3.6);
                    elseif strcmp(BindVariableName,'voie')
                        fprintf(file_id, '%f\t', (variable_data{i_data}-1750)/1000);
                    elseif strcmp(BindVariableName,'angle_volant')
                        fprintf(file_id, '%f\t', variable_data{i_data}/7500*360);
                    end
                end
                fprintf(file_id, '\n');
                clear variable_data
                
                % situation before/after
                fprintf(file_id, '%s\t', id_participant);
                fprintf(file_id, '%s\t', id_scenario);
                fprintf(file_id, '%s\t', names_occurences{i_occurrence});
                fprintf(file_id, '%f\t', situation_occurences_before_startTimecodes{i_occurence});
                fprintf(file_id, '%f\t', situation_occurences_after_endTimecodes{i_occurence});
                fprintf(file_id, '%s\t', [situation_occurences_after_names{i_occurence}(1:end-8) situation_occurences_after_names{i_occurence}(end-1:end)]);
                variable_data = trip.getDataOccurencesInTimeInterval(BindDataName,situation_occurences_before_startTimecodes{i_occurence},situation_occurences_after_endTimecodes{i_occurence}).getVariableValues(BindVariableName);
                for i_data = 1:length(variable_data)
                    if strcmp(BindVariableName,'axeRegard_X') || strcmp(BindVariableName,'axeRegard_Y')
                        fprintf(file_id, '%f\t', variable_data{i_data});
                    elseif strcmp(BindVariableName,'vitesse')
                        fprintf(file_id, '%f\t', variable_data{i_data}*3.6);
                    elseif strcmp(BindVariableName,'voie')
                        fprintf(file_id, '%f\t', (variable_data{i_data}-1750)/1000);
                    elseif strcmp(BindVariableName,'angle_volant')
                        fprintf(file_id, '%f\t', variable_data{i_data}/7500*360);
                    end
                end
                fprintf(file_id, '\n');
                clear variable_data
            end
        end
    end
end
delete(trip);
end