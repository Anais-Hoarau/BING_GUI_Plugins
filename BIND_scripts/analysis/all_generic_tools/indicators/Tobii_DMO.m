% calcul des DMO (Distance de Mouvement Oculaire) distances entre 2 points de regards consécutifs
function Tobii_DMO(trip, meta_info)
    
    if meta_info.existData('tobii')
        % get values
        tobiiAllOccurences = trip.getAllDataOccurences('tobii');
        tobiiTimecodes = tobiiAllOccurences.getVariableValues('timecode');
        mvt_ocu_X = tobiiAllOccurences.getVariableValues('axeRegard_X');
        mvt_ocu_Y = tobiiAllOccurences.getVariableValues('axeRegard_Y');
        trip.setIsBaseData('tobii', 0);
        
        % create DMO column if necessary
        MetaInformations = trip.getMetaInformations;
        if ~MetaInformations.existDataVariable('tobii', 'DMO')
            bindVariable = fr.lescot.bind.data.MetaDataVariable();
            bindVariable.setName('DMO');
            bindVariable.setType('REAL');
            bindVariable.setUnit('px');
            bindVariable.setComments('dist_mvt_ocu calcule');
            trip.addDataVariable('tobii', bindVariable);
        end
        
        % add DMO values
        disp('Calculating DMOs ...');
        trip.setDataVariableAtTime('tobii', 'DMO', tobiiTimecodes{2}, 0);
        for i = 1:length(tobiiTimecodes)-1
            if ~isempty(mvt_ocu_X{i}) && ~isempty(mvt_ocu_X{i+1})
                DMO = sqrt((mvt_ocu_X{i+1}-mvt_ocu_X{i})^2 + (mvt_ocu_Y{i+1}-mvt_ocu_Y{i})^2);
            else
                DMO = 0;
            end
            trip.setDataVariableAtTime('tobii', 'DMO', tobiiTimecodes{i+1}, DMO);
        end
        trip.setDataVariableAtTime('tobii', 'DMO', tobiiTimecodes{1}, 0);
        trip.setIsBaseData('tobii', 1);
    end
end