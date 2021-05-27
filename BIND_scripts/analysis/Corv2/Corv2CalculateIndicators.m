function Corv2CalculateIndicators(trip_file, cas_situation, nom_situation, message_name)
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
    trip.setAttribute(['calcul_' message_name '_' nom_situation], '');
    if ~check_trip_meta(trip,['calcul_' message_name '_' nom_situation],'OK');
        switch message_name
            
            case 'duree'
                addSituationDuration(trip, startTime, endTime, cas_situation)
                
            case 'nbEchantillons'
                addNumberOfSamples(trip, startTime, endTime, cas_situation)
                
            case 'frequency'
                addFrequency(trip, startTime, endTime, cas_situation)
                
            case 'performance'
                addTrackingPerformance(trip, startTime, endTime, cas_situation)
                
            case 'TIVMin'
                addMinTIV(trip, startTime, endTime, cas_situation)
                
            case 'TIVMoy'
                addMeanTIV(trip, startTime, endTime, cas_situation)
                
            case 'TIVVar'
                addVarTIV(trip, startTime, endTime, cas_situation)
            
            case 'TIVEvent'
                addEventTIV(trip, startTime, endTime, cas_situation)
                
            case 'DIVScenario'
                addDIV(trip)

            case 'DIVScenarioV2'
                addDIVv2(trip)
                
            case 'DIVMin'
                addMinDIV(trip, startTime, endTime, cas_situation)
                
            case 'DIVMoy'
                addMeanDIV(trip, startTime, endTime, cas_situation)
                
            case 'DIVVar'
                addVarDIV(trip, startTime, endTime, cas_situation)
                
            case 'DIVEvent'
                addEventDIV(trip, startTime, endTime, cas_situation)
                
            case 'vitesseMoy'
                addMeanSpeed(trip, startTime, endTime, cas_situation)
                
            case 'vitessesVar'
                addSpeedVariations(trip, startTime, endTime, cas_situation)
                
            case 'accelDecelMoy'
                addMeanAccelDecel(trip, startTime, endTime, cas_situation)
                
            case 'nbACoups'
                addSpeedJerk(trip, startTime, endTime, cas_situation);
                
            case 'enfoncementPedaleMean&Max'
                addMeanBreakPedalPercentage(trip, startTime, endTime, cas_situation);
                addMaxBreakPercentage(trip, startTime, endTime, cas_situation);
            
            case 'tempsReactionDecel'
                addTRDecel(trip, startTime, endTime, cas_situation);

            case 'tempsDetection'
                addTimeDetection(trip, startTime, endTime, cas_situation);   
                
            case 'positionLateraleMoy'
                addMeanLateralPosition(trip, startTime, endTime, cas_situation)
                
            case 'positionLateraleVar'
                addLateralPositionVariation(trip, startTime, endTime, cas_situation)
            
            case 'AngleVolantEnDegres'
                addSteeringAnglesInDegrees(trip)
                
            case 'AngleVolantVar'   
                addSteeringAnglesVariations(trip, startTime, endTime, cas_situation)
                
            case 'franchissementsScenario'
                addCrossingLaneAll(trip, startTime, endTime)
                
            case 'franchissementsScenario2'
                addCrossingLaneAll2(trip, startTime, endTime)
                
            case 'franchissementsParSituation'
                addCrossingLaneBySituation(trip, startTime, endTime, cas_situation)
                
            case 'DMOScenario'
                addDMO(trip, meta_info)
                
            case 'fixations'
                addFixations(trip, startTime, endTime, cas_situation)
                
            case 'fixationsAOI'
                addFixationsAOI(trip, startTime, endTime, cas_situation, i)
                
            otherwise
                error(['Fonction non reconnue ! : ' message_name]);
        end
    end
end
trip.setAttribute(['calcul_' message_name '_' nom_situation], 'OK');
delete(trip);
end

% calcul de la durée de la situation
function addSituationDuration(trip, startTime, endTime, cas_situation)

situationDuration = endTime - startTime;
trip.setSituationVariableAtTime(cas_situation, 'duree', startTime, endTime, situationDuration);

end

% calcul du nombre de pas de temps
function addNumberOfSamples(trip, startTime, endTime, cas_situation)

variables_simulateur = trip.getDataOccurencesInTimeInterval('variables_simulateur', startTime, endTime);
pas_de_temps = cell2mat(variables_simulateur.getVariableValues('pas'));

NbPasDeTemps = pas_de_temps(end) - pas_de_temps(1);
trip.setSituationVariableAtTime(cas_situation, 'nb_ech', startTime, endTime, NbPasDeTemps);

end

% calcul de la fréquence de la situation
function addFrequency(trip, startTime, endTime, cas_situation)

suiviOccurences = trip.getSituationOccurencesInTimeInterval(cas_situation, startTime, endTime);
duree = cell2mat(suiviOccurences.getVariableValues('duree'));
nb_ech = cell2mat(suiviOccurences.getVariableValues('nb_ech'));
fs = nb_ech / duree ;

trip.setSituationVariableAtTime(cas_situation, 'freq', startTime, endTime, fs);

end

% calcul des performances de suivi de Brookhuis (cohérence, phase, gain)
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
trip.setSituationVariableAtTime(cas_situation, 'perf_coherence', startTime, endTime, mCoh);
trip.setSituationVariableAtTime(cas_situation, 'perf_phase', startTime, endTime, mPha);
trip.setSituationVariableAtTime(cas_situation, 'perf_gain', startTime, endTime, mGain);

end

% calcul du minimum des TIV du VP
function addMinTIV(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));
minTIV = min(TIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] TIV min = ' num2str(minTIV) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'TIV_min', startTime, endTime, minTIV);
end

% calcul de la moyenne des TIV du VP
function addMeanTIV(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));
meanTIV = mean(TIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] TIV moyen = ' num2str(meanTIV) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'TIV_moy', startTime, endTime, meanTIV);
end

% calcul de la variation des TIV du VP
function addVarTIV(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
TIVs = cell2mat(vitesseVPOccurences.getVariableValues('TIV'));
varTIV = std(TIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations TIV = ' num2str(varTIV) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'TIV_var', startTime, endTime, varTIV);
end

% calcul du TIV du VP lors d'un évènement particulier (levé de pédale)
function addEventTIV(trip, startTime, endTime, cas_situation)
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

% calcul des valeurs de DIV
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

% calcul des valeurs de DIV sans utiliser le TIV
function addDIVv2(trip)

% get values
localisationVPAllOccurences = trip.getAllDataOccurences('localisation');
pksVP = localisationVPAllOccurences.getVariableValues('pk');
veh_1000VPAllOccurences = trip.getAllDataOccurences('veh_1000');
pksVeh1000 = veh_1000VPAllOccurences.getVariableValues('pk');
vitesseVPAllOccurences = trip.getAllDataOccurences('vitesse');
vitessesTimecodes = vitesseVPAllOccurences.getVariableValues('timecode');
% vitessesVP = cell2mat(vitesseVPAllOccurences.getVariableValues('vitesse'));
% tivsVP = cell2mat(vitesseVPAllOccurences.getVariableValues('TIV'));
% divsVP = cell2mat(vitesseVPAllOccurences.getVariableValues('DIV'));
trip.setIsBaseData('vitesse', 0);
divs = (cell2mat(pksVeh1000) - cell2mat(pksVP))/1000 - 3.0258;
% create DIV column if necessary
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable('vitesse', 'DIVv2')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('DIVv2');
    bindVariable.setType('REAL');
    bindVariable.setUnit('m');
    bindVariable.setComments('DIVv2 du VP calcule');
    trip.addDataVariable('vitesse', bindVariable);
end

% add DIV values
disp('Calculating DIVs ...');
for i_occurence = 1:1:length(vitessesTimecodes)
    trip.setDataVariableAtTime('vitesse', 'DIVv2', vitessesTimecodes{i_occurence}, divs(i_occurence));
end
trip.setIsBaseData('vitesse', 1);

end

% calculate Min DIV VP
function addMinDIV(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
DIVs = cell2mat(vitesseVPOccurences.getVariableValues('DIVv2'));
minDIV = min(DIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] DIV minimum = ' num2str(minDIV) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'DIV_min', startTime, endTime, minDIV)
end

% calculate Mean DIV VP
function addMeanDIV(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
DIVs = cell2mat(vitesseVPOccurences.getVariableValues('DIVv2'));
meanDIV = mean(DIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] DIV moyen = ' num2str(meanDIV) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'DIV_moy', startTime, endTime, meanDIV)
end

% calculate variations of DIV VP
function addVarDIV(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
DIVs = cell2mat(vitesseVPOccurences.getVariableValues('DIVv2'));
varDIV = std(DIVs);
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations DIV = ' num2str(varDIV) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'DIV_var', startTime, endTime, varDIV)
end

% calcul du DIV du VP lors d'un évènement particulier (levé de pédale)
function addEventDIV(trip, startTime, endTime, cas_situation)
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
disp(['[' num2str(startTime) ';' num2str(endTime) '] DIV levé de pédale = ' num2str(DIVEvent) ' s']);
trip.setSituationVariableAtTime(cas_situation, 'DIV_levPed', startTime, endTime, DIVEvent);
end

% calculate mean speed VP
function addMeanSpeed(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
Vvp = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));
meanVvp = mean(Vvp)*3.6;
disp(['[' num2str(startTime) ';' num2str(endTime) '] vitesse moyenne = ' num2str(meanVvp) ' km/h']);
trip.setSituationVariableAtTime(cas_situation, 'vit_moy', startTime, endTime, meanVvp);
end

% calculate speed VP variations
function addSpeedVariations(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
Vvp = cell2mat(vitesseVPOccurences.getVariableValues('vitesse'));
varVvp = std(Vvp)*3.6;
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations de vitesse = ' num2str(varVvp) ' km/h']);
trip.setSituationVariableAtTime(cas_situation, 'vit_var', startTime, endTime, varVvp);
end

% calcul moyenne d'accélération/décélération du VP et durées
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

% calcul du nombre d'à-coups sur l'accélération (à partir de la dérivée de l'accélération)
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

% calcul de la moyenne du pourcentage d'enfoncement de la pédale de frein
function addMeanBreakPedalPercentage(trip, startTime, endTime, cas_situation)
vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
breakValues = vitesseOccurences.getVariableValues('frein');
meanBreakPercentage = (mean(cell2mat(breakValues)) / 255) * 100;
disp(['[' num2str(startTime) ';' num2str(endTime) '] meanBreakPercentage : ' num2str(meanBreakPercentage) '%']);
trip.setSituationVariableAtTime(cas_situation, 'frein_moy', startTime, endTime, meanBreakPercentage);
end

% calcul de la valeur maximale de pourcentage d'enfoncement de la pédale de frein
function addMaxBreakPercentage(trip, startTime, endTime, cas_situation)
vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
breakValues = vitesseOccurences.getVariableValues('frein');
maxBreakPercentage = (max(cell2mat(breakValues)) / 255) * 100;
disp(['[' num2str(startTime) ';' num2str(endTime) '] maxBreakPercentage : ' num2str(maxBreakPercentage) '%']);
trip.setSituationVariableAtTime(cas_situation, 'frein_max', startTime, endTime, maxBreakPercentage);
end

% calcul du temps de réaction entre l'allumage du feu stop et la levée de la pédale d'accélérateur
function addTRDecel(trip, startTime, endTime, cas_situation)
feuxStopOccurences = trip.getEventOccurencesInTimeInterval('feux_stop_OnOff', startTime, endTime);
feuxStopTimecodes = feuxStopOccurences.getVariableValues('timecode');
TCFeuxStopOn = feuxStopTimecodes{1};
vitesseOccurences = trip.getDataOccurencesInTimeInterval('vitesse', startTime, endTime);
vitesseTimecodes = vitesseOccurences.getVariableValues('timecode');
AccelValues = vitesseOccurences.getVariableValues('accelerateur');
TCdecel = cell2mat(vitesseTimecodes(find(diff(cell2mat(AccelValues)),1)));
if ~isempty(TCdecel)
    TRdecel = TCdecel - TCFeuxStopOn;
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
disp(['[' num2str(startTime) ';' num2str(endTime) '] TC levée accélérateur : ' num2str(TCdecel) 's']);
trip.setSituationVariableAtTime(cas_situation, 'TCdecel', startTime, endTime, TCdecel);
disp(['[' num2str(startTime) ';' num2str(endTime) '] temps de réaction levée accélérateur : ' num2str(TRdecel) 's']);
trip.setSituationVariableAtTime(cas_situation, 'TRdecel', startTime, endTime, TRdecel);
disp(['[' num2str(startTime) ';' num2str(endTime) '] anticipation : ' num2str(Anticip)]);
trip.setSituationVariableAtTime(cas_situation, 'anticip', startTime, endTime, Anticip);
end

% calcul du temps de réaction entre l'allumage du feu stop et l'appui commande Cd/Cg
function addTimeDetection(trip, startTime, endTime, cas_situation)
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

% calcul de la moyenne des positions latérales du VP par côté
function addMeanLateralPosition(trip, startTime, endTime, cas_situation)

trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
PositionLateraleVP = cell2mat(trajectoireVPOccurences.getVariableValues('voie'))'-2500;

MeanDepLatNeg = mean(PositionLateraleVP<0)/1000;
disp(['[' num2str(startTime) ';' num2str(endTime) '] moyenne de position latérale gauche = ' num2str(MeanDepLatNeg) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'posLatG_moy', startTime, endTime, MeanDepLatNeg);

MeanDepLatPos = mean(PositionLateraleVP>0)/1000;
disp(['[' num2str(startTime) ';' num2str(endTime) '] moyenne de position latérale droite = ' num2str(MeanDepLatPos) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'posLatD_moy', startTime, endTime, MeanDepLatPos);

end

% calcul des variations de positions latérales du VP (standard déviation)
function addLateralPositionVariation(trip, startTime, endTime, cas_situation)

trajectoireVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
PositionLateraleVP = cell2mat(trajectoireVPOccurences.getVariableValues('voie'))'-2500;

varDepLat = std(PositionLateraleVP);
disp(['[' num2str(startTime) ';' num2str(endTime) '] variations de position latérale = ' num2str(varDepLat/1000) ' m']);
trip.setSituationVariableAtTime(cas_situation, 'lat_var', startTime, endTime, varDepLat/1000);

end

% Calcul des valeurs d'angle au volant corrigées (données depuis le G27)
function addSteeringAnglesInDegrees(trip)

%get values
trajectoireVPAllOccurences = trip.getAllDataOccurences('trajectoire');
trajectoireTimecodes = trajectoireVPAllOccurences.getVariableValues('timecode');
AnglesVolantVP = cell2mat(trajectoireVPAllOccurences.getVariableValues('angle_volant'));
trip.setIsBaseData('trajectoire', 0);

% create SteeringAnglesInDegree column if necessary
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable('trajectoire', 'angle_volant_deg')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('angle_volant_deg');
    bindVariable.setType('REAL');
    bindVariable.setUnit('deg');
    bindVariable.setComments('Angle au volant en degres calcule');
    trip.addDataVariable('trajectoire', bindVariable);
end

% add SteeringAnglesInDegree values
disp('Calculating steering angles in degree ...');
for i_occurence = 1:1:length(trajectoireTimecodes)
    AnglesVolantVPInDegree = AnglesVolantVP(i_occurence)/40;
    trip.setDataVariableAtTime('trajectoire', 'angle_volant_deg', trajectoireTimecodes{i_occurence}, AnglesVolantVPInDegree);
end
trip.setIsBaseData('trajectoire', 1);

end

% calculate steeringAngles variations
function addSteeringAnglesVariations(trip, startTime, endTime, cas_situation)
vitesseVPOccurences = trip.getDataOccurencesInTimeInterval('trajectoire', startTime, endTime);
steeringAnglesValues = cell2mat(vitesseVPOccurences.getVariableValues('angle_volant_deg'));
varSteeringAngles = std(steeringAnglesValues);
disp(['[' num2str(startTime) ';' num2str(endTime) '] steering angles variations = ' num2str(varSteeringAngles) ' deg']);
trip.setSituationVariableAtTime(cas_situation, 'steeringAngles_var', startTime, endTime, varSteeringAngles)
end

% calcul des franchissements de voie du VP sur le scénario complet
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

% calcul des franchissements de voie du VP sur le scénario complet sans l'information "sortieVoie"
function addCrossingLaneAll2(trip, startTime, endTime)

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

% calcul des franchissements de voie du VP par situation
function addCrossingLaneBySituation(trip, startTime, endTime, cas_situation)

franchissementVPOccurences = trip.getSituationOccurencesInTimeInterval('franchissement', startTime, endTime);
dureeFranchissement = cell2mat(franchissementVPOccurences.getVariableValues('duree_franchissement'));
dureeFranchissementMoy = mean(dureeFranchissement);

trip.setSituationVariableAtTime(cas_situation, 'nb_SV', startTime, endTime, length(dureeFranchissement));
trip.setSituationVariableAtTime(cas_situation, 'dureeSV_moy', startTime, endTime, dureeFranchissementMoy);

end

% calcul des DMO (Distance de Mouvement Oculaire) distances entre 2 points de regards consécutifs
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

% calculate fixations quantities and durations
function addFixations(trip, startTime, endTime, cas_situation)
tobiiOccurences = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime);
dist_mouv_ocu = cell2mat(tobiiOccurences.getVariableValues('DMO'));

fix = 0;
i_fix = 0;
duree_fix_tot = 0;
for i = 1:length(dist_mouv_ocu)-2
    cond_fix = (dist_mouv_ocu(i+2) - dist_mouv_ocu(i)) < 6;
    if cond_fix
        duree_fix_tot = duree_fix_tot + 0.0333;
    else
        fix = 0;
    end
    if cond_fix && fix == 0
        i_fix = i_fix + 1;
        fix = 1;
    end
end

if i_fix > 0
    duree_fix_moy = duree_fix_tot/i_fix;
else
    duree_fix_moy = 0;
end

disp(['[' num2str(startTime) ';' num2str(endTime) '] nb_fix = ' num2str(i_fix)]);
disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_tot = ' num2str(duree_fix_tot) 's']);
disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_moy = ' num2str(duree_fix_moy) 's']);

trip.setSituationVariableAtTime(cas_situation, 'nb_fix', startTime, endTime, i_fix)
trip.setSituationVariableAtTime(cas_situation, 'duree_fix_tot', startTime, endTime, duree_fix_tot)
trip.setSituationVariableAtTime(cas_situation, 'duree_fix_moy', startTime, endTime, duree_fix_moy)

end

% calculate fixations quantities and durations in AOIs
function addFixationsAOI(trip, startTime, endTime, cas_situation, i)
tobiiOccurences = trip.getDataOccurencesInTimeInterval('tobii', startTime, endTime);
dist_mouv_ocu = cell2mat(tobiiOccurences.getVariableValues('DMO'));
etat_visite_AOI = cell2mat(tobiiOccurences.getVariableValues(['pieton_' num2str(i)]));

fix = 0;
i_fix = 0;
duree_fix_tot = 0;
i_fix_AOI = 0;
duree_fix_AOI_tot = 0;
for i = 1:length(dist_mouv_ocu)-2
    cond_fix = (dist_mouv_ocu(i+2) - dist_mouv_ocu(i)) < 6;
    if cond_fix
        duree_fix_tot = duree_fix_tot + 0.0333;
    else
        fix = 0;
    end
    if cond_fix && fix == 0
        i_fix = i_fix + 1;
        fix = 1;
    end
    if fix == 1 && etat_visite_AOI(i) == 1
        duree_fix_AOI_tot = duree_fix_AOI_tot + 0.0333;
    else
        fix_AOI = 0;
    end
    if fix == 1 && etat_visite_AOI(i) == 1 && fix_AOI == 0
        i_fix_AOI = i_fix_AOI + 1;
        fix_AOI = 1;
    end
end

if i_fix_AOI > 0
    duree_fix_AOI_moy = duree_fix_AOI_tot/i_fix_AOI;
else
    duree_fix_AOI_moy = 0;
end

disp(['[' num2str(startTime) ';' num2str(endTime) '] nb_fix_AOI = ' num2str(i_fix_AOI)]);
disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_AOI_tot = ' num2str(duree_fix_AOI_tot) 's']);
disp(['[' num2str(startTime) ';' num2str(endTime) '] duree_fix_AOI_moy = ' num2str(duree_fix_AOI_moy) 's']);

trip.setSituationVariableAtTime(cas_situation, 'nb_fix_AOI', startTime, endTime, i_fix_AOI)
trip.setSituationVariableAtTime(cas_situation, 'duree_fix_AOI_tot', startTime, endTime, duree_fix_AOI_tot)
trip.setSituationVariableAtTime(cas_situation, 'duree_fix_AOI_moy', startTime, endTime, duree_fix_AOI_moy)

end

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
