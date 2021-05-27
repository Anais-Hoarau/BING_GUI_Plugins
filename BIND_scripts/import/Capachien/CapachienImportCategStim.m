function CapachienImportCategStim(trip_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
metaInfo = trip.getMetaInformations();
%% Get event_stim and Categorize it according to situations : obst_modif_carton, obst_modif_autre, obst_corps_carton, obst_corps_autre, obst_chien_carton, obst_chien_autre, obstacle, arret, demi_tour, parle_chien, parle, chien_doute, contre_chien, sans_anomalie
bindEventName = 'stim_audio';
data_use.timecodes = trip.getAllEventOccurences(bindEventName).getVariableValues('timecode')';
% var_list_to_delete = {'obst_modif_carton','obst_modif_autre','obst_corps_carton','obst_corps_autre','obst_chien_carton','obst_chien_autre','obstacle','arret','demi_tour','parle_chien','parle','chien_doute','contre_chien','rien','sans_anomalie'};
% removeEventVariables(trip,bindEventName,var_list_to_delete);
var_list = {'obst_modif_carton','obst_modif_autre','obst_corps_carton','obst_corps_autre','obst_chien_carton','obst_chien_autre','obstacle','arret','demi_tour','parle_chien','parle','chien_doute','contre_chien','sans_anomalie','sans_anomalie_elarg'};
situation_list = {'obstacle','obstacle','obstacle','obstacle','obstacle','obstacle','','marche','marche','inter_verb','inter_verb','inter_act','inter_act','',''};
modalities_list = {'modif_cart','modif_aut','crps_cart','crps_aut','ch_cart','ch_aut','','arret','demi-tour','parle_chien','parle','chien_doute','contre_chien','',''};
result = zeros(length(data_use.timecodes),length(var_list));
for i_var = 1:length(var_list)
    bindVariableName = var_list{i_var};
    addEventVariable_stim(trip,bindEventName,bindVariableName);
    if ~strcmpi(bindVariableName,'sans_anomalie') && ~strcmpi(bindVariableName,'sans_anomalie_elarg') && ~strcmpi(bindVariableName,'obstacle')
        for i_stim = 1:length(data_use.timecodes)
            if metaInfo.existSituation(situation_list(i_var))
                situationModality = trip.getSituationOccurencesAroundTime(situation_list{i_var},data_use.timecodes{i_stim}).getVariableValues('Modalities');
                if ~isempty(situationModality) && strcmpi(situationModality{:},modalities_list{i_var})
                    result(i_stim,i_var) = 1;
                end
            end
            trip.setEventVariableAtTime(bindEventName,bindVariableName,data_use.timecodes{i_stim},result(i_stim,i_var));
        end
    elseif strcmpi(bindVariableName,'obstacle')
        for i_stim = 1:length(data_use.timecodes)
            if sum(result(i_stim,1:6))>0
                result(i_stim,i_var) = 1;
            end
            trip.setEventVariableAtTime(bindEventName,bindVariableName,data_use.timecodes{i_stim},result(i_stim,i_var));
        end
    elseif strcmpi(bindVariableName,'sans_anomalie')
        for i_stim = 1:length(data_use.timecodes)
            if sum(result(i_stim,:))==0
                result(i_stim,i_var) = 1;
            end
            trip.setEventVariableAtTime(bindEventName,bindVariableName,data_use.timecodes{i_stim},result(i_stim,i_var));
        end
    elseif strcmpi(bindVariableName,'sans_anomalie_elarg')
        for i_stim = 1:length(data_use.timecodes)
            if sum([sum(result(i_stim,7:9)),sum(result(i_stim,11:13))])==0
                result(i_stim,i_var) = 1;
            end
            trip.setEventVariableAtTime(bindEventName,bindVariableName,data_use.timecodes{i_stim},result(i_stim,i_var));
        end
    end
end
trip.setAttribute('import_Categ_Stim', 'OK');
delete(trip)
end

%% SUBFUNCTIONS
% add stim event variable
function addEventVariable_stim(trip,bindEventName,bindVariableName)
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existEventVariable(bindEventName,bindVariableName)
    bindVariable = fr.lescot.bind.data.MetaEventVariable();
    bindVariable.setName(bindVariableName);
    bindVariable.setType('REAL');
    bindVariable.setUnit('');
    bindVariable.setComments('');
    trip.addEventVariable(bindEventName,bindVariable);
end
end