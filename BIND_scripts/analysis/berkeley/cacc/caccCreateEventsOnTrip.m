function caccCreateEventsOnTrip(trip)

% Set up variables we want to access
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load 'acc' data
accData = trip.getAllDataOccurences('acc');
% load 'active', 'enabled', 'car_space', 'set_speed', 'lidar_target_id', 'target_lock' variables
accActiveVar = accData.buildCellArrayWithVariables({'timecode' 'active'});
accEnabledVar = accData.buildCellArrayWithVariables({'timecode' 'enabled'});
accGapVar = accData.buildCellArrayWithVariables({'timecode' 'car_space'});
accSpeedVar = accData.buildCellArrayWithVariables({'timecode' 'set_speed'});
accTargetVar = accData.buildCellArrayWithVariables({'timecode' 'lidar_target_id'});
accTargetLockVar = accData.buildCellArrayWithVariables({'timecode' 'target_lock'});
accTimeGapVar = accData.buildCellArrayWithVariables({'timecode' 'time_gap'});
accApprWarnVar = accData.buildCellArrayWithVariables({'timecode' 'appr_warn'});
accLowSpeedWarnVar = accData.buildCellArrayWithVariables({'timecode' 'low_speed_warn'});
% eventsDiscoverers
thresholdUp = fr.lescot.bind.processing.eventDiscoverers.UpwardThresholdFinder;
thresholdDown = fr.lescot.bind.processing.eventDiscoverers.DownwardThresholdFinder;
changingValue = fr.lescot.bind.processing.eventDiscoverers.ChangingValueFinder;
% situationsDiscoverers
stableSituation = fr.lescot.bind.processing.situationDiscoverers.StabilityDiscoverer;
belowThreshold = fr.lescot.bind.processing.situationDiscoverers.BelowThreshold;

% CREATE (C)ACC Warning EVENTS
%%%%%%%%%%%%%%%%%%%%%%%%

% Creates the MetaEvent
eventName = 'ACC_warning_event';
variables = { ...
        {'event','TEXT'} ...
        };
caccCreateMetaEvent(trip,eventName,variables);

% (C)ACC approach warning
threshold = 0.5;
param = {num2str(threshold)};
eventsToSave = caccDiscoverEvents(thresholdUp,accApprWarnVar,param,'approach');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);
% (C)ACC low speed warning
threshold = 0.5;
param = {num2str(threshold)};
eventsToSave = caccDiscoverEvents(thresholdUp,accLowSpeedWarnVar,param,'low_speed');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);


% CREATE (C)ACC EVENTS
%%%%%%%%%%%%%%%%%%%%%%%%

% Creates the MetaEvent
eventName = 'ACC_events';
variables = { ...
        {'event','TEXT'}, ...
        {'timestamp','TEXT'},...
        {'gap setting','REAL'}, ...
        {'speed setting','REAL'} ...
        };
caccCreateMetaEvent(trip,eventName,variables);

% (C)ACC gap setting change
param = {};
eventsToSave = caccDiscoverEvents(changingValue,accGapVar,param,'gap setting');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);
% (C)ACC speed setting change
param = {};
eventsToSave = caccDiscoverEvents(changingValue,accSpeedVar,param,'speed setting');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);

% (C)ACC activation
% (C)ACC deactivation
threshold = 0.5;
param = {num2str(threshold)};
% detection of all the activation events of the (C)ACC
eventsToSave = caccDiscoverEvents(thresholdUp,accActiveVar,param,'activate');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);
% detection of all the de-activation events of the (C)ACC
eventsToSave = caccDiscoverEvents(thresholdDown,accActiveVar,param,'deactivate');
    % refining the information about the deactivation event
    [~,numEvents] = size(eventsToSave);
    for i=1:numEvents
        tc_deactivation = eventsToSave{1,i};
        accDataAfterDeact = trip.getDataOccurencesInTimeInterval('acc',tc_deactivation,tc_deactivation + 0.250);
        vehDataAfterDeact = trip.getDataOccurencesInTimeInterval('veh',tc_deactivation,tc_deactivation + 0.250);
        
        lowSpeedWarnAfterDeact = accDataAfterDeact.buildCellArrayWithVariables({'low_speed_warn'});
        brakeAfterDeact = vehDataAfterDeact.buildCellArrayWithVariables({'brake'});
        enabledDataAfterDeact = accDataAfterDeact.buildCellArrayWithVariables({'enabled'});
        
        lowSpeedDeact = max(cell2mat(lowSpeedWarnAfterDeact))==1;
        brakeDeact = max(cell2mat(brakeAfterDeact))==1;
        enabledDataAfterDeact = min(cell2mat(enabledDataAfterDeact))==0;
        if(lowSpeedDeact)
            eventsToSave{2,i} = [ eventsToSave{2,i} '_low_speed' ];
        end
        if(brakeDeact)
            eventsToSave{2,i} = [ eventsToSave{2,i} '_brake' ];
        end
        if(enabledDataAfterDeact)
            eventsToSave{2,i} = [ eventsToSave{2,i} '_ACC_power' ];
        end
        if( ~lowSpeedDeact && ~brakeDeact && ~enabledDataAfterDeact)
            eventsToSave{2,i} = [ eventsToSave{2,i} '_cancel_button' ];
        end
    end
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);

% (C)ACC enable
% (C)ACC disable
threshold = 0.5;
param = {num2str(threshold)};
% detection of all the enabling events of the (C)ACC
eventsToSave = caccDiscoverEvents(thresholdUp,accEnabledVar,param,'enable');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);
% detection of all the disabling events of the (C)ACC
eventsToSave = caccDiscoverEvents(thresholdDown,accEnabledVar,param,'disable');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);


% get gap setting and speed setting for each event.
timecodeOfEvents = trip.getAllEventOccurences(eventName).buildCellArrayWithVariables({'timecode'});
gapVar = cell(2,length(timecodeOfEvents));
speedVar = cell(2,length(timecodeOfEvents));
tsVar = cell(2,length(timecodeOfEvents));
for i=1:length(timecodeOfEvents)
    timecode = timecodeOfEvents{i};
    accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecode);
    accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'car_space', 'set_speed'});
    tsDataAtTimecode = trip.getDataOccurenceAtTime('ts',timecode);
    tsVariablesAtTimecode = tsDataAtTimecode.buildCellArrayWithVariables({'text'});
    gapVar{1,i} = timecode;
    speedVar{1,i} = timecode;
    tsVar{1,i} = timecode;
    gapVar{2,i} = accVariablesAtTimecode{1};
    speedVar{2,i} = accVariablesAtTimecode{2};
    tsVar{2,i} = tsVariablesAtTimecode{1};
    
end
trip.setBatchOfTimeEventVariablePairs(eventName, 'gap setting', gapVar);
trip.setBatchOfTimeEventVariablePairs(eventName, 'speed setting', speedVar);
trip.setBatchOfTimeEventVariablePairs(eventName, 'timestamp', tsVar);




% CREATE EVENT
% (C)ACC active target change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creates the MetaEvent
eventName = '(C)ACC-active target';
variables = { ...
        {'event','TEXT'}, ...
        {'old target','REAL'}, ...
        {'new target','REAL'} ...
        };
caccCreateMetaEvent(trip,eventName,variables);

% (C)ACC target change
param = {};
eventsToSave = caccDiscoverEvents(changingValue,accTargetVar,param,'change target');
if ~isempty(eventsToSave)
    timecodeOfEvents = eventsToSave(1,:);
    selectedIndice = [];
    % filter to find only events that are inside a 'target_lock'
    for i=1:length(timecodeOfEvents)
        timecode = timecodeOfEvents{i};
        accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecode);
        accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'target_lock'});
        if accVariablesAtTimecode{1}==1
            selectedIndice = [selectedIndice i];
        end
    end
    trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave(:,selectedIndice));

    timecodeJustBeforeEvents = getTimecodeJustBeforeChangingValue(accTargetVar);
    % old target id and new target id for each event.
    timecodeOfEvents = timecodeOfEvents(:,selectedIndice);
    timecodeJustBeforeEvents = timecodeJustBeforeEvents(:,selectedIndice);
    newTargetVar = cell(2,length(timecodeOfEvents));
    oldTargetVar = cell(2,length(timecodeOfEvents));
    for i=1:length(timecodeOfEvents)
        timecode = timecodeOfEvents{i};
        accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecode);
        accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'lidar_target_id'});
        newTargetVar{1,i} = timecode;
        newTargetVar{2,i} = accVariablesAtTimecode{1};
        timecodeBefore = timecodeJustBeforeEvents{i};
        accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecodeBefore);
        accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'lidar_target_id'});
        oldTargetVar{1,i} = timecode;
        oldTargetVar{2,i} = accVariablesAtTimecode{1};
    end
    trip.setBatchOfTimeEventVariablePairs(eventName, 'new target', newTargetVar);
    trip.setBatchOfTimeEventVariablePairs(eventName, 'old target', oldTargetVar);
end


% (C)ACC target lock
threshold = 0.5;
param = {num2str(threshold)};
% detection of all the times there is no target
eventsToSave = caccDiscoverEvents(thresholdUp,accTargetLockVar,param,'new target');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);

if ~isempty(eventsToSave)
    timecodeOfEvents = eventsToSave(1,:);
    % old target id and new target id for each event.
    newTargetVar = cell(2,length(timecodeOfEvents));
    oldTargetVar = cell(2,length(timecodeOfEvents));
    for i=1:length(timecodeOfEvents)
        timecode = timecodeOfEvents{i};
        accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecode);
        accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'lidar_target_id'});
        newTargetVar{1,i} = timecode;
        newTargetVar{2,i} =  accVariablesAtTimecode{1};
        oldTargetVar{1,i} = timecode;
        oldTargetVar{2,i} = -1;
    end
    trip.setBatchOfTimeEventVariablePairs(eventName, 'new target', newTargetVar);
    trip.setBatchOfTimeEventVariablePairs(eventName, 'old target', oldTargetVar);
end

% (C)ACC no target
threshold = 0.5;
param = {num2str(threshold)};
% detection of all the times there is no target
eventsToSave = caccDiscoverEvents(thresholdDown,accTargetLockVar,param,'no target');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);

if ~isempty(eventsToSave)
    timecodeOfEvents = eventsToSave(1,:);
    % old target id and new target id for each event.
    newTargetVar = cell(2,length(timecodeOfEvents));
    oldTargetVar = cell(2,length(timecodeOfEvents));
    for i=1:length(timecodeOfEvents)
        timecode = timecodeOfEvents{i};
        accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecode);
        accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'lidar_target_id'});
        newTargetVar{1,i} = timecode;
        newTargetVar{2,i} = -1;
        % Take the value of the previous target. If there is a new
        % lidar_target_id corresponding to no target (time_gap == -1), then the
        % new target id will be wrong. It is unlikely, but it actually can
        % happen. In this particular case, the new target will have the wrong
        % number.
        oldTargetVar{1,i} = timecode;
        oldTargetVar{2,i} = accVariablesAtTimecode{1};
    end
    trip.setBatchOfTimeEventVariablePairs(eventName, 'new target', newTargetVar);
    trip.setBatchOfTimeEventVariablePairs(eventName, 'old target', oldTargetVar);
end

% (C)ACC activation
% (C)ACC deactivation
threshold = 0.5;
param = {num2str(threshold)};
% detection of all the activation events of the (C)ACC
eventsToSave = caccDiscoverEvents(thresholdUp,accActiveVar,param,'(C)ACC activate ');

if ~isempty(eventsToSave)
    % check if an event already exist at those timecodes
    timecodeOfEvents = eventsToSave(1,:);
    for i=1:length(timecodeOfEvents)
        timecode = timecodeOfEvents{i};
        try
            eventAtTimecode = trip.getEventOccurenceAtTime(eventName,timecode);
            foundEventNameCell = eventAtTimecode.getVariableValues('event');
            eventsToSave{2,i} = ['(C)ACC activate ' foundEventNameCell{1}];
            if not(strcmp(eventAtTimecode.getVariableValues('event'),'new target'))
                disp('WARNING: a strange thing happened in caccCreateEventsOnTrip:');
                str = sprintf('an event "%s" was detected while it should not!', eventAtTimecode.getVariableValues('event'));
                disp(str);
            end
        catch ME
            if strcmp(ME.identifier,'Trip:getLineAtTime:TimeCodeNotFound')
    %        if strcmp(ME.identifier,'getEventOccurenceAtTime:TimeCodeNotFound')
                eventsToSave{2,i} = '(C)ACC activate no target';
            else
                rethrow(ME);
            end
        end
    end
    trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);
end
% detection of all the de-activation events of the (C)ACC
eventsToSave = caccDiscoverEvents(thresholdDown,accActiveVar,param,'(C)ACC deactivate');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);


% CREATE EVENT
% (C)ACC target change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creates the MetaEvent
eventName = '(C)ACC target';
variables = { ...
        {'event','TEXT'}, ...
        {'old target','REAL'}, ...
        {'new target','REAL'} ...
        };
caccCreateMetaEvent(trip,eventName,variables);

% (C)ACC target change
param = {};
eventsToSave = caccDiscoverEvents(changingValue,accTargetVar,param,'change target');
timecodeJustBeforeEvents = getTimecodeJustBeforeChangingValue(accTargetVar);
if ~isempty(eventsToSave)
    timecodeOfEvents = eventsToSave(1,:);
    % filter to find only events that are inside a 'target_lock'
    for i=1:length(timecodeOfEvents)
        timecodeBefore = timecodeJustBeforeEvents{i};
        accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecodeBefore);
        accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'time_gap'});
     %   accVariablesAtTimecode{1}
        if accVariablesAtTimecode{1} == -1
            eventsToSave{2,i} = 'new target';
        end
    end
    trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);

    % old target id and new target id for each event.
    newTargetVar = cell(2,length(timecodeOfEvents));
    oldTargetVar = cell(2,length(timecodeOfEvents));
    for i=1:length(timecodeOfEvents)
        timecode = timecodeOfEvents{i};
        accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecode);
        accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'lidar_target_id','time_gap'});
        newTargetVar{1,i} = timecode;
        % Deal with false new target (replace id by -1)
        if accVariablesAtTimecode{2} == -1
            newTargetVar{2,i} = -1;
        else
            newTargetVar{2,i} = accVariablesAtTimecode{1};
        end
        % deal with the previous target depending on it is a new target or a
        % target change.
        if strcmp(eventsToSave{2,i},'new target')
            oldTargetVar{1,i} = timecode;
            oldTargetVar{2,i} = -1;
        else  
            timecodeBefore = timecodeJustBeforeEvents{i};
            accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecodeBefore);
            accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'lidar_target_id'});
            oldTargetVar{1,i} = timecode;
            oldTargetVar{2,i} = accVariablesAtTimecode{1};

            timecodeBefore = timecodeJustBeforeEvents{i};
            accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecodeBefore);
            accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'lidar_target_id','time_gap'});
            oldTargetVar{1,i} = timecode;
            % Deal with false new target (replace id by -1)
            if accVariablesAtTimecode{2} == -1
                oldTargetVar{2,i} = -1;
            else
                oldTargetVar{2,i} = accVariablesAtTimecode{1};
            end
        end

    end
    trip.setBatchOfTimeEventVariablePairs(eventName, 'new target', newTargetVar);
    trip.setBatchOfTimeEventVariablePairs(eventName, 'old target', oldTargetVar);
end

% (C)ACC no target
threshold = -0.5;
param = {num2str(threshold)};
% detection of all the times there is no target
eventsToSave = caccDiscoverEvents(thresholdDown,accTimeGapVar,param,'no target');
trip.setBatchOfTimeEventVariablePairs(eventName, 'event', eventsToSave);

if ~isempty(eventsToSave)
    timecodeOfEvents = eventsToSave(1,:);
    % old target id and new target id for each event.
    newTargetVar = cell(2,length(timecodeOfEvents));
    oldTargetVar = cell(2,length(timecodeOfEvents));
    for i=1:length(timecodeOfEvents)
        timecode = timecodeOfEvents{i};
        accDataAtTimecode = trip.getDataOccurenceAtTime('acc',timecode);
        accVariablesAtTimecode = accDataAtTimecode.buildCellArrayWithVariables({'lidar_target_id'});
        newTargetVar{1,i} = timecode;
        newTargetVar{2,i} = -1;
        % Take the value of the previous target. If there is a new
        % lidar_target_id corresponding to no target (time_gap == -1), then the
        % new target id will be wrong. It is unlikely, but it actually can
        % happen. In this particular case, the new target will have the wrong
        % number.
        oldTargetVar{1,i} = timecode;
        oldTargetVar{2,i} = accVariablesAtTimecode{1};
    end
    trip.setBatchOfTimeEventVariablePairs(eventName, 'new target', newTargetVar);
    trip.setBatchOfTimeEventVariablePairs(eventName, 'old target', oldTargetVar);
end

% CREATE SITUATION
% detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creates the MetaEvent
situationName = 'detection';
variables = { ...
        {'situation','TEXT'} ...
        };
caccCreateMetaSituation(trip,situationName,variables);

% target id stable
param = {};
situationToSave = caccDiscoverSituations(stableSituation,accTargetVar,param,'stable_target');
trip.setBatchOfTimeSituationVariableTriplets(situationName, 'situation', situationToSave);

% no target (time gap < 0)
param = {'0'};
situationToSave = caccDiscoverSituations(belowThreshold,accTimeGapVar,param,'no_target');
trip.setBatchOfTimeSituationVariableTriplets(situationName, 'situation', situationToSave);

end