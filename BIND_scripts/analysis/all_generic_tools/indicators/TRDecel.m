% calcul du temps de r�action entre l'allumage du feu stop et la lev�e de la p�dale d'acc�l�rateur
function TRDecel(trip, startTime, endTime, cas_situation)
    feuStopOccurences = trip.getEventOccurencesInTimeInterval('feu_stop_on', startTime, endTime);
    feuStopTimecodes = feuStopOccurences.getVariableValues('timecode');
    TCFeuStopOn = feuStopTimecodes{1};
    vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
    vitesseTimecodes = vitesseOccurences.getVariableValues('timecode');
    AccelValues = vitesseOccurences.getVariableValues('accelerateur');
    TCdecel = cell2mat(vitesseTimecodes(find(diff(cell2mat(AccelValues)),1)));
    if ~isempty(TCdecel)
        TRdecel = TCdecel - TCFeuStopOn;
        if TRdecel<0.05 %reaction time < 50ms is anticipation
            Anticip = 1;
        else
            Anticip = 0;
        end
    else
        TCdecel = NaN;
        TRdecel = NaN;
        Anticip = 1;
    end
    disp(['[' num2str(startTime) ';' num2str(endTime) '] TC lev�e acc�l�rateur : ' num2str(TCdecel) 's']);
    trip.setSituationVariableAtTime(cas_situation, 'TCdecel', startTime, endTime, TCdecel);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] temps de r�action lev�e acc�l�rateur : ' num2str(TRdecel) 's']);
    trip.setSituationVariableAtTime(cas_situation, 'TRdecel', startTime, endTime, TRdecel);
    disp(['[' num2str(startTime) ';' num2str(endTime) '] anticipation : ' num2str(Anticip)]);
    trip.setSituationVariableAtTime(cas_situation, 'anticip', startTime, endTime, Anticip);
end