function CapadynAddIndicators(trip_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
%% GET TRIP DATA
scenario_id = trip.getAttribute('id_scenario');
delete(trip);

% calculate "essai_complet" indicators for all trips
cas_situation = 'essai_complet';
nom_situation = 'essai_complet';
messages_names = {'duree', 'situation_context','situation_deviation','situation_obstacle'};
for i_msg = 1:1:length(messages_names)
    message_name = messages_names{i_msg};
    CapadynCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
end
clear messages_names;

% % calculate "essai_complet" indicators for trips with double task
% if ~isempty(strfind(scenario_id,'DT')) && exist([trip_file(1:end-4) 'csv'],'file')
%     cas_situation = 'essai_complet';
%     nom_situation = 'essai_complet';
%     messages_names = {'stim_context'};
%     for i_msg = 1:1:length(messages_names)
%         message_name = messages_names{i_msg};
%         CapadynCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
%     end
%     clear messages_names;
% end

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
trip.setAttribute('add_indicators', 'OK');
delete(trip);
end