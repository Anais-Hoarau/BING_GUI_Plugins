% calcul du TIV du VP lors d'un évènement particulier (levé de pédale)
function eventTIV(trip, startTime, endTime, cas_situation)
    vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    vitesseTimecodes = cell2mat(vitesseVPOccurences.getVariableValues('timecode'));
    AccelValues = vitesseVPOccurences.getVariableValues('accelerateur');
    TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));
    TCdecel = vitesseTimecodes(find(diff(cell2mat(AccelValues)),1));
    if isempty(TCdecel)
        TIVEvent = NaN;
    else
        TIVEvent = TIVs(vitesseTimecodes==TCdecel);
    end
    disp(['[' num2str(startTime) ';' num2str(endTime) '] TIV levé de pédale = ' num2str(TIVEvent) ' s']);
    trip.setSituationVariableAtTime(cas_situation, 'TIV_levPed', startTime, endTime, TIVEvent);
end