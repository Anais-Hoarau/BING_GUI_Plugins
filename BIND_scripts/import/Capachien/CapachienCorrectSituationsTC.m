% correct TC situations according to start/endTC situation_essai_complet
function CapachienCorrectSituationsTC(trip_file)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
metaInfo = trip.getMetaInformations;
situations_list = metaInfo.getSituationsNamesList;
if metaInfo.existSituation('essai_complet') && length(trip.getAllSituationOccurences('essai_complet').getVariableValues('startTimecode'))==1
    record_essai = trip.getAllSituationOccurences('essai_complet');
    startTC_essai = cell2mat(record_essai.getVariableValues('startTimecode'));
    endTC_essai = cell2mat(record_essai.getVariableValues('endTimecode'));
    for i_situation = 1:length(situations_list)
        if ~strcmp(situations_list{i_situation},'essai_complet')
            initialTimeCodesCellArray{1,1} = trip.getSituationVariableMinimum(situations_list{i_situation},'startTimecode');
            initialTimeCodesCellArray{2,1} = trip.getSituationVariableMinimum(situations_list{i_situation},'endTimecode');
            initialTimeCodesCellArray{1,2} = trip.getSituationVariableMaximum(situations_list{i_situation},'startTimecode');
            initialTimeCodesCellArray{2,2} = trip.getSituationVariableMaximum(situations_list{i_situation},'endTimecode');
            newTimeCodesCellArray = initialTimeCodesCellArray;
            newTimeCodesCellArray{1,1} = startTC_essai;
            newTimeCodesCellArray{2,2} = endTC_essai;
            if ~isempty(find(any(cell2mat(newTimeCodesCellArray) ~= cell2mat(initialTimeCodesCellArray)),1))
                trip.setIsBaseSituation(situations_list{i_situation},0);
                if newTimeCodesCellArray{2,2} <= initialTimeCodesCellArray{1,2}
                    trip.removeSituationOccurenceAtTime(situations_list{i_situation}, initialTimeCodesCellArray{1,2}, initialTimeCodesCellArray{2,2})
                    initialTimeCodesCellArray{1,2} = trip.getSituationVariableMaximum(situations_list{i_situation},'startTimecode');
                    initialTimeCodesCellArray{2,2} = trip.getSituationVariableMaximum(situations_list{i_situation},'endTimecode');
                    newTimeCodesCellArray{1,2} = trip.getSituationVariableMaximum(situations_list{i_situation},'startTimecode');
                elseif newTimeCodesCellArray{1,1} >= initialTimeCodesCellArray{2,1}
                    trip.removeSituationOccurenceAtTime(situations_list{i_situation}, initialTimeCodesCellArray{1,1}, initialTimeCodesCellArray{2,1})
                    initialTimeCodesCellArray{1,1} = trip.getSituationVariableMinimum(situations_list{i_situation},'startTimecode');
                    initialTimeCodesCellArray{2,1} = trip.getSituationVariableMinimum(situations_list{i_situation},'endTimecode');
                    newTimeCodesCellArray{2,1} = trip.getSituationVariableMinimum(situations_list{i_situation},'endTimecode');
                end
                if length(trip.getAllSituationOccurences(situations_list{i_situation}).getVariableValues('startTimecode'))==1
                    newTimeCodesCellArray{2,1} = endTC_essai;
                    trip.updateSituationVariableOccurenceTimecodes(situations_list{i_situation}, initialTimeCodesCellArray(:,1), newTimeCodesCellArray(:,1));
                else
                    trip.updateSituationVariableOccurenceTimecodes(situations_list{i_situation}, initialTimeCodesCellArray, newTimeCodesCellArray);
                end
                trip.setIsBaseSituation(situations_list{i_situation},1)
            end
        end
    end
    trip.setAttribute('correct_TC_situations','OK');
end
delete(trip)
end