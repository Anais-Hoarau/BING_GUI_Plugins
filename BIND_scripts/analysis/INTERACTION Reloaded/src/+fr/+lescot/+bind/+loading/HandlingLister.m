clear all;

alphabet = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'AA' 'AB' 'AC' 'AD' 'AE' 'AF' 'AG'};

warning('off','MATLAB:dispatcher:InexactCaseMatch');

baseFolder = 'c:\';

tripfolder_name = uigetdir(baseFolder,'Select the root folder containing the trips of a participant. This tools only produce relevant results when used one all the trips of a participant.');

[filename, pathname] = uiputfile('*.xls','Call lister - Excel output file name');
xlsFileName = fullfile(pathname,filename);
errorFile = fullfile(pathname,[filename '_error.log']);

if isequal(tripfolder_name,0) || isequal(filename,0)
    disp('User selected Cancel')
    return;
end

errorFileHandler = fopen(errorFile,'wt+');

disp('scanning subfolders, please wait.');

tripList = dirrec(tripfolder_name,'.trip');

numberOfTripsToProcess = length(tripList);
disp([num2str(numberOfTripsToProcess) ' trip found in subfolders.']);

disp('Dispatching trips in each trip sample for the RH.');

RHForTheTrips = cell(1,length(tripList));

startingPointsCoordinate = cell(1,length(tripList));
endingPointsCoordinate = cell(1,length(tripList));
distances = cell(1,length(tripList));

for i=1:length(tripList)
    errorLog = ['Processing trip ' tripList{i} ' - '];
    try
        theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripList{i},0.04,false);
    catch ME
        RHForTheTrips{i} = [];
        startingPointsCoordinate{i} = 0;
        endingPointsCoordinate{i} = 0;
        distances{i} = 0;
        errorLog = [ errorLog 'Opening error'];
        fprintf(errorFileHandler,'%s\n',errorLog);
        continue;
    end
    
    try
        RHForTheTrips{i} = theTrip.getAttribute('useForAnalysis');
    catch ME
        RHForTheTrips{i} = [];
        %startingPointsCoordinate{i} = 0;
        %endingPointsCoordinate{i} = 0;
        %distances{i} = 0;
        % we need to collect data on the general trip set. NO WE CONTINUE
        %errorLog = [ errorLog ' impossible to access to RH description'];
        %fprintf(errorFileHandler,'%s\n',errorLog);
        %delete(theTrip);
        %continue;
    end
    
    metas = theTrip.getMetaInformations();
    % first run, get the driver name
    if i == 1 || i == 3
        try
            driverName = metas.getParticipant.getAttribute('name');
        catch ME
            driverName = 'no name';
            errorLog = [ errorLog ' impossible to access to name properties'];
            fprintf(errorFileHandler,'%s\n',errorLog);
        end
    end
    
    % collect data about trip regularity
    try
        tripStartTime = str2num(theTrip.getAttribute('BeginDate'));
        tripEndTime =  str2num(theTrip.getAttribute('EndDate'));
    catch ME
        RHForTheTrips{i} = [];
        startingPointsCoordinate{i} = 0;
        endingPointsCoordinate{i} = 0;
        distances{i} = 0;
        errorLog = [ errorLog ' impossible to access to duration properties'];
        fprintf(errorFileHandler,'%s\n',errorLog);
        continue;
    end
    % remove 10 minutes to trip and then look in the data to obtain the
    % real timecode when driving ends, not when recording ends!
    drivingLengthInSecond = tripEndTime - tripStartTime - 10 * 60;
    firstTimecode = theTrip.getDataVariableMinimum('Gyroscope','timecode');
    if isnan(firstTimecode)
        firstTimecode = theTrip.getDataVariableMinimum('MatchedPos','timecode');
    end
    if isnan(firstTimecode)
        delete(theTrip)
        continue;
    end
    drivingEndTimecode = firstTimecode + drivingLengthInSecond;
    
    % build GPS route
    record = theTrip.getDataVariableOccurencesInTimeInterval('MatchedPos','latitude',firstTimecode,drivingEndTimecode);
    latitude = cell2mat(record.getVariableValues('latitude'));
    record = theTrip.getDataVariableOccurencesInTimeInterval('MatchedPos','longitude',firstTimecode,drivingEndTimecode);
    longitude = cell2mat(record.getVariableValues('longitude'));
    
    if ~isempty(latitude)
        pointDepart = [latitude(1) longitude(1)];
        pointArrivee = [latitude(end) longitude(end)];
    else
        pointDepart = [0 0];
        pointArrivee = [0 0];
    end
    startingPointsCoordinate{i} = pointDepart;
    endingPointsCoordinate{i} = pointArrivee;
    
    usingGPSSpeed = true;
    % compute distance
    if ~metas.existDataVariable('GPSPos','speed');
        disp(['the trip ' tripList{i} ' requires speed data to compute km driven : not found and using GPS coordinates (less accurate)']);
        usingGPSSpeed = false;
    else
        record = theTrip.getDataVariableOccurencesInTimeInterval('GPSPos','speed',firstTimecode,drivingEndTimecode);
        if length(cell2mat(record.getVariableValues('speed'))) < 50
            usingGPSSpeed = false;
        else
            usingGPSSpeed = true;
        end
        
    end
    
    if usingGPSSpeed
        % estimation of kilometer driven : using mean speed on 1 minute windows
        distanceTrip = 0;
        for j=0:60:drivingEndTimecode
            record = theTrip.getDataVariableOccurencesInTimeInterval('GPSPos','speed',firstTimecode+j,firstTimecode+(j+60));
            meanSpeedOnWindows = mean(cell2mat(record.getVariableValues('speed')));
            if ~isnan(meanSpeedOnWindows)
                meanSpeedInMinute = meanSpeedOnWindows/60;
                distanceTrip = distanceTrip + meanSpeedInMinute;
            end
        end
        distanceTrip  = round(distanceTrip*1000); % distance is in kilometer : put it to meter
    else
        a = pi / 180;
        lat1 = pointDepart(1) * a;
        long1 = pointDepart(2) * a;
        lat2 = pointArrivee(1) * a;
        long2 = pointArrivee(2) * a;
        t = sin((lat1-lat2)/2)*sin((lat1-lat2)/2) + cos(lat1)*cos(lat2)*sin((long1-long2)/2)*sin((long1-long2)/2);
        distanceTrip = 2 * 6371000 * atan2(sqrt(t),sqrt(1-t));
    end
    distances{i} = distanceTrip;
    
    delete(theTrip);
end

% once we have all the info on the trips, we can compute regularity and
% verify which trips are valid
nbTrips = length(tripList);

regularityOfTrip = cell(1,nbTrips);
areRegular = cell(1,nbTrips);

index = 1;
validTrips = {};
regularityOfValidTrips = {};
distanceOfValidTrips = {};

% once all the trips are evaluated, try to compute the regularity of the
% trip : for each trip, we test with all the other trips
for k = 1:nbTrips;
    
    % all trips are valid...
    validTrips{index} = tripList{k};
    distanceOfValidTrips{index} = distances{k};
    regularityOfValidTrips{index} = 0;
    index = index + 1;
    %end
end

tripsToOpen = validTrips;

disp(['Listing calls. Using ' num2str(length(tripsToOpen)) ' trips for the calculation.']);

generalCallIndex = 0;

for i=1:length(tripsToOpen)
    try
        theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripsToOpen{i},0.04,false);
    catch ME
        errorLog = [ errorLog ' impossible to load trip'];
        fprintf(errorFileHandler,'%s\n',errorLog);
        continue;
    end
    
    % first run, get the driver name
    if i == 1 || i == 3
        try
            metas = theTrip.getMetaInformations();
            driverName = metas.getParticipant.getAttribute('name');
        catch ME
            errorLog = [ errorLog ' impossible to access to name properties'];
            fprintf(errorFileHandler,'%s\n',errorLog);
        end
    end
    
    % first general fact about trip
    try
        tripStartTime = str2num(theTrip.getAttribute('BeginDate'));
        tripEndTime =  str2num(theTrip.getAttribute('EndDate'));
    catch ME
        errorLog = [ errorLog ' impossible to access to duration properties'];
        fprintf(errorFileHandler,'%s\n',errorLog);
        continue;
    end
    
    % remove 10 minutes to trip and then look in the data to obtain the
    % real timecode when driving ends, not when recording ends!
    drivingLengthInSecond = tripEndTime - tripStartTime - 10 * 60;
    firstTimecode = theTrip.getDataVariableMinimum('Gyroscope','timecode');
    if isnan(firstTimecode)
        firstTimecode = theTrip.getDataVariableMinimum('MatchedPos','timecode');
    end
    if isnan(firstTimecode)
        delete(theTrip)
        continue;
    end
    drivingEndTimecode = firstTimecode + drivingLengthInSecond;
    
    HeureDebutTrip = datestr(datenum([1970 1 1 0 0 tripStartTime]), 'HH:MM:SS.FFF');
    HeureFinTrip = datestr(datenum([1970 1 1 0 0 tripStartTime+drivingLengthInSecond]), 'HH:MM:SS.FFF');
    
    %first verify that MP coded data are available
    metas = theTrip.getMetaInformations();
    if ~metas.existEventVariable('INTERACTION_CP','timecode');
        MPuse = false;
    else
        record = theTrip.getAllEventOccurences('INTERACTION_CP');
        if ~record.isEmpty()
            MPuse = true;
        else
            MPuse = false;
        end
    end
    
    if MPuse
        % if there is the phone, it is interesting to see if there is the
        % CC or SL
        
        %first find in the trip the moment where CC or SL was engaged
        metas = theTrip.getMetaInformations();
        if ~metas.existEventVariable('INTERACTION_CC_SL','timecode');
            CCSLuse = false;
        else
            record = theTrip.getAllEventOccurences('INTERACTION_CC_SL');
            if ~record.isEmpty()
                CCSLuse = true;
            else
                CCSLuse = false;
            end
        end
        
        if CCSLuse
            times = record.getVariableValues('timecode');
            codedTypes = record.getVariableValues('type');
            codedValues = record.getVariableValues('value');
            
            % the engagement are always coded by hand : we spot them in the
            % coded table
            % the disengagement can be done by foot (not in this table), by manual
            % desengagement or by manual deselection (in this table).
            % For each of theses events, we will try to find the corresponding
            % coding.
            selectionNumber = 0;
            timeCCSelection = {};
            deselectionNumber = 0;
            timeCCDeselection = {};
            engagementNumber = 0;
            timeCCEngagement = {};
            desengagementNumber = 0;
            timeCCDesengagement = {};
            for codingIndex=1:length(codedTypes)
                if strcmp(codedTypes{codingIndex},'CC_Engaged')
                    engagementNumber = engagementNumber + 1;
                    timeCCEngagement{engagementNumber} = times{codingIndex};
                end
                if strcmp(codedTypes{codingIndex},'CC_Desengaged')
                    desengagementNumber = desengagementNumber + 1;
                    timeCCDesengagement{desengagementNumber} = times{codingIndex};
                end
                if strcmp(codedTypes{codingIndex},'CC_Selected')
                    selectionNumber = selectionNumber + 1;
                    timeCCSelection{selectionNumber} = times{codingIndex};
                end
                if strcmp(codedTypes{codingIndex},'CC_Deselected')
                    deselectionNumber = deselectionNumber + 1;
                    timeCCDeselection{deselectionNumber} = times{codingIndex};
                end
            end
            
            % all relevant coding have been found. The objective now is to
            % find matching start / end
            remaingingDesengagement = length(timeCCDesengagement);
            remaingingDeselection = length(timeCCDeselection);
            
            CC_Situations = {};
            
            for j=1:length(timeCCEngagement)
                % The reference window that will be used to look for a disengagement
                % is the time lapse between two engagements or the windows
                % between engagement and end of trip
                searchWindowStart = timeCCEngagement{j};
                if length(timeCCEngagement)==j
                    searchWindowsEnd = drivingEndTimecode;
                else
                    searchWindowsEnd = timeCCEngagement{j+1};
                end
                % during the search window, we start to look for a
                % desengagement
                if remaingingDesengagement~=0
                    endFound = false;
                    for k=1:remaingingDesengagement
                        if  timeCCDesengagement{k} > searchWindowStart && timeCCDesengagement{k} < searchWindowsEnd
                            CC_Situations{j} = [timeCCEngagement{j} ; timeCCDesengagement{k}];
                            timeCCDesengagement(k) = []; % blank this engagement
                            remaingingDesengagement = remaingingDesengagement - 1;
                            % found, go to next CC engagement
                            endFound = true;
                            break;
                        end
                    end
                    if endFound
                        continue;
                    end
                end
                
                % if the desengagement was not found, maybe it is a
                % deselection that exited the CC situations
                if remaingingDeselection~=0
                    endFound = false;
                    for k=1:remaingingDeselection
                        if  timeCCDeselection{k} > searchWindowStart && timeCCDeselection{k} < searchWindowsEnd
                            CC_Situations{j} = [timeCCEngagement{j} ; timeCCDeselection{k}];
                            timeCCDeselection(k) = []; % blank this engagement
                            remaingingDeselection = remaingingDeselection - 1;
                            % found, go to next CC engagement
                            endFound = true;
                            break;
                        end
                    end
                    if endFound
                        continue;
                    end
                end
                
                % at this stage, if there was neither a desengagement nor a
                % deselection, it means that there was an action on a pedal.
                % these information are stored in the "digitalEvents" table
                pedalRecord = theTrip.getEventOccurencesInTimeInterval('DigitalEvents',searchWindowStart,searchWindowsEnd);
                timePedal = pedalRecord.getVariableValues('timecode');
                values = pedalRecord.getVariableValues('value');
                
                % we scan all the values to find the relevent event : clutch
                % press or brake press
                relevantEvents = {'530' '258'};
                for k=1:length(values)
                    if(any(strcmp(num2str(values{k}),relevantEvents)))
                        % as soon as we meet an event that might have desengage the CC,
                        % we store the situation and we continue to the next
                        % engagement.
                        CC_Situations{j} = [timeCCEngagement{j} ; timePedal{k}];
                        continue;
                    end
                end
                
                % if we reach this point, this is bad : there was a CC
                % engagement, but it was impossible to find in the data an
                % event that can indicate the end of the CC situation.
                % we will assume that CC was engaged until the end of the
                % driving trip and that the driver shut the engine off without
                % any CC disengagement...
                
                % TODO : verify this implementation!!!!!!
                % This should be discussed as it is also possible to discard the
                % situation as we can consider it was badly coded.
                CC_Situations{j} = [timeCCEngagement{j} ; drivingEndTimecode];
            end
            
            % the SL engagement are always coded by hand : we spot them in the
            % coded table
            % the SL desengagement can be done by manual desengagement or by manual deselection
            %  For each of theses events, we will try to find the corresponding coding.
            selectionNumber = 0;
            timeSLSelection = {};
            deselectionNumber = 0;
            timeSLDeselection = {};
            engagementNumber = 0;
            timeSLEngagement = {};
            desengagementNumber = 0;
            timeSLDesengagement = {};
            for codingIndex=1:length(codedTypes)
                if strcmp(codedTypes{codingIndex},'SL_Engaged')
                    engagementNumber = engagementNumber + 1;
                    timeSLEngagement{engagementNumber} = times{codingIndex};
                end
                if strcmp(codedTypes{codingIndex},'SL_Desengaged')
                    desengagementNumber = desengagementNumber + 1;
                    timeSLDesengagement{desengagementNumber} = times{codingIndex};
                end
                if strcmp(codedTypes{codingIndex},'SL_Selected')
                    selectionNumber = selectionNumber + 1;
                    timeSLSelection{selectionNumber} = times{codingIndex};
                end
                if strcmp(codedTypes{codingIndex},'SL_Deselected')
                    deselectionNumber = deselectionNumber + 1;
                    timeSLDeselection{deselectionNumber} = times{codingIndex};
                end
            end
            
            % all relevant coding have been found. The objective now is to
            % find matching start / end
            remaingingDesengagement = length(timeSLDesengagement);
            remaingingDeselection = length(timeSLDeselection);
            
            SL_Situations = {};
            
            for j=1:length(timeSLEngagement)
                % The reference window that will be used to look for a disengagement
                % is the time lapse between two engagements or the windows
                % between engagement and end of trip
                searchWindowStart = timeSLEngagement{j};
                if length(timeSLEngagement)==j
                    searchWindowsEnd = drivingEndTimecode;
                else
                    searchWindowsEnd = timeSLEngagement{j+1};
                end
                % during the search window, we start to look for a
                % desengagement
                if remaingingDesengagement~=0
                    endFound = false;
                    for k=1:remaingingDesengagement
                        if  timeSLDesengagement{k} > searchWindowStart && timeSLDesengagement{k} < searchWindowsEnd
                            SL_Situations{j} = [timeSLEngagement{j} ; timeSLDesengagement{k}];
                            timeSLDesengagement(k) = []; % blank this engagement
                            remaingingDesengagement = remaingingDesengagement - 1;
                            % found, go to next CC engagement
                            endFound = true;
                            break;
                        end
                    end
                    if endFound
                        continue;
                    end
                end
                
                % if the desengagement was not found, maybe it is a
                % deselection that exited the SL situations
                if remaingingDeselection~=0
                    endFound = false;
                    for k=1:remaingingDeselection
                        if  timeSLDeselection{k} > searchWindowStart && timeSLDeselection{k} < searchWindowsEnd
                            SL_Situations{j} = [timeSLEngagement{j} ; timeSLDeselection{k}];
                            timeSLDeselection(k) = []; % blank this engagement
                            remaingingDeselection = remaingingDeselection - 1;
                            % found, go to next CC engagement
                            endFound = true;
                            break;
                        end
                    end
                    if endFound
                        continue;
                    end
                end
                
                % if we reach this point, this is bad : there was a SL
                % engagement, but it was impossible to find in the data an
                % event that can indicate the end of the SL situation.
                % we will assume that SL was engaged until the end of the
                % driving trip and that the driver shut the engine off without
                % any SL disengagement...
                
                % TODO : verify this implementation!!!!!!
                % This should be discussed as it is also possible to discard the
                % situation as we can consider it was badly coded.
                SL_Situations{j} = [timeSLEngagement{j} ; drivingEndTimecode];
            end
            % at this stage, we have located all CC situations.
        else
            % if there is no CC at all, let's blank the variable.
            CC_Situations = {};
            SL_Situations = {};
        end
        
        
        %if MPuse
        record = theTrip.getAllEventOccurences('INTERACTION_CP');
        times = record.getVariableValues('timecode');
        codedTypes = record.getVariableValues('type');
        codedValues = record.getVariableValues('value');
        
        callStartNumber = 0;
        timeMPCallStart = {};
        callEndNumber = 0;
        timeMPCallEnd = {};
        numberOfMPInteractionStart = 0;
        timeOfMPInteractionStart = {};
        numberOfMPInteractionEnd = 0;
        timeOfMPInteractionEnd = {};
        
        % the interactions are always coded by hand : we spot them in the
        % coded table; we focus on driver interactions
        for codingIndex=1:length(codedTypes)
            if any(strcmp(codedTypes{codingIndex},{'MP call start'}))
                callStartNumber = callStartNumber + 1;
                timeMPCallStart{callStartNumber} = times{codingIndex};
                callType{callStartNumber} = codedValues{codingIndex};
            end
            if any(strcmp(codedTypes{codingIndex},{'MP call stop'}))
                callEndNumber = callEndNumber + 1;
                timeMPCallEnd{callEndNumber} = times{codingIndex};
            end
            if any(strcmp(codedTypes{codingIndex},{'MP Handling start'}))
                numberOfMPInteractionStart = numberOfMPInteractionStart + 1;
                timeOfMPInteractionStart{numberOfMPInteractionStart} = times{codingIndex};
            end
            if any(strcmp(codedTypes{codingIndex},{'MP Handling stop'}))
                numberOfMPInteractionEnd = numberOfMPInteractionEnd + 1;
                timeOfMPInteractionEnd{numberOfMPInteractionEnd} = times{codingIndex};
            end
        end
        
        % all relevant coding have been found. The objective now is to
        % find matching start / end
        remaingingCallEnd = length(timeMPCallEnd);
        
        MP_CallSituations = {};
        
        for j=1:length(timeMPCallStart)
            % The reference window that will be used to look for a disengagement
            % is the time lapse between two engagements or the windows
            % between engagement and end of trip
            searchWindowStart = timeMPCallStart{j};
            if length(timeMPCallStart)==j
                searchWindowsEnd = drivingEndTimecode;
            else
                searchWindowsEnd = timeMPCallStart{j+1};
            end
            % during the search window, we start to look for a
            % desengagement
            endFound = false;
            if remaingingCallEnd~=0
                for indexCallEnd = 1: length(timeMPCallEnd)
                    if  timeMPCallEnd{indexCallEnd} > searchWindowStart && timeMPCallEnd{indexCallEnd} < searchWindowsEnd
                        MP_CallSituations{j} = [timeMPCallStart{j} ; timeMPCallEnd{indexCallEnd}];
                        timeMPCallEnd(indexCallEnd) = []; % blank this engagement
                        remaingingCallEnd = remaingingCallEnd - 1;
                        endFound = true;
                        % found, go to next call start
                        break;
                    end
                end
            end
            
            % if we reach this point, this is bad : there was a MP call
            % start, but it was impossible to find in the data an
            % event that can indicate the end of the call.
            % we will assume that call was given until the end of the
            % driving trip and that the driver shut the engine off without
            % ending his/her MP call
            
            % TODO : verify this implementation!!!!!!
            % This should be discussed as it is also possible to discard the
            % situation as we can consider it was badly coded.
            if ~endFound
                if timeMPCallStart{j} < drivingEndTimecode
                    MP_CallSituations{j} = [timeMPCallStart{j} ; drivingEndTimecode];
                end
            end
        end
        
        % all relevant coding have been found. The objective now is to
        % find matching start / end
        remaingingHandlingEnd = length(timeOfMPInteractionEnd);
        
        MP_HandlingSituations = {};
        
        for j=1:length(timeOfMPInteractionStart)
            % The reference window that will be used to look for a disengagement
            % is the time lapse between two engagements or the windows
            % between engagement and end of trip
            searchWindowStart = timeOfMPInteractionStart{j};
            if length(timeOfMPInteractionStart)==j
                searchWindowsEnd = drivingEndTimecode;
            else
                searchWindowsEnd = timeOfMPInteractionStart{j+1};
            end
            % during the search window, we start to look for a
            % desengagement
            endFound = false;
            if remaingingHandlingEnd~=0
                for indexCallEnd = 1:length(timeOfMPInteractionEnd)
                    if  timeOfMPInteractionEnd{indexCallEnd} > searchWindowStart && timeOfMPInteractionEnd{indexCallEnd} < searchWindowsEnd
                        MP_HandlingSituations{j} = [timeOfMPInteractionStart{j} ; timeOfMPInteractionEnd{indexCallEnd}];
                        timeOfMPInteractionEnd(indexCallEnd) = []; % blank this engagement
                        remaingingHandlingEnd = remaingingHandlingEnd - 1;
                        endFound = true;
                        % found, go to next handling start
                        break;
                    end
                end
            end
            
            % if we reach this point, this is bad : there was a MP call
            % start, but it was impossible to find in the data an
            % event that can indicate the end of the call.
            % we will assume that call was given until the end of the
            % driving trip and that the driver shut the engine off without
            % ending his/her MP call
            
            % TODO : verify this implementation!!!!!!
            % This should be discussed as it is also possible to discard the
            % situation as we can consider it was badly coded.
            if ~endFound
                if timeOfMPInteractionStart{j} < drivingEndTimecode
                    MP_HandlingSituations{j} = [timeOfMPInteractionStart{j} ; drivingEndTimecode];
                end
            end
        end
        
        uniqueCallIndexInTrip = 0;
        situationEnd = 0;
        if ~isempty(MP_HandlingSituations)
            for l = 1:length(MP_HandlingSituations)
                callMode = 'NA';
                
                generalCallIndex = generalCallIndex + 1;
                
                situation = MP_HandlingSituations{l};
                situationStart = situation(1);
                
                % before updating the end of this CC situation, we check if
                % the beginning of the new situation is very close the end
                % of the previous one : it would mean that it is not a new call but rather 
                % a change of "call mode", from "hand free" to "handheld".
                if situationEnd ~=0 && abs(situationEnd-situationStart)<1
                    disp(['Handling extended - situations starts very close to previous ending, index is still ' num2str(uniqueCallIndexInTrip)]);
                else
                    uniqueCallIndexInTrip = uniqueCallIndexInTrip + 1;
                    disp(['New Handling in trip, index is ' num2str(uniqueCallIndexInTrip)]);
                end
                
                situationEnd =  situation(2);
                % si le début de ce nouvel appel se produit moins d'une
                % seconde avant la fin de l'appel précédent, il s'agit en
                % fait du même appel qui change de mode (un passe d'un CALL
                % hand held à un CALL hand free)
                MPDuration = situationEnd - situationStart;
                
                wasInCCWhenCall = false;
                for ccIndex = 1:length(CC_Situations)
                    accSituation = CC_Situations{ccIndex};
                    ccSituationStart = accSituation(1);
                    ccSituationEnd = accSituation(2);
                    if situationStart > ccSituationStart &&  situationStart < ccSituationEnd
                        wasInCCWhenCall = true;
                        break;
                    end
                end
                
                % added in September : check if CC is still on when MP ends
                wasInCCWhenCallEnds = false;
                for ccIndex = 1:length(CC_Situations)
                    accSituation = CC_Situations{ccIndex};
                    ccSituationStart = accSituation(1);
                    ccSituationEnd = accSituation(2);
                    if situationEnd > ccSituationStart && situationEnd < ccSituationEnd
                        wasInCCWhenCallEnds = true;
                        break;
                    end
                end
                
                wasInSLWhenCall = false;
                for slIndex = 1:length(SL_Situations)
                    aslSituation = SL_Situations{slIndex};
                    slSituationStart = aslSituation(1);
                    slSituationEnd = aslSituation(2);
                    if situationStart > slSituationStart &&  situationStart < slSituationEnd
                        wasInSLWhenCall = true;
                        break;
                    end
                end
                
                % added in September : check if SL is still on when MP ends
                wasInSLWhenCallEnds = false;
                for slIndex = 1:length(SL_Situations)
                    aslSituation = SL_Situations{slIndex};
                    slSituationStart = aslSituation(1);
                    slSituationEnd = aslSituation(2);
                    if situationEnd > slSituationStart && situationEnd < slSituationEnd
                        wasInSLWhenCallEnds = true;
                        break;
                    end
                end
                
                % added in September : check if MP is on when handling
                % start
                wasInMPWhenHandling = false;
                for mpIndex = 1:length(MP_CallSituations)
                    ampSituation = MP_CallSituations{mpIndex};
                    ampSituationStart = ampSituation(1);
                    ampSituationEnd = ampSituation(2);
                    if situationStart > ampSituationStart && situationStart < ampSituationEnd
                        wasInMPWhenHandling = true;
                        break;
                    end
                end
                
               % added in September : check if MP is on when handling
                % ends
                wasInMPWhenHandlingEnds = false;
                for mpIndex = 1:length(MP_CallSituations)
                    ampSituation = MP_CallSituations{mpIndex};
                    ampSituationStart = ampSituation(1);
                    ampSituationEnd = ampSituation(2);
                    if situationEnd > ampSituationStart && situationEnd < ampSituationEnd
                        wasInMPWhenHandlingEnds = true;
                        break;
                    end
                end
                
                typeOfRoadAtStart = 'Nan';
                % At the begining, what type of road context ?
                % for the first stage, we will only evaluate the type of road
                % see documentation in fr.lescot.bind.utils.INTProcessUtils
                roadContextDispatching = fr.lescot.bind.utils.INTProcessUtils.getRoadContextRatio(theTrip,situationStart-5,situationStart+5);
                if isempty(roadContextDispatching);
                    percentageHighway = 0;
                    percentageRural= 0;
                    percentageUrban= 0;
                end
                if roadContextDispatching(1) == 0 && roadContextDispatching(2) == 0 && roadContextDispatching(3) == 0
                    typeOfRoadAtStart = 'Nan';
                else
                    percentageHighway = roadContextDispatching(1);
                    percentageRural= roadContextDispatching(2);
                    percentageUrban= roadContextDispatching(3);
                    
                    if percentageHighway > 50
                        typeOfRoadAtStart = ['Highway (' num2str(percentageHighway) '%)'];
                    end
                    if percentageRural > 50
                        typeOfRoadAtStart = ['Rural (' num2str(percentageRural) '%)'];
                    end
                    if percentageUrban > 50
                        typeOfRoadAtStart = ['Urban (' num2str(percentageUrban) '%)'];
                    end
                end
                
                % At the begining, what type of road context ?
                % for the first stage, we will only evaluate the type of road
                % see documentation in fr.lescot.bind.utils.INTProcessUtils
                roadContextDispatching = fr.lescot.bind.utils.INTProcessUtils.getRoadContextRatio(theTrip,situationStart,situationEnd);
                if isempty(roadContextDispatching);
                    percentageHighway = 0;
                    percentageRural= 0;
                    percentageUrban= 0;
                end
                if roadContextDispatching(1) == 0 && roadContextDispatching(2) == 0 && roadContextDispatching(3) == 0
                    percentageHighway = 0;
                    percentageRural= 0;
                    percentageUrban = 0;
                else
                    percentageHighway = roadContextDispatching(1);
                    percentageRural= roadContextDispatching(2);
                    percentageUrban= roadContextDispatching(3);
                end
                
                % Speed at start
                if ~metas.existDataVariable('GPSPos','timecode');
                    disp(['the trip ' tripsToOpen{i} ' requires speed data to be evaluated : data not availbale, trip not used']);
                    speedAtStart = 'Nan';
                else
                    record = theTrip.getDataVariableOccurencesInTimeInterval('GPSPos','Speed',situationStart-5,situationStart+5);
                    if record.isEmpty()
                        disp(['the trip ' tripsToOpen{i} ' requires speed data to be evaluated : data not available, trip will not be used for speed calculation.']);
                        % continue;
                        speedAtStart = 'Nan';
                    else
                        speed = cell2mat(record.getVariableValues('Speed'));
                        speedAtStart = mean(speed);
                    end
                end
                
                % speed during sections
                record = theTrip.getDataVariableOccurencesInTimeInterval('GPSPos','Speed',situationStart,situationEnd);
                if record.isEmpty()
                    disp(['the trip ' tripsToOpen{i} ' requires speed data to be evaluated : data not available, trip will not be used for speed calculation.']);
                    % continue;
                    meanSpeed = 'Nan';
                else
                    speed = cell2mat(record.getVariableValues('Speed'));
                    meanSpeed = mean(speed);
                    % compute speed dispatching
                    
                end
                
                roadTypeRecord = theTrip.getDataOccurencesInTimeInterval('MatchedPOS',situationStart-1,situationStart+1);
                if roadTypeRecord.isEmpty()
                    disp(['the trip ' tripsToOpen{i} ' requires legal speed data to be evaluated : data not available, trip will not be used for speed calculation.']);
                end
                wayLegalSpeedLimit = mean(cell2mat(roadTypeRecord.getVariableValues('wayLegalSpeedLimit')));
                
                % COMPUTATION DONE
                % writing call to excel file
                disp('Reporting call to Excel file : ');
                tabName = 'Handlings';
                dateTrip = datestr(datenum([1970 1 1 0 0 tripStartTime]));
                columns = {'Driver' 'general ID', 'Handling id In Trip',...
                    'date of Trip',...
                    'time of Handling start (in trip time)',...
                    'time of Handling end (in trip time)',...
                    'hour of Handling start',...
                    'hour of Handling end',...
                    'Handling duration in second',...
                    'Handling duration in minutes',...
                    'Handling mode (kept for compatibility)',...
                    'was In CC When Handling',...
                    'was In CC When Handling Ends',...
                    'was In SL When Handling',...
                    'was In SL When Handling Ends',...
                    'was In MP When Handling',...
                    'was In MP When Handling Ends',...
                    'type Of Road At Start',...
                    'speed At Start',...
                    'wayLegalSpeedLimit',...
                    'percentageHighway during Handling',...
                    'percentageRural during Handling',...
                    'percentageUrban during Handling',...
                    'meanSpeed during Handling',...
                    };
                
                values = {driverName generalCallIndex,num2str(uniqueCallIndexInTrip + i * 1000)...
                    dateTrip,...
                    situationStart,...
                    situationEnd,...
                    datestr(datenum([1970 1 1 0 0 tripStartTime+situationStart]), 'HH:MM:SS.FFF'),...
                    datestr(datenum([1970 1 1 0 0 tripStartTime+situationEnd]), 'HH:MM:SS.FFF'),...
                    situationEnd - situationStart,...
                    (situationEnd - situationStart)/60,...
                    callMode,...
                    wasInCCWhenCall,...
                    wasInCCWhenCallEnds,...
                    wasInSLWhenCall,...
                    wasInSLWhenCallEnds,...
                    wasInMPWhenHandling,...
                    wasInMPWhenHandlingEnds,...
                    typeOfRoadAtStart,...
                    speedAtStart,...
                    wayLegalSpeedLimit,...
                    percentageHighway,...
                    percentageRural,...
                    percentageUrban,...
                    meanSpeed,...
                    };
                % first colum, driver name, always has a special treatment as it is a
                % string
                range = ['A' num2str(generalCallIndex+1) ':A' num2str(generalCallIndex+1)];
                xlswrite(xlsFileName,{driverName},tabName,range);
                % all others are numerical values, so it can loop
                for value = 2:length(values)
                    disp([sprintf('%s',columns{value}) ' = ' num2str(values{value})]);
                    range = [alphabet{value} num2str(generalCallIndex+1) ':' alphabet{value} num2str(generalCallIndex+1)];
                    if isempty(values{value})
                        values{value} = 0;
                    end
                    if isnumeric(values{value})
                        values{value} = sprintf('%.1f',values{value});
                    end
                    xlswrite(xlsFileName,{ values{value}},tabName,range);
                end
            end
        end
    else
        disp(['the trip ' tripsToOpen{i} ' indicate no MP use, but is included in A9 : trip data will still be used for exposition computation']);
    end
    
    delete(theTrip);
end

if length(tripsToOpen) == 0   
    columns = {'No Trips in folder'};
    tabName = 'ERROR';
    range = 'A1:A1';
end
 
% at last, write the first line with the column names.
range = ['A1:' alphabet{length(columns)} '1'];
xlswrite(xlsFileName, columns,tabName,range);



%% END OF ALL INDICATORS
% write to file
fclose(errorFileHandler);
disp('End of the calculation.');
