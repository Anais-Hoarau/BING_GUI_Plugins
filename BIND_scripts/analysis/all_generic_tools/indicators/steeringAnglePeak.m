%
function steeringAnglePeak(trip, startTime, endTime)
    % Pic d'angle au volant (derivée seconde)
    n_largeur = 4;
    square = ones(n_largeur,1)/n_largeur;
    
    dt = diff(data_out.essai.timecode);
    
    d_angleVolant = diff(data_out.essai.angleVolant)./ dt;
    data_out.essai.d_angleVolant = conv(d_angleVolant,square,'same');
    
    dd_angleVolant = diff(data_out.essai.d_angleVolant)./ dt(1:end-1);
    data_out.essai.dd_angleVolant = conv(dd_angleVolant,square,'same');
    
    ddd_angleVolant = diff(data_out.essai.dd_angleVolant)./ dt(1:end-2);
    data_out.essai.ddd_angleVolant = conv(ddd_angleVolant,square,'same');
    
    if SV.state
        [~,id_maxSV]=max(abs(data_out.SV.voie-data_out.SV.voie(1)));
        mask_TR = mask_SV;
        mask_TR(find(mask_SV, 1, 'first')+id_maxSV:end)=0;
        data_out.TR.mask = mask_TR;
        data_out.TR.timecode = data_out.essai.timecode(mask_TR);
        data_out.TR.d_angleVolant = data_out.essai.d_angleVolant(mask_TR);
        data_out.TR.dd_angleVolant = data_out.essai.dd_angleVolant(mask_TR);
        data_out.TR.ddd_angleVolant = data_out.essai.ddd_angleVolant(mask_TR);
    
        [pic_max,~] = find_TR_Pic(data_out,SV);
    
        indicateurs.SV.pic_angleVolant = pic_max;
    else
        indicateurs.SV.pic_angleVolant = nan;
    end
end