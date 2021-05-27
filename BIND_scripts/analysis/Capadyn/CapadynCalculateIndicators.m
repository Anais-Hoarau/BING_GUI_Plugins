function CapadynCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
metaInfo = trip.getMetaInformations();
if metaInfo.existSituation(cas_situation);
    trip.setIsBaseSituation(cas_situation,0);
    %% GET SITUATION DATA
    situationOccurences = trip.getAllSituationOccurences(cas_situation);
    startTime = cell2mat(situationOccurences.getVariableValues('startTimecode'));
    endTime = cell2mat(situationOccurences.getVariableValues('endTimecode'));
    
    %% SWITCH CASE AND APPLY CORRESPONDING PROCESS
    trip.setAttribute(['calcul_' message_name '_' nom_situation], '');
    if ~check_trip_meta(trip,['calcul_' message_name '_' nom_situation],'OK')
        disp(['calcul_' message_name '_' nom_situation])
        tic
        switch message_name
            case 'duree'
                addSituationDuration(trip, startTime, endTime, cas_situation)
                
            case 'situation_context'
                addSituationContext(trip, startTime, endTime, cas_situation)
                
            case 'situation_deviation'
                addSituationDeviation(trip, startTime, endTime, cas_situation)
                
            case 'situation_obstacle'
                addSituationObstacle(trip, startTime, endTime, cas_situation)
                
            case 'stim_context'
                addStimContext(trip, startTime, endTime, cas_situation)
                
            otherwise
                error(['Fonction non reconnue ! : ' message_name]);
        end
        toc
    end
    trip.setAttribute(['calcul_' message_name '_' nom_situation], 'OK');
    trip.setIsBaseSituation(cas_situation,1);
end
delete(trip);
end

%% CALCULATE FUNCTIONS
% calcul de la durée de la situation
function addSituationDuration(trip, startTime, endTime, cas_situation)
bindVariableName = 'duree';
situationDuration = endTime - startTime;
addSituationVariableIndicator(trip,cas_situation,bindVariableName)
trip.setSituationVariableAtTime(cas_situation, bindVariableName, startTime, endTime, situationDuration);
end

% calcul du nombre et de la durée des différents contextes situationnels :
% obst_modif_carton,obst_modif_autre,obst_corps_carton,obst_corps_autre,obst_chien_carton,obst_chien_autre,obstacle,arret,demi_tour,parle_chien,parle,chien_doute,contre_chien,sans_anomalie
function addSituationContext(trip, startTime, endTime, cas_situation)
bindVariablesNames = {'obst_can_cart','obst_can_rail','obst_can_aut','obst_crps_cart','obst_crps_rail','obst_crps_aut','obst_adapt_marche','obstacle','arret','sans_anomalie'};
variablesParameters = {'nb','duree'};
for i_var = 1:length(bindVariablesNames)
    bindVariableName = bindVariablesNames(i_var);
    occurences = cell2mat(trip.getDataOccurencesInTimeInterval('timecode_data',startTime,endTime).getVariableValues(bindVariableName))';
    occurences(end+1) = 0;
    result.nb = ceil(length(find(diff(occurences)))/2);
    result.duree = length(find(occurences))*0.04;
    for i_param = 1:length(variablesParameters)
        bindVariableParameter = variablesParameters{i_param};
        bindVariableNameConcat = [cell2mat(bindVariableName) '_' bindVariableParameter];
        addSituationVariableIndicator(trip,cas_situation,bindVariableNameConcat)
        trip.setSituationVariableAtTime(cas_situation, bindVariableNameConcat, startTime, endTime, result.(bindVariableParameter));
    end
end
end

% calcul du nombre et de la durée de passages dans les différentes zones de déviations :
%
function addSituationDeviation(trip, startTime, endTime, cas_situation)
bindVariablesNames = {'dev_0','dev_1_D','dev_2_D','dev_3_D','dev_1_G','dev_2_G','dev_3_G'};
bindVariablesNamesCoeff = {5,3,1,0,3,1,0};
variablesParameters = {'nb','duree'};
indice_dev = 0;
for i_var = 1:length(bindVariablesNames)
    bindVariableName = bindVariablesNames{i_var};
    bindVariablesNameCoeff = bindVariablesNamesCoeff{i_var};
    deviation_occurences = trip.getSituationOccurencesInTimeInterval('deviation',startTime,endTime);
    deviation_occurrences_startTimecodes = deviation_occurences.getVariableValues('startTimecode')';
    deviation_occurrences_endTimecodes = deviation_occurences.getVariableValues('endTimecode')';
    deviation_occurrences_modalities = deviation_occurences.getVariableValues('Modalities')';
    deviation.(bindVariableName).nb = 0;
    deviation.(bindVariableName).duree = 0;
    for i_occur = 1:length(deviation_occurrences_modalities)
        if strcmp(deviation_occurrences_modalities{i_occur},bindVariableName)
            deviation.(bindVariableName).nb = deviation.(bindVariableName).nb + 1;
            deviation.(bindVariableName).duree = deviation.(bindVariableName).duree + deviation_occurrences_endTimecodes{i_occur} - deviation_occurrences_startTimecodes{i_occur};
        end
    end
    for i_param = 1:length(variablesParameters)
        bindVariableParameter = variablesParameters{i_param};
        bindVariableNameConcat = [bindVariableName '_' bindVariableParameter];
        addSituationVariableIndicator(trip,cas_situation,bindVariableNameConcat)
        trip.setSituationVariableAtTime(cas_situation, bindVariableNameConcat, startTime, endTime, deviation.(bindVariableName).(bindVariableParameter));
    end
    indice_dev = indice_dev + deviation.(bindVariableName).duree/(endTime-startTime)*bindVariablesNameCoeff;
end
addSituationVariableIndicator(trip,cas_situation,'indice_dev')
trip.setSituationVariableAtTime(cas_situation, 'indice_dev', startTime, endTime, indice_dev);
end

% calcul de l'indice de gestion des obstacles :
%
function addSituationObstacle(trip, startTime, endTime, cas_situation)
obst_occur = trip.getSituationOccurencesInTimeInterval('obstacle',startTime,endTime).getVariableValues('Modalities')';
varNames = {'can','adapt_marche','crps','rien','can_rail','crps_rail'};

% matrix creation
obst_matrix = zeros(length(obst_occur),length(varNames));
for i_var = 1:length(varNames)
    for i_occur = 1:length(obst_occur)
        if strfind(obst_occur{i_occur}, varNames{i_var})
            obst_matrix(i_occur,i_var) = 1;
        end
    end
end

% filtrage rail
nb_canRail = 0;
nb_crpsRail = 0;
for i_occur = 1:length(obst_occur)
    if obst_matrix(i_occur,5)
        obst_matrix(i_occur,1:4) = obst_matrix(i_occur-1,1:4);
        nb_canRail = nb_canRail + 1;
    elseif obst_matrix(i_occur,6)
        obst_matrix(i_occur,1:4) = obst_matrix(i_occur-1,1:4);
        nb_crpsRail = nb_crpsRail + 1;
    end
end

% filtrage doublons
for i_var = 1:length(varNames)-3
    diff_pos = find(diff(obst_matrix(:,i_var))==1);
    diff_neg = find(diff(obst_matrix(:,i_var))==-1);
    ecarts_diff = diff_neg-diff_pos;
    if max(ecarts_diff)>1
        indices_ecarts_diff = find(ecarts_diff>1);
        for i_ecarts_diff = 1:length(indices_ecarts_diff)
            indice_doublons = indices_ecarts_diff(i_ecarts_diff);
        	nb_doublons = ecarts_diff(indice_doublons)-1;
            for i_doublon = 1:nb_doublons
                obst_matrix(diff_pos(indice_doublons)+1+i_doublon,i_var)=0;
                obst_matrix(diff_pos(indice_doublons)+1+i_doublon,4)=1;
            end
        end
    end
end

% Calcul indice obstacle : 1=can,2=adapt_marche,3=crps,4=rien,5=can_rail,6=crps_rail
ind_obst_sum = 0;
nb_obst = 0;
for i_occur = 1:length(obst_occur)-2
    if obst_matrix(i_occur,4) && obst_matrix(i_occur+1,1) &&  obst_matrix(i_occur+2,4)
        ind_obst_sum = ind_obst_sum + 5;
        nb_obst = nb_obst + 1;
    elseif obst_matrix(i_occur,4) && obst_matrix(i_occur+1,3) &&  obst_matrix(i_occur+2,4)
        nb_obst = nb_obst + 1;
    elseif obst_matrix(i_occur,4) && obst_matrix(i_occur+1,5) &&  obst_matrix(i_occur+2,4)
        ind_obst_sum = ind_obst_sum + 5;
        nb_obst = nb_obst + 1;
    end
end
for i_occur = 1:length(obst_occur)-3
    if obst_matrix(i_occur,4) && obst_matrix(i_occur+1,1) &&  obst_matrix(i_occur+2,3) &&  obst_matrix(i_occur+3,4)
        ind_obst_sum = ind_obst_sum + 1;
        nb_obst = nb_obst + 1;
    elseif obst_matrix(i_occur,4) && obst_matrix(i_occur+1,5) &&  obst_matrix(i_occur+2,6) &&  obst_matrix(i_occur+3,4)
        ind_obst_sum = ind_obst_sum + 1;
        nb_obst = nb_obst + 1;
    end
end
for i_occur = 1:length(obst_occur)-4
    if obst_matrix(i_occur,4) && obst_matrix(i_occur+1,1) &&  obst_matrix(i_occur+2,2) &&  obst_matrix(i_occur+3,3) && obst_matrix(i_occur+4,4)
        ind_obst_sum = ind_obst_sum + 3;
        nb_obst = nb_obst + 1;
    elseif obst_matrix(i_occur,4) && obst_matrix(i_occur+1,5) &&  obst_matrix(i_occur+2,2) &&  obst_matrix(i_occur+3,6) && obst_matrix(i_occur+4,4)
        ind_obst_sum = ind_obst_sum + 3;
        nb_obst = nb_obst + 1;
    end
end

% % remove columns
% removeSituationVariables(trip, cas_situation, {'nb_canRail','nb_crpsRail','nb_obst','indice_obst'});

addSituationVariableIndicator(trip,cas_situation,'nb_obst')
addSituationVariableIndicator(trip,cas_situation,'indice_obst')
addSituationVariableIndicator(trip,cas_situation,'nb_canRail')
addSituationVariableIndicator(trip,cas_situation,'nb_crpsRail')
trip.setSituationVariableAtTime(cas_situation, 'nb_obst', startTime, endTime, nb_obst);
trip.setSituationVariableAtTime(cas_situation, 'indice_obst', startTime, endTime, ind_obst_sum/nb_obst);
trip.setSituationVariableAtTime(cas_situation, 'nb_canRail', startTime, endTime, nb_canRail);
trip.setSituationVariableAtTime(cas_situation, 'nb_crpsRail', startTime, endTime, nb_crpsRail);
end

% calcul du nombre de réponses correctes et des temps de réponses dans les différents contextes situationnels :
% obst_modif_carton,obst_modif_autre,obst_corps_carton,obst_corps_autre,obst_chien_carton,obst_chien_autre,obstacle,arret,demi_tour,parle_chien,parle,chien_doute,contre_chien,sans_anomalie
function addStimContext(trip, startTime, endTime, cas_situation)
metaInfo = trip.getMetaInformations;
bindVariablesNames = {'obst_can_cart','obst_can_rail','obst_can_aut','obst_crps_cart','obst_crps_rail','obst_crps_aut','obst_adapt_marche','obstacle','arret','sans_anomalie','total'};
variablesParameters = {'nb_stim','nb_corRep','nb_expClic','nb_corClic','TR_corClic'};
if metaInfo.existEvent('stim_audio')
    occurences = trip.getEventOccurencesInTimeInterval('stim_audio',startTime,endTime);
    timecodes = cell2mat(occurences.getVariableValues('timecode'));
    for i_var = 1:length(bindVariablesNames)
        bindVariableName = bindVariablesNames{i_var};
        namesParameters = {bindVariableName,'resp_evaluat','resp_expect','clic_correct','resp_time'};
        for i_param = 1:length(namesParameters)
            if metaInfo.existEventVariable('stim_audio',namesParameters{i_param}) && ~strcmp(namesParameters{i_param},'clic_correct') && ~strcmp(namesParameters{i_param},'total')
                data_in.(namesParameters{i_param}) = cell2mat(occurences.getVariableValues(namesParameters{i_param}))';
            elseif strcmp(namesParameters{i_param},'clic_correct') && metaInfo.existEventVariable('stim_audio','resp_evaluat')
                data_in.(namesParameters{i_param}) = and(cell2mat(occurences.getVariableValues(namesParameters{i_param-2})),cell2mat(occurences.getVariableValues(namesParameters{i_param-1})));
            elseif strcmp(namesParameters{i_param},'total')
                data_in.(namesParameters{i_param}) = ones(length(timecodes));
            end
            data_out.(variablesParameters{i_param}) = 0;
        end
        if metaInfo.existEventVariable('stim_audio',namesParameters{i_param})
            for i_stim = 1:length(data_in.(namesParameters{i_param}))
                if data_in.(bindVariableName)(i_stim)
                    for i_param = 1:length(variablesParameters)
                        bindVariableParameter = variablesParameters{i_param};
                        data_out.(bindVariableParameter) = data_out.(bindVariableParameter) + data_in.(namesParameters{i_param})(i_stim);
                    end
                end
            end
        end
        for i_param = 1:length(variablesParameters)
            bindVariableNameConcat = [bindVariableName '_' variablesParameters{i_param}];
            addSituationVariableIndicator(trip,cas_situation,bindVariableNameConcat);
            trip.setSituationVariableAtTime(cas_situation, bindVariableNameConcat, startTime, endTime, data_out.(variablesParameters{i_param}));
        end
    end
end
end

%% SUBFUNCTIONS
% add stim Data variable
function addSituationVariableIndicator(trip,bindSituationName,bindVariableName)
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existSituationVariable(bindSituationName,bindVariableName)
    bindVariable = fr.lescot.bind.data.MetaSituationVariable();
    bindVariable.setName(bindVariableName);
    bindVariable.setType('REAL');
    bindVariable.setUnit('');
    bindVariable.setComments('');
    trip.addSituationVariable(bindSituationName,bindVariable);
end
end