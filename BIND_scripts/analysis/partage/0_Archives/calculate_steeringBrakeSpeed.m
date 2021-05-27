% Script de calcul de la variable teeringBrake : produit de l'angle volant
% et du pourcentage d'enfoncement / 100

function calculate_steeringBrakeSpeed(trip)

% Load des tables de données capteurs (~1mn)

sensormeasure = trip.getAllDataOccurences('SensorsMeasures');
sensordata = trip.getAllDataOccurences('SensorsData');
% gps5Hz = trip.getAllDataOccurences('GPS5Hz');

%% Load des variables pertinentes (<2sec)

angleVolantBrut=sensormeasure.getVariableValues('SteeringwheelAngle');
pourcentFrein=sensordata.getVariableValues('%Brake');
speed=sensormeasure.getVariableValues('Speed');
%speed=sensormeasure.getVariableValues('Speed');
time = sensormeasure.getVariableValues('timecode');
steeringBrakeSpeed = sensordata.buildCellArrayWithVariables({'timecode','TopConsigne'});

matVolant = cell2mat(angleVolantBrut);
matFrein = cell2mat(pourcentFrein);
matSpeed = cell2mat(speed);

% Création de la nouvelle variable que l'on va calculer
dataName = 'SensorsData'; 
dataVariable = fr.lescot.bind.data.MetaDataVariable;
dataVariable.setName('steeringBrakeSpeed');
dataVariable.setType('REAL');
trip.addDataVariable(dataName,dataVariable);

%Procédure de calcul
disp('calculating new data');
steeringBrakeSpeed(2,:)=num2cell(matSpeed.*matFrein.*matVolant/100);

%Insertion dans le trip
tic
disp('inserting new data in trip');
trip.setBatchOfTimeDataVariablePairs('SensorsData','steeringBrakeSpeed',steeringBrakeSpeed);
toc
end