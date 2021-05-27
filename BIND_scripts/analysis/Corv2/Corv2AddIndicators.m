function Corv2AddIndicators(trip_file)
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
        
        % calculate "detection_centre" indicators
        cas_situation = 'detection_centre';
        nom_situation = 'detection_centre';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'tempsDetection', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Corv2CalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;

        % calculate "detection_centre" indicators
        cas_situation = 'detection_periph';
        nom_situation = 'detection_periph';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'tempsDetection', ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            Corv2CalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
end

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
trip.setAttribute('add_indicators', 'OK');
delete(trip);

end