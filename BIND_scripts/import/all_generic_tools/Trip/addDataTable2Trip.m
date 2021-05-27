% add Data table to the trip with initial variable "name"
function addDataTable2Trip(trip,data,varargin)
    p = inputParser;
    addParameter(p,'type','');
    addParameter(p,'frequency','');
    addParameter(p,'comment','');
    parse(p,varargin{:});
    
    meta_info = trip.getMetaInformations;
    if ~meta_info.existData(data) && ~meta_info.existDataVariable(data,'timecode')
        
        disp(['Adding data table ' data ' in trip ' trip.getTripPath]);
        
        bindVariable = fr.lescot.bind.data.MetaDataVariable();
        bindVariable.setName('timecode');
        bindVariable.setType('REAL');
        bindVariable.setUnit('s');
        bindVariable.setComments('');
        bindVariables{1} = bindVariable;
        
        bindData = fr.lescot.bind.data.MetaData();
        bindData.setName(data);
        bindData.setType(p.Results.type);
        bindData.setFrequency(p.Results.frequency);
        bindData.setComments(p.Results.comment);
        bindData.setVariables(bindVariables);
        
        trip.addData(bindData);
    else
        disp([data ' data table already exist']);
    end
end