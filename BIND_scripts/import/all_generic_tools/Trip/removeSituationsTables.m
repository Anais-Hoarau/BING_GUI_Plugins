% remove situations tables from trip file
function isBaseTable = removeSituationsTables(trip, situationsList, forceIsBase)
    meta = trip.getMetaInformations;
    for i = 1:length(situationsList)
        situation = situationsList{i};
        if meta.existSituation(situation)
            disp(['Removing situation ' situation ' from trip ' trip.getTripPath]);
            isBaseTable = isBase(meta.getMetaSituation(situation));
            if isBaseTable && forceIsBase, trip.setIsBaseSituation(situation, 0); end
            if ~isBaseTable
                trip.removeSituation(situation);
            elseif ~forceIsBase
                disp([situation ' situation is locked by "isBase" protocole']);
            end
            if isBaseTable && forceIsBase, trip.setIsBaseSituation(situation, 1); end
        else
            disp([situation ' situation doesn''t exist']);
        end
    end
end