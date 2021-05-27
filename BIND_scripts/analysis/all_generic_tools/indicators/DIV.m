% calcul des valeurs de DIV
function DIV(trip)

% get values
vitesseVPAllOccurences = trip.getAllDataOccurences('vitesse');
vitessesTimecodes = vitesseVPAllOccurences.getVariableValues('timecode');
vitessesVP = cell2mat(vitesseVPAllOccurences.getVariableValues('vitesse'));
tivsVP = cell2mat(vitesseVPAllOccurences.getVariableValues('TIV'));
trip.setIsBaseData('vitesse', 0);

% create DIV column if necessary
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable('vitesse', 'DIV')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('DIV');
    bindVariable.setType('REAL');
    bindVariable.setUnit('m');
    bindVariable.setComments('DIV du VP calcule');
    trip.addDataVariable('vitesse', bindVariable);
end

% add DIV values
disp('Calculating DIVs ...');
for i_occurence = 1:1:length(vitessesTimecodes)
    divVP = vitessesVP(i_occurence)*tivsVP(i_occurence);
    trip.setDataVariableAtTime('vitesse', 'DIV', vitessesTimecodes{i_occurence}, divVP);
end
trip.setIsBaseData('vitesse', 1);

end