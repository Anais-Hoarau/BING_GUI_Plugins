function RCE2CalculateIndicators(trip_file, cas_situation, message_name)
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
meta_info = trip.getMetaInformations;
%% GET SITUATION DATA
situationOccurences = trip.getAllSituationOccurences(cas_situation);
startTimes = situationOccurences.getVariableValues('startTimecode');
endTimes = situationOccurences.getVariableValues('endTimecode');

%% SWITCH CASE AND APPLY CORRESPONDING PROCESS
for i = 1:1:length(startTimes)
    startTime = startTimes{i};
    endTime = endTimes{i};
    trip.setAttribute(['calcul_' message_name '_' cas_situation], '');
    if ~check_trip_meta(trip,['calcul_' message_name '_' cas_situation],'OK');
        switch message_name
            
            case 'duree'
                addSituationDuration(trip, startTime, endTime, cas_situation)
                
            case 'nbEchantillons'
                addNumberOfSamples(trip, startTime, endTime, cas_situation)
                
            case 'frequency'
                addFrequency(trip, startTime, endTime, cas_situation)
                
            case 'performance'
                addTrackingPerformance(trip, startTime, endTime, cas_situation)
                
            case 'TIVmoyen'
                addMeanTIV(trip, startTime, endTime, cas_situation)
                
            case 'TIVmin'
                addMinTIV(trip, startTime, endTime, cas_situation)
                
            case 'DIVScenario'
                addDIV(trip)
                
            case 'DIVmoyen'
                addMeanDIV(trip, startTime, endTime, cas_situation)
                
            case 'vitesseMoyenne'
                addMeanSpeed(trip, startTime, endTime, cas_situation)
                
            case 'variationsVitesses'
                addSpeedVariations(trip, startTime, endTime, cas_situation)
                
            case 'accelDecelMoyenne'
                addMeanAccelDecel(trip, startTime, endTime, cas_situation)
                
            case 'nbACoups'
                addSpeedJerk(trip, startTime, endTime, cas_situation);
                
            case 'enfoncementPedaleMean&Max'
                addMeanBreakPedalPercentage(trip, startTime, endTime, cas_situation);
                addMaxBreakPercentage(trip, startTime, endTime, cas_situation);
                
            case 'positionLateraleMoyenne'
                addMeanLateralPosition(trip, startTime, endTime, cas_situation)
                
            case 'variationsLaterales'
                addLateralPositionVariation(trip, startTime, endTime, cas_situation)
                
            case 'franchissementsScenario'
                addCrossingLaneAll(trip, startTime, endTime)
                
            case 'franchissementsParSituation'
                addCrossingLaneBySituation(trip, startTime, endTime, cas_situation)
                
            case 'DMOScenario'
                addDMO(trip, meta_info)
                
            case 'fixations'
                addFixations(trip, startTime, endTime, cas_situation)
                
            case 'SteeringAngleVar'
                SteeringAngleVar(trip, startTime, endTime, cas_situation)
                
            case 'successYN'
                successYN(trip, startTime, endTime, cas_situation)
                
            case 'stopYN'
                stopYN(trip, startTime, endTime, cas_situation)
                
            case 'firstReaction'
                firstReaction(trip, startTime, endTime, cas_situation)
                
            otherwise
                error(['Fonction non reconnue ! : ' message_name]);
        end
    end
end
trip.setAttribute(['calcul_' message_name '_' cas_situation], 'OK');
delete(trip);
end

%% calcul de la durée de la situation
function addSituationDuration(trip, startTime, endTime, cas_situation)
situationDuration = endTime - startTime;
disp(['[' num2str(startTime) ';' num2str(endTime) '] durée = ' num2str(situationDuration) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'duree', startTime, endTime, situationDuration);
end

%% calcul du nombre de pas de temps
function addNumberOfSamples(trip, startTime, endTime, cas_situation)
variables_simulateur = trip.getDataOccurencesInTimeInterval('variables_simulateur', startTime, endTime);
pas_de_temps = cell2mat(variables_simulateur.getVariableValues('pas'));
NbPasDeTemps = pas_de_temps(end) - pas_de_temps(1);
disp(['[' num2str(startTime) ';' num2str(endTime) '] nombre d''échantillons = ' num2str(NbPasDeTemps)]);
trip.setSituationVariableAtTime(cas_situation, 'nb_ech', startTime, endTime, NbPasDeTemps);
end

%% calcul de la fréquence de la situation
function addFrequency(trip, startTime, endTime, cas_situation)

suiviOccurences = trip.getSituationOccurencesInTimeInterval(cas_situation, startTime, endTime);
duree = cell2mat(suiviOccurences.getVariableValues('duree'));
nb_ech = cell2mat(suiviOccurences.getVariableValues('nb_ech'));
fs = nb_ech / duree ;

disp(['[' num2str(startTime) ';' num2str(endTime) '] fréquence = ' num2str(fs) ' Hz']);
trip.setSituationVariableAtTime(cas_situation, 'freq', startTime, endTime, fs);

end

%% calcul des performances de suivi de Brookhuis (cohérence, phase, gain)
function addTrackingPerformance(trip, startTime, endTime, cas_situation)

% Variables
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
vVP = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));
vitesseCibleOccurences = trip.getDataOccurencesInTimeInterval('cible', startTime, endTime);
vCible = cell2mat(vitesseCibleOccurences.getVariableValues('vitesseCible'));

suiviOccurences = trip.getSituationOccurencesInTimeInterval(cas_situation, startTime, endTime);
fs = cell2mat(suiviOccurences.getVariableValues('freq'));

% Calculate performance
[mCoh, mPha, mGain] = following(vCible, vVP, fs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] performance du suivi (coherence) = ' num2str(mCoh)]);
disp(['[' num2str(startTime) ';' num2str(endTime) '] performance du suivi (delai) = ' num2str(mPha)]);
disp(['[' num2str(startTime) ';' num2str(endTime) '] performance du suivi (amplitude) = ' num2str(mGain)]);
trip.setSituationVariableAtTime(cas_situation, 'perf_coherence', startTime, endTime, mCoh);
trip.setSituationVariableAtTime(cas_situation, 'perf_phase', startTime, endTime, mPha);
trip.setSituationVariableAtTime(cas_situation, 'perf_gain', startTime, endTime, mGain);

end

%% calcul de la moyenne des TIV du VP
function addMeanTIV(trip, startTime, endTime, cas_situation)

%Calculé par rapport au véhicule cible (-10)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));

meanTIV = mean(TIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] TIV moyen = ' num2str(meanTIV) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'TIV_moy', startTime, endTime, meanTIV);

end

%% calcul du TIV minimum du VP
function addMinTIV(trip, startTime, endTime, cas_situation)

%Calculé par rapport au véhicule cible (-10)
PK_cibleOccurences = trip.getDataOccurencesInTimeInterval('cible', startTime, endTime);
PK_cible = cell2mat(PK_cibleOccurences.getVariableValues('pkCible'));
PK_cibleArret = PK_cible(find(diff(PK_cible)==0, 1));
PK_VPOccurences = trip.getDataOccurencesInTimeInterval('localisation', startTime, endTime);
PK_VP = cell2mat(PK_VPOccurences.getVariableValues('pk'));
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
vitessesVP = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));
TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));
TIV_arret = NaN;
i=1;
while PK_VP(i) < PK_cibleArret
    if vitessesVP(i) == 0
        TIV_arret = TIVs(i);
        break
    end
    i=i+1;
end
disp(['[' num2str(startTime) ';' num2str(endTime) '] TIV arret = ' num2str(TIV_arret) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'TIV_min', startTime, endTime, TIV_arret);

end

%% calcul des valeurs de DIV
function addDIV(trip)

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

%% calculate Mean DIV VP
function addMeanDIV(trip, startTime, endTime, cas_situation)

vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
DIVs = cell2mat(vitesseVPOccurences.getVariableValues('DIV'));

meanDIV = mean(DIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] DIV moyen = ' num2str(meanDIV) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'DIV_moy', startTime, endTime, meanDIV)

end

%% calculate mean speed VP
function addMeanSpeed(trip, startTime, endTime, cas_situation)

vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
Vvp = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));

meanVvp = mean(Vvp)*3.6;
disp(['[' num2str(startTime) ';' num2str(endTime) '] vitesse moyenne = ' num2str(meanVvp) ' km/h']);
trip.setSituationVariableAtTime(cas_situation, 'vit_moy', startTime, endTime, meanVvp);

end

%% calculate speed VP variations
function addSpeedVariations(trip, startTime, endTime, cas_situation)

vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
Vvp = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));

varVvp = std(Vvp)*3.6;
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations de vitesse = ' num2str(varVvp) ' km/h']);
trip.setSituationVariableAtTime(cas_situation, 'vit_var', startTime, endTime, varVvp);

end

%% calcul moyenne d'accélération/décélération du VP et durées
function addMeanAccelDecel(trip, startTime, endTime, cas_situation)

vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
AccVP = cell2mat(vitesseVPOccurences.getVariableValues('acceleration'));

%calculs sur accélération
mask_Acc = AccVP>0;
meanAccVP = mean(AccVP(mask_Acc));
disp(['[' num2str(startTime) ';' num2str(endTime) '] Accélération moyenne = ' num2str(meanAccVP) ' m/s²']);
trip.setSituationVariableAtTime(cas_situation, 'accel_moy', startTime, endTime, meanAccVP);

mask_Dec = AccVP<0;
meanDecVP = mean(AccVP(mask_Dec));
disp(['[' num2str(startTime) ';' num2str(endTime) '] Décéleration moyenne = ' num2str(meanDecVP) ' m/s²']);
trip.setSituationVariableAtTime(cas_situation, 'decel_moy', startTime, endTime, meanDecVP);
end

%% calcul du nombre d'à-coups sur l'accélération (à partir de la dérivée de l'accélération)
function addSpeedJerk(trip, startTime, endTime, cas_situation)
record = trip.getDataVariableOccurencesInTimeInterval('vitesse','vitesse',startTime,endTime);
cell = record.buildCellArrayWithVariables({'timecode' 'vitesse'});
smoothedCell = fr.lescot.bind.processing.signalProcessors.MovingAverage.process(cell, 7);
dVit = fr.lescot.bind.processing.signalProcessors.Derivator.process(smoothedCell, 0);
smoothedDVit = fr.lescot.bind.processing.signalProcessors.MovingAverage.process(dVit, 7);
ddVit = fr.lescot.bind.processing.signalProcessors.Derivator.process(smoothedDVit, 0);
ddVitAbs = num2cell(cellfun(@abs, ddVit));

seuil = 4; % Essayer avec 3, 4 ou ...
grandPicDDVit = fr.lescot.bind.processing.situationDiscoverers.ThresholdComparator.extract(ddVitAbs, '>', seuil);
jerk = length(grandPicDDVit);
disp(['[' num2str(startTime) ';' num2str(endTime) '] jerk (' num2str(seuil) ') : ' num2str(jerk)]);
trip.setSituationVariableAtTime(cas_situation, 'jerk', startTime, endTime, jerk);
end

%% calcul de la moyenne du pourcentage d'enfoncement de la pédale de frein
function addMeanBreakPedalPercentage(trip, startTime, endTime, cas_situation)
vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
breakValues = vitesseOccurences.getVariableValues('frein');
meanBreakPercentage = (mean(cell2mat(breakValues)) / 255) * 100;
disp(['[' num2str(startTime) ';' num2str(endTime) '] meanBreakPercentage : ' num2str(meanBreakPercentage) '%']);
trip.setSituationVariableAtTime(cas_situation, 'frein_moy', startTime, endTime, meanBreakPercentage);
end

%% calcul de la valeur maximale de pourcentage d'enfoncement de la pédale de frein
function addMaxBreakPercentage(trip, startTime, endTime, cas_situation)
vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
breakValues = vitesseOccurences.getVariableValues('frein');
maxBreakPercentage = (max(cell2mat(breakValues)) / 255) * 100;
disp(['[' num2str(startTime) ';' num2str(endTime) '] maxBreakPercentage : ' num2str(maxBreakPercentage) '%']);
trip.setSituationVariableAtTime(cas_situation, 'frein_max', startTime, endTime, maxBreakPercentage);
end

%% calcul de la moyenne des positions latérales du VP par côté
function addMeanLateralPosition(trip, startTime, endTime, cas_situation)

trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
PositionLateraleVP = cell2mat(trajectoireVPOccurences.getVariableValues('voie'))'-1750;

MeanDepLat = mean(PositionLateraleVP)/1000;
disp(['[' num2str(startTime) ';' num2str(endTime) '] moyenne de position latérale = ' num2str(MeanDepLat) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'posLat_moy', startTime, endTime, MeanDepLat);

% MeanDepLatNeg = mean(PositionLateraleVP<0)/1000;
% disp(['[' num2str(startTime) ';' num2str(endTime) '] moyenne de position latérale gauche = ' num2str(MeanDepLatNeg) ' m']);
% trip.setSituationVariableAtTime(cas_situation, 'posLatG_moy', startTime, endTime, MeanDepLatNeg);
%
% MeanDepLatPos = mean(PositionLateraleVP>0)/1000;
% disp(['[' num2str(startTime) ';' num2str(endTime) '] moyenne de position latérale droite = ' num2str(MeanDepLatPos) ' m']);
% trip.setSituationVariableAtTime(cas_situation, 'posLatD_moy', startTime, endTime, MeanDepLatPos);

end

%% calcul des variations de positions latérales du VP (standard déviation)
function addLateralPositionVariation(trip, startTime, endTime, cas_situation)

trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
PositionLateraleVP = cell2mat(trajectoireVPOccurences.getVariableValues('voie'))';

varDepLat = std(PositionLateraleVP);
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations de position latérale = ' num2str(varDepLat/1000) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'lat_var', startTime, endTime, varDepLat/1000);

end

%% calcul des franchissements de voie du VP sur le scénario complet
function addCrossingLaneAll(trip, startTime, endTime)

localisationVPOccurences = trip.getDataOccurencesInTimeInterval('localisation', startTime, endTime);
%routeVP = str2double(localisationVPOccurences.getVariableValues('route')');
pkVP = cell2mat(localisationVPOccurences.getVariableValues('pk'));

trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
franchissementsVP = cell2mat(trajectoireVPOccurences.getVariableValues('franchissement'));
TC_franchissementsVP = cell2mat(trajectoireVPOccurences.getVariableValues('timecode'));
noVoieVP = cell2mat(trajectoireVPOccurences.getVariableValues('no_voie'));

Diff_franchissements = diff(franchissementsVP);
ID_franchissements = find(Diff_franchissements);
%ID_changementsRoutes = find(diff(routeVP));
i_franchissementVoieRef = 0;
for i_franchissement = 1:1:length(ID_franchissements)
    diff_pk = pkVP(ID_franchissements(i_franchissement)) - pkVP(ID_franchissements(i_franchissement)-1);
    if diff_pk>0 && noVoieVP(ID_franchissements(i_franchissement)) == 1 || diff_pk<0 && noVoieVP(ID_franchissements(i_franchissement)) == -1
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

%% calcul des franchissements de voie du VP par situation
function addCrossingLaneBySituation(trip, startTime, endTime, cas_situation)

franchissementVPOccurences = trip.getSituationOccurencesInTimeInterval('franchissement', startTime, endTime);
dureeFranchissement = cell2mat(franchissementVPOccurences.getVariableValues('duree_franchissement'));
dureeFranchissementMoy = mean(dureeFranchissement);

disp(['[' num2str(startTime) ';' num2str(endTime) '] nombre de franchissements = ' num2str(length(dureeFranchissement))]);
disp(['[' num2str(startTime) ';' num2str(endTime) '] durée moyenne des franchissements = ' num2str(dureeFranchissementMoy) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'nb_SV', startTime, endTime, length(dureeFranchissement));
trip.setSituationVariableAtTime(cas_situation, 'dureeSV_moy', startTime, endTime, dureeFranchissementMoy);

end

%% calcul des DMO (Distance de Mouvement Oculaire) distances entre 2 points de regards consécutifs
function addDMO(trip, meta_info)

if meta_info.existData('tobii')
    % get values
    tobiiAllOccurences = trip.getAllDataOccurences('tobii');
    tobiiTimecodes = tobiiAllOccurences.getVariableValues('timecode');
    mvt_ocu_X = tobiiAllOccurences.getVariableValues('axeRegard_X');
    mvt_ocu_Y = tobiiAllOccurences.getVariableValues('axeRegard_Y');
    trip.setIsBaseData('tobii', 0);
    
    % create DMO column if necessary
    MetaInformations = trip.getMetaInformations;
    if ~MetaInformations.existDataVariable('tobii', 'DMO')
        bindVariable = fr.lescot.bind.data.MetaDataVariable();
        bindVariable.setName('DMO');
        bindVariable.setType('REAL');
        bindVariable.setUnit('px');
        bindVariable.setComments('dist_mvt_ocu calcule');
        trip.addDataVariable('tobii', bindVariable);
    end
    
    % add DMO values
    disp('Calculating DMOs ...');
    trip.setDataVariableAtTime('tobii', 'DMO', tobiiTimecodes{2}, 0);
    for i = 1:length(tobiiTimecodes)-1
        if ~isempty(mvt_ocu_X{i}) && ~isempty(mvt_ocu_X{i+1})
            DMO = sqrt((mvt_ocu_X{i+1}-mvt_ocu_X{i})^2 + (mvt_ocu_Y{i+1}-mvt_ocu_Y{i})^2);
        else
            DMO = NaN;
        end
        trip.setDataVariableAtTime('tobii', 'DMO', tobiiTimecodes{i+1}, DMO);
    end
    trip.setIsBaseData('tobii', 1);
end
end

%% calculate fixations quantities and durations
function addFixations(trip, startTime, endTime, cas_situation)
tobiiOccurences = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime);
dist_mouv_ocu = cell2mat(tobiiOccurences.getVariableValues('DMO'));

fix = 0;
i_fix = 0;
duree_fix = 0;
for i = 1:length(dist_mouv_ocu)-2
    if (dist_mouv_ocu(i+2) - dist_mouv_ocu(i)) < 6
        duree_fix = duree_fix + 0.033;
    else
        fix = 0;
    end
    if (dist_mouv_ocu(i+2) - dist_mouv_ocu(i)) < 6 && fix == 0
        i_fix = i_fix + 1;
        fix = 1;
    end
end
duree_fix_moy = duree_fix/i_fix;

disp(['[' num2str(startTime) ';' num2str(endTime) '] nb_fix = ' num2str(i_fix)]);
disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_tot = ' num2str(duree_fix) 's']);
disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_moy = ' num2str(duree_fix_moy) 's']);

trip.setSituationVariableAtTime(cas_situation, 'nb_fix', startTime, endTime, i_fix)
trip.setSituationVariableAtTime(cas_situation, 'duree_fix_tot', startTime, endTime, duree_fix)
trip.setSituationVariableAtTime(cas_situation, 'duree_fix_moy', startTime, endTime, duree_fix_moy)


end

%% calculate steering angle variations
function SteeringAngleVar(trip, startTime, endTime, cas_situation)
trajectoireOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
SteeringAngle = cell2mat(trajectoireOccurences.getVariableValues('angle_volant'));
steeringAngle_var = std(SteeringAngle/7500*360);
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations d''angle au volant = ' num2str(steeringAngle_var) '°']);
trip.setSituationVariableAtTime(cas_situation, 'steeringAngle_var', startTime, endTime, steeringAngle_var)
end

%% calculate steering angle peaks
function SteeringAnglePeak(trip, startTime, endTime)
% % Pic d'angle au volant (derivée seconde)
% n_largeur = 4;
% square = ones(n_largeur,1)/n_largeur;
%
% dt = diff(data_out.essai.timecode);
%
% d_angleVolant = diff(data_out.essai.angleVolant)./ dt;
% data_out.essai.d_angleVolant = conv(d_angleVolant,square,'same');
%
% dd_angleVolant = diff(data_out.essai.d_angleVolant)./ dt(1:end-1);
% data_out.essai.dd_angleVolant = conv(dd_angleVolant,square,'same');
%
% ddd_angleVolant = diff(data_out.essai.dd_angleVolant)./ dt(1:end-2);
% data_out.essai.ddd_angleVolant = conv(ddd_angleVolant,square,'same');
%
% if SV.state
%     [~,id_maxSV]=max(abs(data_out.SV.voie-data_out.SV.voie(1)));
%     mask_TR = mask_SV;
%     mask_TR(find(mask_SV, 1, 'first')+id_maxSV:end)=0;
%     data_out.TR.mask = mask_TR;
%     data_out.TR.timecode = data_out.essai.timecode(mask_TR);
%     data_out.TR.d_angleVolant = data_out.essai.d_angleVolant(mask_TR);
%     data_out.TR.dd_angleVolant = data_out.essai.dd_angleVolant(mask_TR);
%     data_out.TR.ddd_angleVolant = data_out.essai.ddd_angleVolant(mask_TR);
%
%     [pic_max,id_pic] = find_TR_Pic(data_out,SV);
%
%     indicateurs.SV.pic_angleVolant = pic_max;
% else
%     indicateurs.SV.pic_angleVolant = nan;
% end
end

%% find first reaction of the driver
function firstReaction(trip, startTime, endTime, cas_situation)
trajectoireOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
steeringAngle = cell2mat(trajectoireOccurences.getVariableValues('angle_volant'));
vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
breakPourcentage = cell2mat(vitesseOccurences.getVariableValues('frein'));
Timecodes = cell2mat(vitesseOccurences.getVariableValues('timecode'));
maskSteeringAngleTimecodes = Timecodes(diff(steeringAngle) > 5);
maskBreakPourcentageTimecodes = Timecodes(breakPourcentage > 15);
if ~isempty(maskBreakPourcentageTimecodes) && maskBreakPourcentageTimecodes(1) < maskSteeringAngleTimecodes(1)
    firstReaction = 'break';
    TCFirstReaction = maskBreakPourcentageTimecodes(1);
    TRFirstReaction = maskBreakPourcentageTimecodes(1) - startTime;
elseif isempty(maskBreakPourcentageTimecodes) || maskSteeringAngleTimecodes(1) < maskBreakPourcentageTimecodes(1)
    firstReaction = 'steeringWheel';
    TCFirstReaction = maskSteeringAngleTimecodes(1);
    TRFirstReaction = maskSteeringAngleTimecodes(1) - startTime;
end
disp(['[' num2str(startTime) ';' num2str(endTime) '] 1ère réaction = ' firstReaction]);
disp(['[' num2str(startTime) ';' num2str(endTime) '] temps de réaction = ' num2str(TRFirstReaction)]);
trip.setSituationVariableAtTime(cas_situation, '1stReaction', startTime, endTime, firstReaction)
trip.setSituationVariableAtTime(cas_situation, 'TC1stReaction', startTime, endTime, TCFirstReaction)
trip.setSituationVariableAtTime(cas_situation, 'TR1stReaction', startTime, endTime, TRFirstReaction)
end

%% define if the car stoped during the situation
function stopYN(trip, startTime, endTime, cas_situation)
PK_cibleOccurences = trip.getDataOccurencesInTimeInterval('cible', startTime, endTime);
PK_cible = cell2mat(PK_cibleOccurences.getVariableValues('pkCible'));
PK_cibleArret = PK_cible(find(diff(PK_cible)==0, 1));
PK_VPOccurences = trip.getDataOccurencesInTimeInterval('localisation', startTime, endTime);
PK_VP = cell2mat(PK_VPOccurences.getVariableValues('pk'));
vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
vitesseVP = cell2mat(vitesseOccurences.getVariableValues('vitesse'));
arret = 0;
i=1;
while PK_VP(i) < PK_cibleArret
    if min(vitesseVP(i)) < 1
        arret = 1;
    end
    i=i+1;
end
disp(['[' num2str(startTime) ';' num2str(endTime) '] arret = ' num2str(arret)]);
trip.setSituationVariableAtTime(cas_situation, 'arret', startTime, endTime, arret)
end

%% define if the driver succeed the situation
function successYN(trip, startTime, endTime, cas_situation)
piloteAutoOccurences = trip.getSituationOccurencesInTimeInterval(cas_situation, startTime, endTime);
arret = cell2mat(piloteAutoOccurences.getVariableValues('arret'));
franchissementOccurences = trip.getSituationOccurencesInTimeInterval('franchissement', startTime, endTime);
franchissements = cell2mat(franchissementOccurences.getVariableValues('startTimecode'));
if arret == 0 && (isempty(franchissements) || franchissements(1) > startTime+12)
    reussite = 0;
else
    reussite = 1;
end
disp(['[' num2str(startTime) ';' num2str(endTime) '] reussite = ' num2str(reussite)]);
trip.setSituationVariableAtTime(cas_situation, 'reussite', startTime, endTime, reussite)
end