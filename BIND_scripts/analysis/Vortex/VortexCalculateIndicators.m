function VortexCalculateIndicators(trip_file, cas_situation, message_name, HORODATAGE)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    
%     trip_file_splitted = strsplit(trip_file, '\');
%     participant_id = trip_file_splitted{end-2};
%     scenario_id = trip_file_splitted{end-1};
%     
%     %% Get threshold
%     load('\\vrlescot\THESE_GUILLAUME\VORTEX\Cardiaque_Vortex_Seuillage.mat')
%  
%     i_part = find(contains(CardiaqueVortexSeuillage(:,1),participant_id),1);
%     j_sce = find(contains(CardiaqueVortexSeuillage(1,:),scenario_id),1);
%     k_seuil = find(contains(CardiaqueVortexSeuillage(1,15:end),scenario_id),1)+14;
%     if ~isempty(CardiaqueVortexSeuillage(i_part,j_sce))
%         seuil_MPH = str2double(CardiaqueVortexSeuillage(i_part,k_seuil));
%     else
%         return
%     end
    
    %% GET SITUATION DATA
    situationOccurences = trip.getAllSituationOccurences(cas_situation);
    startTimes = situationOccurences.getVariableValues('startTimecode');
    endTimes = situationOccurences.getVariableValues('endTimecode');
        
    %% SWITCH CASE AND APPLY CORRESPONDING PROCESS
    for i = 1:1:length(startTimes)
        startTime = startTimes{i};
        endTime = endTimes{i};
%         trip.setAttribute(['calcul_' message_name '_' cas_situation], '');
        trip.setAttribute(['calcul_steeringAngleVar_' cas_situation], '');
        if ~check_trip_meta(trip,['calcul_' message_name '_' cas_situation],'OK')
            switch message_name
                
                case 'duree'
                    situationDuration(trip, startTime, endTime, cas_situation)
                    
                case 'nbEchantillons'
                    numberOfSamples(trip, startTime, endTime, cas_situation)
                    
                case 'frequency'
                    frequency(trip, startTime, endTime, cas_situation)
                    
                case 'tempsReactionDecel'
                    TRDecel(trip, startTime, endTime, cas_situation);
                    
                case 'vitesseMoyenne'
                    meanSpeed(trip, startTime, endTime, cas_situation)
                    
                case 'variationsVitesses'
                    speedVariations(trip, startTime, endTime, cas_situation)
                    
                case 'accelerationScenario'    
                    acceleration(trip)
                    
                case 'accelDecelMoyenne'
                    meanAccelDecel(trip, startTime, endTime, cas_situation)
                    
                case 'positionLateraleMoyenne'
                    meanLateralPosition(trip, startTime, endTime, cas_situation)
                    
                case 'variationsLaterales'
                    lateralPositionVariation(trip, startTime, endTime, cas_situation)
                    
                case 'steeringAngleVar'
                    steeringAngleVar(trip, startTime, endTime, cas_situation)
                    
                case 'RRintervalsScenario'
                    RRintervalsScenarioV2(trip, trip_file, seuil_MPH, HORODATAGE)
                    
                case 'HRinterpScenario'
                    HRinterpScenario(trip, trip_file)
                    
                case 'RRintervalMoyen'
                    addSituationVariable2Trip(trip,cas_situation,'RRinter_moy','REAL')
                    meanRRintervals(trip, startTime, endTime, cas_situation)
                    
                case 'VariationsRRinterval'
                    addSituationVariable2Trip(trip,cas_situation,'RRinter_var','REAL')
                    RRintervalsVariations(trip, startTime, endTime, cas_situation)

                case 'NbRRintCorrec'
                    addSituationVariable2Trip(trip,cas_situation,'nbRRintCorrec','REAL')
                    nbRRintCorrec(trip, startTime, endTime, cas_situation)
                    
                case 'HRinterpMoyen'
                    addSituationVariable2Trip(trip,cas_situation,'HRinterp_moy','REAL')
                    meanHRinterp(trip, startTime, endTime, cas_situation)
                    
                case 'VariationsHRinterp'
                    addSituationVariable2Trip(trip,cas_situation,'HRinterp_var','REAL')
                    HRinterpVariations(trip, startTime, endTime, cas_situation)
                    
                case 'EDASpontaneousResponse'
                    EDASpontaneousResponse(trip, trip_file, startTime, endTime, cas_situation)
                    
                otherwise
                    error(['Fonction non reconnue ! : ' message_name]);
            end
        end
    end
    
    trip.setAttribute(['calcul_' message_name '_' cas_situation], 'OK');
    delete(trip);
    
end
