function CapadynImportTableConditions(trip_file)
tic
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
metaInfo = trip.getMetaInformations();
%% Get Data_stim and Categorize it according to situations : obst_modif_carton, obst_modif_autre, obst_corps_carton, obst_corps_autre, obst_chien_carton, obst_chien_autre, obstacle, arret, demi_tour, parle_chien, parle, chien_doute, contre_chien, sans_anomalie
bindDatatName = 'timecode_data';
data_use.timecodes = trip.getAllDataOccurences(bindDatatName).getVariableValues('timecode')';
% var_list_to_delete = {'obst_can_cart','obst_can_rail','obst_can_aut','obst_crps_cart','obst_crps_rail','obst_crps_aut','obst_adapt_marche','obstacle','arret','sans_anomalie'};
% removeDataVariables(trip,bindDataName,var_list_to_delete);
var_list = {'obst_can_cart','obst_can_rail','obst_can_aut','obst_crps_cart','obst_crps_rail','obst_crps_aut','obst_adapt_marche','obstacle','arret','sans_anomalie'};
situation_list = {'obstacle','obstacle','obstacle','obstacle','obstacle','obstacle','obstacle','','marche',''};
modalities_list = {'can_cart','can_rail','can_aut','crps_cart','crps_rail','crps_aut','adapt_marche','','arret',''};
result = zeros(length(data_use.timecodes),length(var_list));
for i_var = 1:length(var_list)
    bindVariableName = var_list{i_var};
    addDataVariables(trip,bindDatatName,bindVariableName);
    if ~strcmpi(bindVariableName,'sans_anomalie') && ~strcmpi(bindVariableName,'obstacle')
        for i_line = 1:length(data_use.timecodes)
            if metaInfo.existSituation(situation_list(i_var))
                situationModality = trip.getSituationOccurencesAroundTime(situation_list{i_var},data_use.timecodes{i_line}).getVariableValues('Modalities');
                if ~isempty(situationModality) && strcmpi(situationModality{1},modalities_list{i_var})
                    result(i_line,i_var) = 1;
                end
            end
            trip.setDataVariableAtTime(bindDatatName,bindVariableName,data_use.timecodes{i_line},result(i_line,i_var));
        end
    elseif strcmpi(bindVariableName,'obstacle')
        for i_line = 1:length(data_use.timecodes)
            if sum(result(i_line,1:7))>0
                result(i_line,i_var) = 1;
            end
            trip.setDataVariableAtTime(bindDatatName,bindVariableName,data_use.timecodes{i_line},result(i_line,i_var));
        end
    elseif strcmpi(bindVariableName,'sans_anomalie')
        for i_line = 1:length(data_use.timecodes)
            if sum(result(i_line,:))==0
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