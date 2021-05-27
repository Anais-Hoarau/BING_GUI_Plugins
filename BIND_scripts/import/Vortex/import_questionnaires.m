function import_questionnaires(trip_file)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    if trip.getMetaInformations().existSituation('questionnaire_rawData')
        removeSituationsTables(trip, {'questionnaire_rawData'})
    end
    timecodes = trip.getAllDataOccurences('variables_simulateur').getVariableValues('timecode');
    addSituationTable2Trip(trip, 'questionnaire_rawData', 'comment', 'import brute des reponses des participants')
    addSituationTable2Trip(trip, 'questionnaire_pourcent', 'comment', 'calcule à partir des réponses des participants')
    addSituationTable2Trip(trip, 'questionnaire_pourcent_inat', 'comment', 'calcule à partir des réponses des participants')
    trip.setSituationVariableAtTime('questionnaire_rawData', 'name', timecodes{1}, timecodes{end}, 'questionnaire_rawData')
    load('\\vrlescot\THESE_GUILLAUME\VORTEX\Donnees_Questionnaires.mat')
    header = DonneesQuestionnaires(1,3:size(DonneesQuestionnaires,2));
    
    
    for i = 2:length(DonneesQuestionnaires)
        if contains(trip_file,DonneesQuestionnaires{i,1}) && contains(trip_file,DonneesQuestionnaires{i,2})
            for i_header = 1:length(header)
                addSituationVariable2Trip(trip, 'questionnaire_rawData', cell2mat(header{i_header}), 'REAL')
                if isa(DonneesQuestionnaires{i,i_header+2},'double')
                    % données brutes
                    trip.setSituationVariableAtTime('questionnaire_rawData', cell2mat(header{i_header}), timecodes{1}, timecodes{end}, DonneesQuestionnaires{i,i_header+2})
                    
                    % données en poucentage
%                     donnees_pourcent = DonneesQuestionnaires{i,i_header+2};
%                     trip.setSituationVariableAtTime('questionnaire_pourcent', cell2mat(header{i_header}), timecodes{1}, timecodes{end}, )
                    
                    %
%                     trip.setSituationVariableAtTime('questionnaire_pourcent_inat', cell2mat(header{i_header}), timecodes{1}, timecodes{end}, DonneesQuestionnaires{i,i_header+2})
                else
                    trip.setSituationVariableAtTime('questionnaire_rawData', cell2mat(header{i_header}), timecodes{1}, timecodes{end}, NaN)
                end
            end
        end
    end
    trip.setAttribute('import_questionnaires', 'OK');
    delete(trip)
end