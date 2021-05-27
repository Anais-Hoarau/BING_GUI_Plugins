% add event variable to the trip
function addEventVariable2Trip(trip,event,variable,type,varargin)
    p = inputParser;
    addParameter(p,'unit','');
    addParameter(p,'comment','');
    parse(p,varargin{:});
    
    meta_info = trip.getMetaInformations;
    if meta_info.existEvent(event) && ~meta_info.existEventVariable(event,variable)
        
        disp(['Adding variable ' variable ' to event table ' event ' in trip ' trip.getTripPath]);
        
        bindVariable = fr.lescot.bind.data.MetaEventVariable();
        bindVariable.setName(variable);
        bindVariable.setType(type);
        bindVariable.setUnit(p.Results.unit);
        bindVariable.setComments(p.Results.comment);
        
        trip.addEventVariable(event, bindVariable);
    else
        disp([variable ' variable already exist']);
    end
end