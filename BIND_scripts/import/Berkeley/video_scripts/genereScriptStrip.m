function genereScriptStrip( videoList , indiceVideo )
%videoList = listing de sortie de la methode videoList
%scriptFileName = chemin de sortie du script
%indiceVideo = indice du fichier videoList à utiliser (1: front, 2: quadra)
fichierVideo = videoList{indiceVideo};
numFrameCible = 3596.4;
[pathToBlankFrames, ~, ~] = fileparts(which('genereScriptAppend'));
pathToBlankFrame1 = [pathToBlankFrames '\1blankFrame.avi'];
pathToBlankFrame10 = [pathToBlankFrames '\10blankFrame.avi'];
pathToBlankFrame100 = [pathToBlankFrames '\100blankFrame.avi'];
pathToBlankFrame1 = strrep(pathToBlankFrame1, '\', '\\');
pathToBlankFrame10 = strrep(pathToBlankFrame10, '\', '\\');
pathToBlankFrame100 = strrep(pathToBlankFrame100, '\', '\\');
for i=1:1:length(fichierVideo)
    nomFichierVideo = fichierVideo{i,1};
    % fichier en input
    nomFichierVideoIn = strrep(nomFichierVideo, '\', '\\');
    %fichier en output
    [pathstr, ~, ~] = fileparts(nomFichierVideo);
    nomFichierVideoOut = fullfile(pathstr,['part_' num2str(indiceVideo) '_' num2str(i-1) '.avi']);
    nomFichierVideoOut = strrep(nomFichierVideoOut, '\', '\\');
    nomFichierVideoIntermediaire = fullfile(pathstr,['part_' num2str(indiceVideo) '_' num2str(i-1) '_raw.avi']);
    nomFichierVideoIntermediaire = strrep(nomFichierVideoIntermediaire, '\', '\\');    
    numFrame = fichierVideo{i,2};
    fps = fichierVideo{i,3};
   
    if ~isempty(nomFichierVideo)
        scriptFileName = [nomFichierVideo '.syl'];
        fid = fopen(scriptFileName, 'wt');
        expression =[ '// film ' num2str(i-1)];
        fprintf(fid,'%s\n',expression);

        % si il y a un fichier, il y a 2 cas
        if numFrame > numFrameCible
            % le fichier video a trop de frame, il faut enlever un offset au
            % debut
            expression = ['VirtualDub.Open("' nomFichierVideoIn '");'];
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetSource(1);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetMode(0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetInterleave(1,500,1,0,0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetClipMode(1,1);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetConversion(0,0,0,0,0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetVolume();';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetCompression();';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.EnableFilterGraph(0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetInputFormat(0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetOutputFormat(7);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetMode(3);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetSmartRendering(0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetPreserveEmptyFrames(0);';
            fprintf(fid,'%s\n',expression);            
%            expression = 'VirtualDub.video.SetFrameRate2(0,0,1);';
%            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetIVTC(0, 0, 0, 0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetCompression();';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.filters.Clear();';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.filters.Clear();';
            fprintf(fid,'%s\n',expression);            
            expression = ['VirtualDub.SaveAVI("' nomFichierVideoIntermediaire '");'];
            fprintf(fid,'%s\n',expression);
            expression = 'VirtualDub.Close();';            
            fprintf(fid,'%s\n',expression);

            offset = numFrame-numFrameCible;
            offset = (offset/fps)*1000;
            offset = round(offset);         
            
            expression = ['VirtualDub.Open("' nomFichierVideoIntermediaire '");'];           
            fprintf(fid,'%s\n',expression);
            expression = ['VirtualDub.video.SetRange(' num2str(offset) ',0);'];
            fprintf(fid,'%s\n',expression);
            expression = ['VirtualDub.video.SetCompression(0x78766964,0,10000,0);'];
            fprintf(fid,'%s\n',expression);
            expression = ['VirtualDub.video.SetCompData(141,"LWJ2MSAzODYwMDAgLXZidiA0ODU0MDAwLDMxNDU3MjgsMjM1OTI5NiAtZGlyICJDOlxEb2N1bWVudHMgYW5kIFNldHRpbmdzXGJvbm5hcmRcQXBwbGljYXRpb24gRGF0YVxEaXZYXERpdlggQ29kZWMiIC1iIDEgLXByb2ZpbGU9MyAtcHJlc2V0PTUA");'];
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetMode(3);';
            fprintf(fid,'%s\n',expression);
            expression = ['VirtualDub.SaveAVI("' nomFichierVideoOut '");'];
            fprintf(fid,'%s\n',expression);
            expression = 'VirtualDub.Close();';
            fprintf(fid,'%s\n\n',expression); 
            
        else
            expression = ['VirtualDub.Open("' nomFichierVideoIn '");'];
            fprintf(fid,'%s\n',expression);           
            expression = 'VirtualDub.audio.SetSource(1);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetMode(0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetInterleave(1,500,1,0,0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetClipMode(1,1);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetConversion(0,0,0,0,0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetVolume();';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.SetCompression();';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.EnableFilterGraph(0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetInputFormat(0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetOutputFormat(7);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetMode(3);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetSmartRendering(0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetPreserveEmptyFrames(0);';
            fprintf(fid,'%s\n',expression);            
            %expression = 'VirtualDub.video.SetFrameRate2(0,0,1);';
%            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetIVTC(0, 0, 0, 0);';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.SetCompression();';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.video.filters.Clear();';
            fprintf(fid,'%s\n',expression);            
            expression = 'VirtualDub.audio.filters.Clear();';
            fprintf(fid,'%s\n',expression);            
            expression = ['VirtualDub.SaveAVI("' nomFichierVideoIntermediaire '");'];
            fprintf(fid,'%s\n',expression);
            expression = 'VirtualDub.Close();';            
            fprintf(fid,'%s\n',expression);    

            
            % le fichier video n'a pas suffisament de frames, il faut en
            % rajouter au debut
            frameToAdd = numFrameCible-numFrame;
            frameToAdd = round(frameToAdd);
            
            expression = ['VirtualDub.Open("' pathToBlankFrame1 '");'];
            fprintf(fid,'%s\n',expression);        
            
            frameToAdd = frameToAdd - 1;
            
            
            reste = mod(frameToAdd,100);
            centaine = frameToAdd - reste;
            nbCentaine = centaine / 100;
            
            for j=1:1:nbCentaine
                expression = ['VirtualDub.Append("' pathToBlankFrame100 '");'];
                fprintf(fid,'%s\n',expression);                    
            end
            
            reste2 = mod(reste,10);
            dizaine = reste - reste2;
            nbDizaine = dizaine / 10;

            for j=1:1:nbDizaine
                expression = ['VirtualDub.Append("' pathToBlankFrame10 '");'];
                fprintf(fid,'%s\n',expression);                    
            end
            
            for j=1:1:reste2
                expression = ['VirtualDub.Append("' pathToBlankFrame1 '");'];
                fprintf(fid,'%s\n',expression);                    
            end

            expression = ['VirtualDub.Append("' nomFichierVideoIntermediaire '");'];           
            fprintf(fid,'%s\n',expression);            
            expression = ['VirtualDub.video.SetCompression(0x78766964,0,10000,0);'];
            fprintf(fid,'%s\n',expression);
            expression = ['VirtualDub.video.SetCompData(141,"LWJ2MSAzODYwMDAgLXZidiA0ODU0MDAwLDMxNDU3MjgsMjM1OTI5NiAtZGlyICJDOlxEb2N1bWVudHMgYW5kIFNldHRpbmdzXGJvbm5hcmRcQXBwbGljYXRpb24gRGF0YVxEaXZYXERpdlggQ29kZWMiIC1iIDEgLXByb2ZpbGU9MyAtcHJlc2V0PTUA");'];
            fprintf(fid,'%s\n',expression);             
            expression = 'VirtualDub.video.SetMode(3);';
            fprintf(fid,'%s\n',expression);
            expression = ['VirtualDub.SaveAVI("' nomFichierVideoOut '");'];
            fprintf(fid,'%s\n',expression);
            expression = 'VirtualDub.Close();';
            fprintf(fid,'%s\n\n',expression);        
        end
    fclose(fid); 
    end
end % fin du for