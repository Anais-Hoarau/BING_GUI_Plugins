function [ output_args ] = genereScriptAppend(videoList,fichierVideoOut,scriptFileName,indiceVideo)
%videoList = listing de sortie de la methode videoList
%fichierVideoOut = chemin du fichier video en sortie
%scriptFileName = chemin du script de sortie
%indiceVideo = indice du fichier videoList à utiliser (1: front, 2: quadra)
fid = fopen(scriptFileName, 'wt');
%expression = 'Sylia.MessageBox("Vous etes sur le point de la concatenation!","debut du script");';
%fprintf(fid,'%s\n',expression);
fichierVideo = videoList{indiceVideo};
[pathToBlankSequence, ~, ~] = fileparts(which('genereScriptAppend'));
pathToBlankSequence = [pathToBlankSequence '\blankSequence.avi'];
pathToBlankSequence = strrep(pathToBlankSequence, '\', '\\');
for i=1:1:length(fichierVideo)
    expression =[ '// film ' num2str(i-1)];
    fprintf(fid,'%s\n',expression);
    nomFichierVideo = fichierVideo{i,1};
    [pathstr, ~, ~] = fileparts(nomFichierVideo);
    nomFichierVideoIn = fullfile(pathstr,['part_' num2str(indiceVideo) '_' num2str(i-1) '.avi']);
    nomFichierVideoIn = strrep(nomFichierVideoIn, '\', '\\');
    if i == 1
        % on OPEN le premier
        if ~isempty(nomFichierVideo)            
            expression = ['VirtualDub.Open("' nomFichierVideoIn '");'];
            fprintf(fid,'%s\n',expression);
        else
            expression = ['VirtualDub.Open("' pathToBlankSequence '");'];
            fprintf(fid,'%s\n',expression);
        end
    else
        % on APPEND les autres
        if ~isempty(nomFichierVideo)                    
        expression = ['VirtualDub.Append("' nomFichierVideoIn '");'];
        fprintf(fid,'%s\n',expression);        
        else
            expression = ['VirtualDub.Append("' pathToBlankSequence '");'];
            fprintf(fid,'%s\n',expression);
        
        end
        
    end
end

expression = 'VirtualDub.video.SetMode(0);';
fprintf(fid,'%s\n',expression);
fichierVideoOut = strrep(fichierVideoOut, '\', '\\');
expression = ['VirtualDub.SaveAVI("' fichierVideoOut '");'];
fprintf(fid,'%s\n',expression);
expression = 'VirtualDub.Close();';
fprintf(fid,'%s\n\n',expression);        
fclose(fid);
end


