% add situation variable to the trip
function addSituationVariable2Trip(trip,situation,variable,type,varargin)
    p = inputParser;
    addParameter(p,'unit','');
    addParameter(p,'comment','');
    parse(p,varargin{:});
    
    meta_info = trip.getMetaInformations;
    if meta_info.existSituation(situation) && ~meta_info.existSituationVariable(situation,variable)
        
        disp(['Adding variable ' variable ' to situation table ' situation ' in trip ' trip.getTripPath]);
        
        bindVariable = fr.lescot.bind.data.MetaSituationVariable();
        bindVariable.setName(variable);
        bindVariable.setType(type);
        bindVariable.setUnit(p.Results.unit);
        bindVariable.setComments(p.Results.comment);
        
        trip.addSituationVariable(situation, bindVariable);
    else
        disp([variable ' variable already exist']);
    end
end