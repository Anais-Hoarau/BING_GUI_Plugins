function importScoop2BIND(FileName,PathName)

FileName2 = strtok (FileName,'.');%On supprime l'extension .txt à la fin du nom du fichier
nomTrip = strtok (FileName2,' ');% On parse le nom du fichier pour récuperer 

[nomSujet,token] = strtok(FileName2,'-');%le nom du sujet

[remain,parcoursSujet] = strtok (token,'_');%le parcours
[parcoursSujet,token] = strtok(remain,'-');

[remain,conditionSujet] = strtok(nomTrip, '_'); %la condition
[conditionSujet,token] = strtok(conditionSujet,'_');

[remain,dateSujet] = strtok(FileName2, ' ');%la date
dateSujet = strtrim(dateSujet);

%On clear toutes les variables inutiles
clear FileName2;
clear remain;
clear token;

%% Initialisation des variables

compteur = 1;
nomManip = 'Corola';
frequenceData = 0;
tempsClapDebut = 0;
tempsClapFin = 0;

%% On prépare le trip de destination

sqlFile =  fullfile(PathName, ['trip_' nomTrip '.trip']);
delete(sqlFile);
newTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(sqlFile,0.04,true);

newTrip.setAttribute('nomManip',nomManip);
newTrip.setAttribute('idSujet',nomSujet);
%newTrip.setAttribute('date',dateSujet);

%rajout d'attribut
newTrip.setAttribute('parcours',parcoursSujet);
newTrip.setAttribute('condition',conditionSujet);


%% On s'occupe de la synchro vidéo // fichier de données
offset = 0; % initialisation de l'offset à 0

% On identifie la vidéo située dans le dossier
pattern = fullfile(PathName, [nomSujet parcoursSujet conditionSujet '.avi']);
listingVideo = dir(pattern);

if (~isempty(listingVideo))
    % si on a une vidéo, il faut un fichier de CLAP pour la synchro
    patternClap = fullfile(PathName, ['clap_' nomSujet parcoursSujet conditionSujet '.txt']);
    listingClap = dir(patternClap);
    if (~isempty(listingClap))
        % on lit le fichier de clap
        fid = fopen(patternClap);
        Claps = textscan(fid,'%s');
        fclose(fid);
        if (~isempty(Claps{1}{3}))
            stringToFormat = Claps{1}{3};
            A = sscanf(stringToFormat,'%2d:%2d:%2d:%2d');
            offset = A(1)*3600 + A(2)*60 + A(3) + A(4) * 0.04;
            offset = -offset;
            stringToFormat = Claps{1}{2};
            A = sscanf(stringToFormat,'%2d:%2d:%2d:%2d');
            tempsClapFin = A(1)*3600 + A(2)*60 + A(3) + A(4) * 0.04;
            stringToFormat = Claps{1}{1};
            A = sscanf(stringToFormat,'%2d:%2d:%2d:%2d');
            tempsClapDebut = A(1)*3600 + A(2)*60 + A(3) + A(4) * 0.04;
        end
        
        %on référencie la vidéo pour le lien dans BIND
        videoName = (['.\' listingVideo.name]);
        description = 'Sortie Quadravision';
        laVideo = fr.lescot.bind.data.MetaVideoFile(videoName, offset, description);
        newTrip.addVideoFile(laVideo);
        
    else
        % on a pas de clap... on ne peut pas synchroniser la video
        disp('PAS DE FICHIER CLAP CLAP CLAP');
        disp('Fichier clap.txt nécessaire. Format :');
        disp('1er ligne : temps apparition diode debut format 00:00:00:image');
        disp('2eme ligne : temps apparition diode fin format 00:00:00:image');
        disp('3eme ligne : time code de la premiere image video format 00:00:00:image');
        return
    end
end

% on créé le participant pour le fichier .db
% leParticipant = fr.lescot.bind.data.MetaParticipant();
% leParticipant.setAttribute('name','sujetxx');
% newTrip.setParticipant(leParticipant);

%% boucle pour calculer les offset et glissement pour synchro des données
% il faut utiliser les infos dans le fichier clap.txt et dans le fichier de
% données forgé par SCOOP
offsetVideo = 0;
glissement = 1;
noVideo = true;

% on ouvre le fichier de données
saveFile = fullfile([PathName FileName]);
fid = fopen(saveFile);

pattern = ''; 
N = 197;
for i=1:N
    pattern = [pattern '%f '];
end
A = textscan(fid, pattern,'HeaderLines',1,'TreatAsEmpty','null','EmptyValue',0);

longueurFichier = length(A{1});
fclose(fid);

% null values in timestamp : stripping
%           nullValuesIndices = find(A{1} == 0);
%           A{1}(nullValuesIndices) = [];
%           A{2}(nullValuesIndices) = [];
%           A{3}(nullValuesIndices) = [];

timeNoOffset = A{1} - A{1}(1);
A{4} = timeNoOffset; % time in ms since beginning of recording

topSynchroStart = find(A{9}>0.02,1,'first');
topSynchroEnd = find(A{9}>0.02,1,'last');

timeStampStart = A{1}(topSynchroStart);
timeStampEnd = A{1}(topSynchroEnd);

% tempsClapDebut = tempsClapDebut * 1000; % time in ms
% tempsClapFin = tempsClapFin * 1000; % time in ms

offsetDebut = tempsClapDebut - timeStampStart;

% on recalcule tous les times code pour que le timecode video
% coincide aux time code dans les données
timecode = A{1} + offsetDebut;

%Dans ce nouveau time code, on cherche ou arrive le moment du
%clap de fin
timecodeFin = timecode(topSynchroEnd);

%glissement = timecodeFin / timeStampEnd;
% On regarde s'il y a eu de la dérive en comparant le timecode
% dans les données, au temps du clap de fin
glissement = timecodeFin / tempsClapFin;

%nouvelle colonne qui exprime le nouveau temps de reference
A{199} = timecode / glissement;

%on convertit les données de vitesse en km/h
A{198}=A{166}*3.6;

offsetOrigine = A{199}(1);

% on enlevera a toutes les données le timestamp de base décalé
% des quelques secondes entre le moment ou les données démarrent
% et la vidéo démarre
offsetVideo = A{1}(1) - offsetOrigine;

noVideo = false;

if (noVideo)
    disp('Pas de donnees de synchro video dans les fichiers de sauvegarde');
    disp('rajouter un fichier dans config.ini avec nom de base Synchrovideo_');
    disp('et enregistrer 1 colonne : TopCons');
end

infoUtilisateur = [ 'Processing data. Please wait, this may take a while!'];
disp(infoUtilisateur);

  
for data={'Temps' 'Synchro' 'ActionsConducteur' 'PhysiqueCamion' 'PositionCamionAbsolue' 'DonneesCamionRoute' 'InfoRoute'}
    
    % creation des metadatas
    dataToImport = char(data);
    infoUtilisateur = [ 'Processing data : ' dataToImport];
    disp(infoUtilisateur);
    maData = fr.lescot.bind.data.MetaData();
    maData.setName(dataToImport);
    maData.setFrequency('30');
    
    %creation des metaVariables
    listeVariables = {};
    switch dataToImport
        case 'Temps'
            listeVariables = {'timestamp' 'hour' 'minutes' 'seconds'};
            numeroColonneFichierTxt = {1 2 3 4};
        case 'Synchro'
            listeVariables = {'synchro' };
            numeroColonneFichierTxt = {9};
        case 'ActionsConducteur'
            listeVariables = {'accelerator' 'brake' 'steering' };
            numeroColonneFichierTxt = {10 11 12};
        case  'PhysiqueCamion'
            listeVariables = {'ModelOutput-cab_dd_xyzhpr.1.[00]'
                'ModelOutput-cab_dd_xyzhpr.2.[00]'
                'ModelOutput-cab_dd_xyzhpr.3.[00]'
                'ModelOutput-cab_dd_xyzhpr.4.[00]'
                'ModelOutput-cab_dd_xyzhpr.5.[00]'
                'ModelOutput-cab_dd_xyzhpr.6.[00]'
                'ModelOutput-vhlSpeed.1.[00]'
                'ModelOutput-vhlSpeed.2.[00]'
                'ModelOutput-vhlSpeed.3.[00]'
                'ModelOutput-vhlSpeed.4.[00]'
                'ModelOutput-vhlSpeed.5.[00]'
                'ModelOutput-vhlSpeed.6.[00]'
                };
            numeroColonneFichierTxt = {13 14 15 16 17 18 19 20 21 22 23 24};
        case 'PositionCamionAbsolue'
            listeVariables = {'heading' 'pitch' 'roll' 'X' 'Y' 'Z'};
            numeroColonneFichierTxt = {25 41 57 73 89 105};
        case 'DonneesCamionRoute'
            listeVariables = {'laneGap' 'roadGap' 'wheelAngle' 'speed(km/h)'};
            numeroColonneFichierTxt = {121 136 182 198};
        case'InfoRoute'
            listeVariables = {'roadID'};
            numeroColonneFichierTxt = {151};
    end
    
    variables = cell(1,length(listeVariables));
    for i=1:length(listeVariables)
        uneVariable = fr.lescot.bind.data.MetaDataVariable();
        uneVariable.setName(listeVariables{i});
        variables{1,i} = uneVariable;
    end
    maData.setVariables(variables);
    maData.setComments(['generated ' date]);
    newTrip.addData(maData);
    
    % a cette étapes, les métas data sont prêtes, le trip peut recevoir
    % des données
    parameterNumber = length(listeVariables);
    infoUtilisateur = 'Processing Variables : ';
    disp(infoUtilisateur);
    for i=1:parameterNumber
        infoUtilisateur = [char(listeVariables{i}) '... '];
        disp(infoUtilisateur);
        numeroColonneAImporter = numeroColonneFichierTxt{i};
        timeValueCellArray = [num2cell(A{199}) num2cell(A{numeroColonneAImporter})]';
        newTrip.setBatchOfTimeDataVariablePairs(dataToImport,char(listeVariables{i}),timeValueCellArray);
    end
    newTrip.setIsBaseData(dataToImport,true);
end
delete(newTrip);

end

