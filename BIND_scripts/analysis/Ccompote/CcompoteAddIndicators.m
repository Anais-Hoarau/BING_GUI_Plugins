function CcompoteAddIndicators(trip_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
%% GET TRIP DATA
scenario_id = trip.getAttribute('id_scenario');
delete(trip);

%Identify cases conditions
if strcmp(scenario_id,'EXPERIMENTAL')
    scenario_case = 'BASEXP';
end

switch scenario_case
    %% 'EXPERIMENTAL' CASE
    case 'BASEXP'
        %% CALCULATE INDICATORS
        
        % calculate "scenario" indicators
        cas_situation = 'scenario_complet';
        nom_situation = 'scenario';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'DIVScenario', 'DIVScenarioV2', 'AngleVolantEnDegres', ...
            'TIVMin', 'TIVMoy', 'TIVVar', ...
            'DIVMin', 'DIVMoy', 'DIVVar', ...
            'positionLateraleMoy', 'positionLateraleVar', ...
            'AngleVolantVar', ...
            'franchissementsScenario2', 'franchissementsParSituation', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CcompoteCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "essais" indicators
        cas_situation = 'essais';
        nom_situation = 'essais';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'TIVMin', 'TIVMoy', 'TIVVar', 'TIVEvent', ...
            'DIVMin', 'DIVMoy', 'DIVVar', 'DIVEvent', ...
            'positionLateraleMoy', 'positionLateraleVar', ...
            'tempsReactionDecel', 'AngleVolantVar' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CcompoteCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "essais_A" indicators
        cas_situation = 'essais_A';
        nom_situation = 'essais_A';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'TIVMin', 'TIVMoy', 'TIVVar', 'TIVEvent', ...
            'DIVMin', 'DIVMoy', 'DIVVar', 'DIVEvent', ...
            'positionLateraleMoy', 'positionLateraleVar', ...
            'tempsReactionDecel', 'AngleVolantVar' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CcompoteCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "essais_B" indicators
        cas_situation = 'essais_B';
        nom_situation = 'essais_B';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'TIVMin', 'TIVMoy', 'TIVVar', 'TIVEvent', ...
            'DIVMin', 'DIVMoy', 'DIVVar', 'DIVEvent', ...
            'positionLateraleMoy', 'positionLateraleVar', ...
            'tempsReactionDecel', 'AngleVolantVar' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CcompoteCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "essais_C" indicators
        cas_situation = 'essais_C';
        nom_situation = 'essais_C';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'TIVMin', 'TIVMoy', 'TIVVar', 'TIVEvent', ...
            'DIVMin', 'DIVMoy', 'DIVVar', 'DIVEvent', ...
            'positionLateraleMoy', 'positionLateraleVar', ...
            'tempsReactionDecel', 'AngleVolantVar' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CcompoteCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "feux_stop" indicators
        cas_situation = 'feux_stop';
        nom_situation = 'feux_stop';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'TIVMin', 'TIVMoy', 'TIVVar', ...
            'DIVMin', 'DIVMoy', 'DIVVar', ...
            'positionLateraleMoy', 'positionLateraleVar', ...
            'tempsReactionDecel', 'AngleVolantVar' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CcompoteCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;

end

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
trip.setAttribute('add_indicators', 'OK');
delete(trip);

end