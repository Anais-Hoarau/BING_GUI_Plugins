function  S1createSituationsFromComments(tripFile)
    import fr.lescot.bind.*;

    theTrip = kernel.implementation.SQLiteTrip(tripFile, 0.01, false);
    simulationOccurences = theTrip.getAllDataOccurences('simulation');
    comments = simulationOccurences.buildCellArrayWithVariables({'timecode' 'commentaires'});
    commentsIndexes = find(strcmp(comments(2,:), '0') == false);
    comments = comments(:, commentsIndexes);
    
    situations = {'Full_trip' 'Distraction' 'Lead_vehicle' 'Gap_acceptance' 'Traffic_light'};
    metaInfos = theTrip.getMetaInformations();
    for i = 1:1:length(situations)
        situation = situations{i};
        if metaInfos.existSituation(situation)
            disp(['Removing ' situation]);
            theTrip.removeSituation(situation);
        end
    end
    
    
    %{
    This script is based on a few assumptions :
    - Only one comment per line. So when we split we only have 3 elements.
    - We hope we have all the messages for each scenario occurence
    - No overlapping scenarios
    %}
    
    %This block is in charge of creating the structure for the three types
    %of scenarios. There will be one situation table for each type of
    %scenario. For the moment they will all have the same variables, but
    %once we start the data analysis, it may change, so it's better to
    %separate them.
    scenarioIDVariable = data.MetaSituationVariable();
    scenarioIDVariable.setName('scenarioID');
    scenarioIDVariable.setType(data.MetaSituationVariable.TYPE_TEXT);
    
    versionVariable = data.MetaSituationVariable();
    versionVariable.setName('version');
    versionVariable.setType(data.MetaSituationVariable.TYPE_TEXT);
    
    eventVariable = data.MetaSituationVariable();
    eventVariable.setName('event');
    eventVariable.setType(data.MetaSituationVariable.TYPE_TEXT);
    
    zoneVariable = data.MetaSituationVariable();
    zoneVariable.setName('zone');
    zoneVariable.setType(data.MetaSituationVariable.TYPE_TEXT);
    
    leadVehicleIdVariable = data.MetaSituationVariable();
    leadVehicleIdVariable.setName('lead_vehicle_id');
    leadVehicleIdVariable.setType(data.MetaSituationVariable.TYPE_TEXT);
    
    TLpk = data.MetaSituationVariable();
    TLpk.setName('TL_pk');
    TLpk.setType(data.MetaSituationVariable.TYPE_REAL);
    
    trafficLightSituation = data.MetaSituation();
    trafficLightSituation.setIsBase(false);
    trafficLightSituation.setName('Traffic_light');
    trafficLightSituation.setVariables({scenarioIDVariable versionVariable eventVariable zoneVariable TLpk});
    theTrip.addSituation(trafficLightSituation);
       
    gapAcceptanceSituation = data.MetaSituation();
    gapAcceptanceSituation.setIsBase(false);
    gapAcceptanceSituation.setName('Gap_acceptance');
    gapAcceptanceSituation.setVariables({scenarioIDVariable versionVariable eventVariable zoneVariable});
    theTrip.addSituation(gapAcceptanceSituation);
    
    leadVehicleSituation = data.MetaSituation();
    leadVehicleSituation.setIsBase(false);
    leadVehicleSituation.setName('Lead_vehicle');
    leadVehicleSituation.setVariables({scenarioIDVariable versionVariable eventVariable zoneVariable leadVehicleIdVariable});
    theTrip.addSituation(leadVehicleSituation);
    
    distractionSituation = data.MetaSituation();
    distractionSituation.setIsBase(false);
    distractionSituation.setName('Distraction');
    distractionSituation.setVariables({versionVariable});
    theTrip.addSituation(distractionSituation);
    
    fullTripSituation = data.MetaSituation();
    fullTripSituation.setIsBase(false);
    fullTripSituation.setName('Full_trip');
    fullTripSituation.setVariables({});
    theTrip.addSituation(fullTripSituation);
    %Add the only instance of this situation : from the beginning to the
    %end of the data
    theTrip.setSituationAtTime('Full_trip', 0, theTrip.getMaxTimeInDatas())
    
    %This loop cleans the comments, by keeping only the useful part of the
    %message (the third).
    for i = 1:1:size(comments, 2)
       comment =  comments{2, i};
       %Split the line
       splittedComment = textscan(comment, '%s', 'Delimiter', '|');
       splittedComment = splittedComment{1};%Because the method returns a cell of cells
       comments{2, i} = strrep(splittedComment{3, 1}, '__', '');
       if length(splittedComment) > 3
           pkComment = splittedComment{6, 1};
           pkComment = strrep(pkComment, '__PKTL=', '');
           pkComment = strrep(pkComment, 'dm', '');
           comments{3, i} = str2double(pkComment)*100;
       end
    end
    
    %ok, now we are happy with our fresh and clean comments and their
    %timecodes... Let's make some situations of all this.
    for i = 1:1:size(comments, 2)
        comment = comments{2, i};
        twoFirstChars = comment(1:2);
        splittedComment = textscan(comment, '%s', 'Delimiter', '_');
        splittedComment = splittedComment{1};
        switch(twoFirstChars)
            case 'TE'
                %Case for 'TERMINE'
            case 'LV'
                %We do something only when it is a start of event flag
                if strcmp('S', splittedComment{4})
                    disp(['Lead vehicle : ' comment]);
                    SIndex = i;
                    EIndex = (i - 1) + findMarker(comments(2, i:end), [splittedComment{1} '_' splittedComment{2} '_' splittedComment{3} '_E_' splittedComment{5}]);
                    FIndex = (i - 1) + findMarker(comments(2, i:end), [splittedComment{1} '_' splittedComment{2} '_' splittedComment{3} '_F_' splittedComment{5}]);
                    disp(['--> Lead vehicle ' splittedComment{1} ' : [' num2str(comments{1, SIndex}) ' | ' num2str(comments{1, EIndex}) ' | ' num2str(comments{1, FIndex}) ']']);
                    
                    %Insert the situations in the Trip
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'scenarioID', comments{1, SIndex}, comments{1, EIndex}, splittedComment{1});
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'version', comments{1, SIndex}, comments{1, EIndex}, splittedComment{2});
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'event', comments{1, SIndex}, comments{1, EIndex}, splittedComment{3});
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'zone', comments{1, SIndex}, comments{1, EIndex}, 'approach_zone');
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'lead_vehicle_id', comments{1, SIndex}, comments{1, EIndex}, splittedComment{5});
                    
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'scenarioID', comments{1, EIndex}, comments{1, FIndex}, splittedComment{1});
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'version', comments{1, EIndex}, comments{1, FIndex}, splittedComment{2});
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'event', comments{1, EIndex}, comments{1, FIndex}, splittedComment{3});
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'zone', comments{1, EIndex}, comments{1, FIndex}, 'decision_zone');
                    theTrip.setSituationVariableAtTime('Lead_vehicle', 'lead_vehicle_id', comments{1, EIndex}, comments{1, FIndex}, splittedComment{5});
                end
            case 'GA'
                %We do something only when it is a start of event flag
                if strcmp('SE', splittedComment{3})
                    disp(['Gap acceptance : ' comment]);
                    SEIndex = i;
                    EEIndex = (i - 1) + findMarker(comments(2, i:end), [splittedComment{1} '_' splittedComment{2} '_EE']);
                    disp(['--> Gap acceptance ' splittedComment{1} ' : [' num2str(comments{1, SEIndex}) ' | ' num2str(comments{1, EEIndex}) ']' ]);
                    
                    %Insert the situations in the Trip
                    theTrip.setSituationVariableAtTime('Gap_acceptance', 'scenarioID', comments{1, SEIndex}, comments{1, EEIndex}, splittedComment{1});
                    theTrip.setSituationVariableAtTime('Gap_acceptance', 'version', comments{1, SEIndex}, comments{1, EEIndex}, splittedComment{2});
                    theTrip.setSituationVariableAtTime('Gap_acceptance', 'event', comments{1, SEIndex}, comments{1, EEIndex}, 'GA');
                    theTrip.setSituationVariableAtTime('Gap_acceptance', 'zone', comments{1, SEIndex}, comments{1, EEIndex}, 'decision_zone');
                end
            case 'TL'
                %Traffic light case
                if strcmp('SA', splittedComment{4})
                    disp(['Traffic light : ' comment]);
                    SAIndex = i;
                    SIIndex = (i - 1) + findMarker(comments(2, i:end), [splittedComment{1} '_' splittedComment{2} '_' splittedComment{3} '_SI']);
                    SDIndex = (i - 1) + findMarker(comments(2, i:end), [splittedComment{1} '_' splittedComment{2} '_' splittedComment{3} '_SD']);
                    SFIndex = (i - 1) + findMarker(comments(2, i:end), [splittedComment{1} '_' splittedComment{2} '_' splittedComment{3} '_SF']);
                    FFIndex = (i - 1) + findMarker(comments(2, i:end), [splittedComment{1} '_' splittedComment{2} '_' splittedComment{3} '_FF']);
                    disp(['--> Traffic light ' splittedComment{1} ' : [' num2str(comments{1, SAIndex}) ' | ' num2str(comments{1, SIIndex}) ' | ' num2str(comments{1, SDIndex}) ' | ' num2str(comments{1, SFIndex}) ' | ' num2str(comments{1, FFIndex}) ']' ]);
                    
                    %Insert the situations in the Trip
                    theTrip.setSituationVariableAtTime('Traffic_light', 'scenarioID', comments{1, SAIndex}, comments{1, SIIndex}, splittedComment{1});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'version', comments{1, SAIndex}, comments{1, SIIndex}, splittedComment{2});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'event', comments{1, SAIndex}, comments{1, SIIndex}, splittedComment{3});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'zone', comments{1, SAIndex}, comments{1, SIIndex}, 'approach_zone');
                    theTrip.setSituationVariableAtTime('Traffic_light', 'TL_pk', comments{1, SAIndex}, comments{1, SIIndex}, comments{3, i});
                    
                    theTrip.setSituationVariableAtTime('Traffic_light', 'scenarioID', comments{1, SIIndex}, comments{1, SDIndex}, splittedComment{1});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'version', comments{1, SIIndex}, comments{1, SDIndex}, splittedComment{2});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'event', comments{1, SIIndex}, comments{1, SDIndex}, splittedComment{3});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'zone', comments{1, SIIndex}, comments{1, SDIndex}, 'intermediate_zone');
                    theTrip.setSituationVariableAtTime('Traffic_light', 'TL_pk', comments{1, SIIndex}, comments{1, SDIndex}, comments{3, i});
                    
                    theTrip.setSituationVariableAtTime('Traffic_light', 'scenarioID', comments{1, SDIndex}, comments{1, SFIndex}, splittedComment{1});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'version', comments{1, SDIndex}, comments{1, SFIndex}, splittedComment{2});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'event', comments{1, SDIndex}, comments{1, SFIndex}, splittedComment{3});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'zone', comments{1, SDIndex}, comments{1, SFIndex}, 'decision_zone');
                    theTrip.setSituationVariableAtTime('Traffic_light', 'TL_pk', comments{1, SDIndex}, comments{1, SFIndex}, comments{3, i});
                    
                    theTrip.setSituationVariableAtTime('Traffic_light', 'scenarioID', comments{1, SFIndex}, comments{1, FFIndex}, splittedComment{1});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'version', comments{1, SFIndex}, comments{1, FFIndex}, splittedComment{2});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'event', comments{1, SFIndex}, comments{1, FFIndex}, splittedComment{3});
                    theTrip.setSituationVariableAtTime('Traffic_light', 'zone', comments{1, SFIndex}, comments{1, FFIndex}, 'final_zone');
                    theTrip.setSituationVariableAtTime('Traffic_light', 'TL_pk', comments{1, SFIndex}, comments{1, FFIndex}, comments{3, i});        
                end
                case {'VA' 'VB' 'VC'}
                    %We do something only when it is a start of event flag
                    if strcmp('S', splittedComment{2})
                        disp(['Distraction zone : ' comment]);
                        SIndex = i;
                        FIndex = (i - 1) + findMarker(comments(2, i:end), [splittedComment{1} '_F_' splittedComment{3} '_' 'D\d+' '_' splittedComment{5}]);      
                        disp(['--> Distraction zone ' splittedComment{1} ' : [' num2str(comments{1, SIndex}) ' | ' num2str(comments{1, FIndex}) ']']);

                        %Insert the situations in the Trip
                        theTrip.setSituationVariableAtTime('Distraction', 'version', comments{1, SIndex}, comments{1, FIndex}, twoFirstChars);
                    end
            otherwise
                error([twoFirstChars ' is not a valid prefix for the comment']);
        end
    end
    
    delete(theTrip);
end

function out = findMarker(markersArray, markerRegexp)
    for i = 1:1:length(markersArray)
        
        %if strcmp(markersArray{i}, marker)
        if strcmp(markersArray{i}, regexp(markersArray{i}, markerRegexp, 'match', 'once'))
            out = i;
            return;
        end
    end
    error(['Marker ' markerRegexp ' not found, sorry !']);
end
