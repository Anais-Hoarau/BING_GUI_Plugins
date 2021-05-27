% add data variable to the trip
function addDataVariable2Trip(trip,data,variable,type,varargin)
    p = inputParser;
    addParameter(p,'unit','');
    addParameter(p,'comment','');
    parse(p,varargin{:});
    
    meta_info = trip.getMetaInformations;
    if meta_info.existData(data) && ~meta_info.existDataVariable(data,variable)
        
        disp(['Adding variable ' variable ' to data table ' data ' in trip ' trip.getTripPath]);
        
        bindVariable = fr.lescot.bind.data.MetaDataVariable();
        bindVariable.setName(variable);
        bindVariable.setType(type);
        bindVariable.setUnit(p.Results.unit);
        bindVariable.setComments(p.Results.comment);
        
        trip.addDataVariable(data, bindVariable);
    else
        disp([variable ' variable already exist']);
    end
end