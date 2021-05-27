function VortexAddIndicators(trip_file,HORODATAGE)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    
    %% GET TRIP DATA
    scenario_id = trip.getAttribute('id_scenario');
    
    %Identify cases conditions
    if strcmp(scenario_id,'BASELINE')
        scenario_case = '01BL';
    elseif strcmp(scenario_id,'EXPERIMENTAL')
        scenario_case = '02EXP';
    end
    
    if strcmp(messages_names, 'EDASpontaneousResponse') || strcmp(messages_names, 'steeringAngleVar')
    switch scenario_case
        %% 'BASELINE' CASE
        case '01BL'
            %% CALCULATE INDICATORS
            
            % calculate "scenario" indicators
            cas_situation = 'scenario_complet';
            messages_names = {
                'EDASpontaneousResponse', ...
                };
            for i_msg = 1:1:length(messages_names)
                message_name = messages_names{i_msg};
                VortexCalculateIndicators(trip_file, cas_situation, message_name)
            end
            clear messages_names;
        
            %% 'EXPERIMENTAL' CASE
        case '02EXP'
            
            if strcmp(messages_names, 'steeringAngleVar')
                %% CALCULATE INDICATORS
                
                % calculate "scenario" indicators
                cas_situation = 'scenario_complet';
                messages_names = {
                    'duree', 'nbEchantillons', 'frequency', ...
                    'vitesseMoyenne', 'variationsVitesses', 'accelerationScenario', 'accelDecelMoyenne', ...
                    'positionLateraleMoyenne', 'variationsLaterales', 'steeringAngleVar', ...
                    'RRintervalsScenario', 'HRinterpScenario'...
                    };
                for i_msg = 1:1:length(messages_names)
                    message_name = messages_names{i_msg};
                    VortexCalculateIndicators(trip_file, cas_situation, message_name, HORODATAGE)
                end
                clear messages_names;
                
                % calculate "feu_stop_on" indicators
                cas_situation = 'feu_stop_on';
                messages_names = {
                    'duree', 'nbEchantillons', 'frequency', 'tempsReactionDecel', ...
                    'vitesseMoyenne', 'variationsVitesses', 'accelDecelMoyenne', ...
                    'positionLateraleMoyenne', 'variationsLaterales', 'steeringAngleVar', ...
                    'RRintervalMoyen', 'VariationsRRinterval', 'NbRRintCorrec', 'HRinterpMoyen', 'VariationsHRinterp', ...
                    };
                for i_msg = 1:1:length(messages_names)
                    message_name = messages_names{i_msg};
                    VortexCalculateIndicators(trip_file, cas_situation, message_name)
                end
                clear messages_names;
                
                % calculate "feu_stop_on_before" indicators
                cas_situation = 'feu_stop_on_before';
                messages_names = {
                    'duree', 'nbEchantillons', 'frequency', ...
                    'vitesseMoyenne', 'variationsVitesses', 'accelDecelMoyenne', ...
                    'positionLateraleMoyenne', 'variationsLaterales', 'steeringAngleVar', ...
                    'RRintervalMoyen', 'VariationsRRinterval', 'NbRRintCorrec', 'HRinterpMoyen', 'VariationsHRinterp', ...
                    };
                for i_msg = 1:1:length(messages_names)
                    message_name = messages_names{i_msg};
                    VortexCalculateIndicators(trip_file, cas_situation, message_name)
                end
                clear messages_names;
                
                % calculate "feu_stop_on_after" indicators
                cas_situation = 'feu_stop_on_after';
                messages_names = {
                    'duree', 'nbEchantillons', 'frequency', 'tempsReactionDecel', ...
                    'vitesseMoyenne', 'variationsVitesses', 'accelDecelMoyenne', ...
                    'positionLateraleMoyenne', 'variationsLaterales', 'steeringAngleVar', ...
                    'RRintervalMoyen', 'VariationsRRinterval', 'NbRRintCorrec', 'HRinterpMoyen', 'VariationsHRinterp', ...
                    };
                for i_msg = 1:1:length(messages_names)
                    message_name = messages_names{i_msg};
                    VortexCalculateIndicators(trip_file, cas_situation, message_name)
                end
                clear messages_names;
            end
    end
    
    trip.setAttribute('add_indicators', 'OK');
    delete(trip);
    
end