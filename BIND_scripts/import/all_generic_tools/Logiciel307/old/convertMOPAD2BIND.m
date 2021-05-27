%{
Function:
This function converts MOPAD files to BIND according to the configuration given in the MOPAD config.ini file.

Parameters:
fullDirectory - location of the folder containing MOPAD files (config.ini + associated .txt files
targetTripFileName - complete path of target output file. Should be with .trip extension
importMode - a string that MUST be 'single' or 'batch'. Useful to allow
questdlg and interaction with the user or not. In batch mode, if a video
file or a clap file is missing, the script will stop.

%}

function convertMOPAD2BIND(fullDirectory,targetTripFileName,importMode)

if ~strcmp(importMode,'single') && ~strcmp(importMode,'batch')
    disp('variable importMode must be set to ''single'' or ''batch''');
    disp('If single is defined, the script is interactive');
    return;
end

if strcmp(importMode,'single')
    answer = questdlg('Voulez vous transferer les données MOPAD vers un fichier .trip BIND ou visualiser les données ?','sauvegarde ?','transferer','visualiser','visualiser');
    if strcmp(answer,'visualiser')
        scriptMode = 'view';
    else
        scriptMode = 'record';
    end
else
    % in batch mode, default behaviour is to record
    scriptMode = 'record';
end


[pathstr, name, ext] =  fileparts(fullDirectory);

s2 = regexp(name, '_', 'split');
nomSujet = s2{1};
dateSujet = s2{2};

pattern = '*.ini';
iniFile =  fullfile(fullDirectory, pattern);
listing = dir(iniFile);
% find the correct directory and file
iniFile = ...
    fullfile(fullDirectory, listing.name);

fileID = fopen(iniFile);

compteur = 1;
infos = {};
nomManip = '';
frequenceData = 0;
tempsClapDebut = 0;
tempsClapFin = 0;

infoUtilisateur = [ 'Processing metadata'];
disp(infoUtilisateur);

% parse config file, line by line.
while ~feof(fileID)
    tline = fgetl(fileID);
    if ~isempty(tline)
        
        % determination des spécificités du TRAJET
        expr = '[^\n]*INFO_ESSAI[^\n]*';
        infoTrip= regexp(tline, expr, 'match');
        if ~isempty(infoTrip)
            % on a trouvé un bloc de description du TRIP
            tline = fgetl(fileID);
            A = sscanf(tline, 'NomEssai=%s');
            nomManip = A;
        end
        
        % determination des spécificités de l'acquisition
        expr = '[^\n]*DAQ_0[^\n]*';
        infoAcqui= regexp(tline, expr, 'match');
        if ~isempty(infoAcqui)
            % on a trouvé un bloc de description de l'acquisition
            tline = fgetl(fileID); % status
            tline = fgetl(fileID); % nom fonction
            tline = fgetl(fileID); % parametre
            tline = fgetl(fileID); % nom carte
            tline = fgetl(fileID); % Frequence
            A = sscanf(tline, 'FrequenceBaseOuDecimation=%s');
            frequenceData = A;
        end
        
        % determination des DATAS et VARIABLES a importer
        expr = '[^\n]*SAUVEGARDE_[^\n]*';
        infoSauvegardes = regexp(tline, expr, 'match');
        if ~isempty(infoSauvegardes)
            % on a trouvé un bloc de sauvegarde
            tline = fgetl(fileID);
            A = sscanf(tline, 'Actif=%s');
            if strcmp(A,'oui')
                % on a une sauvegarde active
                tline = fgetl(fileID); %nomFonction
                tline = fgetl(fileID); % Parametre
                tline = fgetl(fileID); % sousEch
                tline = fgetl(fileID); % NOM DU FICHIER
                saveFile = sscanf(tline, 'NomDeBaseFichier=%s');
                tline = fgetl(fileID); % Parametres dans le fichier
                variables = sscanf(tline, 'NomDataEntree=%s');
                tline = fgetl(fileID); % nombre entree
                nombreVariables  = sscanf(tline, 'NombreDataEntree=%d');
                % info is a buffer struct : a triplet 'name of mopad output
                % file; list of all MOPAD variable separated by ','; number
                % of variables
                info = {saveFile,variables,nombreVariables};
                % store in general structure 'infos'
                infos{compteur} = info;
                compteur = compteur + 1;
            end
        end
    end
end
fclose(fileID);
% A la sortie de cette boucle, info est un cell array de descripteur de fichier de sauvegarde!!


%on prépare le trip de destination

if strcmp(scriptMode,'record')
    newTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(targetTripFileName,0.04,true);
    newTrip.setAttribute('nom',nomManip);
    newTrip.setAttribute('numSujet',nomSujet);
    newTrip.setAttribute('date',dateSujet);
end

% initialisation of videoAvaiable variable
videoAvailable = true;

offset = 0;
pattern = fullfile(fullDirectory, '*.avi');
% find the correct video file
listingVideo = dir(pattern);

if (~isempty(listingVideo))
    % si on a une vidéo, il faut un fichier de CLAP pour la synchro
    patternClap = fullfile(fullDirectory, 'clap.txt');
    listingClap = dir(patternClap);
    if (~isempty(listingClap))
        % on lit le fichier de clap
        fid = fopen(patternClap);
        Claps = textscan(fid,'%s');
        fclose(fid);
        % read clap file : clap file MUST HAVE 3 lines... timecode du clap de début /
        % timecode du clap de fin / timecode de la premiere image
        if (~isempty(Claps{1}{3}))
            stringToFormat = Claps{1}{3};
            % SORTIR CETTE METHODE DANS UNE CLASSE UTILS
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
        
        filename = (['.\' listingVideo.name]);
        description = 'quadravision';
        laVideo = fr.lescot.bind.data.MetaVideoFile(filename, offset, description);
        if strcmp(scriptMode,'record')
            newTrip.addVideoFile(laVideo);
        end
    else
        % on a pas de clap... on ne peut pas synchroniser la video
        disp('PAS DE FICHIER CLAP CLAP CLAP');
        disp('Fichier clap.txt nécessaire. Format :');
        disp('1er ligne : temps apparition diode debut format 00:00:00:image');
        disp('2eme ligne : temps apparition diode fin format 00:00:00:image');
        disp('3eme ligne : time code de la premiere image video format 00:00:00:image');
        if strcmp(importMode,'single')
            answer = questdlg('Le fichier CLAP.TXT n''a pas été trouvé : la synchro avec la vidéo ne sera pas possible. voulez vous continuer?','Pas de fichier CLAP','oui','non','non');
            if strcmp(answer,'non')
                return;
            else
                videoAvailable = false;
            end
        else
            % in batch mode, default behaviour is to stop and go to next file.
            videoAvailable = false;
            return;
        end
    end
else
    % on a pas de clap... on ne peut pas synchroniser la video
    disp('PAS DE FICHIER VIDEO AVI !!!');
    disp('Fichier avi nécessaire. ');
    if strcmp(importMode,'single')
        answer = questdlg('Le fichier video *.AVI n''a pas été trouvé. voulez vous continuer?','Pas de fichier AVI','oui','non','non');
        if strcmp(answer,'non')
            return;
        else
            videoAvailable = false;
        end
    else
        % in batch mode, default behaviour is to stop and go to next file.
        videoAvailable = false;
        return;
    end
end

if  videoAvailable
    % boucle pour calculer les offset et glissement pour synchro des données
    % il faut utiliser les infos dans le fichier clap.txt et dans le fichier de
    % sauvegarde par l'appli 307, data : synchroVideo, variable topcons
    offsetVideo = 0;
    glissement = 1;
    
    synchroVideoDataAvailable = false;
    for x=1:length(infos)
        nomData = strrep(char(infos{x}{1}), '_', '');
        % look for DATA called synchrovideo
        if strcmp('Synchrovideo',nomData)
            synchroVideoDataAvailable = true;
            pattern = ['*' infos{x}{1} '*.txt'];
            saveFile = ...
                fullfile(fullDirectory, pattern);
            listing = dir(saveFile);
            if ~isempty(listing)
                saveFile = fullfile(fullDirectory, listing.name);
                fid = fopen(saveFile);
                
                pattern = '%f %f '; %toujours deux colonnes au debut
                N = infos{x}{3};
                for i=1:N
                    pattern = [pattern '%f '];
                end
                A = textscan(fid, pattern);
                fclose(fid);
                % a cette étape, dans A, on a un cell array avec toutes les valeurs
                % du fichier de synchroVideo
                
                % null values in timestamp : stripping
                nullValuesIndices = find(A{1} == 0);
                A{1}(nullValuesIndices) = [];
                A{2}(nullValuesIndices) = [];
                A{3}(nullValuesIndices) = [];
                
                timeNoOffset = A{1} - A{1}(1);
                A{4} = timeNoOffset; % time in ms since beginning of recording
                
                topSynchroStart = find(A{3}>0.02,1,'first');
                topSynchroEnd = find(A{3}>0.02,1,'last');
                
                timeStampStart = A{4}(topSynchroStart);
                timeStampEnd = A{4}(topSynchroEnd);
                
                tempsClapDebut = tempsClapDebut * 1000; % time in ms
                tempsClapFin = tempsClapFin * 1000; % time in ms
                
                offsetDebut = tempsClapDebut - timeStampStart;
                
                % on recalcule tous les times code pour que le timecode video
                % coincide aux time code dans les données
                timecode = A{4} + offsetDebut;
                
                %Dans ce nouveau time code, on cherche ou arrive le moment du
                %clap de fin
                timecodeFin = timecode(topSynchroEnd);
                
                %glissement = timecodeFin / timeStampEnd;
                % On regarde s'il y a eu de la dérive en comparant le timecode
                % dans les données, au temps du clap de fin
                glissement = timecodeFin / tempsClapFin;
                
                A{4} = timecode / glissement;
                
                offsetOrigine = A{4}(1);
                
                % on enlevera a toutes les données le timestamp de base décalé
                % des quelques secondes entre le moment ou les données démarrent
                % et la vidéo démarre
                offsetVideo = A{1}(1) - offsetOrigine;
                
            end
        end
    end
    if ~synchroVideoDataAvailable
        disp('Pas de donnees de synchro video dans les fichiers de sauvegarde');
        disp('rajouter un fichier dans config.ini avec nom de base Synchrovideo_');
        disp('avec la 3 colonne qui enregistre la valeur du capteur de synchro');
    end
else
    % get first data file from MOPAD
    x = 1;
    pattern = ['*' infos{x}{1} '*.txt'];
    saveFile = fullfile(fullDirectory, pattern);
    listing = dir(saveFile);
    if ~isempty(listing)
        saveFile = fullfile(fullDirectory, listing.name);
        fid = fopen(saveFile);
        
        pattern = '%f %f '; %toujours deux colonnes au debut
        % infos{x}{3} : nombre de variable in MOPAD
        N = infos{x}{3};
        for i=1:N
            pattern = [pattern '%f '];
        end
        A = textscan(fid, pattern);
        fclose(fid);
        % a cette étape, dans A, on a un cell array avec toutes les valeurs
        % du premier fichier de sauvegardé déclaré dans MOPAD
        
        % null values in timestamp : stripping
        nullValuesIndices = find(A{1} == 0);
        A{1}(nullValuesIndices) = [];
        offsetVideo = A{1}(1);
        glissement = 1;
    end
end

% At this stage, the synchro has been resolved and data are ready to be
% manipulated

infoUtilisateur = [ 'Processing data. Please wait, this may take a while!'];
disp(infoUtilisateur);

% pour chaque fichier de sauvegarde = chaque data
for x=1:length(infos)
    nomData = strrep(infos{x}{1}, '_', '');
    N = infos{x}{3};
    infoUtilisateur = [ 'Processing data : ' nomData];
    disp(infoUtilisateur);
    % prepare BIND meta data using information from MOPAD config.ini
    maData = fr.lescot.bind.data.MetaData();
    maData.setName(nomData);
    maData.setFrequency(frequenceData);
    lesVariables = infos{x}{2};
    lesVariables  = strrep(lesVariables , ',', ' ');
    pattern = '';
    for i=1:N
        if i == N
            pattern = [pattern '%s'];
        else
            pattern = [pattern '%s '];
        end
    end
    listeVariables =  textscan(lesVariables,pattern);
    listeVariables = {'timecode' 'timestamp' 'pulse' listeVariables{:}};
    variables = cell(1,length(listeVariables));
    for i=1:length(listeVariables)
        
        uneVariable = fr.lescot.bind.data.MetaDataVariable();
        uneVariable.setName(listeVariables{i});
        variables{1,i} = uneVariable;
    end
    maData.setVariables(variables);
    maData.setComments(['generated ' date]);
    if strcmp(scriptMode,'record')
        % record meta data in the trip file
        newTrip.addData(maData);
    end
    
    % a cette étapes, les métas data sont prêtes, le trip peut recevoir
    % des données
    pattern = ['*' infos{x}{1} '*.txt'];
    
    saveFile = ...
        fullfile(fullDirectory, pattern);
    listing = dir(saveFile);
    if ~isempty(listing)
        saveFile = fullfile(fullDirectory, listing.name);
        fid = fopen(saveFile);
        
        pattern = '%f %f '; %toujours deux colonnes au debut
        N = infos{x}{3};
        for i=1:N
            pattern = [pattern '%f '];
        end
        A = textscan(fid, pattern);
        fclose(fid);
        % a cette étape, dans A, on a un cell array avec toutes les valeurs
        % du fichier
        
        parameterNumber = length(A);
        
        % null values in timestamp : stripping
        nullValuesIndices = find(A{1} == 0);
        for i=1:parameterNumber
            A{i}(nullValuesIndices) = [];
        end
        
        % in MOPAD data are recorder in ms.
        timecodes = A{1} - offsetVideo;
        timecodes = timecodes / glissement;
        timecodes = timecodes / 1000;
        
        indicesOutOfVideo = find(timecodes<0);
        timecodes(indicesOutOfVideo) = [];
        for i=1:parameterNumber
            A{i}(indicesOutOfVideo) = [];
        end
        
        dataLength = length(timecodes);
        
        infoUtilisateur = 'Processing Variables (in 0.5 second!) : ';
        disp(infoUtilisateur);
        for i=2:parameterNumber+1
            
            % stop execution for UI refreshment
            pause(0.5)
            
            infoUtilisateur = [char(listeVariables{i}) '... '];
            disp(infoUtilisateur);
            % for debug purpose
            %timeValueCellArray = [num2cell(timecodes(1:100)) num2cell(A{i-1}(1:100))]';
            timeValueCellArray = [num2cell(timecodes) num2cell(A{i-1})]';
            if strcmp(scriptMode,'record')
                
                numberOfLineToAdd = 10000;
                nbSets = floor(length(timeValueCellArray) / numberOfLineToAdd);
                for j=0:(nbSets-1)
                    message = ['Inserting ' char(listeVariables{i}) ' : ' num2str(j*numberOfLineToAdd) ' lines / ' num2str(length(timeValueCellArray)) ' lines'];
                    disp(message);
                    partialTimeValueCellArray = timeValueCellArray(:,(j*numberOfLineToAdd + 1 : (j+1)* numberOfLineToAdd));
                    newTrip.setBatchOfTimeDataVariablePairs(nomData,char(listeVariables{i}),partialTimeValueCellArray);
                end
                lastPartialTimeValueCellArray = timeValueCellArray(:,(nbSets*numberOfLineToAdd + 1 : length(timeValueCellArray)));
                newTrip.setBatchOfTimeDataVariablePairs(nomData,char(listeVariables{i}),lastPartialTimeValueCellArray);
                
                % save data to trip
              %  newTrip.setBatchOfTimeDataVariablePairs(nomData,char(listeVariables{i}),timeValueCellArray);
            else
                % in view mode, display figure
                h = figure('NumberTitle','off','Position',[20 20 1024 768],'Visible','off');
                displayCurves(h,timecodes,A{i-1},[nomData '.' char(listeVariables{i})],['Variables of ' saveFile]);
                movegui(h,'center');
                set(h,'Visible','on');
                waitfor(h);
            end
        end
        if strcmp(scriptMode,'record')
            % set data to be READ ONLY
            newTrip.setIsBaseData(nomData,true);
        end
    end
end

if strcmp(scriptMode,'record')
    delete(newTrip);
end

end

