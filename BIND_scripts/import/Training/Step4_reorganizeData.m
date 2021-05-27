function Step4_reorganizeData(tripFullPath, scenarioType)
    tic;  
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFullPath, 0.04, false);
    %Building matching table according to scenario
    %Matching table : Numero essai | numéro colonne (== nom data) | identifiant du véhicule
    switch scenarioType
        case 'natio1'
            matchingTable = { [49:62] [53:62] [54:67] [64:73] [68:73] [74:77] [74:77]; '-25' '-105' '-106' '-105' '-106' '-105' '-106'; '2RM20' '2RM7' '2RM8' '2RM9' '2RM10' '2RM11' '2RM22'}';
        case 'natio2'
            matchingTable = {[80:91] [82:91] [96:100] [99:108] [102:120] [117:120]; '-25' '-106' '-105' '-106' '-13' '-105'; '2RM21' '2RM12' '2RM14' '2RM15' '2RM2' '2RM16'}';
        case 'autor1'
            matchingTable = {[2:8] [4:7] [16:41] [25:32]; '-105' '-106' '-106' '-105';'2RM1' '2RM0' '2RM4' '2RM5'}';
        case 'autor2'
            matchingTable = {[4:7] [16:24] [25:32] [36:43,250]; '-106' '-105' '-105' '-105'; '2RM19' '2RM3' '2RM5' '2RM6'}';
        case {'ville1' 'ville2'}
            matchingTable = {[199:207] [199:207] [211:220] [211:220] [226:237] [226:237] [238:249] [238:249] [252:281] [252:281] [276:286] [276:286]; '-222' '-5' '-13' '-20' '-222' '-5' '-13' '-20' '-222' '-5' '-13' '-20'; 'Moto1.1' 'Moto1.2' 'Moto2.1' 'Moto2.2' 'Moto3.1' 'Moto3.2' 'Moto4.1' 'Moto4.2' 'Moto5.1' 'Moto5.2' 'Moto6.1' 'Moto6.2'}';
        otherwise
            error('scenario type incorrect !');
    end
    disp('Creating a situation for later aggregation...');
    metaSituation = fr.lescot.bind.data.MetaSituation();
    metaSituation.setName('motos');
    metaSituationVariable = fr.lescot.bind.data.MetaSituationVariable();
    metaSituationVariable.setName('vehicle');
    metaSituationVariable.setType('TEXT');
    metaSituation.setVariables({metaSituationVariable});
    trip.addSituation(metaSituation);

    %Creating the list of data to delete at the end to the script
    deleteList = trip.getMetaInformations().getDatasNamesList();
    indiceToRemove = strcmp(deleteList, 'simulation');
    deleteList(indiceToRemove) = [];
    indiceToRemove = strcmp(deleteList, 'localisation');
    deleteList(indiceToRemove) = [];
    indiceToRemove = strcmp(deleteList, 'trajectoire');
    deleteList(indiceToRemove) = [];
    indiceToRemove = strcmp(deleteList, 'vehicule');
    deleteList(indiceToRemove) = [];

    %Creating the new tables and filling them
    for i = 1:1:length(matchingTable)
        essais = matchingTable{i, 1};
        dataName = matchingTable{i, 2};
        newDataName = matchingTable{i, 3};

        disp(['Essais : [' num2str(essais) '] | Colonne : ' dataName ' | Vehicule : ' newDataName]);

        %Recreate the current data, with the new name.
        metaInfos = trip.getMetaInformations();
        newMetaData = metaInfos.getMetaData(dataName);
        newMetaData.setName(newDataName);
        newMetaData.setIsBase(false);
        trip.addData(newMetaData);

        allSimulationValues = trip.getAllDataOccurences('simulation');
        essaiValues = allSimulationValues.getVariableValues('numero_essai');
        correctEssaiIndices = [];
        for j = 1:1:length(essais)
            correctEssaiIndices = [correctEssaiIndices find(essais(j) == cell2mat(essaiValues))];
        end
        timecodesValues = allSimulationValues.getVariableValues('timecode');
        correctTimecodes = timecodesValues(correctEssaiIndices);

        startTimecodeOfEssai = min(cell2mat(correctTimecodes));
        endTimecodeOfEssai = max(cell2mat(correctTimecodes));

        %Bidouille pour compenser le fait que le véhicule spawne un peu après le
        %début des instructions (quelques pas de temsp)
        dataTimecodes = trip.getAllDataOccurences(dataName).getVariableValues('timecode');
        startTimecodeOfData = min(cell2mat(dataTimecodes));
        endTimecodeOfData = max(cell2mat(dataTimecodes));

        startTimecode = max(startTimecodeOfData, startTimecodeOfEssai);
        endTimecode = min(endTimecodeOfData, endTimecodeOfEssai);

        reallyCorrectTimecodes = trip.getDataVariableOccurencesInTimeInterval(dataName, 'timecode', startTimecode, endTimecode).getVariableValues('timecode');

        startTimecode = min(cell2mat(reallyCorrectTimecodes));
        endTimecode = max(cell2mat(reallyCorrectTimecodes));

        listOfVariablesToCopy = metaInfos.getDataVariablesNamesList(newDataName);
        for j = 1:1:length(listOfVariablesToCopy)
            variableName = listOfVariablesToCopy{j};
            disp(['--> Copying  ' dataName '.' variableName ' to ' newDataName '.' variableName ' on the time span [' num2str(startTimecode) ' ; ' num2str(endTimecode) ']']);
            timecodesToCopy = reallyCorrectTimecodes;
            valuesBetweenStartAndEnd = trip.getDataVariableOccurencesInTimeInterval(dataName, variableName, startTimecode, endTimecode).getVariableValues(variableName);
            trip.setBatchOfTimeDataVariablePairs(newDataName, variableName, {timecodesToCopy{:}; valuesBetweenStartAndEnd{:}});
        end
        disp('Inserting situation occurence...');
        %Test if the situation already exist for an other vehicle
        situation = trip.getSituationOccurenceAtTime('motos', startTimecode, endTimecode);
        if ~situation.isEmpty()
            endTimecode = endTimecode + 0.0001;
        end
        trip.setSituationVariableAtTime('motos', 'vehicle', startTimecode, endTimecode, newDataName);
    end

    disp('Deleting initial datas');
    for i = 1:1:length(deleteList)
        data = deleteList{i};
        disp(['--> Deleting ' data '...']);
        trip.setIsBaseData(data, false);
        trip.removeData(data);
    end
    %Closing the trip
    disp('Closing trip...');
    delete(trip);
    %Display execution time
    elapsedTime = toc;
    disp(['Datas reorganized in ' num2str(elapsedTime) ' seconds']);
end