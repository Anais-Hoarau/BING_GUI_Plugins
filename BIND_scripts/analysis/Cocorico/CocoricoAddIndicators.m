function CocoricoAddIndicators(trip_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
%% GET TRIP DATA
scenario_id = trip.getAttribute('id_scenario');
delete(trip);

%Identify cases conditions
if strcmp(scenario_id,'BASELINE') || strcmp(scenario_id,'EXPERIMENTAL')
    scenario_case = 'BASEXP';
elseif strcmp(scenario_id,'INDUCTION')
    scenario_case = 'INDUCT';
end

switch scenario_case
    %% 'BASELINE' AND 'EXPERIMENTAL' CASES
    case 'BASEXP'
        %% CALCULATE INDICATORS
        
        % calculate "scenario" indicators
        cas_situation = 'scenario_complet';
        nom_situation = 'scenario';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'DIVScenario', 'DMOScenario', ...
            'TIVmoyen', 'variationsTIV', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'accelDecelMoyenne', 'nbACoups', 'enfoncementPedaleMean&Max',...
            'positionLateraleMoyenne', 'variationsLaterales', ...
            'franchissementsScenario', 'franchissementsParSituation', ...
            'fixations' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CocoricoCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "suivi" indicators
        cas_situation = 'suivi_cible';
        nom_situation = 'suivi';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'performance', 'TIVmoyen', 'variationsTIV', 'DIVmoyen', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'accelDecelMoyenne', 'nbACoups', 'enfoncementPedaleMean&Max', ...
            'positionLateraleMoyenne', 'variationsLaterales', ...
            'franchissementsParSituation', ...
            'fixations' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CocoricoCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "pieton" indicators
        cas_situation = 'pieton';
        nom_situation = 'AOI';
        messages_names = {
            'fixations', 'fixationsAOI'  ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CocoricoCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        %% 'INDUCTION' CASE
    case 'INDUCT'
        %% CALCULATE INDICATORS
        
        % calculate "scenario" indicators
        cas_situation = 'scenario_complet';
        nom_situation = 'scenario';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'DIVScenario', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'accelDecelMoyenne',  'nbACoups', 'enfoncementPedaleMean&Max', ...
            'positionLateraleMoyenne', 'variationsLaterales', ...
            'franchissementsScenario', 'franchissementsParSituation' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CocoricoCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "section_libre" indicators
        cas_situation = 'section_libre';
        nom_situation = 'SL';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'accelDecelMoyenne',  'nbACoups', 'enfoncementPedaleMean&Max', ...
            'positionLateraleMoyenne', 'variationsLaterales', ...
            'franchissementsParSituation' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CocoricoCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
        % calculate "section_contrainte" indicators
        cas_situation = 'section_contrainte';
        nom_situation = 'SC';
        messages_names = {
            'duree', 'nbEchantillons', 'frequency', ...
            'TIVmoyen', 'DIVmoyen', ...
            'vitesseMoyenne', 'variationsVitesses', ...
            'accelDecelMoyenne', 'nbACoups', 'enfoncementPedaleMean&Max', ...
            'positionLateraleMoyenne', 'variationsLaterales', ...
            'franchissementsParSituation' ...
            };
        for i_msg = 1:1:length(messages_names)
            message_name = messages_names{i_msg};
            CocoricoCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
        end
        clear messages_names;
        
end

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);

%% Calculate indicators Tobii with new AOI
if trip.getMetaInformations().existData('tobii')
    
    addFixations_scenario(trip, 0, cell2mat(trip.getAllSituationOccurences('scenario_complet').getVariableValues('endTimecode')));
    load('\\vrlescot.ifsttar.fr\DKLESCOT\PROJETS ACTUELS\THESE_FRANCK\COCORICO\DONNEES_PARTICIPANTS\AOI_limits.mat')
    trip_file_path_splited = strsplit(trip_file, '\');
    trip_file_ID = trip_file_path_splited{end}(1:3);
    
    % get AOI limits
    for i_limit = 1:length(AOI_limits)
        if strcmpi(AOI_limits{i_limit}, trip_file_ID)
            AOI_limits_idx = i_limit;
            break
        end
    end
    AOI_limit_left = AOI_limits{AOI_limits_idx, 2};
    AOI_limit_center = AOI_limits{AOI_limits_idx, 3};
    AOI_limit_right = AOI_limits{AOI_limits_idx, 4};
    
    % get tobii data
    startTimecodes = trip.getAllSituationOccurences('suivi_cible').getVariableValues('startTimecode');
    endTimecodes = trip.getAllSituationOccurences('suivi_cible').getVariableValues('endTimecode');
    for i_suivi = 1:length(startTimecodes)
        startTime = startTimecodes{i_suivi};
        endTime = endTimecodes{i_suivi};
        GazePlotX.(['suivi_' num2str(i_suivi)]) = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime).getVariableValues('axeRegard_X')';
        fix.(['suivi_' num2str(i_suivi)]) = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime).getVariableValues('fixations')';
        
        mask_AOI_left = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        mask_AOI_center = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        mask_AOI_right = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        mask_AOI_left_fix = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        mask_AOI_center_fix = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        mask_AOI_right_fix = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        mask_AOI_left_fix_duration = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        mask_AOI_center_fix_duration = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        mask_AOI_right_fix_duration = zeros(1,length(GazePlotX.(['suivi_' num2str(i_suivi)])))';
        
        for i_GPX = 1:length(GazePlotX.(['suivi_' num2str(i_suivi)]))
            GPX = GazePlotX.(['suivi_' num2str(i_suivi)]);
            FIX = [{0}, fix.(['suivi_' num2str(i_suivi)])']';
            if and(GPX{i_GPX} > AOI_limit_left, GPX{i_GPX} < AOI_limit_left + 110)
                mask_AOI_left(i_GPX) = 1;
            elseif and(GPX{i_GPX} > AOI_limit_center, GPX{i_GPX} < AOI_limit_center + 110)
                mask_AOI_center(i_GPX) = 1;
            elseif and(GPX{i_GPX} > AOI_limit_right, GPX{i_GPX} < AOI_limit_right + 110)
                mask_AOI_right(i_GPX) = 1;
            end
            if and(and(and(GPX{i_GPX} > AOI_limit_left, GPX{i_GPX} < AOI_limit_left + 110), FIX{i_GPX+1} == 1), FIX{i_GPX} == 0)
                mask_AOI_left_fix(i_GPX) = 1;
            elseif and(and(and(GPX{i_GPX} > AOI_limit_center, GPX{i_GPX} < AOI_limit_center + 110), FIX{i_GPX+1} == 1), FIX{i_GPX} == 0)
                mask_AOI_center_fix(i_GPX) = 1;
            elseif and(and(and(GPX{i_GPX} > AOI_limit_right, GPX{i_GPX} < AOI_limit_right + 110), FIX{i_GPX+1} == 1), FIX{i_GPX} == 0)
                mask_AOI_right_fix(i_GPX) = 1;
            end
            if and(and(GPX{i_GPX} > AOI_limit_left, GPX{i_GPX} < AOI_limit_left + 110), FIX{i_GPX+1} == 1)
                mask_AOI_left_fix_duration(i_GPX) = 1;
            elseif and(and(GPX{i_GPX} > AOI_limit_center, GPX{i_GPX} < AOI_limit_center + 110), FIX{i_GPX+1} == 1)
                mask_AOI_center_fix_duration(i_GPX) = 1;
            elseif and(and(GPX{i_GPX} > AOI_limit_right, GPX{i_GPX} < AOI_limit_right + 110), FIX{i_GPX+1} == 1)
                mask_AOI_right_fix_duration(i_GPX) = 1;
            end
        end
        
        nbEch_AOILeft = sum(mask_AOI_left);
        nbEch_AOICenter = sum(mask_AOI_center);
        nbEch_AOIRight = sum(mask_AOI_right);
        dureeEch_AOILeft = nbEch_AOILeft*0.033;
        dureeEch_AOICenter = nbEch_AOICenter*0.033;
        dureeEch_AOIRight = nbEch_AOIRight*0.033;
        nbFix_AOILeft = sum(mask_AOI_left_fix);
        nbFix_AOICenter = sum(mask_AOI_center_fix);
        nbFix_AOIRight = sum(mask_AOI_right_fix);
        dureeFix_AOILeft = sum(mask_AOI_left_fix_duration)*0.033;
        dureeFix_AOICenter = sum(mask_AOI_center_fix_duration)*0.033;
        dureeFix_AOIRight = sum(mask_AOI_right_fix_duration)*0.033;
        
        addSituationVariable2Trip(trip, 'suivi_cible', 'nbEch_AOILeft', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'nbEch_AOICenter', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'nbEch_AOIRight', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'dureeEch_AOILeft', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'dureeEch_AOICenter', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'dureeEch_AOIRight', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'nbFix_AOILeft', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'nbFix_AOICenter', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'nbFix_AOIRight', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'dureeFix_AOILeft', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'dureeFix_AOICenter', 'REAL');
        addSituationVariable2Trip(trip, 'suivi_cible', 'dureeFix_AOIRight', 'REAL');
        
        trip.setSituationVariableAtTime('suivi_cible', 'nbEch_AOILeft', startTime, endTime, nbEch_AOILeft);
        trip.setSituationVariableAtTime('suivi_cible', 'nbEch_AOICenter', startTime, endTime, nbEch_AOICenter);
        trip.setSituationVariableAtTime('suivi_cible', 'nbEch_AOIRight', startTime, endTime, nbEch_AOIRight);
        trip.setSituationVariableAtTime('suivi_cible', 'dureeEch_AOILeft', startTime, endTime, dureeEch_AOILeft);
        trip.setSituationVariableAtTime('suivi_cible', 'dureeEch_AOICenter', startTime, endTime, dureeEch_AOICenter);
        trip.setSituationVariableAtTime('suivi_cible', 'dureeEch_AOIRight', startTime, endTime, dureeEch_AOIRight);
        trip.setSituationVariableAtTime('suivi_cible', 'nbFix_AOILeft', startTime, endTime, nbFix_AOILeft);
        trip.setSituationVariableAtTime('suivi_cible', 'nbFix_AOICenter', startTime, endTime, nbFix_AOICenter);
        trip.setSituationVariableAtTime('suivi_cible', 'nbFix_AOIRight', startTime, endTime, nbFix_AOIRight);
        trip.setSituationVariableAtTime('suivi_cible', 'dureeFix_AOILeft', startTime, endTime, dureeFix_AOILeft);
        trip.setSituationVariableAtTime('suivi_cible', 'dureeFix_AOICenter', startTime, endTime, dureeFix_AOICenter);
        trip.setSituationVariableAtTime('suivi_cible', 'dureeFix_AOIRight', startTime, endTime, dureeFix_AOIRight);
    
    end
end
trip.setAttribute('add_indicators', 'OK');
delete(trip);

end

% calculate fixations quantities and durations
function addFixations_scenario(trip, startTime, endTime)
tobiiOccurences = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime);
timecodes = tobiiOccurences.getVariableValues('timecode');
dist_mouv_ocu = [NaN, cell2mat(tobiiOccurences.getVariableValues('DMO'))];

fixations = num2cell(zeros(1,length(dist_mouv_ocu)));
for i = 1:length(dist_mouv_ocu)-2
    if (dist_mouv_ocu(i+2) - dist_mouv_ocu(i)) < 6 && (dist_mouv_ocu(i+1) - dist_mouv_ocu(i)) < 6
        fixations{i} = 1;
    end
end

trip.setIsBaseData('tobii', 0);
addDataVariable2Trip(trip, 'tobii', 'fixations', 'REAL');
trip.setBatchOfTimeDataVariablePairs('tobii', 'fixations', [timecodes', fixations']');
trip.setIsBaseData('tobii', 1);

end