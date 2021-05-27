% création des tables d'évènements
function createEventStructureFromMapping(trip, eventMappings)
    for i = 0:1:eventMappings.getLength() - 1
        eventMapping = eventMappings.item(i);
        bindEventName = char(eventMapping.getAttribute('bind_event_name'));
        meta_info = trip.getMetaInformations;
        if ~meta_info.existEvent(bindEventName)
            disp(['Creating event ' bindEventName ' and his variables']);
            bindEventComment = char(eventMapping.getAttribute('bind_event_comment'));
            variableMappings = eventMapping.getElementsByTagName('variable_mapping');
            bindEventIsBase =  logical(str2double(eventMapping.getAttribute('bind_event_isbase')));
            bindVariables = cell(1, variableMappings.length);
            for j = 0:1:variableMappings.getLength() - 1
                variableMapping =  variableMappings.item(j);
                bindVariableName = char(variableMapping.getAttribute('bind_variable_name'));
                bindVariableType = char(variableMapping.getAttribute('bind_variable_type'));
                bindVariableUnit = char(variableMapping.getAttribute('bind_variable_unit'));
                bindVariableComments = char(variableMapping.getAttribute('bind_variable_comments'));
                
                bindVariable = fr.lescot.bind.data.MetaEventVariable();
                bindVariable.setName(bindVariableName);
                bindVariable.setType(bindVariableType);
                bindVariable.setUnit(bindVariableUnit);
                bindVariable.setComments(bindVariableComments);
                bindVariables{j+1} = bindVariable;
            end
            bindEvent = fr.lescot.bind.data.MetaEvent;
            bindEvent.setName(bindEventName);
            bindEvent.setComments(bindEventComment);
            bindEvent.setVariables(bindVariables);
            
            trip.addEvent(bindEvent);
            disp(['--> set isBase ' bindEventName ' : ' num2str(bindEventIsBase)]);
            trip.setIsBaseEvent(bindEventName, bindEventIsBase);
        else
            disp([bindEventName ' event already exists and won''t be created again']);
        end
    end
end