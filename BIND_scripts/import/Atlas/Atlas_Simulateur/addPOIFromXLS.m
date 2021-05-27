function addPOIFromXLS(tripFullFile,xlsFullFile)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFullFile, 0.04, false);

    disp(['----------------' tripFullFile ': ' xlsFullFile '---------------']);
    [~, name, ~] = fileparts(tripFullFile);
    %Create a log file
    date = clock();
    filename = [name ' ' num2str(date(3)) '.' num2str(date(2)) '.' num2str(date(1)) ' ' num2str(date(4)) 'h' num2str(date(5)) 'm' num2str(round(date(6))) 's.log'];
    file = fopen(filename, 'w+');
    % prepare trip meta data and structure for insertion of sections
    situationName = 'Sections';
    namesOfRequiredVariables = {'type' 'identifier' 'speedLimit' 'mean_deviation_to_prescripted_speed' 'jerk' 'lane_deviation' 'mean_break_percentage' 'max_break_percentage' 'mean_TIV' 'coherence' 'phase_shift' 'modulus'};
    typesOfRequiredVariables = {fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL
        };
    createMetaInformations(trip,situationName,namesOfRequiredVariables,typesOfRequiredVariables);
    trip.removeAllSituationOccurences(situationName);


    % read xls file
    % Excel file has 9 columns with following headers :
    % Type	Pk début (m)	num route	sens	Pk fin (m)	num route	sens	speedLimit	identifier
    [poiTxt ,poiNum , poi] = xlsread(xlsFullFile);
    poi(1,:) = [];
    numberOfPoi = size(poiTxt, 1);

    disp('Getting values from trip');
    recordFromTrajectoire = trip.getAllDataOccurences('trajectoire');
    recordFromLocalisation = trip.getAllDataOccurences('localisation');
    timecodeArray = recordFromTrajectoire.getVariableValues('timecode');
    directionArray = recordFromTrajectoire.getVariableValues('Sens');
    pkArray = recordFromLocalisation.getVariableValues('Pk');
    roadArray = recordFromLocalisation.getVariableValues('route');
    i = 1;
    while i <= numberOfPoi
        %On regarde si le prochain item est marqué comme item alternatif
        %(sauf pour le dernier item)
        if i ~= numberOfPoi && ~isnan(poi{i + 1, 10});
            disp('O Cas avec alternate');
            startTc = findTimecode(poi{i, 2} / 10, num2str(poi{i, 3}), poi{i, 4}, pkArray, roadArray, directionArray, timecodeArray);
            endTc = findTimecode(poi{i, 5} / 10, num2str(poi{i, 6}), poi{i, 7}, pkArray, roadArray, directionArray, timecodeArray);
            startTcAlt = findTimecode(poi{i+1, 2} / 10, num2str(poi{i+1, 3}), poi{i+1, 4}, pkArray, roadArray, directionArray, timecodeArray);
            endTcAlt = findTimecode(poi{i+1, 5} / 10, num2str(poi{i+1, 6}), poi{i+1, 7}, pkArray, roadArray, directionArray, timecodeArray);
            
            initialValid = startTc ~= -1 && endTc ~= -1 && startTc ~= endTc && startTc < endTc;
            altValid = startTcAlt ~= -1 && endTcAlt ~= -1 && startTcAlt ~= endTcAlt && startTcAlt < endTcAlt;
            
            %cas ou on est mal barré
            if ~initialValid && ~altValid
                disp('### Les deux situations sont ko, on en garde aucune');
            else
                %Cas ou on a pas la première situation
                if ~initialValid
                    disp(['--> On garde l''alternate : [' num2str(startTcAlt) ';' num2str(endTcAlt) ']'])
                    trip.setSituationVariableAtTime(situationName,'type', startTcAlt,endTcAlt,poi{i+1, 1});
                    trip.setSituationVariableAtTime(situationName,'identifier', startTcAlt,endTcAlt,poi{i+1, 9});
                    trip.setSituationVariableAtTime(situationName,'speedLimit', startTcAlt,endTcAlt,poi{i+1, 8});
                else
                    disp(['--> On garde l''initiale : [' num2str(startTc) ';' num2str(endTc) ']'])
                    trip.setSituationVariableAtTime(situationName,'type', startTc,endTc,poi{i, 1});
                    trip.setSituationVariableAtTime(situationName,'identifier', startTc,endTc,poi{i, 9});
                    trip.setSituationVariableAtTime(situationName,'speedLimit', startTc,endTc,poi{i, 8});
                end
            end
    
            i = i + 2;
        %Cas ou on a pas un itineraire alternatif
        else
            disp('O Cas sans alternate');
            try
                startTc = findTimecode(poi{i, 2} / 10, num2str(poi{i, 3}), poi{i, 4}, pkArray, roadArray, directionArray, timecodeArray);
                endTc = findTimecode(poi{i, 5} / 10, num2str(poi{i, 6}), poi{i, 7}, pkArray, roadArray, directionArray, timecodeArray);
                trip.setSituationVariableAtTime(situationName,'type', startTc,endTc,poi{i, 1});
                trip.setSituationVariableAtTime(situationName,'identifier', startTc,endTc,poi{i, 9});
                trip.setSituationVariableAtTime(situationName,'speedLimit', startTc,endTc,poi{i, 8});
            catch ME
                switch ME.identifier
                    case 'findTimecode:noCandidates'
                        fprintf(file, '%s', ['No candidates for pk [' num2str(poi{i, 2}) '], roadId [' num2str(poi{i, 3}) '] and direction [' poi{i, 4} ']' char(13)]);
                    case 'findTimecode:tooManyCandidates'
                        fprintf(file, '%s', ['Too many candidates for pk [' num2str(poi{i, 2}) '], roadId [' num2str(poi{i, 3}) '] and direction [' poi{i, 4} ']' char(13) ]);
                    case 'SQLiteTrip:setSituationVariableAtTime:InvalidTimecodes'
                        disp(ME.getReport());
                        fprintf(file, '%s', ['Unexpected error while storing situtation on interval [' num2str(startTc) ';' num2str(endTc) '] ( pk [' num2str(poi{i, 2}) '], roadId [' num2str(poi{i, 3}) '] and direction [' poi{i, 4} ']' ')' char(13) ]);
                end
            end
            i = i + 1;
        end
        
        
    end
    %closing the log file
    fclose(file);
end


%{
    Function:
    This method can be called to verify if the required meta informations are
        already present in the trip for information coding

    Arguments:
    this - optional, the object on which the method is called

    Returns:
    out - a boolean that is true if all conditions are met for the meta inforamtions of the trip with the requirement
        of the coding plugin
    trip - the trip to check
    situationName - string
    namesOfRequiredVariables - cell array of string
    typesOfRequiredVariables - cell array of string
%}
function out = createMetaInformations(trip,situationName,namesOfRequiredVariables,typesOfRequiredVariables)
    metas = trip.getMetaInformations();
    % create meta event in memory
    situation = fr.lescot.bind.data.MetaSituation();
    situation.setName(situationName);

    %delete the situation if it already exist
    if  metas.existSituation(situationName)
        trip.removeSituation(situationName);
    end
    %Add event to trip and refresh meta datas
    trip.addSituation(situation);
    metas = trip.getMetaInformations();
    for i=1:length(namesOfRequiredVariables)
        if (~metas.existSituationVariable(situationName,namesOfRequiredVariables{i}))
            metaVariable = fr.lescot.bind.data.MetaSituationVariable();
            metaVariable.setName(namesOfRequiredVariables{i});
            metaVariable.setType(typesOfRequiredVariables{i});
            trip.addSituationVariable(situationName,metaVariable);
        end
    end
    out = true;
end


function out = findTimecode(pkInMeters, roadId, direction, pkArray, roadArray, directionArray, timecodeArray)
    disp(['Searching timecode for pk [' num2str(pkInMeters) '], roadId [' roadId '] and direction [' direction ']']);
    directionString = '';
    switch(direction)
        case '-'
            directionString = 'Inverse';
        case '+'
            directionString = 'Direct';
    end
    %On commence par filtrer sur la direction
    indicesNOk = ~strcmpi(directionArray, directionString);
    pkArray(indicesNOk) = [];
    roadArray(indicesNOk) = [];
    directionArray(indicesNOk) = [];
    timecodeArray(indicesNOk) = [];
    %On filtre ensuite sur l'id de la route
    indicesNOk = ~strcmp(roadArray, roadId);
    pkArray(indicesNOk) = [];
    roadArray(indicesNOk) = [];
    directionArray(indicesNOk) = [];
    timecodeArray(indicesNOk) = [];
    %On calcule la distance absolue entre le pk de référence et les pk
    %restants
    distances = abs((cell2mat(pkArray) / 1000) - pkInMeters);

    [~, minIndice] = min(distances);
    if length(minIndice) > 1 || length(minIndice) < 1
        out = -1;
        disp(['--> Ko, found ' num2str(length(minIndice)) ' match']);
    else
        disp(['--> Ok, found @ : ' num2str(timecodeArray{minIndice}) 's']);
        out = timecodeArray{minIndice};
    end
end