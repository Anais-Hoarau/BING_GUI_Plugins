function BatchIndicatorsCocorico(MAIN_FOLDER)
MAIN_FOLDER = '\\vrlescot.ifsttar.fr\DKLESCOT\PROJETS ACTUELS\THESE_FRANCK\COCORICO\DONNEES_PARTICIPANTS';
CONFIGURATION_FOLDER = [MAIN_FOLDER '\FICHIERS_CONFIG'];
trip_list = dirrec(MAIN_FOLDER, '.trip');

%% ADD EVENTS, SITUATIONS AND CALCULATE INDICATORS

for i_trip = 1:1:length(trip_list)
    
    trip_file = trip_list{i_trip};
    reg_file = regexp(trip_file, '\');
    trip_name = trip_file(reg_file(end)+1:end);
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    scenario_id = trip.getAttribute('id_scenario');
    
    if strcmp(scenario_id,'BASELINE') || strcmp(scenario_id,'EXPERIMENTAL')
        scenario_case = 'BASEXP';
        %uncomment this 3 lines to calculate again
%         trip.setAttribute('add_events','');
%         trip.setAttribute('add_situations','');
        trip.setAttribute('add_indicators','');
    elseif strcmp(scenario_id,'INDUCTION')
        scenario_case = 'INDUCT';
        %uncomment this 3 lines to calculate again
%         trip.setAttribute('add_events','');
%         trip.setAttribute('add_situations','');
%         trip.setAttribute('add_indicators','');
        %continue
    end
    
    event_xml_name = ['COCORICO_' scenario_case '_Event_Mapping.xml'];
    situation_xml_name = ['COCORICO_' scenario_case '_Situation_Mapping.xml'];
    event_xml_file = [CONFIGURATION_FOLDER filesep 'FICHIERS_XML' filesep event_xml_name];
    situation_xml_file = [CONFIGURATION_FOLDER filesep 'FICHIERS_XML' filesep situation_xml_name];
    
    disp(['Vérification du fichier "' trip_name '"...'])
    
    add_event_needed = ~check_trip_meta(trip, 'add_events','OK');
    add_situation_needed = ~check_trip_meta(trip, 'add_situations','OK');
    add_indicators_needed = ~check_trip_meta(trip, 'add_indicators','OK');
    delete(trip);
    
    try
        disp(['------------------------------------ ' trip_name ' ------------------------------------']);
        
        if add_event_needed || add_situation_needed
            CocoricoAddEventsAndSituations(trip_file, event_xml_file, situation_xml_file)
        end
        
        if add_indicators_needed
            CocoricoAddIndicators(trip_file);
        end
        
    catch ME
        disp('Error caught, logging and skipping to next file');
        log = fopen('BatchIndicatorsCocorico.log', 'a+');
        fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' trip_name]);
        fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
        fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
        fclose(log);
    end
end
disp([num2str(length(trip_list)) ' trips traités.'])

end