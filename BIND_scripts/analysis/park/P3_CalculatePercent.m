function P3_CalculatePercent(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

import fr.lescot.bind.processing.signalProcessors.*

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = ...
fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);
tripMetaInformations = theTrip.getMetaInformations();

% Use BIND to read data in matlab workspac
sensormeasure = theTrip.getAllDataOccurences('SensorsMeasures');
timeacc = sensormeasure.buildCellArrayWithVariables({'timecode' 'Accelerator'});
timebrake = sensormeasure.buildCellArrayWithVariables({'timecode' 'Brake'});
timeclutch = sensormeasure.buildCellArrayWithVariables({'timecode' 'Clutch'});

% Check in meta datas if output events and outpus variables are
% available
if (~tripMetaInformations.existData('ProcessedData'))
    disp('The output event doesnt exist!');
    disp('And it will be created!')
    data = fr.lescot.bind.data.MetaData();
    pacc = fr.lescot.bind.data.MetaDataVariable();
    pbrake = fr.lescot.bind.data.MetaDataVariable();
    pclutch = fr.lescot.bind.data.MetaDataVariable();
    data.setName('ProcessedData');
    pacc.setName('%Accelerator');
    pbrake.setName('%Brake');
    pclutch.setName('%Clutch');
    data.setVariables({pacc,pbrake,pclutch});
    theTrip.addData(data);
else
    if(~tripMetaInformations.existDataVariable('POI','Id')&& ~tripMetaInformations.existSituationVariable('POI','StartTime')&&~tripMetaInformations.existSituationVariable('POI','EndTime')&&~tripMetaInformations.existSituationVariable('POI','Distance'))
        disp('The output event variable dont exist!');
        disp('Please delete the table situationPOI and the MetaSituation situationPOI to store the data!');
        disp('--- The end ---');
        % Because if there is no variable for situationPOI, the table situationPOI could not
        % exist, but if it does not exist, we could not write the data in it.
        % So it is better to delete all to create a new one
        return;
    else
        disp('The output event and output event variables already exist!');
        disp('--- The end ---');
        return;
    end
end

result1 = Scaler.process(timeacc,{num2str(-34.22)});
result2 = Scaler.process(timebrake,{num2str(25.21)});
result3 = Scaler.process(timeclutch,{num2str(25.21)});

theTrip.setBatchOfTimeDataVariablePairs('ProcessedData','%Accelerator',result1);
disp('Finish 1');
theTrip.setBatchOfTimeDataVariablePairs('ProcessedData','%Brake',result2);
disp('Finish 2');
theTrip.setBatchOfTimeDataVariablePairs('ProcessedData','%Clutch',result3);
disp('Finish 3');
delete(theTrip);
close('all');
delete(timerfindall);
clear all;
end