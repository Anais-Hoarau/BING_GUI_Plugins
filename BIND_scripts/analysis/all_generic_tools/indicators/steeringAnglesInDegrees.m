% Calcul des valeurs d'angle au volant corrigées (données depuis le G27)
function steeringAnglesInDegrees(trip)
    
    %get values
    trajectoireVPAllOccurences = trip.getAllDataOccurences('trajectoire');
    trajectoireTimecodes = trajectoireVPAllOccurences.getVariableValues('timecode');
    AnglesVolantVP = cell2mat(trajectoireVPAllOccurences.getVariableValues('angle_volant'));
    trip.setIsBaseData('trajectoire', 0);
    
    % create SteeringAnglesInDegree column if necessary
    MetaInformations = trip.getMetaInformations;
    if ~MetaInformations.existDataVariable('trajectoire', 'angle_volant_deg')
        bindVariable = fr.lescot.bind.data.MetaDataVariable();
        bindVariable.setName('angle_volant_deg');
        bindVariable.setType('REAL');
        bindVariable.setUnit('deg');
        bindVariable.setComments('Angle au volant en degres calcule');
        trip.addDataVariable('trajectoire', bindVariable);
    end
    
    % add SteeringAnglesInDegree values
    disp('Calculating steering angles in degree ...');
    for i_occurence = 1:1:length(trajectoireTimecodes)
        AnglesVolantVPInDegree = AnglesVolantVP(i_occurence)/40;
        trip.setDataVariableAtTime('trajectoire', 'angle_volant_deg', trajectoireTimecodes{i_occurence}, AnglesVolantVPInDegree);
    end
    trip.setIsBaseData('trajectoire', 1);
    
end