% remove situation variables from trip file
function isBaseTable = removeSituationVariables(trip, situation, variablesList, forceIsBase)
    meta = trip.getMetaInformations;
    if meta.existSituation(situation)
        isBaseTable = isBase(meta.getMetaSituation(situation));
        if isBaseTable && forceIsBase, trip.setIsBaseSituation(situation, 0); end
        for i = 1:length(variablesList)
            variable = variablesList{i};
            disp(['Removing variable ' variable ' from situation table ' situation ' in trip ' trip.getTripPath]);
            if ~isBaseTable && meta.existSituationVariable(situation, variable)
                trip.removeSituationVariable(situation, variable);
            else
                disp([situation ' situation is locked by "isBase" protocole']);
            end
        end
        if isBaseTable && forceIsBase, trip.setIsBaseSituation(situation, 1); end
    else
        disp([situation ' situation doesn''t exist']);
    end
end