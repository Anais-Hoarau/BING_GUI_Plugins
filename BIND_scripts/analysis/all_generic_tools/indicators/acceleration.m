% calcul des valeurs d'acceleration à partir des vitesses
function acceleration(trip)

% get values
vitesseVPAllOccurences = trip.getAllDataOccurences('vitesse');
vitessesTimecodes = cell2mat(vitesseVPAllOccurences.getVariableValues('timecode'));
vitessesVP = cell2mat(vitesseVPAllOccurences.getVariableValues('vitesse'));
trip.setIsBaseData('vitesse', 0);

% create DIV column if necessary
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable('vitesse', 'acceleration')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('acceleration');
    bindVariable.setType('REAL');
    bindVariable.setUnit('m/s²');
    bindVariable.setComments('Acceleration du VP calcule');
    trip.addDataVariable('vitesse', bindVariable);
end

% add DIV values
disp('Calculating accelerations ...');
for i = 1:length(vitessesTimecodes)-1
    accelVP = (vitessesVP(i+1)-vitessesVP(i))/(vitessesTimecodes(i+1)-vitessesTimecodes(i));
    trip.setDataVariableAtTime('vitesse', 'acceleration', vitessesTimecodes(i), accelVP);
end
trip.setIsBaseData('vitesse', 1);

end