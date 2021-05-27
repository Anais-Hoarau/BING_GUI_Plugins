% calcul des franchissements de voie du VP sur le scénario complet sans l'information "sortieVoie"
function crossingLaneAll2(trip, startTime, endTime)
    
    trajectoireVPAllOccurences = trip.getAllDataOccurences('trajectoire');
    timecodes = cell2mat(trajectoireVPAllOccurences.getVariableValues('timecode'));
    voieVP = cell2mat(trajectoireVPAllOccurences.getVariableValues('voie'));
    largeurVP = 1820;
    largeurRoute = 3500;
    
    mask_franchissement = (voieVP - (largeurVP/2) < 0 | voieVP + (largeurVP/2) > largeurRoute);
    cellArrayFranchissement(1,:) = num2cell(real(timecodes(1,:)));
    cellArrayFranchissement(2,:) = num2cell(real(mask_franchissement));
    
    trip.setIsBaseData('trajectoire', 0);
    trip.setBatchOfTimeDataVariablePairs('trajectoire', 'franchissement', cellArrayFranchissement);
    trip.setIsBaseData('trajectoire', 1);
    
    localisationVPOccurences = trip.getDataOccurencesInTimeInterval('localisation', startTime, endTime);
    %routeVP = str2double(localisationVPOccurences.getVariableValues('route')');
    pkVP = cell2mat(localisationVPOccurences.getVariableValues('pk'));
    
    trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
    franchissementsVP = cell2mat(trajectoireVPOccurences.getVariableValues('franchissement'));
    TC_franchissementsVP = cell2mat(trajectoireVPOccurences.getVariableValues('timecode'));
    % noVoieVP = cell2mat(trajectoireVPOccurences.getVariableValues('no_voie'));
    
    Diff_franchissements = diff(franchissementsVP);
    ID_franchissements = find(Diff_franchissements);
    %ID_changementsRoutes = find(diff(routeVP));
    i_franchissementVoieRef = 0;
    for i_franchissement = 1:1:length(ID_franchissements)
        diff_pk = pkVP(ID_franchissements(i_franchissement)) - pkVP(ID_franchissements(i_franchissement)-1);
        if diff_pk>0
            i_franchissementVoieRef = i_franchissementVoieRef + 1;
            if ~mod(i_franchissementVoieRef, 2) == 0 && Diff_franchissements(ID_franchissements(i_franchissement))>0
                ID_franchissementVoieRef(i_franchissementVoieRef) = ID_franchissements(i_franchissement);
            elseif mod(i_franchissementVoieRef, 2) == 0 && Diff_franchissements(ID_franchissements(i_franchissement))<0
                ID_franchissementVoieRef(i_franchissementVoieRef) = ID_franchissements(i_franchissement);
            else
                i_franchissementVoieRef = i_franchissementVoieRef - 1;
                continue
            end
            %         for i_cond = 1:1:length(ID_changementsRoutes)
            %             conditionInf = logical(ID_franchissements(i_franchissement-1)<ID_changementsRoutes(i_cond) && ID_franchissements(i_franchissementVoieVPConsigne)<ID_changementsRoutes(i_cond));
            %             conditionSup = logical(ID_franchissements(i_franchissement-1)>ID_changementsRoutes(i_cond) && ID_franchissements(i_franchissementVoieVPConsigne)>ID_changementsRoutes(i_cond));;
            %             break
            %         end
            if mod(i_franchissementVoieRef, 2) == 0 %&& (conditionInf || conditionSup)
                nom_franchissement = ['franchissement n°' num2str(i_franchissementVoieRef/2)];
                TC_franchissementsVP_deb = TC_franchissementsVP(ID_franchissementVoieRef(i_franchissementVoieRef-1));
                TC_franchissementsVP_fin = TC_franchissementsVP(ID_franchissementVoieRef(i_franchissementVoieRef));
                duree_franchissement = TC_franchissementsVP_fin - TC_franchissementsVP_deb;
                trip.setSituationVariableAtTime('franchissement', 'name', TC_franchissementsVP_deb, TC_franchissementsVP_fin, nom_franchissement);
                trip.setSituationVariableAtTime('franchissement', 'duree_franchissement', TC_franchissementsVP_deb, TC_franchissementsVP_fin, duree_franchissement);
            end
        end
    end
    trip.setAttribute('nb_franchissements',num2str(i_franchissementVoieRef/2));
end