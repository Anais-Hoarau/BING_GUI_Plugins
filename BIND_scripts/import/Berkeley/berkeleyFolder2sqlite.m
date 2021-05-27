function videoBaseName = berkeleyFolder2sqlite(inputFolder, outputFolder)
tic;
%Avoid problems with berkely utility if the folder is not ended by a
%'filesep'
inputFolder = [inputFolder filesep];
outputFolder = [outputFolder filesep];

disp('Loading berkeley structure from folder...');
[trip load_index] = load_trip(inputFolder);
disp('Berkeley structure loaded.');
metadata = trip.meta;
timecodes = trip.ts;
% In order to keep the timestamps in UTC format in the SQLiteTrip
datas = rmfield(trip, {'meta'});
% Otherwise, this would remove the timestamps table
%datas = rmfield(trip, {'meta', 'ts'});
% videoBaseName
videoBaseName = [metadata.study '-' metadata.driver '-' metadata.vehicle '-' metadata.date '-' metadata.tripid];

%Transcode from hh:mm:ss.sss to seconds and shift to get an initial
%timecode of 0.
disp('Recalculating timecodes in bind format...');
timecodeText = timecodes.text;
timecode = zeros(length(timecodeText),1);
initialTimeCode = 0;
for i = 1:1:length(timecodeText)
    tokens = regexp(timecodeText(i,:), '\.||:', 'split');
    seconds = str2double(tokens{1})*3600 + str2double(tokens{2})*60 + str2double(tokens{3}) + str2double(tokens{4})/1000;
    if(i == 1)
        initialTimeCode = seconds;
    end
    seconds = seconds - initialTimeCode;
    timecode(i) = seconds;
end
disp('Timecodes recalculated.');

%Merge the time code whith all other datas
disp('Merging timecodes with data...');
dataList = fieldnames(datas);
for i=1:1:size(dataList)
    dataName = dataList{i};
    eval(['datas.' dataName '.timecode = timecode;']);
end
disp('Timecodes merged.');
sqliteTripPath = [outputFolder metadata.study '-' metadata.driver '-' metadata.vehicle '-' metadata.date '-' metadata.tripid '.trip'];
disp(['Writing to ' sqliteTripPath '...']);
sqliteTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(sqliteTripPath, 0.04, true);
%Trip attributes
sqliteTrip.setAttribute('nom', [metadata.study ' - ' metadata.driver ' - ' metadata.vehicle ' - ' metadata.tripid]);
sqliteTrip.setAttribute('date', metadata.date);
%Driver attributes
participant = fr.lescot.bind.data.MetaParticipant();
participant.setAttribute('numSujet', metadata.driver);
sqliteTrip.setParticipant(participant);
%Vidéo attributes
tcBeginFirstDataFile = load_index(1,2);
tcEndFirstDataFile = load_index(1,3);
offset = 120 - (tcEndFirstDataFile - tcBeginFirstDataFile);
videoFront = fr.lescot.bind.data.MetaVideoFile(['.\' videoBaseName '-front.avi'],offset,'front');
sqliteTrip.addVideoFile(videoFront);
videoQuadra = fr.lescot.bind.data.MetaVideoFile(['.\' videoBaseName '-quadra.avi'],offset,'quadra');
sqliteTrip.addVideoFile(videoQuadra);


%The datas structure + the real content
for i = 1:1:length(dataList)
    disp(['-->' dataList{i}]);
    metadata = fr.lescot.bind.data.MetaData();
    metadata.setFrequency(20)%TODO: voir si pb encodage
    metadata.setType('');
    metadata.setIsBase(false);
    metadata.setName(dataList{i});
    %The variables
    dataStructure = eval(['datas.' dataList{i}]);
    variablesList = fieldnames(dataStructure);
    variablesList(strcmp('timecode', variablesList)) = [];
    metavariables = cell(1, length(variablesList));
    for j = 1:1:length(variablesList)
        metavariable = fr.lescot.bind.data.MetaDataVariable();
        metavariable.setName(variablesList{j});
        % deal with the case of the timestamp (only variable which is not
        % real... ('ts.text' field)
        % /!\ not generic!
        if strcmp(dataList{i},'ts') && strcmp(variablesList{j},'text')
            metavariable.setType(fr.lescot.bind.data.MetaDataVariable.TYPE_TEXT);
        else
            metavariable.setType(fr.lescot.bind.data.MetaDataVariable.TYPE_REAL);
        end
        metavariables{j} = metavariable;
    end
    metadata.setVariables(metavariables);
    sqliteTrip.addData(metadata);
    %now the structure of the data is prepared, so let's store everything
    timecodes = num2cell(eval(['datas.' dataList{i} '.timecode']));
    for j = 1:1:length(variablesList)
        % deal with the case of the timestamp (only variable which is not
        % real... ('ts.text' field)
        % /!\ not generic!
        if strcmp(dataList{i},'ts') && strcmp(variablesList{j},'text')
            text_mat = eval(['datas.' dataList{i} '.' variablesList{j} ]);
            l = length(text_mat);
            values = mat2cell(eval(['datas.' dataList{i} '.' variablesList{j} ]),ones(l,1),[12]);
        else
            values = num2cell(eval(['datas.' dataList{i} '.' variablesList{j} ]));
        end
        array = [timecodes(:), values(:)]';
        sqliteTrip.setBatchOfTimeDataVariablePairs(dataList{i}, variablesList{j}, array);
    end
    metadata.setIsBase(true);%KO
end

delete(sqliteTrip);
disp(['Written. Trip converted in ' num2str(toc/60) 'm']);

end

