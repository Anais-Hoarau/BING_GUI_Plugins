% création des tables de situations
function createSituationStructureFromMapping(trip, situationMappings)
    for i = 0:1:situationMappings.getLength() - 1
        situationMapping = situationMappings.item(i);
        bindSituationName = char(situationMapping.getAttribute('bind_situation_name'));
        meta_info = trip.getMetaInformations;
        if ~meta_info.existSituation(bindSituationName)
            disp(['Creating situation ' bindSituationName ' and his variables']);
            bindSituationComment = char(situationMapping.getAttribute('bind_situation_comment'));
            variableMappings = situationMapping.getElementsByTagName('variable_mapping');
            bindSituationIsBase =  logical(str2double(situationMapping.getAttribute('bind_situation_isbase')));
            bindVariables = cell(1, variableMappings.length);
            for j = 0:1:variableMappings.getLength() - 1
                variableMapping =  variableMappings.item(j);
                bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
                bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
                bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
                bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));
                
                bindVariable = fr.lescot.bind.data.MetaSituationVariable();
                bindVariable.setName(bindVariableName);
                bindVariable.setType(bindVariableType);
                bindVariable.setUnit(bindVariableUnit);
                bindVariable.setComments(bindVariableComments);
                bindVariables{j+1} = bindVariable;
            end
            bindSituation = fr.lescot.bind.data.MetaSituation;
            bindSituation.setName(bindSituationName);
            bindSituation.setComments(bindSituationComment);
            bindSituation.setVariables(bindVariables);
            
            trip.addSituation(bindSituation);
            disp(['--> set isBase ' bindSituationName ' : ' num2str(bindSituationIsBase)]);
            trip.setIsBaseSituation(bindSituationName, bindSituationIsBase);
        else
            disp([bindSituationName ' situation already exists and won''t be created again']);
        end
    end
end