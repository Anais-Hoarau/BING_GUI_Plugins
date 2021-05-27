function CapachienImportTableConditions(trip_file)
tic
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
metaInfo = trip.getMetaInformations();
%% Get Data_stim and Categorize it according to situations : obst_modif_carton, obst_modif_autre, obst_corps_carton, obst_corps_autre, obst_chien_carton, obst_chien_autre, obstacle, arret, demi_tour, parle_chien, parle, chien_doute, contre_chien, sans_anomalie
bindDatatName = 'timecode_data';
data_use.timecodes = trip.getAllDataOccurences(bindDatatName).getVariableValues('timecode')';
% var_list_to_delete = {'obst_modif_carton','obst_modif_autre','obst_corps_carton','obst_corps_autre','obst_chien_carton','obst_chien_autre','obstacle','arret','demi_tour','parle_chien','parle','chien_doute','contre_chien','sans_anomalie','sans_anomalie_elarg'};
% removeDataVariables(trip,bindDataName,var_list_to_delete);
var_list = {'obst_modif_carton','obst_modif_autre','obst_corps_carton','obst_corps_autre','obst_chien_carton','obst_chien_autre','obstacle','arret','demi_tour','parle_chien','parle','chien_doute','contre_chien','sans_anomalie','sans_anomalie_elarg'};
situation_list = {'obstacle','obstacle','obstacle','obstacle','obstacle','obstacle','','marche','marche','inter_verb','inter_verb','inter_act','inter_act',''};
modalities_list = {'modif_cart','modif_aut','crps_cart','crps_aut','ch_cart','ch_aut','','arret','demi-tour','parle_chien','parle','chien_doute','contre_chien',''};
result = zeros(length(data_use.timecodes),length(var_list));
for i_var = 1:length(var_list)
    bindVariableName = var_list{i_var};
    addDataVariables(trip,bindDatatName,bindVariableName);
    if ~strcmpi(bindVariableName,'sans_anomalie') && ~strcmpi(bindVariableName,'sans_anomalie_elarg') && ~strcmpi(bindVariableName,'obstacle')
        for i_line = 1:length(data_use.timecodes)
            if metaInfo.existSituation(situation_list(i_var))
                situationModality = trip.getSituationOccurencesAroundTime(situation_list{i_var},data_use.timecodes{i_line}).getVariableValues('Modalities');
                if ~isempty(situationModality) && strcmpi(situationModality{1},modalities_list{i_var})
                    result(i_line,i_var) = 1;
                end
            end
%             trip.setDataVariableAtTime(bindDatatName,bindVariableName,data_use.timecodes{i_stim},result(i_stim,i_var));
        end
    elseif strcmpi(bindVariableName,'obstacle')
        for i_line = 1:length(data_use.timecodes)
            if sum(result(i_line,1:6))>0
                result(i_line,i_var) = 1;
            end
%             trip.setDataVariableAtTime(bindDatatName,bindVariableName,data_use.timecodes{i_stim},result(i_stim,i_var));
        end
    elseif strcmpi(bindVariableName,'sans_anomalie')
        for i_line = 1:length(data_use.timecodes)
            if sum(result(i_line,:))==0
                result(i_line,i_var) = 1;
            end
%             trip.setDataVariableAtTime(bindDatatName,bindVariableName,data_use.timecodes{i_stim},result(i_stim,i_var));
        end
    elseif strcmpi(bindVariableName,'sans_anomalie_elarg')
        for i_line = 1:length(data_use.timecodes)
            if sum([sum(result(i_line,7:9)),sum(result(i_line,11:13))])==0
                result(i_line,i_var) = 1;
            end
            trip.setDataVariableAtTime(bindDatatName,bindVariableName,data_use.timecodes{i_line},result(i_line,i_var));
        end
    end
end
trip.setAttribute('import_table_cond', 'OK');
delete(trip)
toc
end

%% SUBFUNCTIONS
% add stim Data variable
function addDataVariables(trip,bindDataName,bindVariableName)
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable(bindDataName,bindVariableName)
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName(bindVariableName);
    bindVariable.setType('REAL');
    bindVariable.setUnit('');
    bindVariable.setComments('');
    trip.addDataVariable(bindDataName,bindVariable);
end
end