function Vagabon2AddIndicators(trip_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
%% GET TRIP DATA
scenario_id = trip.getAttribute('id_scenario');
delete(trip);

%Identify cases conditions
if strcmp(scenario_id,'BASELINE')
    scenario_case = '01BL';
elseif strcmp(scenario_id,'SANS_OBSTACLE')
    scenario_case = '02SO';
elseif strcmp(scenario_id,'AVEC_OBSTACLE')
    scenario_case = '03AO';
end

switch scenario_case
    %% 'SANS_OBSTACLE' CASE
    case '02SO'
        %% CALCULATE INDICATORS

        % calculate "self_report_before" indicators
        cas_situation = 'self_report_before';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "self_report_after" indicators
        cas_situation = 'self_report_after';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "rep_stop_before" indicators
        cas_situation = 'rep_stop_before';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "rep_stop_after" indicators
        cas_situation = 'rep_stop_after';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "conduite_libre" indicators
        cas_situation = 'conduite_libre';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', 'nbSelfReportByCL', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "tache_prospective" indicators
        cas_situation = 'tache_prospective';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "scenario" indicators
        cas_situation = 'scenario_complet';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', 'nbSelfReportByScenario', ... %'DMOScenario'
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'RRintervals', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        %% 'AVEC_OBSTACLE' CASE
    case '03AO'
        %% CALCULATE INDICATORS
        
        % calculate "self_report_before" indicators
        cas_situation = 'self_report_before';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "self_report_after" indicators
        cas_situation = 'self_report_after';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "rep_stop_before" indicators
        cas_situation = 'rep_stop_before';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "rep_stop_after" indicators
        cas_situation = 'rep_stop_after';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;

        % calculate "conduite_libre" indicators
        cas_situation = 'conduite_libre';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', 'nbSelfReportByCL', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "tache_prospective" indicators
        cas_situation = 'tache_prospective';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
        % calculate "obstacle" indicators
        cas_situation = 'obstacle';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'firstReaction', 'stopYN', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messagesNames;
        
        % calculate "obstacle_before" indicators
        cas_situation = 'obstacle_before';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'fixations', 'fixites' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messagesNames;

        % calculate "scenario" indicators
        cas_situation = 'scenario_complet';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency','nbSelfReportByScenario', ... %'DMOScenario'
            'vitesseMoyenne', 'variationsVitesses', 'variationsLaterales', ...
            'RRintervals'
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Vagabon2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messages_names;
        
end

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
trip.setAttribute('add_indicators', 'OK');
delete(trip);

end