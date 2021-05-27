function CapachienCalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
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
            
        case 'stim_context'
            addStimContext(trip, startTime, endTime, cas_situation)
            
        otherwise
            error(['Fonction non reconnue ! : ' message_name]);
    end
    toc
end
trip.setAttribute(['calcul_' message_name '_' nom_situation], 'OK');
trip.setIsBaseSituation(cas_situation,1);
delete(trip);
end

%% CALCULATE FUNCTIONS
% calcul de la durée de la situation
function addSituationDuration(trip, startTime, endTime, cas_situation)
bindVariableName = 'duree';
situationDuration = endTime - startTime;
addSituationVariableContext(trip,cas_situation,bindVariableName)
trip.setSituationVariableAtTime(cas_situation, bindVariableName, startTime, endTime, situationDuration);
end

% calcul du nombre et de la durée des différents contextes situationnels :
% obst_modif_carton,obst_modif_autre,obst_corps_carton,obst_corps_autre,obst_chien_carton,obst_chien_autre,obstacle,arret,demi_tour,parle_chien,parle,chien_doute,contre_chien,sans_anomalie
function addSituationContext(trip, startTime, endTime, cas_situation)
bindVariablesNames = {'arret','demi_tour','contre_chien','chien_doute','parle_chien','parle','obst_modif_carton','obst_modif_autre','obst_corps_carton','obst_corps_autre','obst_chien_carton','obst_chien_autre','obstacle','sans_anomalie','sans_anomalie_elarg'};
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
        addSituationVariableContext(trip,cas_situation,bindVariableNameConcat)
        trip.setSituationVariableAtTime(cas_situation, bindVariableNameConcat, startTime, endTime, result.(bindVariableParameter));
    end
end
end

% calcul du nombre de réponses correctes et des temps de réponses dans les différents contextes situationnels :
% obst_modif_carton,obst_modif_autre,obst_corps_carton,obst_corps_autre,obst_chien_carton,obst_chien_autre,obstacle,arret,demi_tour,parle_chien,parle,chien_doute,contre_chien,sans_anomalie
function addStimContext(trip, startTime, endTime, cas_situation)
bindVariablesNames = {'arret','demi_tour','contre_chien','chien_doute','parle_chien','parle','obstacle','sans_anomalie','sans_anomalie_elarg','total'};
variablesParameters = {'nb_stim','nb_corRep','nb_expClic','nb_corClic','TR_corClic'};
variablesParameters_to_delete = {'nb_stim','nb_expRep','nb_corRep','nb_corClic','TR_corClic'};
for i_var = 1:length(bindVariablesNames)
    bindVariableName = bindVariablesNames{i_var};
    namesParameters = {bindVariableName,'resp_expect','resp_evaluat','resp_evaluat','resp_time'};
    for i_param = 1:length(namesParameters)
        var_list_to_delete{i_param+i_var*5-5} = [bindVariableName '_' variablesParameters_to_delete{i_param}];
    end
end
removeSituationVariables(trip,cas_situation,var_list_to_delete);
occurences = trip.getEventOccurencesInTimeInterval('stim_audio',startTime,endTime);
timecodes = cell2mat(occurences.getVariableValues('timecode'));
for i_var = 1:length(bindVariablesNames)
    bindVariableName = bindVariablesNames{i_var};
    namesParameters = {bindVariableName,'resp_evaluat','resp_expect','clic_correct','resp_time'};
    for i_param = 1:length(namesParameters)
        if strcmp(namesParameters{i_param},'total')
            data_in.(namesParameters{i_param}) = ones(length(timecodes));
        elseif strcmp(namesParameters{i_param},'clic_correct')
            data_in.(namesParameters{i_param}) = and(cell2mat(occurences.getVariableValues(namesParameters{i_param-2})),cell2mat(occurences.getVariableValues(namesParameters{i_param-1})));
        else
            data_in.(namesParameters{i_param}) = cell2mat(occurences.getVariableValues(namesParameters{i_param}))';
        end
        data_out.(variablesParameters{i_param}) = 0;
    end
    for i_stim = 1:length(data_in.(namesParameters{i_param}))
        if data_in.(bindVariableName)(i_stim)
            for i_param = 1:length(variablesParameters)
                bindVariableParameter = variablesParameters{i_param};
                data_out.(bindVariableParameter) = data_out.(bindVariableParameter) + data_in.(namesParameters{i_param})(i_stim);
            end
        end
    end
    for i_param = 1:length(variablesParameters)
        bindVariableNameConcat = [bindVariableName '_' variablesParameters{i_param}];
        addSituationVariableContext(trip,cas_situation,bindVariableNameConcat);
        trip.setSituationVariableAtTime(cas_situation, bindVariableNameConcat, startTime, endTime, data_out.(variablesParameters{i_param}));
    end
end
end

%% SUBFUNCTIONS
% add stim Data variable
function addSituationVariableContext(trip,bindSituationName,bindVariableName)
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