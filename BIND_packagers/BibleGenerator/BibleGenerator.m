%{
For the documentation of this script is located at https://redmine.inrets.fr/projects/bindpackagers/wiki
%}
classdef BibleGenerator

    properties
    end
    
    methods(Static)
        
        function generateBible()
            currentDir = pwd;
            pathToSrc = uigetdir(currentDir, 'Racine du code source de BIND');  
            [filename, pathname, ~] = uiputfile('*.tex','Fichier tex à générer', 'bible.tex');
            destPath = [pathname filesep filename];
            cd(pathToSrc);
            mFiles = BibleGenerator.findAllMFiles('.');
            cd(currentDir);
            texFile = fopen(destPath, 'w+');
            fprintf(texFile, '\\documentclass[a4paper]{article}\n');
            fprintf(texFile, '\\usepackage[T1]{fontenc}\n');
            fprintf(texFile, '\\usepackage[latin1]{inputenc}\n');
            fprintf(texFile, '\\usepackage[frenchb]{babel}\n');
            fprintf(texFile, '\\usepackage{listings}\n');
            fprintf(texFile, '\\usepackage{color}\n');
            fprintf(texFile, '\\usepackage[left=2cm,top=1cm,right=2cm,bottom=1cm,nohead]{geometry}\n');
            fprintf(texFile, '\\usepackage[cm]{aeguill}}\n');
            fprintf(texFile, '\n');
            fprintf(texFile, '\\begin{document}\n'); 
            fprintf(texFile, '\\title{BIND : Listing intégral}\n');
            fprintf(texFile, '\\author{Arnaud BONNARD et Damien SORNETTE}\n');
            fprintf(texFile, '\\maketitle\n'); 
            fprintf(texFile, '\\tableofcontents\n'); 
            
            fprintf(texFile, ['\\lstset{inputpath='  strrep(pathToSrc, '\', '/') '}\n']);
            fprintf(texFile, '\\definecolor{darkgray}{gray}{0.35}\n');
            fprintf(texFile, '\\lstset{language=Matlab, numbers=left, numberstyle=\\footnotesize, basicstyle=\\footnotesize, commentstyle=\\itshape\\color{darkgray}, breaklines=true, morekeywords={classdef,methods,properties}, morecomment=[s]{\\%%\\{}{\\%%\\}}}\n');
            for i=1:1:length(mFiles)
                cleanName = regexprep(mFiles{i}, ['^\.' filesep], '');
                cleanName = strrep(cleanName, '+', '');
                cleanName = strrep(cleanName, filesep, '.');
                cleanName = strrep(cleanName, '.m', '');
                fprintf(texFile, ['\\section{' cleanName '}']);
                fprintf(texFile, ['\\lstinputlisting{' strrep(mFiles{i}, '\', '/') '}\n']);
            end
            fprintf(texFile, '\n');
            fprintf(texFile, '\\end{document}\n');
            fclose(texFile);
        end
        
    end
    
    methods(Static, Access = private)
        
        function out = findAllMFiles(path)
            out = {};
            listing = dir(path);
            for i = 1:1:length(listing)
                if listing(i).isdir
                    if ~any(strcmp(listing(i).name, {'.' '..'}))
                        out = [out{:} BibleGenerator.findAllMFiles([path filesep listing(i).name])];
                    end
                else
                   if regexp(listing(i).name, '.*\.m$', 'once')
                      out{end + 1} = [path filesep listing(i).name];
                   end
                end
            end         
        end
    end
    
end

