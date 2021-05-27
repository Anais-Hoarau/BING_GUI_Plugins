function P3_BasicCalculation(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

import fr.lescot.bind.processing.situationAggregators.*

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

% Use BIND to read data in matlab workspace
situationPOI = theTrip.getAllSituationOccurences('Intersection');
situationTime = situationPOI.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
sensormeasure = theTrip.getAllDataOccurences('SensorsMeasures');
sensordata = theTrip.getAllDataOccurences('SensorsData');

% Create a cell array to put the variables you want to calculate
% This list can be extended according to the need of the user
variables = cell(1,5); % The second number is the quantity of the variables that you wanna treat
variables{1} = 'Speed';
variables{2} = 'SteeringwheelAngle';
variables{3} = '%Accelerator';
variables{4} = '%Brake';
variables{5} = '%Clutch';

% calculate & save the averages and the standard deviations
i = 1; % Accumulator to skim the whole list
while i <= length(variables)
    % We switch different variable to different cases and to do different treatments.
    switch lower(variables{i})
        case 'speed'
            speeddata = sensormeasure.buildCellArrayWithVariables({'timecode' 'Speed'});
            disp('calculate meanspeed');
            meanspeed = Average.process(situationTime,speeddata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','AverageSpeed',meanspeed);
            disp('calculate stdevspeed');
            stdevspeed = Stdev.process(situationTime,speeddata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','StdevSpeed',stdevspeed);
        case 'steeringwheelangle'
            angledata = sensormeasure.buildCellArrayWithVariables({'timecode' 'SteeringwheelAngle'});
            disp('calculate meanangle');
            meanangle = Average.process(situationTime,angledata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','AverageAngle',meanangle);
            disp('calculate stdevangle');
            stdevangle = Stdev.process(situationTime,angledata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','StdevAngle',stdevangle);
        case '%accelerator'
            accdata = sensordata.buildCellArrayWithVariables({'timecode' '%Accelerator'});
            disp('calculate mean%accelerator');
            meanacc = Average.process(situationTime,accdata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','AverageAccelerator',meanacc);
            disp('calculate stdev%accelerator');
            stdevacc = Stdev.process(situationTime,accdata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','StdevAccelerator',stdevacc);
        case '%brake'
            brakedata = sensordata.buildCellArrayWithVariables({'timecode' '%Brake'});
            disp('calculate mean%brake');
            meanbrake = Average.process(situationTime,brakedata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','AverageBrake',meanbrake);
            disp('calculate stdev%brake');
            stdevbrake = Stdev.process(situationTime,brakedata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','StdevBrake',stdevbrake);
        case '%clutch'
            clutchdata = sensordata.buildCellArrayWithVariables({'timecode' '%Clutch'});
            disp('calculate mean%brake');
            meanclutch = Average.process(situationTime,clutchdata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','AverageClutch',meanclutch);
            disp('calculate stdev%brake');
            stdevclutch = Stdev.process(situationTime,clutchdata);
            theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','StdevClutch',stdevclutch);
        otherwise
            disp('No method specified to calculate');
    end
    i = i + 1;
end
delete(theTrip);
close('all');
delete(timerfindall);
clear all;
end