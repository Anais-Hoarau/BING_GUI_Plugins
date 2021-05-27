function RCE2AddIndicators(trip_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
%% GET TRIP DATA
scenario_id = trip.getAttribute('id_scenario');
delete(trip);

%Identify cases conditions
scenario_cases = {'PILAUT', 'AUDVSP'};
if strcmp(scenario_id, scenario_cases{1})
    scenario_case = scenario_cases{1};
else
    scenario_case = scenario_cases{2};
end

switch scenario_case
    %% 'PILAUT' CASE
    case 'PILAUT'
        %% CALCULATE INDICATORS
        
        % calculate "scenario" indicators
        cas_situation = 'scenario';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'franchissementsScenario', 'franchissementsParSituation' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            RCE2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messagesNames;
        
        % calculate "pilote_auto" indicators
        cas_situation = 'pilote_auto';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'TIVmin', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'franchissementsParSituation' ...
            'firstReaction', 'stopYN', 'successYN', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            RCE2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messagesNames;
        
    %% 'AUDVSP' CASE
    case 'AUDVSP'        
        %% CALCULATE INDICATORS
        
        % calculate "scenario" indicators
        cas_situation = 'scenario';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'accelDecelMoyenne',  'nbACoups', 'enfoncementPedaleMean&Max', ...
            'variationsLaterales', ...
            'SteeringAngleVar', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            RCE2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messagesNames;
        
        % calculate "stimulation_avant" indicators
        cas_situation = 'stimulation_avant';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'accelDecelMoyenne',  'nbACoups', 'enfoncementPedaleMean&Max', ...
            'variationsLaterales', ...
            'SteeringAngleVar', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            RCE2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messagesNames;
        
        % calculate "stimulation_apres" indicators
        cas_situation = 'stimulation_apres';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'accelDecelMoyenne', 'nbACoups', 'enfoncementPedaleMean&Max', ...
            'variationsLaterales', ...
            'SteeringAngleVar', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            RCE2CalculateIndicators(trip_file, cas_situation, message_name)
        end
        clear messagesNames;
        
end

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
trip.setAttribute('add_indicators', 'OK');
delete(trip);

end