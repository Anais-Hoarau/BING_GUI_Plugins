% création des tables de données
function createDataStructureFromMapping(trip, dataMappings)
    for i = 0:1:dataMappings.getLength() - 1
        dataMapping = dataMappings.item(i);
        bindDataName = char(dataMapping.getAttribute('bind_data_name'));
        disp(['Creating ' bindDataName ' and his variables']);
        bindDataComment = char(dataMapping.getAttribute('bind_data_comment'));
        bindDataFrequency = char(dataMapping.getAttribute('bind_data_frequency'));
        variableMappings = dataMapping.getElementsByTagName('variable_mapping');
        bindVariables = cell(1, variableMappings.length);
        for j = 0:1:variableMappings.getLength() - 1
            variableMapping =  variableMappings.item(j);
            bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
            bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
            bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
            bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));
            
            bindVariable = fr.lescot.bind.data.MetaDataVariable();
            bindVariable.setName(bindVariableName);
            bindVariable.setType(bindVariableType);
            bindVariable.setUnit(bindVariableUnit);
            bindVariable.setComments(bindVariableComments);
            bindVariables{j+1} = bindVariable;
        end
        bindData = fr.lescot.bind.data.MetaData();
        bindData.setName(bindDataName);
        bindData.setComments(bindDataComment);
        bindData.setFrequency(bindDataFrequency);
        bindData.setVariables(bindVariables);
        
        trip.addData(bindData);
    end
end