function [errors] = berkeleyVideoConversion( tripPath , outDir , videoBaseName)
%tripPath = chemin du trip
%outDir = repertoire de sauvegarde des scripts et des videos
pathToVirtualDub = 'C:\vdub\vdub.exe';
tic;
disp('Start rebuilding videos...');
disp(['Generating video list for Trip in path: ' tripPath]);
[listing errors] = videoList(tripPath, outDir);
disp('Videos list generated.');
disp('Generating scripts for video stripping: ');

for indiceVideo=1:2
    commandes = {};
    if indiceVideo==1
        movieID = [videoBaseName '-front'];
    else
        movieID = [videoBaseName '-quadra'];
    end
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    disp(['Generating video: ' movieID]);
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    genereScriptStrip(listing,indiceVideo);
    fichierVideo = listing{indiceVideo};
    % la fonction genere un fichier scriptStrip2Minutes.syl
    % lancer virtual dub pour generer toutes les parties a concatener
    for i=1:1:length(fichierVideo)
        nomFichierVideo = fichierVideo{i,1};
        if ~isempty(nomFichierVideo)
            scriptFile = [nomFichierVideo '.syl'];
            expression = ['!"' pathToVirtualDub '" /s "' scriptFile '"'];
        else
            expression = '';
        end
        commandes = {commandes{:} expression};
    end

    a = commandes;
    disp('Stripping script generated.');

    disp('Generating appending script...');
    scriptFile = fullfile(outDir,[movieID '-scriptAppendParts.syl']);
    %[pathstr, name, ext, versn] = fileparts(tripPath);
    videoFile = fullfile(outDir,[movieID '.avi']);
    genereScriptAppend(listing,videoFile,scriptFile,indiceVideo);
    %la fonction genere un fichier scriptAppendParts.syl
    expression = ['!"' pathToVirtualDub '" /s "' scriptFile '"'];
    disp('Appending script generated');
    % lancer virtual dub pour concatener toutes les parties.
    b = expression;

    disp('Running virtual dub scripts...');
    % on run toutes les commandes
    for i=1:1:length(commandes)
        disp(['Processing movie : ' num2str(i-1) '/' num2str(length(commandes)) ]);
        % on invoque le programme externe
        eval(a{i});
        % on verifie que rien ne traine
        nomFichierVideo = fichierVideo{i,1};
        [pathstr, ~, ~] = fileparts(nomFichierVideo);
        nomFichierVideoIntermediaire = fullfile(pathstr,['part_' num2str(indiceVideo) '_' num2str(i-1) '_raw.avi']);

        if exist(nomFichierVideoIntermediaire,'file')
            % comme certain scripts generent des fichiers temporaires, il ne
            % faut pas oublier de les supprimer.
            delete(nomFichierVideoIntermediaire);
        end
    end

    disp('Appending all video parts...');
    % on concatene toutes les videos part_xx.avi
    eval(b);

    % comme certain scripts generent des fichiers temporaires, il ne
    % faut pas oublier de les supprimer.
    disp('Cleaning');
    % on efface les parties part_xx.avi et les .syl
    for i=1:1:length(fichierVideo)
        nomFichierVideo = fichierVideo{i,1};
        [pathstr, ~, ~] = fileparts(nomFichierVideo);
        % video
        nomFichierVideoIntermediaire = fullfile(pathstr,['part_' num2str(indiceVideo) '_' num2str(i-1) '.avi']);
        if exist(nomFichierVideoIntermediaire,'file');
            delete(nomFichierVideoIntermediaire);
        end
        % .syl dans le trip
        nomFichierSylIntermediaire = [nomFichierVideo '.syl'];
        if exist(nomFichierSylIntermediaire,'file');
            delete(nomFichierSylIntermediaire);
        end
    end
    % .syl du script append
    nomFichierSylFinal = fullfile(outDir,[movieID '-scriptAppendParts.syl']);
    if exist(nomFichierSylFinal,'file');
        delete(nomFichierSylFinal);
    end
    
    disp(['Video file "' movieID '.avi" generated!']);
end
conversionTime = num2str(toc/60);
disp(['Movies rebuilt in ' conversionTime 'm']);
end