% select the directory containing the data
directory = uigetdir('\\dklescot\DataLescot\307\PARK');
[pathstr, name, ext, versn] =  fileparts(directory);

% find the correct file for the trip database
pattern = 'C*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = ...
fullfile(directory, listing.name);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

% select the directory containing the files
directory = uigetdir('\\dklescot\DataLescot\307\PARK');
[pathstr, name, ext, versn] =  fileparts(directory);

% find the correct file containing information
pattern = '*.avc';
txtFile =  fullfile(directory, pattern);
listing = dir(txtFile);

% Through all the file .avc
for i = 1:numel(listing)
    textFile = fullfile(directory,listing(i).name);
    fileID = fopen(textFile);
    [time,remark,number] = textread(textFile,'%s\t%s\t%s');
    
    % Change the time point in second
    timecode = zeros(length(time),1);
    for j = 1:length(time)
        A = sscanf(time{j},'%2d%2d%2d%2d');
        timecode(j) = A(1)*3600 + A(2)*60 + A(3) + A(4) * 0.04;
    end
    
    if regexp(listing(i).name, 'Consigne')
        % Create the database
        if (~theTrip.getMetaInformations().existSituation('ConsignePoudrette'))
            disp('The output event doesnt exist!');
            disp('And it will be created!')
            situation = fr.lescot.bind.data.MetaSituation();
            timeBegin = fr.lescot.bind.data.MetaSituationVariable();
            timeEnd = fr.lescot.bind.data.MetaSituationVariable();
            label = fr.lescot.bind.data.MetaSituationVariable();
            situation.setName('ConsignePoudrette');
            timeBegin.setName('startTimecode');
            timeEnd.setName('endTimecode');
            label.setName('Label');
            timeBegin.setIsUnique(true);
            timeEnd.setIsUnique(true);
            situation.setVariables({timeBegin,timeEnd,label});
            theTrip.addSituation(situation);
        else
            disp('The output event and output event variables already exist!');
            disp('Please delete them all to create or update!')
            disp('--- The end ---');
        end
        
        % Save the data
        theTrip.setSituationVariableAtTime('ConsignePoudrette', 'Label', timecode(1), timecode(2),' ');
         
    elseif regexp(listing(i).name, 'Contexte')
        % Create the database
        if (~theTrip.getMetaInformations().existSituation('ContextePoudrette'))
            disp('The output event doesnt exist!');
            disp('And it will be created!')
            situation = fr.lescot.bind.data.MetaSituation();
            timeBegin = fr.lescot.bind.data.MetaSituationVariable();
            timeEnd = fr.lescot.bind.data.MetaSituationVariable();
            label = fr.lescot.bind.data.MetaSituationVariable();
            situation.setName('ContextePoudrette');
            timeBegin.setName('startTimecode');
            timeEnd.setName('endTimecode');
            label.setName('Label');
            situation.setVariables({timeBegin,timeEnd,label});
            theTrip.addSituation(situation);
        else
            disp('The output event and output event variables already exist!');
            disp('Please delete them all to create or update!')
            disp('--- The end ---');
        end
        
        sum = 0;
        for j =1:length(remark)
            if regexp(remark{j},'_VF_')
                sum = sum + 1;
            end
        end

        tabletimebegin = zeros(sum,1);
        tabletimeend = zeros(sum,1);
        labelcellArray = cell(sum,1);
        
        ind = 1;
        for j = 1:length(remark)
            if regexp(remark{j},'VF_Gauche') & ~strcmpi(remark{j},'Fin_VF_Gauche')
                disp('gauche');
                tabletimebegin(ind) = timecode(j);
                for k = j+1:length(remark)
                    if regexp(remark{k},'Fin_VF_Gauche')
                        tabletimeend(ind) = timecode(k);
                        break;
                    end
                end                  
                labelcellArray{ind} = 'VF_Gauche';
                ind = ind + 1;
            elseif regexp(remark{j},'VF_Droite') & ~strcmpi(remark{j},'Fin_VF_Droite')
                disp('droite');
                tabletimebegin(ind) = timecode(j);
                for k = j+1:length(remark)
                    if regexp(remark{k},'Fin_VF_Droite')
                        tabletimeend(ind) = timecode(k);
                        break;
                    end
                end
                labelcellArray{ind} = 'VF_Droite';
                ind = ind + 1;
            elseif regexp(remark{j},'VF_ToutDroit') & ~strcmpi(remark{j},'Fin_VF_ToutDroit')
                disp('toutdroit');
                tabletimebegin(ind) = timecode(j);
                for k = j+1:length(remark)
                    if regexp(remark{k},'Fin_VF_ToutDroit')
                        tabletimeend(ind) = timecode(k);
                        break;
                    end
                end
                labelcellArray{ind} = 'VF_ToutDroit';
                ind = ind + 1;
            elseif regexp(remark{j},'ON')
                disp('voiture devant');
                tabletimebegin(ind) = timecode(j);
                for k = j+1:length(remark)
                    if regexp(remark{k},'OFF')
                        tabletimeend(ind) = timecode(k);
                        break;
                    end
                end
                labelcellArray{ind} = 'VoitureDevant';
                ind = ind + 1;
            end
        end
        
        % Check if there is a zero in endTimecode
        for j = 1:length(tabletimeend)
            if tabletimeend(j) == 0
                for k = 1:length(listing)
                    if regexp(listing(k).name, 'Zones')
                        textFile = fullfile(directory,listing(k).name);
                        fileID = fopen(textFile);
                        [time,remark,number] = textread(textFile,'%s\t%s\t%s');
                        
                        % Change the time point in second
                        A = sscanf(time{7},'%2d%2d%2d%2d');
                        fintimecode = A(1)*3600 + A(2)*60 + A(3) + A(4) * 0.04;
                        
                        % Change the endTimecode 0 by the new timecode(endTimecode of Zone 7)
                        tabletimeend(j) = fintimecode;
                        
                        break;
                    end
                end
            end
        end
        
        % Save the data
        for j = 1:sum
            theTrip.setSituationVariableAtTime('ContextePoudrette', 'Label', tabletimebegin(j), tabletimeend(j),labelcellArray{j});
        end
        
    elseif regexp(listing(i).name, 'Conversation')
        % Create the database
        if (~theTrip.getMetaInformations().existSituation('ConversationPoudrette'))
            disp('The output event doesnt exist!');
            disp('And it will be created!')
            situation = fr.lescot.bind.data.MetaSituation();
            timeBegin = fr.lescot.bind.data.MetaSituationVariable();
            timeEnd = fr.lescot.bind.data.MetaSituationVariable();
            label = fr.lescot.bind.data.MetaSituationVariable();
            situation.setName('ConversationPoudrette');
            timeBegin.setName('startTimecode');
            timeEnd.setName('endTimecode');
            label.setName('Label');
            timeBegin.setIsUnique(true);
            timeEnd.setIsUnique(true);
            situation.setVariables({timeBegin,timeEnd,label});
            theTrip.addSituation(situation);
        else
            disp('The output event and output event variables already exist!');
            disp('Please delete them all to create or update!')
            disp('--- The end ---');
        end
        
        % Save the data
        labelname = [remark{1} ' -> ' remark{2}];
        theTrip.setSituationVariableAtTime('ConversationPoudrette', 'Label', timecode(1), timecode(2),labelname);
        
    elseif regexp(listing(i).name, 'StrategiesVisuelles')
        % Create the database
        if (~theTrip.getMetaInformations().existSituation('RegardPoudrette'))
            disp('The output event doesnt exist!');
            disp('And it will be created!')
            situation = fr.lescot.bind.data.MetaSituation();
            timeBegin = fr.lescot.bind.data.MetaSituationVariable();
            timeEnd = fr.lescot.bind.data.MetaSituationVariable();
            label = fr.lescot.bind.data.MetaSituationVariable();
            situation.setName('RegardPoudrette');
            timeBegin.setName('startTimecode');
            timeEnd.setName('endTimecode');
            label.setName('Label');
            timeBegin.setIsUnique(true);
            timeEnd.setIsUnique(true);
            situation.setVariables({timeBegin,timeEnd,label});
            theTrip.addSituation(situation);
        else
            disp('The output event and output event variables already exist!');
            disp('Please delete them all to create or update!')
            disp('--- The end ---');
        end
        
        l = length(remark);
        for j = 2:l
            theTrip.setSituationVariableAtTime('RegardPoudrette', 'Label', timecode(j-1), timecode(j),remark{j-1});
        end
        fintime = timecode(l);
        finremark = remark{l};
        
        % The last one finishes at the endTimecode of Zone7
        for k = 1:length(listing)
            if regexp(listing(k).name, 'Zones')
                textFile = fullfile(directory,listing(k).name);
                fileID = fopen(textFile);
                [time,remark,number] = textread(textFile,'%s\t%s\t%s');
                
                % Change the time point in second
                A = sscanf(time{7},'%2d%2d%2d%2d');
                fintimecode = A(1)*3600 + A(2)*60 + A(3) + A(4) * 0.04;
                
                break;
            end
        end
        theTrip.setSituationVariableAtTime('RegardPoudrette', 'Label', fintime, fintimecode, finremark);
        
    elseif regexp(listing(i).name, 'Zones')
        % Create the database
        if (~theTrip.getMetaInformations().existSituation('ZonesPoudrette'))
            disp('The output event doesnt exist!');
            disp('And it will be created!')
            situation = fr.lescot.bind.data.MetaSituation();
            timeBegin = fr.lescot.bind.data.MetaSituationVariable();
            timeEnd = fr.lescot.bind.data.MetaSituationVariable();
            label = fr.lescot.bind.data.MetaSituationVariable();
            situation.setName('ZonesPoudrette');
            timeBegin.setName('startTimecode');
            timeEnd.setName('endTimecode');
            label.setName('Label');
            timeBegin.setIsUnique(true);
            timeEnd.setIsUnique(true);
            situation.setVariables({timeBegin,timeEnd,label});
            theTrip.addSituation(situation);
        else
            disp('The output event and output event variables already exist!');
            disp('Please delete them all to create or update!')
            disp('--- The end ---');
            return;
        end
        
        % From FinConsigne to Point1
        dataSituation = theTrip.getAllSituationOccurences('ConsignePoudrette');
        finconsigne = cell2mat(dataSituation.getVariableValues('endTimecode'));
        theTrip.setSituationVariableAtTime('ZonesPoudrette', 'Label', finconsigne, timecode(1),num2str(1));
        
        % From Point2 to FinZones
        for j = 2:length(remark)
            theTrip.setSituationVariableAtTime('ZonesPoudrette', 'Label', timecode(j-1), timecode(j),num2str(j));
        end
        
    end
    
end