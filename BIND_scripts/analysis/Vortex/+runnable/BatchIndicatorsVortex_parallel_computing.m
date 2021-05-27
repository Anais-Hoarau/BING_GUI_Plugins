function BatchIndicatorsVortex_parallel_computing(MAIN_FOLDER)
    HORODATAGE = char(datetime('now','Format','yyMMdd_HHmm'));
    MAIN_FOLDER = '\\vrlescot\THESE_GUILLAUME\VORTEX\Data\TESTS';
    CONFIGURATION_FOLDER = '\\vrlescot\THESE_GUILLAUME\VORTEX\Data\~FICHIERS_CONFIG';
    mkdir([MAIN_FOLDER filesep '~DATA_EXPORT' filesep 'FIGURES']);
    trip_list = dirrec(MAIN_FOLDER, '.trip')';
    
    %% ADD EVENTS, SITUATIONS AND CALCULATE INDICATORS
    
    parfor i_trip = 1:length(trip_list)
        
        trip_file = trip_list{i_trip};
        reg_file = regexp(trip_file, '\');
        trip_name = trip_file(reg_file(end)+1:end);
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        scenario_id = trip.getAttribute('id_scenario');
        
        if strcmp(scenario_id,'BASELINE')
            scenario_case = '01BL';
            %         %uncomment this 3 lines to calculate again
            %         trip.setAttribute('add_events','');
            %         trip.setAttribute('add_situations','');
            %         trip.setAttribute('add_indicators','');
        elseif strcmp(scenario_id,'EXPERIMENTAL')
            scenario_case = '02EXP';
            %uncomment this 3 lines to calculate again
%             trip.setAttribute('add_events','');
%             trip.setAttribute('add_situations','');
            trip.setAttribute('add_indicators','');
        end
        
        event_xml_name = ['VORTEX_' scenario_case '_Event_Mapping.xml'];
        situation_xml_name = ['VORTEX_' scenario_case '_Situation_Mapping.xml'];
        event_xml_file = [CONFIGURATION_FOLDER filesep 'FICHIERS_XML' filesep event_xml_name];
        situation_xml_file = [CONFIGURATION_FOLDER filesep 'FICHIERS_XML' filesep situation_xml_name];
        
        disp(['Vérification du fichier "' trip_name '"...'])
        
        add_event_needed = ~check_trip_meta(trip, 'add_events','OK');
        add_situation_needed = ~check_trip_meta(trip, 'add_situations','OK');
        add_indicators_needed = ~check_trip_meta(trip, 'add_indicators','OK');
        delete(trip);
        
        try
            disp(['------------------------------------ ' trip_name ' ------------------------------------']);
            if ~strcmp(scenario_id,'BASELINE')
                
                if add_event_needed || add_situation_needed
                    VortexAddEventsAndSituations(trip_file, event_xml_file, situation_xml_file)
                end
                
                if add_indicators_needed
                    VortexAddIndicators(trip_file,HORODATAGE);
                end
                
            end
            
        catch ME
            disp('Error caught, logging and skipping to next file');
            log = fopen('BatchIndicatorsVortex.log', 'a+');
            fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' trip_name]);
            fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
            fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
            fclose(log);
        end
    end
    disp([num2str(length(trip_list)) ' trips traités.'])
    
end