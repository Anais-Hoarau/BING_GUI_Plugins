function generateSPSS()

    %Chargement du tripset sur le dossier qui contient tout les sujets
    directory = uigetdir(pwd, 'Choisissez le chemin du dossier contenant tout les trips de PARK');
    if directory == 0
        return;
    end
    %Choix du dossier de sortie
    outDirectory = uigetdir(directory, 'Choisissez le dossier de destination des fichiers générés');
    if outDirectory == 0
        return;
    end
    %Chargement des trips
    tripsFolders = {'park01_100607_10h07/trip_park01.trip',...
                'park02_100608_10h02/trip_park02.trip', ...
                'park03_100610_10h03/trip_park03.trip',...
                'park04_100614_10h10/trip_park04.trip',...
                'park05_100615_10h09/trip_park05.trip',...
                'park06_100621_09h59/trip_park06.trip',...
                'park07_100622_10h13/trip_park07.trip',...
                'park08_100624_10h17/trip_park08.trip',...
                'park09_100628_10h23/trip_park09.trip',...
                'park10_100629_10h06/trip_park10.trip',...
                'park11_100701_10h31/trip_park11.trip',...
                'park12_100705_10h04/trip_park12.trip',...
                'park13_100706_10h34/trip_park13.trip',...
                'park14_100708_10h17/trip_park14.trip',...
                'park16_100914_10h02/trip_park16.trip',...
                'park17_101004_10h42/trip_park17.trip',...
                'park18_101011_10h10/trip_park18.trip',...
                'park20_101018_10h08/trip_park20.trip',...
                'park21_101019_10h20/trip_park21.trip',...
                'park22_101025_10h03/trip_park22.trip',...
                'park23_101026_10h18/trip_park23.trip',...
                'park24_101108_10h24/trip_park24.trip',...
                'park25_101109_10h07/trip_park25.trip',...
                'park26_101115_10h20/trip_park26.trip',...
                'park27_101116_10h08/trip_park27.trip',...
                'park28_101118_10h23/trip_park28.trip',...
                'park29_101122_10h16/trip_park29.trip',...
                'park30_101123_10h10/trip_park30.trip',...
                'park31_101125_10h22/trip_park31.trip',...
                'park32_101129_10h49/trip_park32.trip',...
                'park33_101130_10h15/trip_park33.trip',...
                'park34_101206_10h12/trip_park34.trip',...
                'park35_101207_10h11/trip_park35.trip',...
                'park36_110110_10h12/trip_park36.trip',...
                'park38_110411_10h06/trip_park38.trip',...
                'park39_110516_10h31/trip_park39.trip',...
                'park40_110517_08h11/trip_park40.trip',...
                };
                %'park19_101012_10h02/trip_park19.trip',...
                %'park15_100913_10h05/trip_park15.trip',...
                %'park37_110228_10h21/trip_park37.trip',...
    numberOfTrips = length(tripsFolders);

    %Bloc de déclaration des variables sur lesquelles on va devoir itérer
    trips = cell(numberOfTrips);
    drivers = cell(numberOfTrips);
    numberStatuses = cell(numberOfTrips);
    statuses = cell(numberOfTrips);
    coders = {'Maud' 'Laurence'};
    situationsTypes = {'RP' 'TAGNP' 'CNP' 'CP' 'Z'};%Ronds points, Tourne à gauche non protégés, Priorité à droite, croisement prioritaire, Entre deux situations
    situationsTypesIds = {{1 2 13 17 34 35 41 42 43} {3 8 12 14 31 37 39} {15} {4 10 11 28} {'7and8' '14and15' '16and17' '17and18' '24and25' '35and36' '36and37' '37and38'}}; 
    situationsPositions = {'entryInt' 'int'};
    variableNames = {'PAD' 'FO' 'FR' 'CLD' ...
                     'Stop' 'AbsCli' 'CliTardif'...
                     'PbBV' 'PbPedales' 'FreinBrusque'...
                     'FreinTardif' 'RegardFixe'...
                     'AngleMort' 'AbsRetro' 'MvsChoixVoie'...
                     'ChgmtVoieTardif' 'TrajCoupee' 'TrajLarge'...
                     'PosG++' 'PosD++' 'FranchiLigne'...
                     'ArretTardif' 'ArretVoie' 'TropVite'...
                     'TropLent' 'DIVCourte' 'GAPCourt'...
                     'NDPietons' 'Klaxon' 'IntervFrein'...
                     'IntervVolant' 'IntervBoite de Vitesse'...
                     'IntervOrale'};
    %Chargement des trips dans le cell array
    for i = 1:1:numberOfTrips
        completeFilePath = [directory filesep tripsFolders{i}];
        disp(['Chargement de ' completeFilePath]);
        trips{i} = fr.lescot.bind.kernel.implementation.SQLiteTrip(completeFilePath, 0.1, false);
    end
    disp([num2str(numberOfTrips) ' trips chargés']);

    %Chargement des infos sur les participants dans les cell arrays qui vont
    %bien.
    for i = 1:1:numberOfTrips;
        trip = trips{i};
        disp(['Récupération des métadonnées du sujet ' num2str(i)]);
        participant = trip.getMetaInformations().getParticipant();

        drivers{i} = num2str(participant.getAttribute('Driver'));
        disp(['-- Driver : ' drivers{i}]); 

        numberStatuses{i} = participant.getAttribute('Number_status');
        disp(['-- Number status : ' numberStatuses{i}]); 

        statuses{i} = num2str( participant.getAttribute('Status'));
        disp(['-- Status : ' statuses{i}]); 
    end

    %Pour chaque type de situation et pour chaque codeur, on va créer un fichier Excel
    for coderIndex = 1:1:length(coders)
        coder = coders{coderIndex};
        for situationsTypesIndex = 1:1:length(situationsTypes)
            %Pour chaque occurence de la situation on crée un onglet.
            situationsIds = situationsTypesIds{situationsTypesIndex};
            for situationTypesIdIndex = 1:1:length(situationsIds)
                situationType = situationsTypes{situationsTypesIndex};
                situationID = num2str(situationsIds{situationTypesIdIndex});
                
                tabContent = generateTabContent(coder, trips, situationsPositions, variableNames, situationType, situationID, drivers, numberStatuses, statuses);
                
                if strcmp('Z', situationType)
                    xlsPath = [outDirectory filesep 'CNP' '_' coder '.xls'];
                else
                    xlsPath = [outDirectory filesep situationType '_' coder '.xls'];
                end
                tabName = [situationType '_' situationID];
                xlswrite(xlsPath, tabContent, tabName);
            end
        end
    end
end

function out = generateTabContent(coder, trips, situationsPositions, variableNames, situationType, situationID, drivers, numberStatuses, statuses)
    numberOfTrips = length(trips);    
    tabContent = {}; %TODO : voir si on peut préallouer
    %On écrit les en-têtes
    tabContent{1, 1} = 'Numéro du trip';
    tabContent{1, 2} = 'Sujet';
    tabContent{1, 3} = 'Status';
    for i = 1:1:length(situationsPositions)
        numberOfVariables = length(variableNames);
        for j = 1:1:numberOfVariables
            variableName = [situationsPositions{i} '_' variableNames{j}];
            variableIndex  = 3 + j + ( (i - 1) * numberOfVariables);
            tabContent{1, variableIndex} = variableName;
        end
    end
    %Pour chaque trip on remplit les informations et les valeurs
    %des variables
    for tripIndex = 1:1:numberOfTrips
        %Les informations du sujet
        tabContent{tripIndex + 1, 1} = drivers{tripIndex};
        tabContent{tripIndex + 1, 2} = numberStatuses{tripIndex};
        tabContent{tripIndex + 1, 3} = statuses{tripIndex};
        %Les codages
        trip = trips{tripIndex};
        record = trip.getAllSituationOccurences(['errorSituationsBy' coder]);
        %On itère sur les variables pour les obtenir sous forme de
        %cell array
        for i = 1:1:length(situationsPositions)
            numberOfVariables = length(variableNames);
            for j = 1:1:length(variableNames)
                variableName = variableNames{j};
                occurencesLabels = record.getVariableValues('Label');
                if strcmp('Z', situationType)
                    correctLabelLogicalIndexes = strcmpi(['betweenInt' situationID], occurencesLabels);
                else
                    correctLabelLogicalIndexes = strcmpi([situationsPositions{i} situationID], occurencesLabels);
                end
                

                occurencesTypes = record.getVariableValues('Type');
                correctTypeLogicalIndexes = strcmpi(situationType, occurencesTypes);
                
                correctOccurenceLogicalIndex = correctLabelLogicalIndexes & correctTypeLogicalIndexes;
                
                variableValues = record.getVariableValues(variableName);
                variableValue = variableValues{correctOccurenceLogicalIndex};
                tabContent{tripIndex + 1, 3 + j + ( (i - 1) * numberOfVariables)} = variableValue;
            end
        end
    end
    out = tabContent;
end
