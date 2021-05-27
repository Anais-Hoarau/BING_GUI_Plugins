% add Event table to the trip with initial variable "name"
function addEventTable2Trip(trip,event,varargin)
    p = inputParser;
    addParameter(p,'comment','');
    parse(p,varargin{:});
    
    meta_info = trip.getMetaInformations;
    if ~meta_info.existEvent(event) && ~meta_info.existEventVariable(event,'timecode')
        
        disp(['Adding event table ' event ' in trip ' trip.getTripPath]);
        
        bindVariable = fr.lescot.bind.data.MetaEventVariable();
        bindVariable.setName('timecode');
        bindVariable.setType('TEXT');
        bindVariable.setUnit('');
        bindVariable.setComments('');
        bindVariables{1} = bindVariable;
        
        bindEvent = fr.lescot.bind.data.MetaEvent();
        bindEvent.setName(event);
        bindEvent.setComments(p.Results.comment);
        bindEvent.setVariables(bindVariables);
        
        trip.addEvent(bindEvent);
    else
        disp([event ' event table already exist']);
    end
end