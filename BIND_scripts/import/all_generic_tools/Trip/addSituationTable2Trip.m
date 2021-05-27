% add situation table to the trip with initial variable "name"
function addSituationTable2Trip(trip,situation,varargin)
    p = inputParser;
    addParameter(p,'comment','');
    parse(p,varargin{:});
    
    meta_info = trip.getMetaInformations;
    if ~meta_info.existSituation(situation) && ~meta_info.existSituationVariable(situation,'startTimecode')
        
        disp(['Adding situation table ' situation ' in trip ' trip.getTripPath]);
        
        bindVariable = fr.lescot.bind.data.MetaSituationVariable();
        bindVariable.setName('startTimecode');
        bindVariable.setType('TEXT');
        bindVariable.setUnit('');
        bindVariable.setComments('');
        bindVariables{1} = bindVariable;
        
        bindSituation = fr.lescot.bind.data.MetaSituation();
        bindSituation.setName(situation);
        bindSituation.setComments(p.Results.comment);
        bindSituation.setVariables(bindVariables);
        
        trip.addSituation(bindSituation);
    else
        disp([situation ' situation table already exist']);
    end
end