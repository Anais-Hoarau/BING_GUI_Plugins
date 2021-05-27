% Script de calcul de la variable teeringBrake : produit de l'angle volant
% et du pourcentage d'enfoncement / 10

function calculate_steeringBrake(trip)

% Load des tables de données capteurs (

sensormeasure = trip.getAllDataOccurences('SensorsMeasures');
sensordata = trip.getAllDataOccurences('SensorsData');

%% Load des variables pertinentes 

angleVolantBrut=sensormeasure.buildCellArrayWithVariables({'timecode','SteeringwheelAngle'});
pourcentFrein=sensordata.buildCellArrayWithVariables({'timecode','%Brake'});
% time = sensormeasure.getVariableValues('timecode');

matVolant = cell2mat(angleVolantBrut(2,:));
matFrein = cell2mat(pourcentFrein(2,:));

% Création de la nouvelle variable que l'on va calculer
data=fr.lescot.bind.data.MetaData;
data.setName('ExploratoryData'); 
trip.addData(data);
dataName='ExploratoryData';
dataVariable = fr.lescot.bind.data.MetaDataVariable;
dataVariable.setName('steeringBrake');
dataVariable.setType('REAL');
trip.addDataVariable(dataName,dataVariable);
% dataVariable.setName('steeringBrakeSpeed');
% trip.addDataVariable(dataName,dataVariable);

%Procédure de calcul
disp('calculating new data');
[~,taille]=size(pourcentFrein);
steeringBrake=cell(2,taille);
steeringBrake(1,:)=pourcentFrein(1,:);
steeringBrake(2,:)=num2cell(matVolant.*matFrein/10);

%Insertion dans le trip
disp('inserting new data in trip');
tic
trip.setBatchOfTimeDataVariablePairs('ExploratoryData','steeringBrake',steeringBrake);
toc
end