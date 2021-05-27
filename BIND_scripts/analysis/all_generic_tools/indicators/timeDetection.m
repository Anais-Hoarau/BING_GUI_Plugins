% calcul du temps de réaction entre l'allumage du feu stop et l'appui commande Cd/Cg
function timeDetection(trip, startTime, endTime, cas_situation)
adaptComportOccurences = trip.getDataOccurencesInTimeInterval('adaptation_comportementale', startTime, endTime);
adaptComportTimecodes = adaptComportOccurences.getVariableValues('timecode');
indics = adaptComportOccurences.getVariableValues('indics');
CdIndics = strfind(indics, 'Cd');
CgIndics = strfind(indics, 'Cg');
for i_occurences = 1:length(adaptComportTimecodes)
    if ~isempty(CdIndics{i_occurences})
        TCdetection = adaptComportTimecodes{i_occurences};
        detectionTime = TCdetection - startTime;
        break
    elseif ~isempty(CgIndics{i_occurences})
        TCdetection = adaptComportTimecodes{i_occurences};
        detectionTime = TCdetection - startTime;
        break
    else
        TCdetection = NaN;
        detectionTime = NaN;
    end
end
disp(['[' num2str(startTime) ';' num2str(endTime) '] temps de détection : ' num2str(detectionTime) 's']);
trip.setSituationVariableAtTime(cas_situation, 'detectionTime', startTime, endTime, detectionTime);

% if ~isempty(TCdecel)
%     timeDetection = TCdecel - startTimecode;
%     if TRdecel<0.05 %reaction time < 50ms is anticipation
%         Anticip = 1;
%     else
%         Anticip = 0;
%     end
% else
%     TCdecel = NaN;
%     TRdecel = NaN;
%     Anticip = 1;
% end
% disp(['[' num2str(startTime) ';' num2str(endTime) '] temps de réaction levée accélérateur : ' num2str(TRdecel) 's']);
% trip.setSituationVariableAtTime(cas_situation, 'TRdecel', startTime, endTime, TRdecel);
% disp(['[' num2str(startTime) ';' num2str(endTime) '] anticipation : ' num2str(Anticip)]);
% trip.setSituationVariableAtTime(cas_situation, 'anticip', startTime, endTime, Anticip);
end