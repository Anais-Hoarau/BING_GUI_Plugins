
function out = functionImportABSTRACT(FileName,PathName)
% find the correct directory and file
matFile = ...
    fullfile(PathName, FileName);
disp(['converting file :' matFile]);
matManip = open(matFile);

nomManip = matManip.Manipsave.nom;
numSujet = matManip.Manipsave.numSujet;

%on prépare le trip de destination
sqlFile =  fullfile(PathName, ['trip_' nomManip num2str(numSujet) '.trip']);
delete(sqlFile);
newTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(sqlFile,0.04,true);

newTrip.setAttribute('nom',nomManip);
newTrip.setAttribute('numSujet',num2str(numSujet));

videoFilename = (['.\toBeReplaced.avi' ]);
description = 'quadravision';
offset = -1;
laVideo = fr.lescot.bind.data.MetaVideoFile(videoFilename, offset, description);
newTrip.addVideoFile(laVideo);

infosData = matManip.Manipsave.data;
[dataNumber , ~] = size(infosData);

for x=1:dataNumber
    nomData = infosData(x).nom;
    infoUtilisateur = [ 'Processing data : ' nomData];
    disp(infoUtilisateur);
    maData = fr.lescot.bind.data.MetaData();
    maData.setName(nomData);
    maData.setFrequency(num2str(infosData(x).frequence));
    infoVariables = infosData(x).nomsColonne;
    [variableNumber , ~] = size(infoVariables);
    
    listeVariables{1} = 'timecode';
    hasDistance = 0;
    hasAngleVolant = 0;
    for i=2:variableNumber
        if strcmp(infoVariables(i).nom,'Distance')
            if (hasDistance == 0)
                listeVariables{i} = infoVariables(i).nom;
                hasDistance = 1;
            else
                listeVariables{i} = 'Distance2';
            end
        else
            if strcmp(infoVariables(i).nom,'AngleVolant')
                if (hasAngleVolant == 0)
                    listeVariables{i} = infoVariables(i).nom;
                    hasAngleVolant = 1;
                else
                    listeVariables{i} = 'AngleVolant2';
                end
            else
                
                listeVariables{i} = infoVariables(i).nom;
            end
        end
    end
    
    clear('infoVariables');
    
    % first variable is timecode
    nbVariableToRecord = length(listeVariables)-1;
    variables = cell(1,nbVariableToRecord);
    indice = 1;
    for i=1:length(listeVariables)
        % no need to create timecode variable
        if ~strcmp(char(listeVariables{i}),'timecode')
            uneVariable = fr.lescot.bind.data.MetaDataVariable();
            uneVariable.setName(char(listeVariables{i}));
            variables{1,indice} = uneVariable;
            indice = indice +1 ;
        end
        
    end
    maData.setVariables(variables);
    maData.setComments(['generated ' date]);
    newTrip.addData(maData);
    
    data = matManip.ManipDatasave(x).data;
    
    timecodes = data(:,1);
    
    infoUtilisateur = 'Processing Variables : ';
    disp(infoUtilisateur);
    % on ne sauvegarde pas la column 1 qui est le timecode
    for i=2:variableNumber
        infoUtilisateur = [char(listeVariables{i}) '... '];
        disp(infoUtilisateur);
        dataToRecord = data(:,i);
        timeValueCellArray = [num2cell(timecodes) num2cell(dataToRecord)]';
        newTrip.setBatchOfTimeDataVariablePairs(nomData,char(listeVariables{i}),timeValueCellArray);
    end
    newTrip.setIsBaseData(nomData,true);
    
    clear('data');
end
delete(newTrip);
clear newTrip;
end