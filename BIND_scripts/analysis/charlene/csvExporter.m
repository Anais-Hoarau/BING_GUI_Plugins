function csvExporter()

    rootDir = uigetdir('.', 'Choose the directory containing all the participants');
    log = fopen([rootDir filesep 'failedExport.log'], 'w+');
    try
        listingFolder = dir(rootDir);
        %We keep only the dirs
        indicesToRemove = [];
        for i = 1:1:length(listingFolder)
            if (~listingFolder(i).isdir) || (any(strcmp({'.' '..'}, listingFolder(i).name)))
                indicesToRemove(end + 1) = i;
            end
        end
        listingFolder(indicesToRemove) = [];

        %Iterate on the folders, ie. on the participants
        for i = 1:1:length(listingFolder)
            csvFile = createCSVFile(rootDir, listingFolder(i));
            tripFilesList = listTrips([rootDir filesep listingFolder(i).name]);
            writeCSV(csvFile, tripFilesList)
            fclose(csvFile);
        end
    catch ME
        disp(ME.getReport());
        fprintf(log, '%s', ['######## ' pathToTrip ' ########' char(10)]);
        fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
    end
    fclose(log);
    
end

function writeCSV(csvFile, tripFilesList)
    %Header, hard coded, dirty style. I plead guilty your honor !
    header = 'DataID;Eventid;Drive;Ver;Condition;TaskZone;Event;Zone;TlStdSpd;TlAvgSpd;TlDist;TlSpdDz;StopTL;TlColour;MaxDecTL;RTTL;TlStdLp;TlAvgLp;GaStdSpd;GaAvgSpd;GapStop;GapPk;GapYes;GapRej;GVDis;GapMax;GapBig;LvNo;LvStdSpd;LvAvgSpd;LvSpdSt;LvSpdEn;LvGear;GearChg;LvStdLp;LvAvgLp;HwMin;HwAvg;HwStd;LvRt;TtcMin;TtcMax;TtcAvg;TtcStd;MaxDecLV';
    fprintf(csvFile, '%s\n', header);
    
    for i = 1:1:length(tripFilesList)
        disp(['[ ' num2str(i) ' ] Processing ' tripFilesList{i} '- TL']);
        currentTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFilesList{i}, 0.04, false);
        
        trafficLightOccurences = currentTrip.getAllSituationOccurences('Traffic_light');
        
        [dataID, drive, condition, version] = getInfosFromFileName(tripFilesList{i});
        
        scenarioIds = trafficLightOccurences.buildCellArrayWithVariables({'scenarioID'});
        events = trafficLightOccurences.buildCellArrayWithVariables({'event'});
        zones = trafficLightOccurences.buildCellArrayWithVariables({'zone'});
        speedStdDevs = trafficLightOccurences.buildCellArrayWithVariables({'speed_stdDev'});
        averageSpeeds = trafficLightOccurences.buildCellArrayWithVariables({'speed_average'});
        distancesFromTL = trafficLightOccurences.buildCellArrayWithVariables({'distance_from_TL_at_event'});
        decisionZoneEntrySpeeds = trafficLightOccurences.buildCellArrayWithVariables({'speed_at_decision_zone_entry'});
        stopppeds = trafficLightOccurences.buildCellArrayWithVariables({'stopped'});
        colourTrafficLights = trafficLightOccurences.buildCellArrayWithVariables({'ran_traffic_light'});
        maxDecelerations = trafficLightOccurences.buildCellArrayWithVariables({'maximum_deceleration'});
        reactionTimes = trafficLightOccurences.buildCellArrayWithVariables({'reaction_time'});
        lanePositionStdDevs = trafficLightOccurences.buildCellArrayWithVariables({'lane_position_stdDev'});
        lanePositionAverages = trafficLightOccurences.buildCellArrayWithVariables({'lane_position_average'});
        
        for j = 1:1:length(scenarioIds)
            fprintf(csvFile, '%s;', dataID);  
            fprintf(csvFile, '%s;', scenarioIds{j});
            fprintf(csvFile, '%s;', drive);  
            fprintf(csvFile, '%s;', version);
            fprintf(csvFile, '%s;', condition);
            fprintf(csvFile, '%s;', guessTaskZone(condition, scenarioIds{j}));
            fprintf(csvFile, '%s;', events{j});    
            fprintf(csvFile, '%s;', codeZone(zones{j}));
            fprintf(csvFile, '%.12f;', speedStdDevs{j});
            fprintf(csvFile, '%.12f;', averageSpeeds{j});
            fprintf(csvFile, '%s;', codeDistanceFromTL(zones{j}, distancesFromTL{j}));
            fprintf(csvFile, '%s;', codeDZEntrySpeed(zones{j}, decisionZoneEntrySpeeds{j}));
            fprintf(csvFile, '%s;', codeStops(zones{j}, stopppeds{j}));
            fprintf(csvFile, '%s;', codeTrafficLightColour(zones{j}, colourTrafficLights{j}));
            fprintf(csvFile, '%s;', codeDeceleration(zones{j}, maxDecelerations{j}));
            fprintf(csvFile, '%.12f;', reactionTimes{j});
            fprintf(csvFile, '%.12f;', lanePositionStdDevs{j});
            fprintf(csvFile, '%.12f;', lanePositionAverages{j}); 
            fprintf(csvFile, '%s', '99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;');
            fprintf(csvFile, '\n');
        end
        delete(currentTrip);
    end
    
    for i = 1:1:length(tripFilesList)
        disp(['[ ' num2str(i) ' ] Processing ' tripFilesList{i} '- GA']);
        currentTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFilesList{i}, 0.04, false);
        
        gapAcceptanceOccurences = currentTrip.getAllSituationOccurences('Gap_Acceptance');
        
        [dataID, drive, condition, version] = getInfosFromFileName(tripFilesList{i});
        
        scenarioIds = gapAcceptanceOccurences.buildCellArrayWithVariables({'scenarioID'});
        events = gapAcceptanceOccurences.buildCellArrayWithVariables({'event'});
        zones = gapAcceptanceOccurences.buildCellArrayWithVariables({'zone'});
        speedStdDevs = gapAcceptanceOccurences.buildCellArrayWithVariables({'speed_stdDev'});
        averageSpeeds = gapAcceptanceOccurences.buildCellArrayWithVariables({'speed_average'});
        stopppeds = gapAcceptanceOccurences.buildCellArrayWithVariables({'stopped'});   
        stopPks = gapAcceptanceOccurences.buildCellArrayWithVariables({'stop_pk'}); 
        chosenGaps = gapAcceptanceOccurences.buildCellArrayWithVariables({'chosen_gap_size'}); 
        rejectedGaps = gapAcceptanceOccurences.buildCellArrayWithVariables({'rejected_gaps'}); 
        discardedCarNumbers = gapAcceptanceOccurences.buildCellArrayWithVariables({'number_of_discarded_cars'}); 
        maxGaps = gapAcceptanceOccurences.buildCellArrayWithVariables({'max_proposed_gap'}); 
        gapBigs = gapAcceptanceOccurences.buildCellArrayWithVariables({'GapBig'}); 
        
        for j = 1:1:length(scenarioIds)
            fprintf(csvFile, '%s;', dataID);  
            fprintf(csvFile, '%s;', scenarioIds{j});
            fprintf(csvFile, '%s;', drive);  
            fprintf(csvFile, '%s;', version);
            fprintf(csvFile, '%s;', condition);
            fprintf(csvFile, '%s;', guessTaskZone(condition, scenarioIds{j}));
            fprintf(csvFile, '%s;', events{j});    
            fprintf(csvFile, '%s;', codeZone(zones{j}));
            fprintf(csvFile, '%s;', '99;99;99;99;99;99;99;99;99;99');
            fprintf(csvFile, '%.12f;', speedStdDevs{j});
            fprintf(csvFile, '%.12f;', averageSpeeds{j});
            fprintf(csvFile, '%s;', trueOrFalseConverter(stopppeds{j}));
            fprintf(csvFile, '%d;', stopPks{j});
            fprintf(csvFile, '%d;', chosenGaps{j});
            fprintf(csvFile, '%s;', rejectedGaps{j});
            fprintf(csvFile, '%d;', discardedCarNumbers{j});
            fprintf(csvFile, '%d;', maxGaps{j});
            fprintf(csvFile, '%s;', codeGapBig(gapBigs{j}));
            fprintf(csvFile, '%s;', '99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;');
            fprintf(csvFile, '\n');
        end
        delete(currentTrip);
    end
    
    for i = 1:1:length(tripFilesList)
        disp(['[ ' num2str(i) ' ] Processing ' tripFilesList{i} '- LV']);
        currentTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFilesList{i}, 0.04, false);
        
        leadVehicleOccurences = currentTrip.getAllSituationOccurences('Lead_vehicle');
        
        [dataID, drive, condition, version] = getInfosFromFileName(tripFilesList{i});
        
        scenarioIds = leadVehicleOccurences.buildCellArrayWithVariables({'scenarioID'});
        events = leadVehicleOccurences.buildCellArrayWithVariables({'event'});
        zones = leadVehicleOccurences.buildCellArrayWithVariables({'zone'});
        lvIDs = leadVehicleOccurences.buildCellArrayWithVariables({'lead_vehicle_id'});
        speedStdDevs = leadVehicleOccurences.buildCellArrayWithVariables({'speed_stdDev'});
        averageSpeeds = leadVehicleOccurences.buildCellArrayWithVariables({'speed_average'});
        startSpeeds = leadVehicleOccurences.buildCellArrayWithVariables({'speed_at_start_of_zone'});
        endSpeeds = leadVehicleOccurences.buildCellArrayWithVariables({'speed_at_end_of_zone'});
        gearsSequences = leadVehicleOccurences.buildCellArrayWithVariables({'gear_sequence'});
        gearChangeds = leadVehicleOccurences.buildCellArrayWithVariables({'gear_changed'});
        lanePositionStdDevs = leadVehicleOccurences.buildCellArrayWithVariables({'lane_position_stdDev'});
        lanePositionAverages = leadVehicleOccurences.buildCellArrayWithVariables({'lane_position_average'});
        headWayMins = leadVehicleOccurences.buildCellArrayWithVariables({'headway_minimum'});
        headWayAverages = leadVehicleOccurences.buildCellArrayWithVariables({'headway_average'});
        headWayStandardDeviations = leadVehicleOccurences.buildCellArrayWithVariables({'headway_stdDev'});
        reactionTimes = leadVehicleOccurences.buildCellArrayWithVariables({'reaction_time'});
        ttcMins = leadVehicleOccurences.buildCellArrayWithVariables({'ttc_minimum'});
        ttcMaximums = leadVehicleOccurences.buildCellArrayWithVariables({'ttc_maximum'});
        ttcAverages = leadVehicleOccurences.buildCellArrayWithVariables({'ttc_average'});
        ttcStdDevs = leadVehicleOccurences.buildCellArrayWithVariables({'ttc_stdDev'});
        maxDecelerations = leadVehicleOccurences.buildCellArrayWithVariables({'maximum_deceleration'});
        
        for j = 1:1:length(scenarioIds)
            fprintf(csvFile, '%s;', dataID);  
            fprintf(csvFile, '%s;', scenarioIds{j});
            fprintf(csvFile, '%s;', drive);  
            fprintf(csvFile, '%s;', version);
            fprintf(csvFile, '%s;', condition);
            fprintf(csvFile, '%s;', guessTaskZone(condition, scenarioIds{j}));
            fprintf(csvFile, '%s;', events{j});    
            fprintf(csvFile, '%s;', codeZone(zones{j}));
            fprintf(csvFile, '%s;', '99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99;99');  
            fprintf(csvFile, '%s;', lvIDs{j});
            fprintf(csvFile, '%.12f;', speedStdDevs{j});
            fprintf(csvFile, '%.12f;', averageSpeeds{j});
            fprintf(csvFile, '%s;', codeStartEndSpeed(zones{j}, startSpeeds{j}));
            fprintf(csvFile, '%s;', codeStartEndSpeed(zones{j}, endSpeeds{j}));
            fprintf(csvFile, '%s;', gearsSequences{j});
            fprintf(csvFile, '%s;', trueOrFalseConverter(gearChangeds{j}));
            fprintf(csvFile, '%.12f;', lanePositionStdDevs{j});
            fprintf(csvFile, '%.12f;', lanePositionAverages{j});
            fprintf(csvFile, '%.12f;', headWayMins{j});
            fprintf(csvFile, '%.12f;', headWayAverages{j});
            fprintf(csvFile, '%.12f;', headWayStandardDeviations{j});
            fprintf(csvFile, '%s;', codeReactionTime(reactionTimes{j}));
            fprintf(csvFile, '%s;', codeTTC(ttcMins{j}));
            fprintf(csvFile, '%s;', codeTTC(ttcMaximums{j}));   
            fprintf(csvFile, '%s;', codeTTC(ttcAverages{j}));
            fprintf(csvFile, '%s;', codeTTC(ttcStdDevs{j})); 
            fprintf(csvFile, '%.12f;', maxDecelerations{j});
            fprintf(csvFile, '\n');
        end
        delete(currentTrip);
    end
end

function out = guessTaskZone(condition, scenarioId)
    switch(condition)
        case('baseline')
            out = 'base';
        case 'SuRT'
            switch(scenarioId);
                case {'GA01' 'TL01' 'LV01'}
                    out = 'surt0';
                case {'GA02' 'TL02' 'TL04' 'GA05' 'GA06' 'TL05' 'GA07' 'TL07' 'GA08' 'TL08' 'LV02' 'LV03' 'TL09' 'LV05' 'LV06' 'TL11' 'LV07' 'LV08' 'LV10' 'TL12' 'LV12' 'TL15' 'TL16'}
                    out = 'surt1';
                case {'GA03' 'TL03' 'GA04' 'TL06' 'TL10' 'LV04' 'LV09' 'TL13' 'TL14' 'LV11'}
                    out = 'surt2';
                otherwise
                    error('Something''s wrong... Roll a d20 in the table to know what happened');
            end
        case 'nback'
            switch(scenarioId);
                case {'GA01' 'TL01' 'LV01'}
                    out = 'n-back0';
                case {'GA02' 'TL02' 'TL04' 'GA05' 'GA06' 'TL05' 'GA07' 'TL07' 'GA08' 'TL08' 'LV02' 'LV03' 'TL09' 'LV05' 'LV06' 'TL11' 'LV07' 'LV08' 'LV10' 'TL12' 'LV12' 'TL15' 'TL16'}
                    out = 'n-back1';
                case {'GA03' 'TL03' 'GA04' 'TL06' 'TL10' 'LV04' 'LV09' 'TL13' 'TL14' 'LV11'}
                    out = 'n-back2';
                otherwise
                    error('Something''s wrong... Roll a d20 in the table to know what happened');
            end
        otherwise
            error('Let''s leave and have a drink, something crashed and I''m too tired to understand what caused it !');
    end
end

function out = codeTTC(ttc)
    if ~isnumeric(ttc) ||isnan(ttc)
        out = '88';
    else
        out = sprintf('%.12f', ttc);
    end
end

function out = codeReactionTime(rt)
    if rt == 0
        out = '88';
    else
       out = sprintf('%.12f', rt); 
    end
end

function out = codeStartEndSpeed(zone, speed)
    switch(zone)
        case 'approach_zone'
            out = '88';
        case 'decision_zone'
            out = sprintf('%.12f', speed);
        otherwise
            error(['"Speed : ' speed '" could not be converted for zone ' zone]);
    end
end

function out = codeGapBig(gapBig)
    switch(gapBig)
        case('equal')
            out = 'E';
        case('true')
            out = 'T';
        case('undef')
            out = '88';
    end
end

function out = codeDeceleration(zone, deceleration)
    switch(zone)
        case {'approach_zone' 'intermediate_zone' 'final_zone'}
            out = '88';
        case 'decision_zone'
            out = sprintf('%.12f', deceleration);
        otherwise
            error(['"Deceleration : ' deceleration '" could not be converted for zone ' zone]);
    end
end


function out = codeTrafficLightColour(zone, colour)
    switch(zone)
        case {'approach_zone' 'final_zone' 'intermediate_zone'}
            out = '88';
        case {'decision_zone'}
            out = colour;
        otherwise
            error(['"Ran_trafficl_light : ' ran '" could not be converted for zone ' zone]);
    end
end

function out = codeStops(zone, stopped)
    switch(zone)
        case {'approach_zone' 'final_zone'}
            out = '88';
        case {'decision_zone' 'intermediate_zone'}
            out = trueOrFalseConverter(stopped);
        otherwise
            error(['"Stopped : ' stopped '" could not be converted for zone ' zone]);
    end
end

function out = codeDZEntrySpeed(zone, speed)
    switch(zone)
        case {'approach_zone' 'intermediate_zone' 'final_zone'}
            out = '88';
        case 'decision_zone'
            out = sprintf('%.12f', speed);
        otherwise
            error(['"Speed : ' speed '" could not be converted for zone ' zone]);
    end
end

function out = codeDistanceFromTL(zone, distance)
    switch(zone)
        case {'approach_zone' 'intermediate_zone' 'final_zone'}
            out = '88';
        case 'decision_zone'
            out = sprintf('%d', distance);
        otherwise
            error(['"Distance : ' distance '" could not be converted for zone ' zone]);
    end
end

function out = codeZone(zone)
    switch(zone)
        case 'approach_zone'
            out = 'AZ';
        case 'intermediate_zone'
            out = 'IZ';
        case 'decision_zone'
            out = 'DZ';
        case 'final_zone'
            out = 'FZ';
        otherwise
            error(['"Zone : ' zone '" could not be converted']);
    end
end

function out = trueOrFalseConverter(trueOrFalse)
    switch(trueOrFalse)
        case('true')
            out = 'T';
        case('false')
            out = 'F';
        otherwise
            error([trueOrFalse ' is neither true of false o_O']);
    end
end

function [dataID, drive, condition, version] = getInfosFromFileName(filepath)
    [~, filename, ~] = fileparts(filepath);
    tokens = {};
    remainder = filename;
    while(~isempty(remainder))
       [tokens{end + 1}, remainder] = strtok(remainder, '_');
    end
    dataID = tokens{5};
    drive = tokens{1};
    version = ['V' tokens{2}];
    conditionToken = tokens{4};
    switch(conditionToken)
        case 'base'
            condition = 'baseline';
        case 'surt'
            condition = 'SuRT';
        case 'nback'
            condition = 'nback';
        otherwise
            error(['Impossible de comprendre ' conditionToken]);
    end
end

function out = listTrips(folder)
    tripsListing = dir(folder);
    %We keep only the dirs
    indicesToRemove = [];
    for i = 1:1:length(tripsListing)
        [ ~, ~, extension] = fileparts(tripsListing(i).name);
        if (tripsListing(i).isdir) || (any(strcmp({'.' '..'}, tripsListing(i).name))) || ~strcmp('.trip', extension) 
            indicesToRemove(end + 1) = i;
        end
    end
    tripsListing(indicesToRemove) = [];
    out = cell(length(tripsListing), 1);
    for i = 1:1:length(tripsListing)
        out{i} = [folder filesep tripsListing(i).name];
    end
end

function out = createCSVFile(rootDir, folder)
    csvFileName = [rootDir filesep folder.name filesep folder.name '.csv'];
    if exist(csvFileName, 'file')
        delete(csvFileName);
        disp([csvFileName ' deleted']);
    end
    [out message] = fopen(csvFileName, 'w+');
    disp(message);
    disp([csvFileName ' created']);
end