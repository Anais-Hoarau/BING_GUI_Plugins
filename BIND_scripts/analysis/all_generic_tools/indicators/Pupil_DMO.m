% calcul des DMO (Distance de Mouvement Oculaire) distances entre 2 points de regards consécutifs
function Pupil_DMO(trip, meta_info)
    
    if meta_info.existData('PUPIL_GLASSES_gazes')
        % get values
        record = trip.getAllDataOccurences('PUPIL_GLASSES_gazes');
        timecodes = record.getVariableValues('timecode');
        mvt_ocu_X = record.getVariableValues('norm_pos_X');
        mvt_ocu_Y = record.getVariableValues('norm_pos_Y');
        trip.setIsBaseData('PUPIL_GLASSES_gazes', 0);
        
        % create DMO column if necessary
        MetaInformations = trip.getMetaInformations;
        if ~MetaInformations.existDataVariable('PUPIL_GLASSES_gazes', 'DMO')
            bindVariable = fr.lescot.bind.data.MetaDataVariable();
            bindVariable.setName('DMO');
            bindVariable.setType('REAL');
            bindVariable.setUnit('px');
            bindVariable.setComments('dist_mvt_ocu calcule');
            trip.addDataVariable('PUPIL_GLASSES_gazes', bindVariable);
        end
        
        % add DMO values
        disp('Calculating DMOs ...');
        trip.setDataVariableAtTime('PUPIL_GLASSES_gazes', 'DMO', timecodes{2}, 0);
        for i = 1:length(timecodes)-1
            if ~isempty(mvt_ocu_X{i}) && ~isempty(mvt_ocu_X{i+1})
                DMO = sqrt((mvt_ocu_X{i+1}-mvt_ocu_X{i})^2 + (mvt_ocu_Y{i+1}-mvt_ocu_Y{i})^2);
            else
                DMO = 0;
            end
            trip.setDataVariableAtTime('PUPIL_GLASSES_gazes', 'DMO', timecodes{i+1}, DMO);
        end
        trip.setDataVariableAtTime('PUPIL_GLASSES_gazes', 'DMO', timecodes{1}, 0);
        trip.setIsBaseData('PUPIL_GLASSES_gazes', 1);
    end
end