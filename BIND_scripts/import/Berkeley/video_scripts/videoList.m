function [ out errors ] = videoList( tripPath, logFileDir )
% tripPath - chemin du répertoire qui contient le trip
% return
% logFileDir - path of the directory where to write a log file.
% out - cell array of front video and quadra videos array.
% each array is 'path to video', 'numframe', 'fps'. As many cell as
% subdirectory in the trip.
% errors - the number of VideoReader:initializationError exceptions that
% were triggered during the conversion.
    errors = 0;
    cd(tripPath)
    ls = dir();
    % Keep only the directories
    ls = ls(cell2mat({ls(:).isdir}));
%    listing = cell(1,2);
    fichiersVideoFront = cell(length(ls)-2,3);
    listing = {fichiersVideoFront fichiersVideoFront};
    index = 1;
    for i=3:1:length(ls)
        repertoire = ls(i).name;
        cd(repertoire);
        chemin = pwd;
        dirFichiersVideos = {
            dir('*f*.avi'),...  % front
            dir('*q*.avi')...   % quadra
            };
        
        % On traite les fichiers videos (front puis quadra
        for indexFichier=1:2
            dirFichierVideo = dirFichiersVideos{indexFichier};
            if isempty(dirFichierVideo)
                % pas de fichier video front
                listing{indexFichier}{index,1} = '';
                listing{indexFichier}{index,2} = 0;
                listing{indexFichier}{index,3} = 0;            
            else
                fichierVideo = fullfile(chemin,dirFichierVideo(1).name);
                try
                    vr = VideoReader(fichierVideo);
                    infos = get(vr);
                    fps = infos.FrameRate;
                    numFrames = infos.NumberOfFrames;
         %           close(vr);

                    listing{indexFichier}{index,1} = fichierVideo;
                    listing{indexFichier}{index,2} = numFrames;
                    listing{indexFichier}{index,3} = fps;
        %            listing{1}{index,3} = 29.97; %fps;
                catch ME
                    % log the error
                    logFileName = fullfile(logFileDir,['log_video_conversion_' date '.txt']);
                    logFile = fopen(logFileName, 'a');
                    fprintf(logFile, 'Matlab exception: %s\n', ME.identifier);
                    fprintf(logFile, 'occurred with file: %s\n\n', fichierVideo);
                    fclose(logFile);
                    if strcmp(ME.identifier,'MATLAB:VideoReader:initializationError')
                        errors = errors+1;
                        disp('');
                        message = sprintf('Problem with the file: %s...',fichierVideo);
                        disp(message);
                        disp('Warning: the video file could not be read by the VideoReader.');
                        disp('It will be replaced by an empty sequence. Check that this video file');
                        disp('is not corrupted, or that you installed the codecs to read it.');
                        % behave as if there was no video file
                        listing{indexFichier}{index,1} = '';
                        listing{indexFichier}{index,2} = 0;
                        listing{indexFichier}{index,3} = 0; 
                    else
                        rethrow(ME);
                    end
                end
            end
        end
        
        index = index + 1;
        cd('..');
    end
    cd('..');
    out = listing;    
    
end
