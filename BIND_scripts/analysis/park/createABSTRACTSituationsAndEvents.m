%{ sample function for possible use of processing classes

%}
function createABSTRACTSituationsAndEvents( theTrip )

targetSituationTableName = 'Observe';

tableCreationNeeded = false;
%first check metadata
if (theTrip.getMetaInformations().existSituation(targetSituationTableName))
    %if it is there, check if  the variables are correct
    if (theTrip.getMetaInformations().existSituationVariable(targetSituationTableName, 'startTimecode') && theTrip.getMetaInformations().existSituationVariable(targetSituationTableName, 'endTimecode') && theTrip.getMetaInformations().existSituationVariable(targetSituationTableName, 'endTimecode') )
        % table can store data : empty it for regeneration
        theTrip.removeAllSituationOccurences(targetSituationTableName);
    else
        % table exist but cannot store data : delete and recreate with good
        % strucuture
        theTrip.removeSituation(targetSituationTableName);
        tableCreationNeeded = true;
    end
else
    % table does not exist
    tableCreationNeeded = true;
end

if tableCreationNeeded
    % create table structure for backup
    newSituation = fr.lescot.bind.kernel.MetaSituation();
    newSituation.setName(targetSituationTableName);
    
    timeBegin = fr.lescot.bind.data.MetaSituationVariable();
    timeBegin.setName('startTimecode');
    timeBegin.setIsUnique(true);
    
    timeEnd = fr.lescot.bind.data.MetaSituationVariable();
    timeEnd.setName('endTimecode');
    timeEnd.setIsUnique(true);
    
    label = fr.lescot.bind.data.MetaSituationVariable();
    label.setName('OIType');
    
    newSituation.setVariables({timeBegin,timeEnd,label});
    newSituation.setIsBase(false);
    theTrip.addSituation(newSituation);
end

% real processing
OIType = { ...
     'Appui_Frein',...
     'Frein_Fort',...
     'Frein_Abrupt',...
     'Frein_TempsReaction',...
     'Accelerateur_Reacceleration',...
     'Vitesse_ALarret',...
     'Vitesse_AuPas',...
     'Acceleration_Longitudinale',...
     'Deceleration_Longitudinale',...
    };

% This threshold will be used as default values in the following script.
default_threshold_pedals = 2;

% get all data values from trip data "SensorsMeasures"
recordSensorsMeasures = theTrip.getAllDataOccurences('SensorsMeasures');
% get all data values from trip data "GPS5Hz"
recordGPSData = theTrip.getAllDataOccurences('GPS5Hz');
            
for x = OIType
    relevantSituations = {};
    OIName = char(x);
    
    switch OIName
        case 'Appui_Frein'
            % create cell array using only 'timecode' and 'Brake' values
            timebrake = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'Brake'});
            
            % convert brake sensor value on a 0%-100% scale
            timebrake = fr.lescot.bind.processing.signalProcessors.Scaler.process(timebrake,{num2str(25.21)});
            
            threshold = default_threshold_pedals;
            % detection of all situation where braking is above 40%
            relevantSituations = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(timebrake,{num2str(threshold)});
        
        case 'Frein_Fort'
            % create cell array using only 'timecode' and 'Brake' values
            timebrake = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'Brake'});
            
            % convert brake sensor value on a 0%-100% scale
            timebrake = fr.lescot.bind.processing.signalProcessors.Scaler.process(timebrake,{num2str(25.21)});
            
            threshold = 45;
            % detection of all situation where braking is above 40%
            relevantSituations = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(timebrake,{num2str(threshold)});
        
        case 'Frein_Abrupt'
            % create cell array using only 'timecode' and 'Brake' values
            timebrake = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'Brake'});
            
            % convert brake sensor value on a 0%-100% scale
            timebrake = fr.lescot.bind.processing.signalProcessors.Scaler.process(timebrake,{num2str(25.21)});
            
            % calculate derivative
            
            timebrakeDerivative = fr.lescot.bind.processing.signalProcessors.QADDerivative.process(timebrake,{num2str(50)});
            
            % If calculated depending on the driver:
            %brakeDerivative = cell2mat(timebrakeDerivative(2,:));
            %maxBrakeDerivative = max(brakeDerivative);
            %threshold = 0.8 * maxBrakeDerivative;
            threshold = 350;
            % detection of all situation where braking derivative is above
            % 100%/s
            relevantSituations = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(timebrakeDerivative,{num2str(threshold)});
            
        case 'Frein_TempsReaction'
            % create cell array using only 'timecode' and 'Brake' values
            timebrake = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'Brake'});
            % create cell array using only 'timecode' and 'Brake' values
            timeaccelerator = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'Accelerator'});
            
            % convert accelerator sensor value on a 0%-100% scale
            timeaccelerator = fr.lescot.bind.processing.signalProcessors.Scaler.process(timeaccelerator,{num2str(-34.22)});
            % convert brake sensor value on a 0%-100% scale
            timebrake = fr.lescot.bind.processing.signalProcessors.Scaler.process(timebrake,{num2str(25.21)});
            
            threshold = default_threshold_pedals;
            % detection of all situation where braking is above 5%
            relevantBrakingSituations = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(timebrake,{num2str(threshold)});
            % detection of all situation where braking is above 5%
            relevantAcceleratingSituations = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(timeaccelerator,{num2str(threshold)});
            
            k = 1;
            relevantSituationDetected = 0;
            timeStartPreviousBraking = 0;
            timeStopPreviousBraking = 0;
            
            for i=1:length(relevantBrakingSituations)
                timeStartBraking = relevantBrakingSituations{1,i};
                timeStopBraking = relevantBrakingSituations{2,i};
                
                for j=1:length(relevantAcceleratingSituations)
                    timeStartAccelerating = relevantAcceleratingSituations{1,j};
                    timeStopAccelerating = relevantAcceleratingSituations{2,j};
                    
                    if timeStopAccelerating < timeStartBraking
                        % good pattern detected  
                        relevantSituationDetected = j;
                    end
                end
                
                if relevantSituationDetected ~= 0
                    
                    relevantTimeStartAccelerating = relevantAcceleratingSituations{1,relevantSituationDetected};
                    relevantTimeStopAccelerating = relevantAcceleratingSituations{2,relevantSituationDetected};
                    
                    % check if there is no other brake between the relevant
                    % Acceleration sequence and this current brake sequence
                    if timeStartPreviousBraking > relevantTimeStopAccelerating
                        % there was another brake situation before!
                    else
                        % no other situation : can save !
                        relevantSituations{1,k} = relevantTimeStopAccelerating;
                        relevantSituations{2,k} = timeStartBraking;
                        k = k + 1;
                    end
                    relevantSituationDetected = 0;
                end
                
                timeStartPreviousBraking = timeStartBraking;
                timeStopPreviousBraking = timeStopBraking;
            end
            case 'Accelerateur_Reacceleration'
            % create cell array using only 'timecode' and 'Brake' values
            timebrake = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'Brake'});
            % create cell array using only 'timecode' and 'Brake' values
            timeaccelerator = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'Accelerator'});
            
            % convert accelerator sensor value on a 0%-100% scale
            timeaccelerator = fr.lescot.bind.processing.signalProcessors.Scaler.process(timeaccelerator,{num2str(-34.22)});
            % convert brake sensor value on a 0%-100% scale
            timebrake = fr.lescot.bind.processing.signalProcessors.Scaler.process(timebrake,{num2str(25.21)});
            
            threshold = default_threshold_pedals;
            % detection of all situation where braking is above 5%
            relevantBrakingSituations = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(timebrake,{num2str(threshold)});
            % detection of all situation where braking is above 5%
            relevantAcceleratingSituations = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(timeaccelerator,{num2str(threshold)});
            
            k = 1;
            relevantSituationDetected = 0;
            timeStartPreviousAccelerating = 0;
            timeStopPreviousAccelerating = 0;
            
            for i=1:length(relevantAcceleratingSituations)
                timeStartAccelerating = relevantAcceleratingSituations{1,i};
                timeStopAccelerating = relevantAcceleratingSituations{2,i};
                
                for j=1:length(relevantBrakingSituations)
                    timeStartBraking = relevantBrakingSituations{1,j};
                    timeStopBraking = relevantBrakingSituations{2,j};
                    
                    if timeStopBraking < timeStartAccelerating
                        % good pattern detected  
                        relevantSituationDetected = j;
                    end
                end
                
                if relevantSituationDetected ~= 0
                    
                    relevantTimeStartBraking = relevantBrakingSituations{1,relevantSituationDetected};
                    relevantTimeStopBraking = relevantBrakingSituations{2,relevantSituationDetected};
                    
                    % check if there is no other brake between the relevant
                    % Acceleration sequence and this current brake sequence
                    if timeStartPreviousAccelerating > relevantTimeStopBraking
                        % there was another brake situation before!
                    else
                        % no other situation : can save !
                        relevantSituations{1,k} = relevantTimeStopBraking;
                        relevantSituations{2,k} = timeStartAccelerating;
                        k = k + 1;
                    end
                    relevantSituationDetected = 0;
                end
                
                timeStartPreviousAccelerating = timeStartAccelerating;
                timeStopPreviousAccelerating = timeStopAccelerating;
            end
            case 'Vitesse_ALarret' 
            % create cell array using only 'timecode' and 'Speed' values
            timespeed = recordGPSData.buildCellArrayWithVariables({'timecode' 'VitesseGPS_5Hz'});
            threshold = 2;
            % detection of all situation where speed is below 2%
            relevantSituations = fr.lescot.bind.processing.situationDiscoverers.BelowThreshold.extract(timespeed,{num2str(threshold)});
            
            case 'Vitesse_AuPas' 
            % create cell array using only 'timecode' and 'Speed' values
            timespeed = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'Speed'});
            threshold = 5;
            % detection of all situation where speed is below 5%
            relevantSituations = fr.lescot.bind.processing.situationDiscoverers.BelowThreshold.extract(timespeed,{num2str(threshold)});
            
            case 'Deceleration_Longitudinale' 
            % create cell array using only 'timecode' and 'Speed' values
            timeaccX = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'AccX'});
            
            % smoothing
            timeaccX = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process(timeaccX,{'25'});
            
            threshold = -0.6;
            % detection of all situation where below is below -0.6
            relevantSituations = fr.lescot.bind.processing.situationDiscoverers.BelowThreshold.extract(timeaccX,{num2str(threshold)});
            %case 'Acceleration_LongitudinalAcceleration' 
             case 'Acceleration_Longitudinale' 
            % create cell array using only 'timecode' and 'Speed' values
            timeaccX = recordSensorsMeasures.buildCellArrayWithVariables({'timecode' 'AccX'});
            
            % smoothing
            timeaccX = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process(timeaccX,{'25'});
            
            threshold = 0.6;
            % detection of all situation where below is above 0.6
            relevantSituations = fr.lescot.bind.processing.situationDiscoverers.AboveThreshold.extract(timeaccX,{num2str(threshold)});
            %case 'Acceleration_LongitudinalAcceleration' 
    end
    
    % create triplets of StartTimecode, EndTimecode, Labels for backups
    for i=1:length(relevantSituations)
        tripletsToSave{1,i} = relevantSituations{1,i};
        tripletsToSave{2,i} = relevantSituations{2,i};
        tripletsToSave{3,i} = OIName;
    end
    
    % backups the data
    theTrip.setBatchOfTimeSituationVariableTriplets(targetSituationTableName, 'OIType', tripletsToSave);
end

end