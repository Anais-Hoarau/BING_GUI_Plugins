function addPOI(tripFullFile,xlsFullFile)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFullFile, 0.04, false);

    [~, name, ~] = fileparts(tripFullFile);
    %Create a log file
    date = clock();
    filename = [name ' ' num2str(date(3)) '.' num2str(date(2)) '.' num2str(date(1)) ' ' num2str(date(4)) 'h' num2str(date(5)) 'm' num2str(round(date(6))) 's.log'];
    file = fopen(filename, 'w+');
    % prepare trip meta data and structure for insertion of sections
    situationName = 'Sections';
    namesOfRequiredVariables = {'type' 'identifier' 'speedLimit' 'meanSpeed' 'sdSpeed' 'minSpeed' 'maxSpeed' 'speedEntropy' 'deviationToSpeedLimit' 'meanLaneDeviation' 'sdLaneDeviation' 'minLaneDeviation' 'maxLaneDeviation' 'laneDeviationEntropy' 'HFCSteeringWheel' 'SRR' };
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
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        };
    createMetaInformations(trip,situationName,namesOfRequiredVariables,typesOfRequiredVariables);
    trip.removeAllSituationOccurences(situationName);


    % read xls file
    % Excel file has 9 columns with following headers :
    % Type	Pk début (m)	num route	sens	Pk fin (m)	num route	sens	speedLimit	identifier
    [~,~,poi] = xlsread(xlsFullFile);
    poi(1,:) = [];
    [numberOfPoi, ~] = size(poi);

    disp('Getting values from trip');
    recordFromTrajectoire = trip.getAllDataOccurences('trajectoire');
    recordFromLocalisation = trip.getAllDataOccurences('localisation');
    timecodeArray = recordFromTrajectoire.getVariableValues('timecode');
    directionArray = recordFromTrajectoire.getVariableValues('Sens');
    pkArray = recordFromLocalisation.getVariableValues('Pk');
    roadArray = recordFromLocalisation.getVariableValues('route');
    for i = 1:1:numberOfPoi
        
        % Recherche et sauvegarde des resultats dans la base de données
        try
            startTc = findTimecode(poi{i, 2}, num2str(poi{i, 3}), poi{i, 4}, pkArray, roadArray, directionArray, timecodeArray);
            endTc = findTimecode(poi{i, 5}, num2str(poi{i, 6}), poi{i, 7}, pkArray, roadArray, directionArray, timecodeArray);
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
                    fprintf(file, '%s', ['Unexpected error while storing situtation on interval [' num2str(startTc) ';' num2str(endTc) '] ( pk [' num2str(poi{i, 2}) '], roadId [' num2str(poi{i, 3}) '] and direction [' poi{i, 4} ']' ')' char(13) ]);
            end
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

    % add it to the trip if it does not exist
    if  ~metas.existSituation(situationName)
        %Add event to trip and refresh meta datas
        trip.addSituation(situation);
        metas = trip.getMetaInformations();
    end
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
    if length(minIndice) > 1
        throw(MException('findTimecode:tooManyCandidates', 'We found more than one candidate for this point'));
    elseif isempty(minIndice)
        throw(MException('findTimecode:noCandidates', 'We found zero candidates for this point'));
    else
        disp('--> Ok, we found this one !');
        out = timecodeArray{minIndice};
    end
end