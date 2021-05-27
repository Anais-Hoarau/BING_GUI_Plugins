function P11_SRRandEntropy(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

import fr.lescot.bind.processing.*
import fr.lescot.bind.processing.situationAggregators.*

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

if ~theTrip.getMetaInformations().existSituationVariable('Intersection','SRR')
    srr = fr.lescot.bind.data.MetaSituationVariable();
    srr.setName('SRR');
    srr.setType('REAL');
    theTrip.addSituationVariable('Intersection',srr);
end

if ~theTrip.getMetaInformations().existSituationVariable('Intersection','Entropy')
    entropy = fr.lescot.bind.data.MetaSituationVariable();
    entropy.setName('Entropy');
    entropy.setType('REAL');
    theTrip.addSituationVariable('Intersection',entropy);
end

situation = theTrip.getAllSituationOccurences('Intersection');
situationTime = situation.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
data = theTrip.getAllDataOccurences('SensorsMeasures');
inputAngleData = data.buildCellArrayWithVariables({'timecode' 'SteeringwheelAngle'});

srrprocessedValues = SRR.process(situationTime, inputAngleData,{'higher',num2str(5)});
theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','SRR',srrprocessedValues);

entropyprocessedValues = SteeringEntropy.process(situationTime, inputAngleData);
theTrip.setBatchOfTimeSituationVariableTriplets('Intersection','Entropy',entropyprocessedValues);

