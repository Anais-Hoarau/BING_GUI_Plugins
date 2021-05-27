% calcul du DIV du VP lors d'un �v�nement particulier (lev� de p�dale)
function eventDIV(trip, startTime, endTime, cas_situation)
    vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    vitesseTimecodes = cell2mat(vitesseVPOccurences.getVariableValues('timecode'));
    AccelValues = vitesseVPOccurences.getVariableValues('accelerateur');
    DIVs = cell2mat(vitesseVPOccurences.getVariableValues('DIVv2'));
    TCdecel = vitesseTimecodes(find(diff(cell2mat(AccelValues)),1));
    if isempty(TCdecel)
        DIVEvent = NaN;
    else
        DIVEvent = DIVs(vitesseTimecodes==TCdecel);
    end
    disp(['[' num2str(startTime) ';' num2str(endTime) '] DIV lev� de p�dale = ' num2str(DIVEvent) ' s']);
    trip.setSituationVariableAtTime(cas_situation, 'DIV_levPed', startTime, endTime, DIVEvent);
end