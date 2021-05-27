% calcul des valeurs de DIV sans utiliser le TIV
function DIVv2(trip)
    
    % get values
    localisationVPAllOccurences = trip.getAllDataOccurences('localisation');
    pksVP = localisationVPAllOccurences.getVariableValues('pk');
    veh_1000VPAllOccurences = trip.getAllDataOccurences('veh_1000');
    pksVeh1000 = veh_1000VPAllOccurences.getVariableValues('pk');
    vitesseVPAllOccurences = trip.getAllDataOccurences('vitesse');
    vitessesTimecodes = vitesseVPAllOccurences.getVariableValues('timecode');
    % vitessesVP = cell2mat(vitesseVPAllOccurences.getVariableValues('vitesse'));
    % tivsVP = cell2mat(vitesseVPAllOccurences.getVariableValues('TIV'));
    % divsVP = cell2mat(vitesseVPAllOccurences.getVariableValues('DIV'));
    trip.setIsBaseData('vitesse', 0);
    divs = (cell2mat(pksVeh1000) - cell2mat(pksVP))/1000 - 3.0258;
    % create DIV column if necessary
    MetaInformations = trip.getMetaInformations;
    if ~MetaInformations.existDataVariable('vitesse', 'DIVv2')
        bindVariable = fr.lescot.bind.data.MetaDataVariable();
        bindVariable.setName('DIVv2');
        bindVariable.setType('REAL');
        bindVariable.setUnit('m');
        bindVariable.setComments('DIVv2 du VP calcule');
        trip.addDataVariable('vitesse', bindVariable);
    end
    
    % add DIV values
    disp('Calculating DIVs ...');
    for i_occurence = 1:1:length(vitessesTimecodes)
        trip.setDataVariableAtTime('vitesse', 'DIVv2', vitessesTimecodes{i_occurence}, divs(i_occurence));
    end
    trip.setIsBaseData('vitesse', 1);
    
end